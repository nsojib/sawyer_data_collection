% 
% %% load original trajectory recorded in matlab
clear all;
clc;


dirname="demos/drawer_push/19-Aug-2023/"
files = dir(fullfile(dirname, '*.mat'));

h5_file_name="test.h5";
% demo_no=3;
for demo_no=1:size(files,1)
    fp=strcat(files(demo_no).folder,'/', files(demo_no).name)
    disp(fp);
    save2hdf5(h5_file_name, fp, demo_no);
end




