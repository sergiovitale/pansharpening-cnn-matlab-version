function net = load_net(path)
%*************************************************************    
% load finetuned network according to the epoch with minimum loss
%
% path:     finetuned network path
% net:      finetuned network
%********************************************************
    
    %load info regarding loss
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
end