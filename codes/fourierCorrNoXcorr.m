% nb this function should only take azimuthal mode ...
function [qq]=fourierCorrNoXcorr(currentTime, currentCrossSec, qMinusQbar_noCsYet,xcorrDone,aliasStr)
% [ntimesteps, rMin, rMax, ss, ncs, plotOn, azimuthalSet ,azimuthalSetSize ,printStatus ,lags]=constants();
  [ntimesteps, rMin, rMax, ss, ncs, plotOn, azimuthalSet ,azimuthalSetSize ,printStatus ,lags, blocLength, saveDir,csSet,timeSet]=constants();
  [postAzimuthFft_noCsYet]=initData2("postAzimuthFft_noCsYet");
if aliasStr=="noAlias"
elseif aliasStr=="alias"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
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
% do not correlate here.
%%%clear qMinusQbar_noCsYet; % yes, clear this..
%%%   for timeBloc = 1:blocLength% time % disable; already declared above in fftAzimuth
%%%        saveStr=[saveDir 'qMinusQbar[Case]C' num2str(ncs) 'T' num2str(ntimesteps) '[crossSec]' num2str(currentCrossSec) '[TimeBloc]' num2str(timeBloc) '.mat'       ];
%%%        load(saveStr,'qMinusQbar_noCsYet');
%%%    ordStr="xcorrNow";
%%%%    if ordStr=="xcorrNow" % remove that.
%%%        parfor t=1:ntimesteps%
%%%            vec = zeros(1,540); % collect radial points..
%%%                for m=1:1080
%%%                for r=1:540% size xcorr
%%%                  aa = qMinusQbar_noCsYet(t).circle(m).dat(r,1);
%%%                  vec(r) = aa;
%%%                end % r
%%%                  [bb, lags] = rcorr(vec,"normalized"); % bb is 1079 because of xcorr ! <- new annotat.
%%%                xcorrDone(t).circle(m).dat=bb';
%%%                end % m
%%%        end % (little)t
%%%  saveStr=[saveDir 'xcorrDone[Case]C' num2str(ncs) 'T' num2str(ntimesteps) '[crossSec]' num2str(currentCrossSec) '[TimeBloc]' num2str(timeBloc) '.mat'       ];
%%%   save(saveStr,'xcorrDone','-v7.3');
%%%   end % timebloc
%%%
%%%end % if alias
qq = xcorrDone; % asign qq and exi
end % fc
