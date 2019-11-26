function img = image_stretch(img,th)
    
    img = double(img);
    if numel(th) == 2,
        img = (img-th(1))/(th(2)-th(1));
    else
        [Nr,Nc,Nk] = size(img);
        for index = 1:Nk
            img(:,:,index) = (img(:,:,index)-th(index,1))/(th(index,2)-th(index,1));
        end
    end