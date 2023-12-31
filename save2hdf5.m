function [res] = save2hdf5(h5_file_name,mat_file_name, demo_no)


    data=load(mat_file_name).allMsg;

    
    % convert into 6d vector (xyzrpy) and save
    
    
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
    xyzrpy=ctraj';
    
    % create delta actions.
    
    dxyzrpy=[]; %store delta xyzrpy
    cp_old=xyzrpy(1,:);
    for i =2:length(xyzrpy)
        cp=xyzrpy(i, :);
        d=cp-cp_old;
        dxyzrpy=cat(1, dxyzrpy, d);
    end
    last_d=zeros(1,6); %toadd 1 for gripper open.
    dxyzrpy=cat(1, dxyzrpy, last_d);
    
    
    
    % load imgs 
    imgs=[];
    for i=1:size(data,1)
        img=data(i).img;
        I2 = imcrop(img,[60 30 868 479]);
        I3=imresize(I2, 0.207);
    %     imshow(I3)
        s=reshape(I3,[1,100,180,3]);
        imgs=cat(1, imgs, s); 
    end
    
     
    
    % load positions, velocities & gripper status
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
    
    % combine delta xyzrpy and gripper to make robomimic like action.
    robomimic_action=cat(2, dxyzrpy, grips);
    
    
    % create hdf5
    poss=poss(:,2:8);
    vels=vels(:,2:8);
    xyzs=xyzrpy(:,1:3);
    
    
    demo_group="/data/demo_"+demo_no
    
    imgs=permute(imgs, [4,3,2,1]);
    h5create(h5_file_name, demo_group+"/obs/robot0_eye_in_hand_image", size(imgs)) 
    h5write(h5_file_name, demo_group+"/obs/robot0_eye_in_hand_image", imgs);
    
    h5create(h5_file_name, demo_group+"/obs/robot0_eef_pos", size(xyzs')) 
    h5write(h5_file_name, demo_group+"/obs/robot0_eef_pos", xyzs');
    
    h5writeatt(h5_file_name,demo_group+'/','num_samples', size(xyzs,1));
    
    h5create(h5_file_name, demo_group+"/actions", size(robomimic_action')) 
    h5write(h5_file_name, demo_group+"/actions", robomimic_action');
    
    h5create(h5_file_name, demo_group+"/obs/robot0_joint_pos", size(poss')) 
    h5write(h5_file_name, demo_group+"/obs/robot0_joint_pos", poss');
    
    h5create(h5_file_name, demo_group+"/obs/robot0_joint_vel", size(vels')) 
    h5write(h5_file_name, demo_group+"/obs/robot0_joint_vel", vels');
    
    h5create(h5_file_name, demo_group+"/time", size(times')) 
    h5write(h5_file_name, demo_group+"/time", times');
    
    res=true;


end

