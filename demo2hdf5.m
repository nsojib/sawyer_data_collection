
%% load original trajectory recorded in matlab
clear all;
clc;

% addpath('../../data_sawyer/'); 
% dir='../../data_sawyer/april29/';
% ofn="sawyer_pick_b5.mat";
% % ofn="sawyer_pick_1.mat";
% fn=dir+ofn;
% data=load(fn).allMsg;


dir="../../data_sawyer/july2/"
ofn="sawyer_coke_grab.mat"
% ofn="j2_coke_sawyer_pick_1.mat"
fn=dir+ofn
data=load(fn).allMsg;
% data=data(27:110);


%% convert into 6d vector (xyzrpy) and save


robot = Sawyer();

ctraj=[];
for i = 1:length(data)
    msg = data(i);
    robot.setJointsMsg(msg);
    
    T=robot.getBodyTransform(18);
    xyz=T(1:3,4); 
    e_zyx=rotm2eul(T(1:3, 1:3));    %orientation
    
    d6 =[xyz; reshape(e_zyx,[3,1])];
    ctraj= cat(2, ctraj, d6);

end
xyz=ctraj';

%% load imgs 

% for i=1:size(data,1)
%     img=data(i).img;
%     imshow(img)
% end


%% load imgs 
imgs=[];
for i=1:size(data,1)
    img=data(i).img;
    s=reshape(img,[1,540,960,3]);
    imgs=cat(1, imgs, s); 
end


%% load positions, velocities & gripper status
poss=[];
vels=[];
grips=[];
times=[];
for i=1:size(data,1)
    pos=data(i).Position;
    vel=data(i).Velocity;
    grip=data(i).gripper.Data;
    time=(double(data(i).Header.Stamp.Sec)*1e9+double(data(i).Header.Stamp.Nsec) )/1e9;
    
    poss=cat(2, poss, pos);
    vels=cat(2, vels, vel);
    grips=cat(1, grips, grip);
    times=cat(1, times, time);
end
poss=poss';
vels=vels';



%% create hdf5
% ixpvgt

h5_file_name="test.h5";
demo_no=1;

demo_group="/data/demo_"+demo_no

imgs=permute(imgs, [4,3,2,1]);
h5create(h5_file_name, demo_group+"/img", size(imgs)) 
h5write(h5_file_name, demo_group+"/img", imgs);

h5create(h5_file_name, demo_group+"/xyzrpy", size(xyz')) 
h5write(h5_file_name, demo_group+"/xyzrpy", xyz');

h5create(h5_file_name, demo_group+"/position", size(poss')) 
h5write(h5_file_name, demo_group+"/position", poss');

h5create(h5_file_name, demo_group+"/velocity", size(vels')) 
h5write(h5_file_name, demo_group+"/velocity", vels');

h5create(h5_file_name, demo_group+"/gripper", size(grips')) 
h5write(h5_file_name, demo_group+"/gripper", grips');

h5create(h5_file_name, demo_group+"/time", size(times')) 
h5write(h5_file_name, demo_group+"/time", times');


