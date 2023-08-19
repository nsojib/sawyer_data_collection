%require:run first_connect_sawyer.m 

% load posture and safely (slowly) move to this position.


robot = Sawyer();
joint_sub = rossubscriber('/robot/joint_states', 'DataFormat','struct');
pubJointCmd = rospublisher('/robot/limb/right/joint_command')
pubGripper = rospublisher('/gripper_command')


%% load posture

filename='saved_posture/drawer_push/ee_init.mat'
% filename='saved_posture/drawer_push/ee_on_handle.mat'
data=load(filename).data;

%% goto to posture
gain=0.5;
th=0.2;
executeReference(gain, data, joint_sub, robot, pubJointCmd, pubGripper, 2, th, false)
