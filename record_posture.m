%require:run first_connect_sawyer.m 

% save robot current position.
% save one data only.
% (optional) press gripper open/release to start recording.

%% manual movement to record demonstration.
close all
joint_sub = rossubscriber('/robot/joint_states', 'DataFormat','struct');

gripper_sub = rossubscriber('/gripper_command', 'DataFormat','struct');

% disp('waiting for gripper action')
% 
% gripper_sub.receive();
% pause(3); 

robot.setJointsMsg(receive(joint_sub))
q = robot.getJoints();

data = joint_sub.LatestMessage;
assert(length(data.Position) > 5)
robot.setJointsMsg(data);
q2 = robot.getJoints();

grip=gripper_sub.LatestMessage;  %TODO: create empty gripper msg without querying to the topic. 
grip.Data=true;                  %set gripper open.
data.gripper=grip; %adding gripper data in allMsg


disp('posture recorded in data')

%% now save the data.

% posture_name='ee_init'
posture_name='ee_on_handle'
task='drawer_push/';
dir='saved_position/';
fn=strcat(dir, task, posture_name,'.mat')

% save(fn, 'data')
disp('saved')

