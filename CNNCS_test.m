function CNNCS_test

clc
clear all
close all

root_path='/local/scratch/shared/Yao/AMIDA-13/';
patch_shift=200;
patch_size=200;
addpath([root_path,'Github/dal-master']);
offset=0;
% Load OA
load('OA-dictionary-Regular-30-200.mat');
% Load sensing matrix
load('Sensing-matrix.mat');

for patient_count=1:1:34
	if patient_count<10
        patient_count=['0',num2str(patient_count)];
    else
        patient_count=num2str(patient_count);
	end
        
    struct=dir([root_path,'mitoses-test-image-data/',patient_count,'/*.tif']);
    image_num=size(struct,1);
    for image_count=1:1:image_num
        if image_count<10
            image_count=['0',num2str(image_count)];
        else
            image_count=num2str(image_count);
        end
        
%         if ~exist([root_path,'mitoses_ground_truth/',num2str(patient_count),'/',image_count,'.csv'])
%             continue
%         end
        %disp([root_path,'mitoses_ground_truth/',num2str(patient_count),'/',image_count,'.csv']);
        
        %read image
        image=imread([root_path,'mitoses-test-image-data/',patient_count,'/',image_count,'.tif']);%Whole image
        [rows,cols,~]=size(image);
        
        % Read ground-truth label of testing data
        cor_Matrix = csvread([root_path,'mitoses-test-ground-truth/',patient_count,'/',image_count,'.csv']);
        mitos_num=size(cor_Matrix,1);
        MatData=zeros(rows,cols);
        row=cor_Matrix(:,1);
        col=cor_Matrix(:,2);
        for i=1:1:mitos_num
            MatData(row(i),col(i))=1;
        end
        
        %% Partition images to patches
        for m=offset+1:patch_shift:rows-patch_size+1,
            for n=offset+1:patch_shift:cols-patch_size+1,
                blkMat = MatData(m:m+patch_size-1,n:n+patch_size-1);%Label
                patch = image(m:m+patch_size-1,n:n+patch_size-1,:);%RGB patch
%                 plot([n; n+patch_size; n+patch_size; n; n], [m; m; m+patch_size; m+patch_size; m],'g');
                [x,y]=find(blkMat==1);%True coordinates in patch
                
                if sum(sum(blkMat))==0
                    continue
                end
                
                [rec_center_y,rec_center_x]=Decode_recovery(patch,LineParams,G);
                
                % Visualize a patch's result
                imshow(patch),hold on;
                plot(y,x,'y+');%Ground-truth
                plot(rec_center_y, rec_center_x,'r+');%Prediction
                hold off,axis image;
                
            end
        end
        

        
    end
end
rmpath([root_path,'Github/dal-master']);
end