function [resultVec] = fourier2(temp,aziSet,mSize)

dtheta=5;
% this will be an issue. 
t=0:dtheta/355:1;

% define function to test the fourier series approx
%temp=cos(2*pi*3*t);


%%%%%%%%%%%%%%forward transform.....fft
tic
temp_hat=fft(temp)*dtheta/180*pi;
toc
%%%%%%%%%%%%inverse transform.....fft
temp_inv=ifft(temp_hat)/dtheta*180/pi;
%%%%%%%%%%%%%

%%%%%%%%%%%%%forward transform.... dft
lngth=length(t);
deg=0;
tic
for m=0:lngth-1
    sumSij=0;
    for n=1:lngth
        rad=deg/180*pi;
        sumSij=temp(n)*exp(-1i*m*rad)*dtheta/180*pi+sumSij;
        deg=deg+dtheta;
    end %for n 
    
    Sij(m+1)=sumSij;
end % for m 
toc
%%%%%%%%%%%%inverse transform.....dft
for n=1:lngth
    sumSij=0;
    rad=deg/180*pi;
    %for m=0:0%1:lngth-1
    for m=1:lngth-1
        sumSij=1/(2*pi)*Sij(m+1)*exp(1i*m*rad)+sumSij;
        sumSij=1/(2*pi)*Sij(72-m+1)*exp(1i*(72-m)*rad)+sumSij;
        sprintf('%s','p')
    end
    deg=deg+dtheta;
    Sij_inv(n)=sumSij;
end
%%%%%%%%%%%%%%%%%%%%%%%%
subplot(1,2,1)
plot(0:71,temp_hat,0:71,Sij)
title('tempHat ()')
%figure(2)
subplot(1,2,2)

%plot(t,Sij_inv,t,temp,t,temp_inv)
hold on;
plot(t,Sij_inv) % blu 1 has larger amplitudes than 2,3
plot(t,temp,'b.') % 2 and 3 matching
plot(t,temp_inv,'r--') % 

title('plots of (1) SijInv, (2) tempInv.. and (3) temp ')
sprintf('%s','p')
resultVec = temp;
end % f
