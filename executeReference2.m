function executeReference2(gain, allMsg, joint_sub, robot, pubJointCmd, time_scale, th, is_reverse)
% Take a JointState trajectory and execute it using velocity command.
% allMsg: trajectory
% joint_sub:
% robot: object
% pubJointCmd: publisher
% time_scale: scale
% th: velocity threshold so that robot doesn't make sudden move.

% without gripper


msgJointCmd = rosmessage('intera_core_msgs/JointCommand');

msgJointCmd.Mode = msgJointCmd.VELOCITYMODE;

inds = [1 3 4 5 6 7 8];
msgJointCmd.Names = robot.jointNames(inds)

time = arrayfun(@(x) double(x.Header.Stamp.Sec) + double(x.Header.Stamp.Nsec)*1E-9, allMsg);
time = time - time(1);
refTraj = allMsg; 

if is_reverse
    refTraj=allMsg(end:-1:1);
end

% arrayfun(@(x) x.Position, allMsg, 'UniformOutput', false)
for i = 2:length(refTraj) %was 1
    if length(refTraj(i).Position) < 7
        refTraj(i) = refTraj(i-1);
    end
end



time = time*time_scale;

vel = 1;
tic
while norm(vel) > .002 || toc < time(end)
    msg = joint_sub.receive();
    if isempty(msg) || length(msg.Position) < 7
        continue
    end
 
    
    curTime =  toc;
    curTime
    
    ind = find(curTime < time, 1);
    if isempty(ind)
        ind = length(time);
    end
    
    robot.setJointsMsg(msg);
    curJoint = robot.getJoints();
    curJoint = curJoint(inds);
    
    refmsg = refTraj(ind);
    

    robot.setJointsMsg(refmsg);
    refJoint = robot.getJoints();
    refJoint = refJoint(inds);

    refVel = robot.getJointsVelfromMsg(refmsg);
    refVel = refVel(inds)./time_scale;

    refVel = refVel*(ind<length(time));
    vel = refVel + gain*(refJoint - curJoint);
    
    %ensure vel isn't too high. parameter to play=th
    if max(abs(vel) > th)
        vel = th*vel./max(abs(vel));
    end

    msgJointCmd.Velocity = vel;
    send(pubJointCmd, msgJointCmd)
    
end
end