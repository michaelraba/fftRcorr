% nb this function should only take azimuthal mode ...
function [qq]=fourierCorrNoXcorr(currentTime, currentCrossSec, qMinusQbar_noCsYet,xcorrDone,aliasStr)
% [ntimesteps, rMin, rMax, ss, ncs, plotOn, azimuthalSet ,azimuthalSetSize ,printStatus ,lags]=constants();
  [ntimesteps, rMin, rMax, ss, ncs, plotOn, azimuthalSet ,azimuthalSetSize ,printStatus ,lags, blocLength, saveDir,csSet,timeSet]=constants();
  [postAzimuthFft_noCsYet]=initData2("postAzimuthFft_noCsYet");
for timeBloc = 1:blocLength% time
    parfor t = 1:ntimesteps % time % parfor
      for  rr = 1:540
        aziSet=1:5:540;
        mSize = size(aziSet) ;  mSize=mSize(2) ;
            vec = zeros(mSize,1);
            mCounter = 1;
            for mm=aziSet
            aa=qMinusQbar_noCsYet(t).circle(mm).dat(rr,1); % this can perhaps be truncated to 540, then duplicated for the second half, too prevent aliasing.!
            vec(mCounter)= aa;
            mCounter = mCounter+1;
            end % for mm
            result = fourier2(vec,aziSet,mSize);
               end % r
        end % time
    end % timeBloc
qq = result; % asign qq and exi
end % fc