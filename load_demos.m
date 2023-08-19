
%% load sawyer data
clear all;
clc;

robot = Sawyer();

data_dir="/home/ns/data_sawyer/"
 
fn=data_dir+'reach/july6/sawyer_block_reach_25.mat'

data=load(fn).allMsg;
 


% dir='demos_downloaded/';
%data=load(dir+"sawyer_pick1_10.mat").allMsg;
%data=load(dir+"sawyer_pick1b_1.mat").allMsg;

% data=load("sawyer_coke_grab.mat").allMsg;
% data=data(27:110);

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

%% trim silence
% prev=data(80).Position;
% for i = 81:length(data)
%     msg = data(i);
%     jp=msg.Position;
%     if norm(prev-jp)==0
%         disp("stop");
%         i
%         break 
%     end
%     prev=jp;
% end



%% jp trajs

jps=[];
for i = 1:length(data)
    msg = data(i);
    jp=msg.Position
    jps=cat(2, jp, jps);
end
jps=jps';

csvwrite("jps3.csv", jps);


%% show imgs

for i=1:size(data,1)
    img=data(i).img;
    imshow(img)
end


%% goto the 1st point

msg = data(1);
robot.setJointsMsg(msg);
hold off
robot.plotObject

%% plot using velocities

% goto the 1st point

msg = data(1);
robot.setJointsMsg(msg);
hold off
robot.plotObject


inds = [1 3 4 5 6 7 8];
msgJointCmd.Names = robot.jointNames(inds)

dt=0.08;
for i = 1:length(data)
    msg = data(i);
%     robot.setJointsMsg(msg);
    v=msg.Velocity;
    v=[0,v']';

    q = robot.getJoints()+ dt*v;  
    msgJointCmd.Velocity = q(inds);
    robot.setJoints(q);


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



%% load from py actions
fn="wreg/actions_org_py.mat";
actions_org=load(fn);

fn="wreg/actions_pred_py.mat";
actions_pred=load(fn);

% actions=actions_org.traj_0;
% actions=actions_pred.traj_7;
actions=actions_org.traj_7;


% goto the 1st point

msg = data(7);
robot.setJointsMsg(msg);
hold off
robot.plotObject


inds = [1 3 4 5 6 7 8];
msgJointCmd.Names = robot.jointNames(inds)

dt=0.08;
for i = 1:length(actions)
%     msg = data(i);
%     robot.setJointsMsg(msg);
%     v=msg.Velocity;
    v=actions(i,:)';
    v=[0,v']';

    q = robot.getJoints()+ dt*v;  
    msgJointCmd.Velocity = q(inds);
    robot.setJoints(q);


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





