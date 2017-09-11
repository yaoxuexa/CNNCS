function [rec_center_y,rec_center_x]=Decode_recovery(patch,LineParams,G)
%G: 103*283
[h,w,~]=size(patch);
R = round(sqrt((h/2)^2 + (w/2)^2));
m=size(G,1);
n=283;
lambda=0.1;
num_lines=size(LineParams,1);

%% Load the model and predict
if ~exist('/local/scratch/shared/Yao/cell-train-test-for-mxnet/model20-noTT-noShortcut-BN--0-0012.params', 'file')
    display('Model does not exist.');
end

addpath('/home/yxue/mxnet/matlab/');
clear model
model = mxnet.model;
model.load('/local/scratch/shared/Yao/cell-train-test-for-mxnet/model20-noTT-noShortcut-BN--0',12);%model/Inception_BN
pred_signal = model.forward(patch);

if sum(pred_signal)==0
    rec_center_y=[];
    rec_center_x=[];
else
    
    Ap=zeros(num_lines,n);
    for i=1:num_lines
        current_signal=pred_signal((i-1)*m+1:i*m);
        % DAL recovery
        [temp,status]=dalsql1(zeros(n,1), G, current_signal, lambda);
        temp=full(temp)';
        Ap(i,:)=temp;
    end
    
    % m = 1024; n = 16*m; k = round(0.01*n); A=randn(m,n);
    % w0=randsparse(n,k); b=A*w0+0.1*randn(m,1);
    % lambda=0.5; %0.1*max(abs(A'*b));
    % w = myDALL1(A,b,zeros(n,1),lambda);
    
    threshold=13;
    low_noise=find(abs(Ap)<threshold);
    Ap(low_noise)=0;
    
    % Decode points
    J = zeros(h,w);
    for k=1:size(Ap,1),
        for i=1:size(Ap,2),
            if abs(Ap(k,i)) > 1e-5,
                x1 = round(LineParams(k,2) + (i-R-1)*cos(LineParams(k,3)) - Ap(k,i)*sin(LineParams(k,3)));
                y1 = round(LineParams(k,1) + (i-R-1)*sin(LineParams(k,3)) + Ap(k,i)*cos(LineParams(k,3)));
                if x1>=1 && x1<=w && y1>=1 && y1<=h,
                    J(y1,x1) = J(y1,x1) + 1;
                end
            end
        end
    end
    [rec_y, rec_x]=find(J>0);
    
    % Mean-shift clustering
    if isempty(rec_y)
        rec_center_y=0;
        rec_center_x=0;
    else
        candidates=[rec_y,rec_x];
        bandWidth=133;
        plotFlag=0;
        [clustCent,data2cluster,cluster2dataCell] = MeanShiftCluster(candidates',bandWidth,plotFlag);
        rec_center_y=round(clustCent(1,:));
        rec_center_x=round(clustCent(2,:));
    end
    
end



end