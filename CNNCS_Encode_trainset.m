function CNNCS_Encode_trainset

clc
clear all
close all

root_path='/local/scratch/shared/Yao/AMIDA-13/';
patch_shift=200;
patch_size=200;
rows=2000;
cols=2000;
offset=0;
patch_count=1;
data_augment=0;%Need data_augment or not?

% Load OA
load('OA-dictionary-Regular-30-200.mat');
% Load sensing matrix
G=load('Sensing-matrix.mat');
G=G.G;

% Creat file for storing training patch paths and encoded signals
fid=fopen([root_path,'/AMIDA-Encoded-Train-Set/train-list.txt'],'w');

for patient_count=1:1:73
	if patient_count<10
        patient_count=['0',num2str(patient_count)];
    else
        patient_count=num2str(patient_count);
    end
    
    struct=dir([root_path,'mitoses_ground_truth/',patient_count,'/*.csv']);
    image_num=size(struct,1);
    for image_count=1:1:image_num
        if image_count<10
            image_count=['0',num2str(image_count)];
        else
            image_count=num2str(image_count);
        end
        
        cor_Matrix = csvread([root_path,'mitoses_ground_truth/',patient_count,'/',image_count,'.csv']);
        mitos_num=size(cor_Matrix,1);
        MatData=zeros(rows,cols);
        row=cor_Matrix(:,1);
        col=cor_Matrix(:,2);
        for i=1:1:mitos_num
            MatData(row(i),col(i))=1;
        end
        
        %AMIDA-13 trianing sets:
        %mitoses_image_data_part_1
        %mitoses_image_data_part_2
        %mitoses_image_data_part_3
        if str2num(patient_count)<15
            image=imread([root_path,'mitoses_image_data_part_1/',patient_count,'/',image_count,'.tif']);
        elseif str2num(patient_count)<34
            image=imread([root_path,'mitoses_image_data_part_2/',patient_count,'/',image_count,'.tif']);
        elseif str2num(patient_count)<74
            image=imread([root_path,'mitoses_image_data_part_3/',patient_count,'/',image_count,'.tif']);
        end
        
        %% Partition images to patches
        for m=offset+1:patch_shift:rows-patch_size+1,
            for n=offset+1:patch_shift:cols-patch_size+1,
                blkMat = MatData(m:m+patch_size-1,n:n+patch_size-1);%Label
                patch = image(m:m+patch_size-1,n:n+patch_size-1,:);%RGB patch
                %                 plot([n; n+patch_size; n+patch_size; n; n], [m; m; m+patch_size; m+patch_size; m],'g');
                [x,y]=find(blkMat==1);%True coordinates in patch
                
                Enc_signal=Encode_projection(patch,x,y,LineParams,G);
                
                % Save every training patch and its encoded signal
                image_path=[root_path,'/AMIDA-Encoded-Train-Set/Patches/',num2str(patient_count),'-',...
                    num2str(image_count),'-',num2str(patch_count),'.jpg'];
                imwrite(patch,image_path,'jpg');
                write_train_list(image_path,Enc_signal,fid,patch_count);
%                 fprintf(fid,[image_path,' ']);
%                 fprintf(fid,num2str(Enc_signal'));
%                 fprintf(fid,'\r\n');
                patch_count=patch_count+1;
                
                if data_augment==1
                    rot_patch=patch;
                    rot_blkMat=blkMat;
                    for times=1:1:3%rotate each patch iteratively
                        rot_patch=imrotate(rot_patch,90);%Left rotate 90 degree
                        rot_blkMat=rot90(rot_blkMat);%Left rotate 90 degree
                        [x,y]=find(rot_blkMat==1);
                        Enc_signal=Encode_projection(rot_patch,x,y,LineParams,G);
                        
                        %save
                        image_path=[root_path,'/AMIDA-Encoded-Train-Set/Patches/',num2str(patient_count),'-',...
                            num2str(image_count),'-',num2str(patch_count),'-rotate',num2str(times),'.jpg'];
                        imwrite(rot_patch,image_path,'jpg');
                        write_train_list(image_path,Enc_signal,fid,patch_count);
%                         fprintf(fid,[image_path,' ']);
%                         fprintf(fid,num2str(Enc_signal'));
%                         fprintf(fid,'\r\n');
                        patch_count=patch_count+1;
                    end
                end

            end
        end

    end
end
fclose(fid);
end