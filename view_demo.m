
%% load sawyer data
clear all;
clc;

robot = Sawyer();

dirname="demos/drawer_push/19-Aug-2023/"
files = dir(fullfile(dirname, '*.mat'));

id=2;
fn= strcat(files(id).folder, '/', files(id).name)

data=load(fn).allMsg;


%% play animation
gripperBaseInd = 18;
for i = 1:length(data)
    msg = data(i);
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

    robot.getJoints();
    
    i, msg.gripper.Data

end

