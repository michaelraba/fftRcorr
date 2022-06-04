function [structPost]=fourier(structPre)     
          %deltaTheta = 1.32841328413    % 360/271
          deltaTheta = 1/271;
        % calculates the fourier Series
        % NOT using any Dft, although that can be done by using folding - however direct calculation is done here.
        for t=1:ntimesteps
        for c=1:ncs% size xcorr
        for m=1:azimuthalSetSize%
        vec=[];
        for r=1:1079 % pre has this form
          a = structPre(c).t(t).azimuthal(m).dat ; % load S(r,r'; k,m) init memory for all r
        end %r
        % then for each deltaTheta (azimuthal mode), multiply.
        % do sum
        b = zeros(1,1079);
        for sum_m = 1:271*2
          % a is a vector. that was inspired by sccb code. thats why weird.
          b= b +a*exp(j*sum_m*m)*deltaTheta;
        end % sum
          structPost(c).t(t).azimuthal(m).dat = b; % load S(r,r'; k,m) init memory for all r
          %sprintf('%s','pause');

        end %m
        end %c
        end %t
        %sprintf('%s','pause');
        return structPost(c).t(t).azimuthal(m).dat;
%
