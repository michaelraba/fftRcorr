function [fourierVecPost]=fourier(vecPre,aziSet,mSize)
          %deltaTheta = 1/271;
          fourierVecPost =  zeros(mSize,1);
  deltaTheta = 108*pi/180;
        % calculates the fourier Series
        % NOT using any Dft, although that can be done by using folding - however direct calculation is done here.
  a=zeros(mSize,1);
        for mm =1:mSize
          a(mm) = vecPre(mm); % load S(r,r'; k,m) init memory for all r
          %b=zeros(mSize,1);
          b=0;
        for sum_m = mSize
          b= b +a(mm)*exp(j*sum_m*mm)*deltaTheta;
        end % sum
        fourierVecPost(mm) = b ;
        %  duplicate the data too for anti-aliasing
        end %mm
end %fc
