function [pd1i,pd2i,p1i,p2i]=pitch_detect_lpc_sift(x,fs,imf,L,R)
%
% Inputs:
%   x: input speech signal
%   fs: sampling rate
%   imf: 1 for male talkers, 2 for female talkers
%   L: frame duration in samples
%   R: frame shift in samples
%   fname: name of file being processed
%
% Outputs:
%   pd1i: pitch period contour based on refined location of first candidate
%   pd2i: pitch period contour based on refined location of second candidate
%   p1i: modified correlation level of refined first candidate
%   p2i: modified correlation level of refined secondary candidate
% low pitch period corresponds to 350 Hz pitch
% high pitch period corresponds to 50 Hz pitch
    if (imf == 1)
        freqlow=50;
        freqhigh=200;
        fprintf('male speaker: freq low/high: %d, %d \n',freqlow,freqhigh);
    elseif (imf == 2)
        freqlow=150;
        freqhigh=350;
        fprintf('female speaker: freq low/high: %d, %d \n',freqlow,freqhigh);
    end
        ppdlow=round(fs/freqhigh);
        ppdhigh=round(fs/freqlow);
        fprintf('period low/high: %d, %d \n',ppdlow,ppdhigh);
    
% determine signal length to block into frames
    ls=length(x);
    
% utilize frames of duration L samples, with shift of R samples between
% analysis frames
    fcenter=L/2;
    
% initialize pitch period and level arrays
    clear pd1 p1;
    p1=[];
    p2=[];
    pd1=[];
    pd2=[];
    p1i=[];
    p2i=[];
    pd1i=[];
    pd2i=[];
    frame=1;
    
% initialize count, define search region
    count=1;
    count1=0;
    n=ppdlow:ppdhigh;
    
% loop on all analysis frames
    %while (fcenter+L/2 <= ls)
        frame1=x(max(fcenter-L/2+1,1):min(ls,fcenter+L/2));
        lf=length(frame1);
        %if (max(frame1) < 2)
        %    frame1=(randn(lf,1)*0.001)';
        %    count1=count1+1
        %end
        
% do p=4-th order lpc analysis of frame using hamming window (wtype=1)
        p=4;
        [r,lg] = xcorr(frame1,frame1');
        r(lg<0) = [];
        alpha=levinson(r,p);
%         coff = alpha(1:p);
        den=[1 -alpha(1:p)];
        
% inverse filter speech window to get error signal
        error=filter(den,1,frame1);
        
% initialize autocorrelation computation 
        indexlow=ppdlow+1;
        indexhigh=ppdhigh+1;
        frame1a=error;
        frame2=frame1a';
        
% compute autocorrelation of frame1a and frame2
        lf=max(length(frame1a),length(frame2));
        c=xcorr(frame1a,frame2);
        c=c(lf:2*lf-1);
        c=c/max(c);
%         plot(c);
        
        pmax1=max(c(1+ppdlow:1+ppdhigh));
        ploc1=find(c(1+ppdlow:1+ppdhigh) == pmax1);        
        p1=[p1 pmax1];
        pd1=[pd1 ploc1+ppdlow-1];
        
% eliminate strongest peak to do secondary test on peaks
        offset=1;
        n1=max(1,ploc1+ppdlow-1-offset);
        n2=min(ploc1+ppdlow+1+offset,length(c));
        cp2=c;
        cp2(n1:n2)=-1;
        pmax2=max(cp2(1+ppdlow:1+ppdhigh));
        p2=[p2 pmax2];
        ploc2=find(cp2(1+ppdlow:1+ppdhigh) == pmax2);
        pd2=[pd2 ploc2+ppdlow-1];
        
% resample waveform to original rate of fsd;
        yi=resample(frame1a,5,1);
        ch=xcorr(yi,yi');
        lfi=length(yi);
        ch=ch(lfi:2*lfi-1);
        chmax=max(ch);
        ch=ch/chmax;
        
% refine peak locations at 10 kHz rate       
        center1=5*(ploc1+ppdlow-1)+1;
        low1=center1-3;
        high1=center1+3;
        pmax1i=max(ch(low1:high1));
        p1i=[p1i pmax1i];
        ploc1i=find(ch(low1:high1) == pmax1i);
        ploc1i=low1+ploc1i-1;
        pd1i=[pd1i ploc1i];
   
        center2=5*(ploc2+ppdlow-1)+1;
        low2=center2-3;
        high2=center2+3;
        pmax2i=max(ch(low2:high2));
        p2i=[p2i pmax2i];
        ploc2i=find(ch(low2:high2) == pmax2i);
        ploc2i=low2+ploc2i-1;
        pd2i=[pd2i ploc2i];
        
%         fcenter=fcenter+R;
        frame=frame+1;
    end
    %end