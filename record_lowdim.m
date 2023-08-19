%require:run first_connect_sawyer.m 

% record robot state without camera image.
% For low dimension trajectory
% and initial robot posture and end-effector position saving for object location.

%% manual movement to record demonstration.
close all
joint_sub = rossubscriber('/robot/joint_states', 'DataFormat','struct');

gripper_sub = rossubscriber('/gripper_command', 'DataFormat','struct');
gripper_sub.receive();
pause(3);

allMsg = [];

robot.setJointsMsg(receive(joint_sub))
q = robot.getJoints();

orig = joint_sub.LatestMessage;
assert(length(orig.Position) > 5)
robot.setJointsMsg(orig);
q2 = robot.getJoints();

count = 0;
trigger = false;
while 1
    jointMsg = joint_sub.LatestMessage;
    robot.setJointsMsg(jointMsg);
    q1 = robot.getJoints();

    if norm(q1-q2) < 0.02 && ~trigger
        continue
    end
    
    trigger= true

    robot.setJointsMsg(jointMsg); 

    % if count>40 && triggered
    % 
    %     if norm(q1-q2) < 0.02 
    %         disp('no change detected');
    %         break;
    %     end
    % 
    %     q2=q1;
    % end


    if isempty(gripper_sub.LatestMessage)
        continue;
    end
    %     if (norm(q-robot.getJoints()) < .005 )
    %         continue
    %     end
    %     q = robot.getJoints();
    %     robot.plotObject()

    if length(jointMsg.Position) < 5   %ignore only the gripper joint data.
        continue;
    end


    grip=gripper_sub.LatestMessage;
    % grip=0; %TODO: remove
    jointMsg.gripper=grip; %adding gripper data in allMsg

    allMsg = cat(1, allMsg, jointMsg);
    count = count + 1
    % pause(0.005);
end

%% now save the data.
 
% save('april29/sawyer_pick_b5.mat', 'allMsg')

 
%% view recorded trajectory as 3d animation.

gripperBaseInd = 18;
for i = 1:length(allMsg)
    msg = allMsg(i);
    robot.setJointsMsg(msg);
    hold off
    robot.plotObject
    hold on

    T = robot.getBodyTransform(gripperBaseInd);
    point = T(1:3,end);
    line =  [point point+T(1:3,1)*.15];
    hold on
    plot3(line(1,:), line(2,:), line(3,:),'MarkerSize',10, 'Marker','.', 'Color','r')
    line =  [point point+T(1:3,2)*.15];
    hold on
    plot3(line(1,:), line(2,:), line(3,:),'MarkerSize',10, 'Marker','.', 'Color','g')
    line =  [point point+T(1:3,3)*.15];
    hold on
    plot3(line(1,:), line(2,:), line(3,:),'MarkerSize',10, 'Marker','.', 'Color','b')

    drawnow
    pause(.01)

    robot.getJoints()

end
