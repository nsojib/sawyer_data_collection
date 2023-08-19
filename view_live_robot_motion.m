% View robot motion as a 3D animation.
% To visualize kinesthetic demonstration.


%% init ros
setenv('ROS_MASTER_URI', 'http://192.168.1.10:11311')
setenv('ROS_IP', '192.168.1.30')
rosshutdown()
rosinit()
robot = Sawyer();
joint_sub = rossubscriber('/robot/joint_states', 'DataFormat','struct');

pubJointCmd = rospublisher('/robot/limb/right/joint_command')
 

%% joint reading 3d plot

gripperBaseInd = 18;
while 1
    msg = joint_sub.LatestMessage;
    if isempty(msg)
        continue
    end
    robot.setJointsMsg(msg);
    hold off
    robot.plotObject
    hold on

    q2=robot.getJoints()

    %
    T = robot.getBodyTransform(gripperBaseInd);
    %     T = T*Tc1_c2;
    %     T = T*Toffset;
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

end
