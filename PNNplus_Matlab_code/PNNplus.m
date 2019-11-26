%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: 
%        PNN+ algorithm for pansharpening by Scarpa et al. (2018)
%        Reference:
%        G. Scarpa, S. Vitale, and D. Cozzolino, 
%        "Target-adaptive CNN-based pansharpening," 
%        IEEE Transactions on Geoscience and Remote Sensing, 
%        vol. 56, no. 9, pp. 5443-5457, Sep. 2018.
%           
% Interface:
%         P      = PNNplus(MS, PAN, sensor_model, FT_epochs, nBits, MTF);
%         P      = PNNplus(MS, PAN, sensor_model, FT_epochs, nBits);
%         P      = PNNplus(MS, PAN, sensor_model, FT_epochs);
%         P      = PNNplus(MS, PAN, sensor_model);
%        [P AUX] = PNNplus(MS, PAN, sensor_model, FT_epochs, nBits, MTF);
%        [P AUX] = PNNplus(MS, PAN, sensor_model, FT_epochs, nBits);
%        [P AUX] = PNNplus(MS, PAN, sensor_model, FT_epochs);
%        [P AUX] = PNNplus(MS, PAN, sensor_model);
%
% Input:
%        MS:              4- or 8-band multispectral image
%        PAN:             panchromatic image (must be 4x4x larger than MS)
%        sensor_model:    one of the following string:
%                         'IKONOS'
%                         'GeoEye1'
%                         'WV2'
%                         'WV3'
%                         '<full-path file name of any pretrained model>'
%               WARNING: If an own model is used, the file must be a work
%                        space with a cell-array variable named 'layers'
%                        containing the sequence of weights and bias of the
%                        three convolutional layers. Also the following
%                        variables must be enclosed in the work space: lr, 
%                        patch_size, ratio, sensor, inputType, typeInterp.
%                        For consistency check watch the content of any 
%                        provided model (e.g., 'IKONOS_PNNplus_model.mat').
%                        
%        nBits:           #bits (radiometric precision);  default=11;
%        FT_epochs(>=0):  0->no fine tuning;              default=50;
%               WARNING: In case of CPU-only PC it is recommended to avoid
%               (FT_epochs = 0) or limit to a few iterations the
%               fine-tuning.
%        MTF:             struct with custom MTF gains (GNyq and GNyqPan) 
%
% Output:
%        P:               pansharpened image;
%        AUX:             auxiliary output variable containing the
%                         fine-tuned model and other training details;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [P AUX] = PNNplus(MS, PAN, sensor_model, FT_epochs, nBits, MTF)

MTFflag = false; if nargin==6, MTFflag = true; end
if nargin<5, nBits=11; elseif isempty(nBits), nBits = 11; end 
if nargin<4, FT_epochs = 50; elseif isempty(FT_epochs), FT_epochs = 50; end

MS = single(MS); PAN = single(PAN); nBits = single(nBits);

[M,N,Nb] = size(MS);

%%% LOAD PRETRAINED MODEL
available_models = {'IKONOS', 'GeoEye1','WV2', 'WV3'};
if sum(ismember(available_models,sensor_model)) 
    sensor_model = which([sensor_model '_PNNplus_model.mat']);
    
end

model = load(sensor_model);
if isfield(model,'model'), model = model.model; end

model.L = nBits;

net_scope = model_scope(model);

% build list of layers
firstLayer = imageInputLayer([M N Nb+1],'Name','InputLayer','Normalization','none');
layers = load_layers(firstLayer,model);

%scaling learning rate on last layer
layers(end).WeightLearnRateFactor =0.1;     
layers(end).BiasLearnRateFactor =0.1;

layers = [layers,maeRegressionLayer('regre')];

lgraph = []; traininfo = [];
pad = model.padSize;
[Mpan, Npan] = size(PAN);
Train_time = 0;
if FT_epochs>0
    tempDir = 'temporary_pnn_plus';
    delete([tempDir '/*.*']);
    mkdir(tempDir);
    tic;
    if MTFflag
        [net, traininfo] = fine_tune(MS, PAN, model, layers, FT_epochs, tempDir, MTF);
    else
        [net, traininfo] = fine_tune(MS, PAN, model, layers, FT_epochs, tempDir);
    end
    Train_time = toc;
    
    %%%% LOAD BEST MODEL
    [best_val best] = min(traininfo.TrainingLoss);
    pref = [tempDir sprintf('/net_checkpoint__%d__*',best)];
    fn = dir(pref); fn = [tempDir '/' fn.name];
    net = getfield(load(fn),'net')
    %%%%
    
    delete([tempDir '/*.*']);  rmdir(tempDir);
    lgraph = layerGraph(net.Layers);
    model.layers{1} = net.Layers(2).Weights;
    model.layers{2} = net.Layers(2).Bias;
    model.layers{3} = net.Layers(4).Weights;
    model.layers{4} = net.Layers(4).Bias;
    model.layers{5} = net.Layers(6).Weights;
    model.layers{6} = net.Layers(6).Bias;        
else
    lgraph = layerGraph(layers);
end
lgraph = replaceLayer(lgraph,lgraph.Layers(1).Name,imageInputLayer([Mpan+pad Npan+pad Nb+1],'Name','InputLayer','Normalization','none'));
net = assembleNetwork(lgraph);
   
AUX.model = model;
AUX.traininfo = traininfo;

%% Pansharpening
I_in = input_preparation(MS,PAN,model);
tic;
P = predict(net,I_in);
Test_time = toc;

I_MS_int = (2^model.L)*I_in(floor(net_scope/2)+1:end-floor(net_scope/2),floor(net_scope/2)+1:end-floor(net_scope/2),1:end-1,:);
P = P*(2^model.L)+I_MS_int;
P(P<0)=0;

%%
disp(sprintf('------>  [PNN+]: Fine-tuning (%d it) time = %0.4gs  //  Prediction time = %0.4gs',FT_epochs, Train_time, Test_time));
    

end




