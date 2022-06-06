% Classic POD
function podClassicNoXcorr()
[ntimesteps, rMin, rMax, ss, ncs, plotOn, azimuthalSet ,azimuthalSetSize ,printStatus ,lags, blocLength, saveDir,csSet,timeSet]=constants();

dr = 9.276438000000004e-04 + zeros(ss,1);
rMat=0:dr:.50001; % [0, ...,0.5] with 540 elements %  needs checked


%function pod()
%figure(1);
%hold on;
[phiVecAv]=initData2("phiVecAv");
[eigVec]=initData2("eigVec");
[eigVal]=initData2("eigVal");

saveStr=[saveDir 'avgTimeEnd[Case]C' num2str(ncs) 'T' num2str(ntimesteps) '[crossSec]' num2str(ncs) '.mat'];
qq=open(saveStr);
avgTimeEnd=qq.avgTimeEnd; % Rmat(time).cs(cs).circle(=azimuthalSetSize1:18)

        clear qq;
for cc=1:ncs % streamwise mode % cannot exceed 1...        
for mm=1:azimuthalSetSize % azimuthal mod
 %c = avgTimeEnd(cc).circle(mm); % this is the R(k;m;t,t').
 c = avgTimeEnd(cc).circle(mm).dat(1:ss); % this is the R(k;m;t,t').
for rR=1:ss
% multi by sqrt r 
abb(rR )   = c(rR) * sqrt(rMat(rR));
end % rR
cM = abb.*ctranspose(abb);
% end correlation matrix.
sprintf('%s','take eigenvals');
[eigVec_tmp,eigVal_tmp]=eig(cM);
[d,ind] = sort(diag(eigVal_tmp),'descend');
eigVal(mm).c(cc).dat=eigVal_tmp(ind,ind);
eigVec(mm).c(cc).dat= eigVec_tmp(:,ind); % this needs to be stored for each m-mode.
tTrapz=zeros(ntimesteps,1);
%phiVec=zeros(ss,1);
end % mm
end % cc

%  find av over crossecs.
for podModeNumber=1:3
for mm=1:azimuthalSetSize
%phiVecAv(podModeNumber).circle(mm).dat = eigVec(:,podModeNumber) + phiVecAv(podModeNumber).circle(mm).dat;
phiVecAv(podModeNumber).circle(mm).dat = eigVec(mm).c(cc).dat(:,podModeNumber) + phiVecAv(podModeNumber).circle(mm).dat;
end % mm
end % podMode

% call plotSkmr


sprintf('%s','done');
%%for podModeNumber=1:3
%%for rr=1:ss
%%for tt=1:ntimesteps % finding the n eigenfunctions Phi^{(n)}(r)...:
%%    % fftTransformedFluctuation(18).cs(3).rad
%%    % uXfft(18).cs(3).rad
%%    aa=uXfft(mm).cs(cc).rad(rr).dat(tt); % this indeed varies with t.
%%    % must distinguish between alpha^{n} (t)
%%    bb=ctranspose(eigVec(podModeNumber)); % this t plays the role of eigvecs \in [0,N]. Should save each separate.
%%    ab = aa*bb;
%%    tTrapz(tt) = ab;
%%  end % tt
%%ad= trapz(tTrapz);
%%phiVec(podModeNumber).c(cc).m(mm).dat(rr) = ad/(eigVal(tt,tt)*ntimesteps); % smits.eq.2.5
%%end %rr
%%
%%end % podMode
%%hold on;
%%if 2 <= mm < azimuthalSetSize
%%%plot(real(phiVec));
%%end % if
%%end % circle mm
%%end % ncs

end % fc
