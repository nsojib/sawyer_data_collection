%% init ros
setenv('ROS_MASTER_URI', 'http://192.168.1.10:11311')
setenv('ROS_IP', '192.168.1.30')
rosshutdown()
rosinit()
robot = Sawyer();
joint_sub = rossubscriber('/robot/joint_states', 'DataFormat','struct');

pubJointCmd = rospublisher('/robot/limb/right/joint_command')

%% gripper init
pubGripper = rospublisher('/gripper_command')
msgGripper =  rosmessage(pubGripper)

%% gripper open
msgGripper.Data = true;
send(pubGripper, msgGripper)


%% gripper close
msgGripper.Data = false;
send(pubGripper, msgGripper)


%% manual movement to record demonstration.
close all
joint_sub = rossubscriber('/robot/joint_states', 'DataFormat','struct');

gripper_sub = rossubscriber('/gripper_command', 'DataFormat','struct');
gripper_sub.receive();
pause(3);

disp('starting cam');

cam = webcam(1);

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
    
    img = cam.snapshot();
    img=imresize(img, 0.5);
    imshow(img)

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

    jointMsg.img=img %adding image data.



    allMsg = cat(1, allMsg, jointMsg);
    count = count + 1
    % pause(0.005);
end

%% now save the data.
 
save('april29/sawyer_pick_b5.mat', 'allMsg')
%testDemo6 recorded all the values, then used allMsg(1:3:end)


%% from last, find idle index
 
q=allMsg(size(allMsg,1));      %last index
q_old=q;

for i=size(allMsg,1)-1:-1:1
     q=allMsg(i);

     if norm(q.Velocity-q_old.Velocity) < 0.01
        continue;
     end
     fprintf('stop at %d\n',i);
     break;
     
end


allMsg=allMsg(1:i);

 

 
%% playback (plotting)

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




%% goto 1st position

gain=0.5;
th=0.2;
executeReference2(gain, allMsg(1) , joint_sub, robot, pubJointCmd, 2, th, false)

%% play the recorded demo
% executeReference2(gain, allMsg , joint_sub, robot, pubJointCmd, 2, th, false)
executeReference(gain, allMsg, joint_sub, robot, pubJointCmd, pubGripper, 2, th, false)


%% show imgs
for i=1: size(allMsg,1)
    img=allMsg(i).img;
    imshow(img);
    % pause(0.005);
end

%% gripper info
for i=1: size(allMsg,1)
    gs=allMsg(i).gripper;
    i
    gs

end