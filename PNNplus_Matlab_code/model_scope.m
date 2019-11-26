function net_scope = model_scope(model)
% *******************************
% compute the network scope
% model:  struct with training details of pretrained network
% net_scope: scope if network
%************************************

    net_scope = 0;
    for i = 1:2:length(model.layers)
        net_scope = net_scope + size(model.layers{i},1)-1;
    end
    net_scope = double(net_scope+1);
end