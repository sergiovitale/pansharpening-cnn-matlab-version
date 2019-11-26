function I_in = input_preparation_(I_MS_LR,I_PAN,model)
%*******************************************
% prepare the data for training:
%   interpolate I_MS_LR image in order to bring it to PAN dimension
%   create a stack of (MS,PAN) and normalize to maximum dynimc of image
%
% I_MS_LR:      ms image donwgraded for Wald Protocol
% I_PAN:        pan image downgraded for Wald Protocol
% model:    struct with training details of pretrained network
% I_in:         stack of (MS,PAN) for fine tune the network
%*************************************************************

mav_value = 2^double(model.L);

if isequal(model.typeInterp,'interp23tap')
    I_MS = interp23tap(I_MS_LR, double(model.ratio));
elseif isequal(model.typeInterp,'cubic')
    I_MS = imresize(I_MS_LR,size(I_PAN),'bicubic');
else
    error('Interpolation not supported');
end

if isequal(model.inputType,'MS')
    I_in = single(I_MS)/mav_value;
elseif isequal(model.inputType,'MS_PAN')
    I_in = single(cat(3,I_MS,I_PAN))/mav_value;
elseif isequal(model.inputType,'MS_PAN_NDxI')
    I_in = single(cat(3,I_MS,I_PAN))/mav_value;
    I_in = single(cat(3,I_in,single(NDxI))); % CHANGE
else
   error('Configuration not supported');
end

padSize = double(model.padSize);
I_in = padarray(I_in, [padSize,padSize]/2, 'replicate','both');

end
