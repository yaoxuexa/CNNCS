function Enc_signal=Encode_projection(patch,x,y,LineParams,G)

h=size(patch,1);
w=size(patch,2);
R = round(sqrt((h/2)^2 + (w/2)^2));
num_lines=size(LineParams,1);

% draw lines
% imagesc(patch);
% hold on
% for i=1:num_lines,
%     
% %     subplot(1,2,1);
%     
% %     plot(LineParams(i,2), LineParams(i,1),'+');
%     
%     plot([-R*cos(LineParams(i,3))+LineParams(i,2), R*cos(LineParams(i,3))+LineParams(i,2)],...
%          [-R*sin(LineParams(i,3))+LineParams(i,1), R*sin(LineParams(i,3))+LineParams(i,1)],'b');
% end
% hold off
% % axis([1 h 1 w]);
% axis([-h 2*h -w 2*w]);

% Encode points
A = zeros(num_lines,2*R+1);
for k=1:length(x),
    for i=1:num_lines,
        r = round((x(k)-LineParams(i,2))*cos(LineParams(i,3)) + (y(k)-LineParams(i,1))*sin(LineParams(i,3)));
        d = -(x(k)-LineParams(i,2))*sin(LineParams(i,3)) + (y(k)-LineParams(i,1))*cos(LineParams(i,3));  
        A(i,r+R+1) = d;
    end
end
% imagesc(A);

% Compress each row of A by random projection
Enc_signal=[];
for i=1:num_lines
    row=A(i,:);
    signal = G*row';
    Enc_signal=[Enc_signal;signal];
end

end