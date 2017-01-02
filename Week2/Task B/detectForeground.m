function detection = detectForeground(grayscale, means, deviations, alpha)
%A pixel is detected as foreground if it satisfies this equation
detection = abs(grayscale - means) >= (alpha+2).*deviations;

end