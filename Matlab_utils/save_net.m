function net = save_net(path)
%*************************************************************    
% save finetuned network according to the epoch with minimum loss:
% delete the default checkpoint saved by matlab and only the min loss
% network will be saved
% path:     finetuned network path
% net:      finetuned network
%********************************************************
    
    %load info regarding loss
    delete([path,'network.mat']);
    
    info = load([path,'traininfo.mat']);
    loss = info.traininfo.TrainingLoss;
    %get epoch with minimum loss
    [m,idx] = min(loss);
    %get checkpoint in according to idx
    nets = dir(path);
    for i = 3:52
        if nnz(num2str(idx) - '-')==2
            if strcmp(nets(i).name(1:18),sprintf('net_checkpoint__%d',idx))
                break
            end
        else
            if strcmp(nets(i).name(1:18),sprintf('net_checkpoint__%d_',idx))
                break
            end
        end
    end
    net = load([nets(i).folder,'/',nets(i).name]);
    net = net.net;
    training_info = info;
    delete([path,'*.mat']);
    save([path,'network.mat'],'net','training_info');
end