function alpha = estimate_LPC_coeff(R,p)
E = R(1);
alpha = zeros(1,p-1);
temp =  zeros(1,p-2);
for i = 2:p
    sop = SOP(alpha,R,i-1);
    k = (R(i) - sop)/E;
    alpha(i-1) = k; 
    for j = 1:i-2
        temp(j) = alpha(j) - (k*alpha(i-1-j));
    end
    for j = 1:i-2
        alpha(j) = temp(j);
    end
%     alpha = [temp k];
E = E*(1-(k*k));
end
end
function y = SOP(alpha,R,i)
    y=0;
    for j=1:i-1
        y = y+alpha(j)*R(abs(i-j+1));
    end
end