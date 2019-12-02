[y1,Fs] = audioread('C:/users/username/Downloads/a-z_vocal.mp3');

%taking a part of speech for analysis
y = audioread('C:/users/username/Downloads/a-z_vocal.mp3',[800000 1500000]);

%playing the audio just for fun
player = audioplayer(y,Fs);
play(player);

%decimating the input by factor of 4
y = resample(y,1,4);

%length of frame
L = 250;

%length of frame shift for analysis of pitch period, usually taken as L/2
R1 = 125;

%center coordinates  of frame
fcenter = L/2;

%length of signal
ls = length(y);

%no. of coefficeints or can be interpreted as no. dominant formant frequencies(usually 4) 
%no. of coefficients are double the no. of formant freq
p=8;

%sn is reconstructed signal of length ls+p
%first p samples of sn will be zeros and remaining be synthesized using the synthesis equations 
sn = zeros(1,ls+p);

% initialize the frame count
framecount=1;

%taking the first frame of length L
frame1=y(1:(fcenter+L/2));

%count_max denotes the maximum no. of frames that are possible with signal length

count_max = round(length(y)/R1);

%flag for unvoiced and voiced speech
v = zeros(1,count_max);

%Energy of frame
E = zeros(1,count_max);
i = 1;

%iterating on each frame
 while (count_max > framecount && fcenter <= ls)
     %extracting the frame of length L
        frame1=y(fcenter-(L/2)+1:min(ls,(fcenter+(L/2))));
        lf=length(frame1);
        
        
        %pd1i - location of first pitch period
        %pd2i - location of second pitch period
        %p1i - energy of signal on pd1i
        %p2i - energy of signal on pd2i
        %estimate the pitch period using SIFT 
        [pd1i,pd2i,p1i,p2i] = SIFT_code(frame1);
%         find the correlation of signal frame wise
        [out1,lags] = correlation(frame1,frame1,0,length(frame1)-1,0,length(frame1)-1);
       
        %extracting the samples from [0 L] from obtained correaltion length [-L L]
        out1=out1(lf:2*lf-1);
        
        %taking the first p samples of correlation 
        R = out1(1:(p+1));
        
        %normalize the correlation level
        out1=out1/max(out1);
        
        %taking the first p  samples of normalized correlation
        r = out1(1:p+1);
        alpha = estimate_LPC_coeff(r,p+1);
        
        %calc the square of gain 
        G_sq = R(1) - (alpha(1:end)*R(2:end)');
        Gain = sqrt(G_sq);
        cum_sum = cumsum(pd1i);
        
        %initialize the start and end parameter
        start = fcenter-(L/2)+1;
            
        end1 = fcenter+(L/2);
        
        %calc the energy of frame1
        E(i) = (1/lf)*sum(frame1.^2);
        
        %if energy > 10^-2.4 classify as voiced otherwise as unvoiced
        if (E(i)>10^(-2.4))
            %iniitialze the input excitation signal
            u = zeros(1,L+1);
            %create impulse at pitch periods
            u(1) = 1;
            u(pd1i) = 1;
            u(pd2i) = 1;
%             u = zeros(1,L+1);
            v(i) = 1;
        else
            %create random noise and give it as input excitation 
            u = random('Normal',0.5,10^-1.2,1,L+1);
            v(i) = 0;
        end
        i=i+1;
        
        %synthesize the output signal
        sn  = LPC_synthesizer(p,start,end1,alpha,u,Gain,sn);
        
        %shift the frame by R1
        fcenter = fcenter+R1;
        framecount=framecount+1;
 end
plot(sn,'-b');
Fs = 11000;
player = audioplayer(sn/2,Fs); 
play(player);