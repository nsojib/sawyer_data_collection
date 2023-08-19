
close all;
clear all;
clc;

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
% msgGripper.Data = true;
% send(pubGripper, msgGripper)


%% gripper close
% msgGripper.Data = false;
% send(pubGripper, msgGripper)

