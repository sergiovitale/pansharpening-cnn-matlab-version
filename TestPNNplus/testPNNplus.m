clear all; close all; clc;
addpath('./../PNNplus_Matlab_code/');

%%% LOAD INPUT IMAGES AND INFOS %%%%%%%%%%%%%%%%%%%%%%%%
in_folder = './imgs/';
%%%%%%%%%%%%%%% UNCOMMENT ONLY ONE CODE LINE %%%%%%%%%%%
%%%%%%%%%% Dataset                                     %
% fname = 'imgGeoEye1.mat';                            %
% fname = 'imgIkonos.mat';                             %
fname = 'imgWV2.mat';                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fpath = [in_folder fname];
dat = load(fpath);
I_MS_LR = dat.I_MS;         I_PAN = dat.I_PAN;
L = dat.L;                  sensor = dat.sensor;        RGB_indexes = dat.RGB_indexes;
clear dat;


%%%% UNCOMMENT ONE OR MORE LINE PAIRS TO RUN ONE OR MORE METHODS %%%%%
%
%%%%%%%%%%%%% PNN+ pansharpening (full version with fine-tuning)
P1 = PNNplus(I_MS_LR, I_PAN, sensor, 50, L);
save([fname(1:end-4) '_PNNplus.mat'],'P1');

%%%%%%%%%%%%% PNN+ pansharpening (without fine-tuning)
P2 = PNNplus(I_MS_LR, I_PAN, sensor, 0, L);
save([fname(1:end-4) '_PNNplus_noFT.mat'],'P2');

%%%%%%%%%%%%%% PNN pansharpening
P3 = PNN(I_MS_LR,I_PAN,sensor,L);
save([fname(1:end-4) '_PNN.mat'],'P3');

%%%%%%%%%%%%%% PNN_noIDX pansharpening
P4 = PNN(I_MS_LR,I_PAN,sensor,L,false);
save([fname(1:end-4) '_PNN_noIDX.mat'],'P4');

addpath('./../Matlab_utils/');
qMS=image_quantile(I_MS_LR(:,:,RGB_indexes),[0.01 0.99]);
qPAN=image_quantile(I_PAN,[0.01,0.99]);

figure();
ax(1)=subplot(241); imshow(image_stretch(I_PAN,qPAN));
ax(2)=subplot(242); imshow(image_stretch(interp23tap(I_MS_LR(:,:,RGB_indexes),4.0),qMS));
ax(3)=subplot(245); imshow(image_stretch(P1(:,:,RGB_indexes),qMS));title('PNN+ft');
ax(4)=subplot(246); imshow(image_stretch(P2(:,:,RGB_indexes),qMS));title('PNN+');
ax(5)=subplot(247); imshow(image_stretch(P3(:,:,RGB_indexes),qMS));title('PNN-ndxi');
ax(6)=subplot(248); imshow(image_stretch(P4(:,:,RGB_indexes),qMS));title('PNN');
linkaxes(ax,'xy');


