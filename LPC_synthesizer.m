function [sn,j] = LPC_synthesizer(p,start,end1,alpha,u,G,sn)
for i=start+p:end1+p
sn1 = sn(i-p:i-1);
% if(i-start-p+1 == 1||i-start-p+1==pd1i||i-start-p+1==pd2i)
%     alpha = alpha_inter(j,:);
% %     alpha
%     Gain = G(j);
%     j=j+1;
% end
flip_alpha = flip(alpha);
sm= (flip_alpha(1:end)*sn1(1:end)');
s = sm+(G*u(i-start-p+1));
sn(i) = s;
end
end

