%% init ros
setenv('ROS_MASTER_URI', 'http://192.168.1.10:11311')
setenv('ROS_IP', '192.168.1.44')
rosshutdown()
rosinit()
robot = Sawyer();
joint_sub = rossubscriber('/robot/joint_states', 'DataFormat','struct');

pubJointCmd = rospublisher('/robot/limb/right/joint_command')
pubGripper = rospublisher('/gripper_command')

msgGripper =  rosmessage(pubGripper)

%% gripepr open
msgGripper.Data = true;
send(pubGripper, msgGripper)

%% gripper close
msgGripper.Data = false;
send(pubGripper, msgGripper)

%% load initial_trajectory 
fn='sawyer_pick1_1.mat'
allMsg=load(fn).allMsg;

% tmp: goto 1st position
gain=0.5;
th=0.2;
executeReference2(gain, allMsg(1) , joint_sub, robot, pubJointCmd, 2, th, false)


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

