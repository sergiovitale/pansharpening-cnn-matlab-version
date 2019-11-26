function lr = ft_learning_rate(model,net_scope,size_ms)
%************************************************************
% adapting learning rate for new image dimension
% model:        struct with training details of pretrained network
% net_scope:    network scope
% size_ms:      size of ms image 
% lr:           learning rate for finetuning
%***********************************************************
pretrained_lr = model.lr;
if isfield(model,'block_size')
        patch_size = double(model.block_size);
    else
        patch_size = double(model.patch_size);
end
lr = pretrained_lr*((patch_size-net_scope+1)^2./(size_ms(1)-net_scope+1)/(size_ms(1)-net_scope+1));
end
