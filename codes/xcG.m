function xcorrGpu()
clear all;

[ntimesteps , rMin, rMax ,ss ,ncs ,plotOn ,azimuthalSet ,azimuthalSetSize ,printStatus ,lags, blocLength, saveDir,csSet,timeSet]=constants();

%%
%genStr=input("(L)oad or (G)enerate? If load eg c2t4\n> ","s");
genStr="G";
if genStr=="G" ||  genStr=="g"
  sprintf('%s%s%s%s%s%s%s%s','**************',newline,'Generating to file C',num2str(ncs),'t',num2str(ntimesteps),newline,'**************'   )
emptyStr=[];
%[qMinusQbar]= fftStep("readDataAndFindVeloFluctuation",emptyStr);
[qMinusQbar]= fftStep("readDataAndFindVeloFluctuation",emptyStr);

sprintf('%s','Saving velocity fluctuations into file...')
saveStr=['/mnt/archLv/mike/podData/structSave/qMinusQbar_CaseC' num2str(ncs) 't' num2str(ntimesteps) '.mat'       ];
%save(saveStr,'qMinusQbar','-v7.3');
sprintf('%s%s','Saved velocity fluctuations into file ',saveStr);
%% 
else % eg load qMinusQbar_C2T400
saveStr=['/mnt/archLv/mike/podData/structSave/qMinusQbar_' genStr '.mat'];
load(saveStr)
sprintf('%s%s','Loaded velocity fluctuations from file ',saveStr);
end % if
%% 
sprintf('%s','done qMinusQbar.')
% Next step is take azimuthal fft...
% [post]=fftStep("azimuth",qMinusQbar)
sprintf('%s','done qMinusQbar.')