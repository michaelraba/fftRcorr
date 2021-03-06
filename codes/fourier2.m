function [resultVec] = fourier2(temp,aziSet,mSize)

dtheta=5;
% this will be an issue. 
t=0:dtheta/355:1;

% define function to test the fourier series approx
%temp=cos(2*pi*3*t);


%%%%%%%%%%%%%%forward transform.....fft
%tic
temp_hat=fft(temp)*dtheta/180*pi;
%toc
%%%%%%%%%%%%inverse transform.....fft
temp_inv=ifft(temp_hat)/dtheta*180/pi;
%%%%%%%%%%%%%

%%%%%%%%%%%%%forward transform.... dft
%lngth=length(t);
lngth=mSize;
deg=0;
%tic
for m=0:lngth-1
    sumSij=0;
    for n=1:lngth
        rad=deg/180*pi;
        sumSij=temp(n)*exp(-1i*m*rad)*dtheta/180*pi+sumSij;
        deg=deg+dtheta;
    end %for n     
    Sij(m+1)=sumSij;
end % for m 

resultVec = Sij;
%toc
%%%%%%%%%%%%inverse transform.....dft
for n=1:lngth
    sumSij=0;
    rad=deg/180*pi;
    %for m=0:0%1:lngth-1
    for m=1:lngth-1
        sumSij=1/(2*pi)*Sij(m+1)*exp(1i*m*rad)+sumSij;
        %sumSij=1/(2*pi)*Sij(72-m+1)*exp(1i*(72-m)*rad)+sumSij;
       sumSij=1/(2*pi)*Sij(mSize-m+1)*exp(1i*(mSize-m)*rad)+sumSij;

        %sprintf('%s','p')
    end
    deg=deg+dtheta;
    Sij_inv(n)=sumSij;
end
%%%%%%%%%%%%%%%%%%%%%%%%
hold off;
subplot(1,2,1)
hold on;
plot(1:mSize,temp_hat,1:mSize,Sij)
title('tempHat ()')
subplot(1,2,2)
hold on;
plot(real(temp),'b.') % 2 and 3 matching
plot(real(temp_inv),'o--') % 

title('plots of (1) SijInv, (2) tempInv.. and (3) temp ')
sprintf('%s','p')
resultVec = temp; %temp is the reconstruct. dont return that.
reSultVec = Sij;  % this is the coefficients. 
end % f
