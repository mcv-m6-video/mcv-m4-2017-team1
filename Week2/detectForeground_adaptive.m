function [detection,means,deviations] = detectForeground_adaptive(grayscale, means, deviations, alpha,rho)
%A pixel is detected as foreground if it satisfies this equation
detection = abs(grayscale - means) >= alpha.*(deviations+2);
means(~logical(detection))=rho*grayscale(~logical(detection)) + (1-rho)*means(~logical(detection));
deviations(~logical(detection))=sqrt(rho*(grayscale(~logical(detection))-means(~logical(detection))).^2 + (1-rho)*deviations(~logical(detection)).^2);
 

end