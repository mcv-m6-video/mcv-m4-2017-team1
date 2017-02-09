function y = RemovePerspective(img, H, s)
% Function used from Team2, class2016 , M4
% s: it is a row vector indicating the size of the output image

y = uint8(zeros(s(1), s(2), 3));

T = inv(H);
for r = 1:s(1)
    for c = 1:s(2)
        p = double([c r 1]');
        pimh = T*p;
        pim(1) = pimh(1) / pimh(3);
        pim(2) = pimh(2) / pimh(3);
        cim = pim(1);
        rim = pim(2);
        
        cc = round(cim);
        rr = round(rim);
        if cc>0 && cc<=size(img, 2) && rr>0 && rr<=size(img, 1)
            y(r, c, :) = img(rr, cc, :);
        end
    end
end