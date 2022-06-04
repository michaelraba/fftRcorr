function [fourierVecPost]=fourier(vecPre,aziSet,mSize)
          %deltaTheta = 1/271;
  deltaTheta = 108*pi/180;
        % calculates the fourier Series
        % NOT using any Dft, although that can be done by using folding - however direct calculation is done here.
        for mm =mSize
          a = vecPre(m); % load S(r,r'; k,m) init memory for all r
          %b=zeros(mSize,1);
          b=0;
        for sum_m = mSize
          b= b +a(mm)*exp(j*sum_m*m)*deltaTheta;
        end % sum
        fourierVecPost(mm) = b ;
        %  duplicate the data too for anti-aliasing
        end %m
