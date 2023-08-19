%% init ros
rosshutdown()
rosinit()
robot = Sawyer();
joint_sub = rossubscriber('/robot/joint_states', 'DataFormat','struct');
pubJointCmd = rospublisher('/robot/limb/right/joint_command')
pubGripper = rospublisher('/gripper_command')

% msgJointCmd = rosmessage(pubJointCmd)
% msgJointCmd = rosmessage('intera_core_msgs/JointCommand')


%% gripepr command test

msgGripper =  rosmessage(pubGripper)

%open
msgGripper.Data = true;
send(pubGripper, msgGripper)


%gripper close
msgGripper.Data = false;
send(pubGripper, msgGripper)


%% load initial_trajectory and play
init_allMsg=load("initial_trajectory.mat").allMsg;

%go top initial position
gain=0.5;
th=0.2;
executeReference(gain, init_allMsg(1), joint_sub, robot, pubJointCmd, pubGripper, 2, th, false)

%play the trajectory: from top to grip position.
gain=2;
th=0.4;
executeReference(gain, init_allMsg, joint_sub, robot, pubJointCmd, pubGripper,  2, th, false)

%% now, load a trajectory and play
allMsg2=load("trajectory3.mat").allMsg;


%first play initial_trajectory
%now play the trajector (requrire to play initial_trajectory first)
gain=2;
th=0.4;
executeReference(gain, allMsg2, joint_sub, robot, pubJointCmd, pubGripper, 2, th, false)


% reverse_allMsg2=allMsg2(end:-1:1);
gain=2;
th=0.4;
executeReference(gain,  allMsg2, joint_sub, robot, pubJointCmd, pubGripper, 2, th, true)




%% helper code
% First position:
% 21
% 22
% 23
% Second position:
% 31
% 32
% 33
% third position
% 41
% 42
% 43


