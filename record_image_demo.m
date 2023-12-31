%require:run first_connect_sawyer.m 

% collect lowdim+rgb image from realsense


%% manual movement to record demonstration.
close all
joint_sub = rossubscriber('/robot/joint_states', 'DataFormat','struct');

gripper_sub = rossubscriber('/gripper_command', 'DataFormat','struct');
% gripper_sub.receive();
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
    imshow(img);
    jointMsg.img=img; %adding image data.

    if norm(q1-q2) < 0.02 && ~trigger
        continue
    end
    
    trigger= true;

    robot.setJointsMsg(jointMsg); 


    if isempty(gripper_sub.LatestMessage)
        continue;
    end

    if length(jointMsg.Position) < 5   %ignore only the gripper joint data.
        continue;
    end


    grip=gripper_sub.LatestMessage;
    jointMsg.gripper=grip; %adding gripper data in allMsg
 
    allMsg = cat(1, allMsg, jointMsg);
    count = count + 1
    % pause(0.005);
end
%end of record section. [press stop button to stop] 
%click:

%% find first movement [to discard silence before starting action]

start_i=1;
q_old=allMsg(1);
for i=2: size(allMsg,1)
    q=allMsg(i);

     if norm(q.Velocity-q_old.Velocity) < 0.02
        continue;
     end
     fprintf('start at %d\n',i);
     start_i=i;
     break;
end


% from last, find idle index
stop_i=size(allMsg,1);
q=allMsg(size(allMsg,1));      %last index
q_old=q;

for i=size(allMsg,1)-1:-1:1
     q=allMsg(i);

     if norm(q.Velocity-q_old.Velocity) < 0.02
        continue;
     end
     fprintf('stop at %d\n',i);
     stop_i=i;
     break;
     
end

% crop [start_i-1:stop_i]

allMsg=allMsg(start_i-1 : stop_i);

%% now save the trajectory
datetime.setDefaultFormats('default','yyyy-MM-dd-hh-mm')

task='drawer_push/'
fn=strcat('demos/',task, date , '/' , string(datetime) ,'_i.mat')
save(fn, 'allMsg')


 
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


%% show imgs
for i=1: size(allMsg,1)
    img=allMsg(i).img;
    imshow(img);
    pause(0.005);
end




