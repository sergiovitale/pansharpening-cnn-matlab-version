function layers = load_layers(firstLayer,model)
%*******************************************************
% load pretrained layers from network trained in python
%   
% firstLayer:   input layer with info for input image
% model:        struct with training details of pretrained network
% layers:       list of layers
%******************************
conv_layer = {};
k=0;
layers=[firstLayer];
for i = [1:2:length(model.layers)]
    k=k+1;
    s = size(model.layers{i});
    conv_layer{k}=convolution2dLayer(s(1),s(4));    
    conv_layer{k}.Name = sprintf('conv%d',k);
    conv_layer{k}.Weights = model.layers{i};
    conv_layer{k}.Bias = model.layers{i+1};
    if i < length(model.layers)-1
        l = reluLayer('Name',sprintf('relu%d',k));
        layers = [layers,conv_layer{k},l];
    else
        layers = [layers,conv_layer{k}];
    end
end

end