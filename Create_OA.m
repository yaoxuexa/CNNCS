function Create_OA

clc
clear all
close all

patch_size=200;

% % create L random lines
% L=30;
% LineParams = zeros(L,3);
% R = round(sqrt((patch_size/2)^2 + (patch_size/2)^2));%radius
% for i=1:L,
%     LineParams(i,3) = 2*pi*rand;
%     LineParams(i,1) = round(patch_size/2) + R*cos(LineParams(i,3));
%     LineParams(i,2) = round(patch_size/2) - R*sin(LineParams(i,3));
% end
% save(['OA-dictionary-Random-',num2str(L),'-',num2str(patch_size),'.mat']);

% create L regular distributed lines
L=30;
LineParams = zeros(L,3);
R = round(sqrt((patch_size/2)^2 + (patch_size/2)^2));%radius
for i=1:L,
    LineParams(i,3) = 2*pi/L*i;
    LineParams(i,1) = round(patch_size/2) + R*cos(LineParams(i,3));
    LineParams(i,2) = round(patch_size/2) - R*sin(LineParams(i,3));
end

if ~exist(['OA-dictionary-Regular-',num2str(L),'-',num2str(patch_size),'.mat'])
    save(['OA-dictionary-Regular-',num2str(L),'-',num2str(patch_size),'.mat']);
end
end