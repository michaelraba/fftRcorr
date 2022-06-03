% redesign.
function redesign()

 % initialize data
[ntimesteps , ~, rMax ss ncs plotOn azimuthalSet azimuthalSetSize printStatus lags]=constants();
%sprintf('%s','pause');
[radialXcorrStruct]=initData2("radialXcorrStruct"); % initialize avg struct

%sprintf('%s','pause');
[XcorrData]=initData2("XcorrData");
[XcorrDonePreCsFft]=initData2("XcorrDonePreCsFft");
[XcorrDonePostCsFft]=initData2("XcorrDonePostCsFft");
[XcorrDoneCsFftDonePreAzimFft]=initData2("XcorrDoneCsFftDonePreAzimFft");
[XcorrDoneCsFftDonePostAzimFft]=initData2("XcorrDoneCsFftDonePostAzimFft");
[XcorrAzimDonePreTimeAvg]=initData2("XcorrAzimDonePreTimeAvg");
[XcorrAzimDonePostTimeAvg]=initData2("XcorrAzimDonePostTimeAvg");
[Skmr]=initData2("Skmr");



%% initData
%genStr=input("(L)oad or (G)enerate? If load eg c2t4\n> ","s");
genStr="G";
if genStr=="G" ||  genStr=="g"
  sprintf('%s%s%s%s%s%s%s%s','**************',newline,'Generating to file C',num2str(ncs),'t',num2str(ntimesteps),newline,'**************'   )

[qMinusQbar]= readDataAndFindVeloFluctuation();
saveStr=['/home/mi/podData/structSave/qMinusQbar_c' num2str(ncs) 't' num2str(ntimesteps) '.mat'       ];
save(saveStr,'qMinusQbar','-v7.3');
sprintf('%s%s','Saved velocity fluctuations into file ',saveStr);
else % eg load qMinusQbar_C2T400
saveStr=['/home/mi/podData/structSave/qMinusQbar_' genStr '.mat'];
load(saveStr)
sprintf('%s%s','Loaded velocity fluctuations from file ',saveStr);
end % if
% in Approach (A), call autocorrelation form of xcorr() radially,
% for each t,c, and theta,
% then take the fourier transform in cs and azimuthal direction.
fftCase="A";
if fftCase=="A" % xcorr method: (1) xcorr (2) fft-x (3) fft-azimuthal

[radialXcorrStruct]=fftStreamwise(qMinusQbar, radialXcorrStruct,"populateXcorr");
clear qMinusQbar;
save('/home/mi/podData/structSave/radialXcorrStruct.mat','radialXcorrStruct');
%lags=0;
[XcorrData,lags]=DoXcorrRadial(radialXcorrStruct,XcorrData,"none"); %none, graph, graphPause
clear radialXcorrStruct;
[XcorrDonePreCsFft]=DoFftXcorr(XcorrData,XcorrDonePreCsFft,"setupVec","xDir","off",lags);
clear XcorrData;
[XcorrDonePostCsFft]=DoFftXcorr(XcorrDonePreCsFft,XcorrDonePostCsFft,"runFft","xDir","off",lags);
clear XcorrDonePreCsFft;
% fourier-Series-azimuthal try
%[SrrPrForFourierPre]=initData2("SrrPrForFourierPre");
%[SrrPrForFourierPost]=initData2("SrrPrForFourierPost");
%
%%SrrPrForFourier(1).t(3).azimuthal(1).dat
%[SrrPrForFourierPre]=DoFftXcorr(XcorrDonePostCsFft,SrrPrForFourierPre,"setupVec","SrrPrForFourier","off",lags);
%[SrrPrForFourierPost]=DoFftXcorr(SrrPrForFourierPre,SrrPrForFourierPost,"runFft","SrrPrForFourier","off",lags);
%%sprintf('%s','pause');
%plotSkmr(SrrPrForFourierPost,"graph")
%%sprintf('%s','pause');

% fft-azimuthal
[XcorrDoneCsFftDonePreAzimFft]=DoFftXcorr(XcorrDonePostCsFft,XcorrDoneCsFftDonePreAzimFft ,"setupVec","azimDir","off",lags)
% Method A: just call fft in azimuthal dir
[XcorrDoneCsFftDonePostAzimFft]=DoFftXcorr(XcorrDoneCsFftDonePreAzimFft,XcorrDoneCsFftDonePostAzimFft,"runFft","azimDirCaseA","off",lags)
% * Now we have the velocity fluctuation correlation tensor fft-transformed
% in both crossection and azimuthal directions.
% * The next step according to hellstrom2016.equation.2.2 is to
% average (in integral sense) over time; we call trapz() for this.
[XcorrAzimDonePreTimeAvg]=DoFftXcorr(XcorrDoneCsFftDonePostAzimFft,XcorrAzimDonePreTimeAvg,"setupVec","timeDir","off",lags)
[XcorrAzimDonePostTimeAvg]=DoFftXcorr(XcorrAzimDonePreTimeAvg  ,XcorrAzimDonePostTimeAvg ,"runFft","timeDir","off",lags)
[Skmr]=DoFftXcorr(XcorrAzimDonePostTimeAvg,Skmr,"setupVec","Skmr","off",lags)
%plotSkmr(Skmr,"graph")
%sprintf('%s','pause');


%
%[XcorrDoneCsFftDonePreAzimFft]=DoFftXcorr(XcorrDonePostCsFft,XcorrDoneCsFftDonePreAzimFft ,"setupVec","azimDir","off",lags);
%% Method A: just call fft in azimuthal dir
%[XcorrDoneCsFftDonePostAzimFft]=DoFftXcorr(XcorrDoneCsFftDonePreAzimFft,XcorrDoneCsFftDonePostAzimFft,"runFft","azimDirCaseA","off",lags);
%% average (in integral sense) over time; we call trapz() for this.
%[XcorrAzimDonePreTimeAvg]=DoFftXcorr(XcorrDoneCsFftDonePostAzimFft,XcorrAzimDonePreTimeAvg,"setupVec","timeDir","off",lags);
%clear XcorrDoneCsFftDonePostAzimFft;
%[XcorrAzimDonePostTimeAvg]=DoFftXcorr(XcorrAzimDonePreTimeAvg  ,XcorrAzimDonePostTimeAvg ,"runFft","timeDir","off",lags);
%clear XcorrAzimDonePreTimeAvg;
%[Skmr]=DoFftXcorr(XcorrAzimDonePostTimeAvg,Skmr,"setupVec","Skmr","off",lags);
plotSkmr(Skmr,"graph")
sprintf('%s','pause');

elseif fftCase=="B" % Tutkin method. StreamwiseFft of each signal and (2) multiply and average (3) then fourier series azimuthally.
  % inits
[streamwiseStruct]=initData("streamwisePreFft"); % initialize avg struct
[streamwiseFft]=initData("streamwisePostFft"); % initialize avg struct
[u_mk]=initData("u_mk"); % initialize avg struct

[streamwiseStruct]=fftStreamwise(qMinusQbar, streamwiseStruct,"populate")
%sprintf('%s','pause');
[streamwiseFft]=fftStreamwise(qMinusQbar, streamwiseStruct,"fftStreamwise")
%sprintf('%s','doTutkinEq8')
%sprintf('%s','doTutkinEq8')

%sprintf('%s','doTutkinEq8')
%
%

[Stilda_av]=initData("Stilda_av"); % initialize avg struct
[StildaVec]=initData("StildaVec"); % initialize avg struct
[Sij]=initData("Sij"); % initialize avg struct
for c = 1:ncs  % local loop
for t = 1:ntimesteps % time
doTutkinEq9tic=tic;
%sprintf('%s%d%s%d','doTutkinEq9 c=',c,',t=',t)
% form cross-spectra Tutkun eq 9
for deltaTheta=1:(azimuthalSetSize-1) % eg 23*2 = 46 should be.
%%%% plot of one of the streamwise:  https://i.imgur.com/Qt2qmd2.png for ii=1:28 plot(ii,streamwiseFft(1).RadialCircle(3).azimuth(1,ii).dat(1),'r.') hold on end
[StildaVec]=doTutkinEq9ReduxThree(t,c,streamwiseFft,StildaVec,deltaTheta); %fft instreamwise
% https://i.imgur.com/Slep3Tf.png 
% graph of StildaVec(1).crossSec(1).azimuth(1).dat(:,i) % vary i
elapse = ["el min " toc(doTutkinEq9tic)/60];
%
doTutkinEq10tic = tic;
%sprintf('%s','doTutkinEq10');
%% Find S, Tutkin eq 10
end % deltaTheta
end % t
end % c local

% take average of all crosssection
for t = 1:ntimesteps % time
%sprintf('%s%d%s%d','doTutkinEq9 c=',c,',t=',t)
for deltaTheta=1:(azimuthalSetSize-1) % eg 23*2 = 46 should be.
for c = 1:ncs  % local loop
% StildaVec
  Stilda_av(t).azimuth(deltaTheta).dat = Stilda_av(t).azimuth(deltaTheta).dat + StildaVec(t).crossSec(c).azimuth(deltaTheta).dat;
end%c
end%deltaTheta
end%t

for t = 1:ntimesteps % time
%sprintf('%s%d%s%d','doTutkinEq9 c=',c,',t=',t)
for deltaTheta=1:(azimuthalSetSize-1) % eg 23*2 = 46 should be.
[Sij]=doTutkinEq10Redux(t,c,Stilda_av,Sij, deltaTheta)
elapse = [ "elap min" toc(doTutkinEq10tic)/60];
%sprintf('%s','doTutkinEq8')
end % deltaTheta
end % t
%sprintf('%s','pause');

for t = 1:ntimesteps % time
for deltaTheta=1:(azimuthalSetSize-1) % eg 23*2 = 46 should be.
aa = Sij(t).azimuth(deltaTheta).dat;
plot(real(aa));
hold on;
end
end
%sprintf('%s','pause')


%for c = 1:ncs  % local loop
%for t = 1:ntimesteps % time
%%sprintf('%s%d%s%d','* eq 10, t=',t,'c=',c)
%for deltaTheta=1:(azimuthalSetSize-1) % eg 23*2 = 46 should be.
%for r = 1:540
%%[Sij]=doTutkinEq10Redux(t,c,Stilda_av,Sij, deltaTheta)
%  [u_mk]=doTutkinEq10Redux_u(t,c,r,streamwiseFft,u_mk, deltaTheta);
%end % rr
%end % deltaTheta
%end %t
%end %c
%%sprintf('%s','doTutkinEq8')
elseif fftCase=="C" % CB method. (1) fft in theta, (2) multiply and average signals (3) fourier streamwise

end % if fftCase





% plotting
%plot(real(Skmr(1).crosssection(1).dat  ))


% take fft in streamwise direction.
%%%  [streamwiseStruct]=initData("streamwisePreFft"); % initialize avg struct
%%%  %
%%%  % does not need c,t loop
%%%  [streamwiseStruct]=fftStreamwise(t,c,qMinusQbar, streamwiseStruct,"populate")
%%%  [streamwiseFft]=initData("streamwisePostFft"); % initialize avg struct
%%%  [streamwiseFft]=fftStreamwise(t,c,qMinusQbar, streamwiseStruct,"fft")
%%%  %sprintf('%s','doTutkinEq8')
%%%  %
%%%  [u_mk]=initData("u_mk"); % initialize avg struct
%%%
%%%
%%%  for c = 1:ncs  % local loop
%%%  for t = 1:ntimesteps % time
%%%  %sprintf('%s%d%s%d','* eq 10, t=',t,'c=',c)
%%%  for deltaTheta=1:(azimuthalSetSize-1) % eg 23*2 = 46 should be.
%%%  for r = 1:540
%%%  %[Sij]=doTutkinEq10Redux(t,c,Stilda_av,Sij, deltaTheta)
%%%    [u_mk]=doTutkinEq10Redux_u(t,c,r,streamwiseFft,u_mk, deltaTheta);
%%%  end % rr
%%%  end % deltaTheta
%%%  end %t
%%%  end %c
%%%
%%%
%%%  % do hellstrom eq 2.2: find the radial correlation, then average in time
%%%  [Shellstrom2dot2]=initData("Shellstrom2dot2"); % initialize avg struct
%%%  for t = 1:ntimesteps % time
%%%  for k = 1:ncs  % local loop
%%%  %sprintf('%s%d%s%d','* eq hellstrom.2.2, t=',t,'c=',c)
%%%  for m=1:(azimuthalSetSize-1) % eg 23*2 = 46 should be.
%%%    % nb c = k mode
%%%    % deltaTheta = m mode
%%%  [Shellstrom2dot2]=doHellstromEq2dot2(t,k,m,u_mk)
%%%  end % deltaTheta
%%%  end %t
%%%  end %c
 
end % function fft

%cte->fft constants...siehe auch, kte fuer den pod
function [ntimesteps rMin rMax, ss, ncs, plotOn azimuthalSet azimuthalSetSize printStatus lags]=constants()
plotOn=0;
rMin = 0;
rMax = 1079;
ncs = 6;
ntimesteps = 6; % fft mode
lags=[-540, -539,-538,-537,-536,-535,-534,-533,-532,-531,-530,-529,-528,-527,-526,-525,-524,-523,-522,-521,-520,-519,-518,-517,-516,-515,-514,-513,-512,-511,-510,-509,-508,-507,-506,-505,-504,-503,-502,-501,-500,-499,-498,-497,-496,-495,-494,-493,-492,-491,-490,-489,-488,-487,-486,-485,-484,-483,-482,-481,-480,-479,-478,-477,-476,-475,-474,-473,-472,-471,-470,-469,-468,-467,-466,-465,-464,-463,-462,-461,-460,-459,-458,-457,-456,-455,-454,-453,-452,-451,-450,-449,-448,-447,-446,-445,-444,-443,-442,-441,-440,-439,-438,-437,-436,-435,-434,-433,-432,-431,-430,-429,-428,-427,-426,-425,-424,-423,-422,-421,-420,-419,-418,-417,-416,-415,-414,-413,-412,-411,-410,-409,-408,-407,-406,-405,-404,-403,-402,-401,-400,-399,-398,-397,-396,-395,-394,-393,-392,-391,-390,-389,-388,-387,-386,-385,-384,-383,-382,-381,-380,-379,-378,-377,-376,-375,-374,-373,-372,-371,-370,-369,-368,-367,-366,-365,-364,-363,-362,-361,-360,-359,-358,-357,-356,-355,-354,-353,-352,-351,-350,-349,-348,-347,-346,-345,-344,-343,-342,-341,-340,-339,-338,-337,-336,-335,-334,-333,-332,-331,-330,-329,-328,-327,-326,-325,-324,-323,-322,-321,-320,-319,-318,-317,-316,-315,-314,-313,-312,-311,-310,-309,-308,-307,-306,-305,-304,-303,-302,-301,-300,-299,-298,-297,-296,-295,-294,-293,-292,-291,-290,-289,-288,-287,-286,-285,-284,-283,-282,-281,-280,-279,-278,-277,-276,-275,-274,-273,-272,-271,-270,-269,-268,-267,-266,-265,-264,-263,-262,-261,-260,-259,-258,-257,-256,-255,-254,-253,-252,-251,-250,-249,-248,-247,-246,-245,-244,-243,-242,-241,-240,-239,-238,-237,-236,-235,-234,-233,-232,-231,-230,-229,-228,-227,-226,-225,-224,-223,-222,-221,-220,-219,-218,-217,-216,-215,-214,-213,-212,-211,-210,-209,-208,-207,-206,-205,-204,-203,-202,-201,-200,-199,-198,-197,-196,-195,-194,-193,-192,-191,-190,-189,-188,-187,-186,-185,-184,-183,-182,-181,-180,-179,-178,-177,-176,-175,-174,-173,-172,-171,-170,-169,-168,-167,-166,-165,-164,-163,-162,-161,-160,-159,-158,-157,-156,-155,-154,-153,-152,-151,-150,-149,-148,-147,-146,-145,-144,-143,-142,-141,-140,-139,-138,-137,-136,-135,-134,-133,-132,-131,-130,-129,-128,-127,-126,-125,-124,-123,-122,-121,-120,-119,-118,-117,-116,-115,-114,-113,-112,-111,-110,-109,-108,-107,-106,-105,-104,-103,-102,-101,-100,-99,-98,-97,-96,-95,-94,-93,-92,-91,-90,-89,-88,-87,-86,-85,-84,-83,-82,-81,-80,-79,-78,-77,-76,-75,-74,-73,-72,-71,-70,-69,-68,-67,-66,-65,-64,-63,-62,-61,-60,-59,-58,-57,-56,-55,-54,-53,-52,-51,-50,-49,-48,-47,-46,-45,-44,-43,-42,-41,-40,-39,-38,-37,-36,-35,-34,-33,-32,-31,-30,-29,-28,-27,-26,-25,-24,-23,-22,-21,-20,-19,-18,-17,-16,-15,-14,-13,-12,-11,-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,280,281,282,283,284,285,286,287,288,289,290,291,292,293,294,295,296,297,298,299,300,301,302,303,304,305,306,307,308,309,310,311,312,313,314,315,316,317,318,319,320,321,322,323,324,325,326,327,328,329,330,331,332,333,334,335,336,337,338,339,340,341,342,343,344,345,346,347,348,349,350,351,352,353,354,355,356,357,358,359,360,361,362,363,364,365,366,367,368,369,370,371,372,373,374,375,376,377,378,379,380,381,382,383,384,385,386,387,388,389,390,391,392,393,394,395,396,397,398,399,400,401,402,403,404,405,406,407,408,409,410,411,412,413,414,415,416,417,418,419,420,421,422,423,424,425,426,427,428,429,430,431,432,433,434,435,436,437,438,439,440,441,442,443,444,445,446,447,448,449,450,451,452,453,454,455,456,457,458,459,460,461,462,463,464,465,466,467,468,469,470,471,472,473,474,475,476,477,478,479,480,481,482,483,484,485,486,487,488,489,490,491,492,493,494,495,496,497,498,499,500,501,502,503,504,505,506,507,508,509,510,511,512,513,514,515,516,517,518,519,520,521,522,523,524,525,526,527,528,529,530,531,532,533,534,535,536,537,538,539,540];
azimuthalSet=[1,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76,80,84,88,92,96,100,104,108,112,116,120,124,128,132,136,140,144,148,152,156,160,164,168,172,176,180,184,188,192,196,200,204,208,212,216,220,224,228,232,236,240,244,248,252,256,260,264,268,272,276,280,284,288,292,296,300,304,308,312,316,320,324,328,332,336,340,344,348,352,356,360,364,368,372,376,380,384,388,392,396,400,404,408,412,416,420,424,428,432,436,440,444,448,452,456,460,464,468,472,476,480,484,488,492,496,500,504,508,512,516,520,524,528,532,536,540,544,548,552,556,560,564,568,572,576,580,584,588,592,596,600,604,608,612,616,620,624,628,632,636,640,644,648,652,656,660,664,668,672,676,680,684,688,692,696,700,704,708,712,716,720,724,728,732,736,740,744,748,752,756,760,764,768,772,776,780,784,788,792,796,800,804,808,812,816,820,824,828,832,836,840,844,848,852,856,860,864,868,872,876,880,884,888,892,896,900,904,908,912,916,920,924,928,932,936,940,944,948,952,956,960,964,968,972,976,980,984,988,992,996,1000,1004,1008,1012,1016,1020,1024,1028,1032,1036,1040,1044,1048,1052,1056,1060,1064,1068,1072,1076,1080];
azimuthalSetSizeb=size(azimuthalSet);
azimuthalSetSize=azimuthalSetSizeb(2);

printStatus="on";
%ntimesteps = 988; % fft mode
ss=540;
cMin = 1;
%format long
end

function [myPreFft_noTimeYet]=readCircles2(t,c,myPreFft_noTimeYet) % redo for parfor loop.
                                                         % % does not take such a big struct.
[ntimesteps, rMin ,rMax, ss ,ncs ,plotOn ,azimuthalSet, azimuthalSetSize ,printStatus, lags]=constants();
%[M_mat]=initData2("myPreFft_noTimeYet");
  Bavg = zeros(ss,rMax+1);
  tic
      %sprintf('%s%d%s%d','*t = ',t,'**c=',c)
      M_mat = zeros(540,540); % streamwiseData
      if t==1
      %x_vec = zeros(1,540); % streamwiseData
      %y_vec = zeros(1,540); % streamwiseData
        x_vec = [];
      y_vec = [];

      end
      cc = sprintf( '%03d', c  ) ;
      tt = sprintf( '%04d', t  ) ;
      %cc = 0001;
      %tt = 0001 ;
      daPath = '/home/mi/podData/snaps3/';
      %daPath = '/home/mi/podData/snapsTest/';
      fileName = [ daPath 'snap_cs_' num2str(cc) '_ts_' num2str(tt) '.dat']; % t starts at 0.
      formatSpec = '%f';
      a=fopen(fileName, 'r');
      importedData = fscanf(a,formatSpec);
      for r=1:rMax  % r is azimuthal mode
        %sprintf('%s%d%s%d','*r = ',r);
      for p=1:540 % p is point
        pointOnLine_r = p + 540*r;
        M_mat(r,p)=importedData(pointOnLine_r,1); % 5 for streamwise entry of the data matrix % 1 for 1 col
      end %p
      end %r
%&---------------------------------------------------------------------
      for p=1:540 % p is point
          % myPreFft_noTimeYet(1).circle(4).dat(1,540)
        % eliminate 3x540 array, that is so expensive to carry around!
        %myPreFft(c).t(t).circle(p).dat(1,:)=    M(:,p);
        %myPreFft_noTimeYet(p).dat(1,:)=    M_mat(:,p); % this works
        myPreFft_noTimeYet(p).dat =    M_mat(:,p)';

      end %p
end % fc

function [myPreFft]=readCircles(t,c,myPreFft,performanceString)
[ntimesteps rMin ,rMax, ss ,ncs ,plotOn ,azimuthalSet, azimuthalSetSize ,printStatus, lags]=constants();
if performanceString=="efficient"
  Bavg = zeros(ss,rMax+1);
  tic
      %sprintf('%s%d%s%d','*t = ',t,'**c=',c)
      M = zeros(540,540); % streamwiseData
      if t==1
      %x_vec = zeros(1,540); % streamwiseData
      %y_vec = zeros(1,540); % streamwiseData
        x_vec = [];
      y_vec = [];

      end
      cc = sprintf( '%03d', c  ) ;
      tt = sprintf( '%04d', t  ) ;
      %cc = 0001;
      %tt = 0001 ;
      daPath = '/home/mi/podData/snaps3/';
      %daPath = '/home/mi/podData/snapsTest/';
      fileName = [ daPath 'snap_cs_' num2str(cc) '_ts_' num2str(tt) '.dat']; % t starts at 0.
      formatSpec = '%f';
      a=fopen(fileName, 'r');
      importedData = fscanf(a,formatSpec);
      for r=1:rMax  % r is azimuthal mode
        %sprintf('%s%d%s%d','*r = ',r);
      for p=1:540 % p is point
        pointOnLine_r = p + 540*r;
        M(r,p)=importedData(pointOnLine_r,1); % 5 for streamwise entry of the data matrix % 1 for 1 col
      end %p
      end %r
%---------------------------------------------------------------------
      for p=1:540 % p is point
        % eliminate 3x540 array, that is so expensive to carry around!
        myPreFft(c).t(t).circle(p).dat(1,:)=    M(:,p);
      end %p
      %figure(1);
      % save this struct as .mat file
      % then we can load this in as tall array.
      %
%---------------------------------------------------------------------
%---------------------------------------------------------------------
%---------------------------------------------------------------------
%    Non-efficient case;
%---------------------------------------------------------------------
%%---------------------------------------------------------------------


elseif performanceString=="drawCircles"
  Bavg = zeros(ss,rMax+1);
  tic
      %sprintf('%s%d%s%d','*t = ',t,'**c=',c)
      M = zeros(540,540); % streamwiseData
      if t==1
      x_vec = zeros(1,540); % streamwiseData
      y_vec = zeros(1,540); % streamwiseData
      end
      cc = sprintf( '%03d', c  ) ;
      tt = sprintf( '%04d', t  ) ;
      %cc=1;
      %tt=1;
      daPath = '/home/mi/podData/snaps3/';
      %daPath = '/home/mi/podData/snapsTest/';


      fileName = [ daPath 'snap_cs_' num2str(cc) '_ts_' num2str(tt) '.dat']; % t starts at 0.

      %formatSpec = '%f';
      formatSpec = '%f';
      a=fopen(fileName, 'r');
      importedData = fscanf(a,formatSpec);
      % just disabled importedData = importdata(fileName);
      for r=1:rMax  % r is azimuthal mode
        %sprintf('%s%d%s%d','*r = ',r);
      for p=1:540 % p is point
        pointOnLine_r = p + 540*r;
        M(r,p)=importedData(pointOnLine_r,1); % 5 for streamwise entry of the data matrix % 1 for 1 col
      end %p
      end %r
%---------------------------------------------------------------------
      for p=1:540 % p is point
        % eliminate 3x540 array, that is so expensive to carry around!
        myPreFft(c).t(t).circle(p).dat(3,:)=    M(:,p);
      end %p
      %figure(1);
      % save this struct as .mat file
      % then we can load this in as tall array.
      %
end % if
end %fcn


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555
%%% Redo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555
function [qq]=initData2(initStr) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
  [ntimesteps rMin ,rMax, ss ,ncs ,plotOn ,azimuthalSet, azimuthalSetSize ,printStatus, lags]=constants();
Ncs= [ncs,1];
Nts= [ntimesteps,1];
Naz = [azimuthalSetSize,1]; % azimuthal
Nps=[540,1];
  if printStatus=="on"
    %sprintf('%s%s', '* Initializing ', initStr)
  end
if initStr=="myPreFftDrawCircle" %redo
qq=struct('t', repmat({struct('circle', repmat({  struct('dat',repmat({zeros(3,1079)}, Nps))}, Nts)) }, Ncs));
elseif initStr=="myPreFft" %redo
qq=struct('t', repmat({struct('circle', repmat({  struct('dat',repmat({zeros(1,1079)}, Nps))}, Nts)) }, Ncs));
elseif initStr=="myPreFft_noTimeYet" %redo
%qq=struct('circle', repmat({  struct('dat',repmat({zeros(1,1079)}, Nps))}, Nts))
%qq=struct('dat', repmat({  struct('dat',repmat({zeros(1,1079)}, Nps))}, Nts))
qq=struct('dat', repmat({zeros(1,1079)}, [1,540]));
elseif initStr=="avgPreFft" %redo
qq=struct('circle', repmat({struct('dat',repmat({zeros(1,1079)}, [1,1079]))} , [1,ncs]));
elseif initStr=="qMinusQbar"
qq=struct('t', repmat({struct('circle', repmat({  struct('dat',repmat({zeros(1,1079)}, Nps))}, Nts)) }, Ncs));
elseif initStr=="radialXcorrStruct" % redo
qq=struct('crossSec', repmat({struct('azimuth', repmat({  struct('dat',repmat({zeros(1,540)}, Naz))}, Ncs)) }, Nts));
elseif initStr=="XcorrData"
%%%%%    XcorrData(t).crossSec(c).azimuth(m).dat = zeros(1,1079);
qq=struct('crossSec', repmat({struct('azimuth', repmat({  struct('dat',repmat({zeros(1,1079)}, Naz))}, Ncs)) }, Nts));
elseif initStr=="XcorrDonePreCsFft"
qq=struct('radial', repmat({struct('azimuth', repmat({  struct('dat',repmat({zeros(1,ncs)}, Naz))}, [1,1079])) }, Nts));
elseif initStr=="XcorrDonePostCsFft"
qq=struct('radial', repmat({struct('azimuth', repmat({  struct('dat',repmat({zeros(1,ncs)}, Naz))}, [1,1079])) }, Nts));
elseif initStr=="XcorrDoneCsFftDonePreAzimFft"
qq=struct('radial', repmat({struct('azimuth', repmat({  struct('dat',repmat({zeros(1,azimuthalSetSize)}, Ncs))}, [1,1079])) }, Nts));
elseif initStr=="XcorrDoneCsFftDonePostAzimFft"
qq=struct('crossSec', repmat({struct('azimuth', repmat({  struct('dat',repmat({zeros(1,azimuthalSetSize)}, Ncs))}, [1,1079])) }, Nts));
elseif initStr=="XcorrAzimDonePreTimeAvg"
qq=struct('radial', repmat({struct('crosssection', repmat({  struct('dat',repmat({zeros(1,ntimesteps)}, Ncs))}, [1,1079])) }, Naz));
elseif initStr=="XcorrAzimDonePostTimeAvg"
qq=struct('radial', repmat({struct('crosssection', repmat({  struct('dat',repmat({zeros(1,ntimesteps)}, Ncs))}, [1,1079])) }, Naz));
elseif initStr=="Skmr"
qq=struct('radial', repmat({struct('crosssection', repmat({  struct('dat',repmat({zeros(1,ntimesteps)}, Ncs))}, [1,1])) }, Naz));
elseif initStr=="streamwiseFft"
qq=struct('RadialCircle', repmat({struct('azimuth', repmat({  struct('dat',repmat({zeros(1,540)}, Naz))}, [1,540])) }, Nts));
elseif initStr=="SrrPrForFourierPre"
qq=struct('t', repmat({struct('azimuthal', repmat({  struct('dat',repmat({zeros(1,540)}, Naz))}, Nts)) }, Ncs));
elseif initStr=="SrrPrForFourierPost"
qq=struct('t', repmat({struct('azimuthal', repmat({  struct('dat',repmat({zeros(1,540)}, Naz))}, Nts)) }, Ncs));

end %if

end %fc

%%%%%  %iii initData here%%
%%%%%  function [qq]=initData(initStr)
%%%%%    [ntimesteps rMin ,rMax, ss ,ncs ,plotOn ,azimuthalSet, azimuthalSetSize ,printStatus, lags]=constants();
%%%%%
%%%%%    if printStatus=="on"
%%%%%      %sprintf('%s%s', '* Initializing ', initStr)
%%%%%    end
%%%%%
%%%%%  if initStr=="myPreFft"
%%%%%  % init myPrefft
%%%%%  for c=1:ncs%
%%%%%  for t=1:ntimesteps%
%%%%%  for p=1:540%
%%%%%    myPreFft(c).t(t).circle(p).dat= zeros(3,1079 );
%%%%%  end %p
%%%%%  end %t
%%%%%  end %c
%%%%%  % end init myPrefft
%%%%%  qq = myPreFft
%%%%%
%%%%%  elseif initStr=="avgPreFft"
%%%%%
%%%%%  for c=1:ncs%
%%%%%  for p=1:540%
%%%%%    avgPreFft(c).circle(p).dat= zeros(1,1079 );
%%%%%  end %p
%%%%%  end %c
%%%%%  qq = avgPreFft
%%%%%  %end % if
%%%%%
%%%%%  elseif initStr=="qMinusQbar"
%%%%%
%%%%%  % init myPrefft
%%%%%  for c=1:ncs% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%  for t=1:ntimesteps% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%  for p=1:540% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%    qMinusQbar(c).t(t).circle(p).dat= zeros(1,1079 );
%%%%%  end %p
%%%%%  end %t
%%%%%  end %c
%%%%%  % end init myPrefft
%%%%%  qq = qMinusQbar
%%%%%
%%%%%  elseif initStr=="streamwisePreFft"
%%%%%  for t=1:ntimesteps% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%  for p=1:540% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%  %for m=1:1079% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%  for m=1:azimuthalSetSize% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%    streamwiseStruct(t).RadialCircle(p).azimuth(m).dat = zeros(1,ncs);
%%%%%  end % m
%%%%%  end %p
%%%%%  end %t
%%%%%  qq = streamwiseStruct;
%%%%%  % end this if
%%%%%  elseif initStr=="streamwisePostFft"
%%%%%  for t=1:ntimesteps% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%  %for p=1:540% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%  for p=1:540% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%  %for m=1:1079% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%  for m=1:azimuthalSetSize% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%    streamwiseFft(t).RadialCircle(p).azimuth(m).dat = zeros(1,ncs);
%%%%%  end % m
%%%%%  end %p
%%%%%  end %t
%%%%%  qq = streamwiseFft;
%%%%%  elseif initStr=="Stilda_av"
%%%%%  for t=1:ntimesteps% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%  for p=1:azimuthalSetSize% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%    %Stilda_av(t).azimuth(p).dat=zeros(1079,1);
%%%%%    Stilda_av(t).azimuth(p).dat=zeros(1,540);
%%%%%  end %jj
%%%%%  end %tt
%%%%%  qq=Stilda_av;
%%%%%
%%%%%
%%%%%  elseif initStr=="Stilda"
%%%%%  for c=1:ncs% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%  for t=1:ntimesteps% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%  for p=1:azimuthalSetSize% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%    %Stilda(t).azimuth(p).dat=zeros(540,540);
%%%%%    %Stilda(t).azimuth(p).dat=zeros(540,1);
%%%%%    Stilda(c).time(t).azimuth(p).dat=zeros(1079,1);
%%%%%  end %jj
%%%%%  end %tt
%%%%%  end %cc
%%%%%  qq=Stilda;
%%%%%
%%%%%  elseif initStr=="Sij"
%%%%%  for t=1:ntimesteps% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%  for p=1:azimuthalSetSize% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%    %Stilda(t).azimuth(p).dat=zeros(540,540);
%%%%%    %Sij(t).azimuth(p).dat=zeros(540,1);
%%%%%    Sij(t).azimuth(p).dat=zeros(1079,1);
%%%%%  end %jj
%%%%%  end %tt
%%%%%  qq=Sij;
%%%%%
%%%%%  elseif initStr=="StildaMat"
%%%%%  for t=1:ntimesteps% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%  for c=1:ncs% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%  for p=1:azimuthalSetSize% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%    StildaMat(t).crossSec(c).azimuth(p).dat=zeros(540,540);
%%%%%  end %p
%%%%%  end %c
%%%%%  end%t
%%%%%  qq=StildaMat;
%%%%%
%%%%%  elseif initStr=="StildaVec"
%%%%%  for t=1:ntimesteps% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%  for c=1:ncs% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%  for p=1:azimuthalSetSize% do this. first pod mode = 1st col of eigenvalue = Lspod.
%%%%%    StildaVec(t).crossSec(c).azimuth(p).dat=zeros(1,540);
%%%%%  end %p
%%%%%  end %c
%%%%%  end%t
%%%%%  qq=StildaVec;
%%%%%
%%%%%
%%%%%  elseif initStr=="u_mk"
%%%%%  for c=1:ncs%
%%%%%  for t=1:ntimesteps%
%%%%%  for p=1:azimuthalSetSize%
%%%%%  for r=1:540
%%%%%    u_mk(c).time(t).RadialCircle(r).azimuth(p).dat=zeros(1079,1);
%%%%%  end %rr
%%%%%  end %jj
%%%%%  end %tt
%%%%%  end %cc
%%%%%  qq=u_mk;
%%%%%  elseif initStr=="Shellstrom2dot2"
%%%%%  for c=1:ncs%
%%%%%  for t=1:ntimesteps%
%%%%%  for p=1:azimuthalSetSize%
%%%%%  for r=1:540
%%%%%    u_mk(c).time(t).RadialCircle(r).azimuth(p).dat=zeros(1079,1);
%%%%%  end %rr
%%%%%  end %jj
%%%%%  end %tt
%%%%%  end %cc
%%%%%  qq=u_mk;
%%%%%
%%%%%
%%%%%  elseif initStr=="radialXcorrStruct"
%%%%%  for t=1:ntimesteps%
%%%%%  for c=1:ncs
%%%%%  for m=1:azimuthalSetSize%
%%%%%    radialXcorrStruct(t).crossSec(c).azimuth(m).dat = zeros(1,540);
%%%%%
%%%%%  end % m
%%%%%  end %p
%%%%%  end %t
%%%%%  qq = radialXcorrStruct;
%%%%%  % end this if
%%%%%
%%%%%
%%%%%  elseif initStr=="XcorrData"
%%%%%  for t=1:ntimesteps%
%%%%%  for c=1:ncs
%%%%%  for m=1:azimuthalSetSize%
%%%%%    XcorrData(t).crossSec(c).azimuth(m).dat = zeros(1,1079);
%%%%%  end % m
%%%%%  end %p
%%%%%  end %t
%%%%%  qq = XcorrData;
%%%%%
%%%%%
%%%%%  elseif initStr=="XcorrDonePreCsFft"
%%%%%  for t=1:ntimesteps%
%%%%%  for r=1:1079 % this dim from xcorr in radial
%%%%%  for m=1:azimuthalSetSize%
%%%%%    XcorrDonePreCsFft(t).crossSec(r).azimuth(m).dat = zeros(1,ncs);
%%%%%  end % m
%%%%%  end %p
%%%%%  end %t
%%%%%  qq = XcorrDonePreCsFft;
%%%%%
%%%%%  elseif initStr=="XcorrDonePostCsFft"
%%%%%  for t=1:ntimesteps%
%%%%%  for r=1:1079 % this dim from xcorr in radial
%%%%%  for m=1:azimuthalSetSize%
%%%%%    XcorrDonePostCsFft(t).crossSec(r).azimuth(m).dat = zeros(1,ncs);
%%%%%  end % m
%%%%%  end %p
%%%%%  end %t
%%%%%  qq = XcorrDonePostCsFft;
%%%%%  elseif initStr=="XcorrDoneCsFftDonePreAzimFft"
%%%%%    % prepare load azimuthal
%%%%%  for t=1:ntimesteps%
%%%%%  for r=1:1079 % this dim from xcorr in radial
%%%%%  %for m=1:azimuthalSetSize%
%%%%%  for c=1:ncs
%%%%%  XcorrDoneCsFftDonePreAzimFft(t).crossSec(r).azimuth(c).dat = zeros(1,azimuthalSetSize); % 28
%%%%%  end % m
%%%%%  end %p
%%%%%  end %t
%%%%%  qq = XcorrDoneCsFftDonePreAzimFft;
%%%%%  elseif initStr=="XcorrDoneCsFftDonePostAzimFft"
%%%%%    % prepare load azimuthal
%%%%%  for t=1:ntimesteps%
%%%%%  for r=1:1079 % this dim from xcorr in radial
%%%%%  %for m=1:azimuthalSetSize%
%%%%%  for c=1:ncs
%%%%%  % old XcorrDoneCsFftDonePostAzimFft(t).crossSec(r).azimuth(c).dat = zeros(1,azimuthalSetSize); % 28
%%%%%  XcorrDoneCsFftDonePostAzimFft(t).radial(r).crosssection(c).dat = zeros(1,azimuthalSetSize); % 28
%%%%%  %        XcorrDoneCsFftDonePreAzimFft(t).radial(r).crosssection(c).dat = vec;
%%%%%
%%%%%  end % m
%%%%%  end %p
%%%%%  end %t
%%%%%  qq = XcorrDoneCsFftDonePostAzimFft;
%%%%%
%%%%%
%%%%%  elseif initStr=="XcorrAzimDonePreTimeAvg"
%%%%%    % prepare load azimuthal
%%%%%  for m=1:azimuthalSetSize%
%%%%%  for r=1:1079 % this dim from xcorr in radial
%%%%%  %for m=1:azimuthalSetSize%
%%%%%  for c=1:ncs
%%%%%  % old XcorrDoneCsFftDonePostAzimFft(t).crossSec(r).azimuth(c).dat = zeros(1,azimuthalSetSize); % 28
%%%%%  XcorrAzimDonePreTimeAvg(m).radial(r).crosssection(c).dat = zeros(1,ntimesteps); % 28
%%%%%  %        XcorrDoneCsFftDonePreAzimFft(t).radial(r).crosssection(c).dat = vec;
%%%%%
%%%%%  end % m
%%%%%  end %p
%%%%%  end %t
%%%%%  qq = XcorrAzimDonePreTimeAvg;
%%%%%
%%%%%  elseif initStr=="XcorrAzimDonePreTimeAvg"
%%%%%    % prepare load azimuthal
%%%%%  for m=1:azimuthalSetSize%
%%%%%  for r=1:1079 % this dim from xcorr in radial
%%%%%  %for m=1:azimuthalSetSize%
%%%%%  for c=1:ncs
%%%%%  % old XcorrDoneCsFftDonePostAzimFft(t).crossSec(r).azimuth(c).dat = zeros(1,azimuthalSetSize); % 28
%%%%%  XcorrAzimDonePreTimeAvg(m).radial(r).crosssection(c).dat = zeros(1,ntimesteps); % 28
%%%%%  %        XcorrDoneCsFftDonePreAzimFft(t).radial(r).crosssection(c).dat = vec;
%%%%%
%%%%%  end % m
%%%%%  end %p
%%%%%  end %t
%%%%%  qq = XcorrAzimDonePreTimeAvg;
%%%%%
%%%%%  elseif initStr=="XcorrAzimDonePostTimeAvg"
%%%%%    % prepare load azimuthal
%%%%%  for m=1:azimuthalSetSize%
%%%%%  for r=1:1079 % this dim from xcorr in radial
%%%%%  %for m=1:azimuthalSetSize%
%%%%%  for c=1:ncs
%%%%%  % old XcorrDoneCsFftDonePostAzimFft(t).crossSec(r).azimuth(c).dat = zeros(1,azimuthalSetSize); % 28
%%%%%    % integral is a single number
%%%%%  XcorrAzimDonePostTimeAvg(m).radial(r).crosssection(c).dat = 0;
%%%%%  %        XcorrDoneCsFftDonePreAzimFft(t).radial(r).crosssection(c).dat = vec;
%%%%%
%%%%%  end % m
%%%%%  end %p
%%%%%  end %t
%%%%%  qq = XcorrAzimDonePostTimeAvg;
%%%%%
%%%%%  elseif initStr=="Skmr"
%%%%%    % prepare load azimuthal
%%%%%  for m=1:azimuthalSetSize%
%%%%%  for r=1:1079 % this dim from xcorr in radial
%%%%%  %for m=1:azimuthalSetSize%
%%%%%  for c=1:ncs
%%%%%  % old XcorrDoneCsFftDonePostAzimFft(t).crossSec(r).azimuth(c).dat = zeros(1,azimuthalSetSize); % 28
%%%%%    % integral is a single number
%%%%%  Skmr(m).crosssection(c).dat = 0;
%%%%%  %        XcorrDoneCsFftDonePreAzimFft(t).radial(r).crosssection(c).dat = vec;
%%%%%  end % m
%%%%%  end %p
%%%%%  end %t
%%%%%  qq = Skmr;
%%%%%
%%%%%
%%%%%  end % if
%%%%%  end %fc
%%%%%  %jjjj initData here%%

% takes in t,c
% avgPreFft (because this is void for the outer loop c )

function [avgPreFft]=findQbar(t,c,myPreFft,avgPreFft)
[ntimesteps rMin ,rMax, ss ,ncs ,plotOn ,azimuthalSet, azimuthalSetSize ,printStatus, lags]=constants();

     %for m=1:540 % m=1:540
     % if t < ntimesteps
     %   avgPreFft(c).circle(m).dat=avgPreFft(c).circle(m).dat + myPreFft(c).t(t).circle(m).dat(3,:); %
     % elseif t==ntimesteps
     %   avgPreFft(c).circle(m).dat=(avgPreFft(c).circle(m).dat + myPreFft(c).t(t).circle(m).dat(3,:))/ntimesteps; %
     % end % if

     for m=1:540 % m=1:540
      if t < ntimesteps
        avgPreFft(c).circle(m).dat=avgPreFft(c).circle(m).dat + myPreFft(c).t(t).circle(m).dat(1,:); %
        %avgPreFft(c).circle(m).dat=avgPreFft(c).circle(m).dat + myPreFft(c).t(t).circle(m).dat(:,1); %
      elseif t==ntimesteps
        avgPreFft(c).circle(m).dat=(avgPreFft(c).circle(m).dat + myPreFft(c).t(t).circle(m).dat(1,:))/ntimesteps; %
        %avgPreFft(c).circle(m).dat=(avgPreFft(c).circle(m).dat + myPreFft(c).t(t).circle(m).dat(:,1))/ntimesteps; %
      end % if

      end % m % from oben.
%      toc
end % fc


function  [ qMinusQbar]=FindqMinusQbar(t,c,myPreFft,avgPreFft,qMinusQbar,performanceString)
  % find difference AND take fft.
[ntimesteps rMin ,rMax, ss ,ncs ,plotOn ,azimuthalSet, azimuthalSetSize ,printStatus, lags]=constants();

fftMatQminusQbar=[];
if performanceString=="drawCircles"

 % Take FFT of Difference q - \bar{q}
     %  - the post-fft streamwise data is stored in fftMat.
for m=1:540 % m=1:540
  % find the difference, q-bar{q}, each azimuth-circle
%ad=myPreFft(c).t(t).circle(m).dat(3,:) - avgPreFft(c).circle(m).dat()  ; % 3 corresponds ot the streamwise data; 1 2 and are the x coordinates!
% this is yielding zeros for the last timestep ..., traced it.
qMinusQbar(c).t(t).circle(m).dat = myPreFft(c).t(t).circle(m).dat(3,:) - avgPreFft(c).circle(m).dat()  ; % 3 corresponds ot the streamwise data; 1 2 and are the x coordinates!
%sprintf('%s%d','Start windowing *m = ',m);
%qMinusQbar= [fftMatQminusQbar;ad]; % fftMat is r by 1079 Matrix
end %m
%fftTimeQminusQbar(t).dat = fftMatQminusQbar;

elseif performanceString=="efficient"

 % Take FFT of Difference q - \bar{q}
     %  - the post-fft streamwise data is stored in fftMat.
for m=1:540 % m=1:540
  % find the difference, q-bar{q}, each azimuth-circle
%ad=myPreFft(c).t(t).circle(m).dat(3,:) - avgPreFft(c).circle(m).dat()  ; % 3 corresponds ot the streamwise data; 1 2 and are the x coordinates!
% this is yielding zeros for the last timestep ..., traced it.
qMinusQbar(c).t(t).circle(m).dat = myPreFft(c).t(t).circle(m).dat(1,:) - avgPreFft(c).circle(m).dat()  ; % 3 corresponds ot the streamwise data; 1 2 and are the x coordinates!
%sprintf('%s%d','Start windowing *m = ',m);
%qMinusQbar= [fftMatQminusQbar;ad]; % fftMat is r by 1079 Matrix
end %m
%fftTimeQminusQbar(t).dat = fftMatQminusQbar;


end % if
end %fcn



function [qMinusQbar ]= readDataAndFindVeloFluctuation()
[ntimesteps rMin ,rMax, ss ,ncs ,plotOn ,azimuthalSet, azimuthalSetSize ,printStatus, lags]=constants();
%sprintf('%s',"initData..")
  %[myPreFft]=initData2("myPreFftDrawCircle"); % for drawing circles
  [myPreFft]=initData2("myPreFft");
  [avgPreFft]=initData2("avgPreFft"); % initialize avg struct
  [qMinusQbar]=initData2("qMinusQbar"); % initialize avg struct

%sprintf('%s','*t = ')
%myList = linspace(rMin,rMax,rMax - rMin + 1);
%myListLength = length( myList) ;
%    for c = 1:ncs  % crosssection
%            preFft_avg(c).dat = zeros(myListLength,ss);
%    end
parfor c = 1:ncs  % crosssection

for t = 1:ntimesteps % time
  M_mat=zeros(540,540);
bigCLoopTic = tic;
[myPreFft_noTimeYet]=initData2("myPreFft_noTimeYet");
%myPreFft_noTimeYet(1).circle(7).dat
myPreFft(c).t(t).circle=readCircles2(t,c,myPreFft_noTimeYet);
end %c
end %t
sprintf('%s','read circle and findQbar ')

% compute average for each cross section.
for c = 1:ncs  % crosssection
for t = 1:ntimesteps % time
[avgPreFft]=findQbar(t,c,myPreFft,avgPreFft); % find temporal average.
end %t
end %c
%sprintf('%s','initialize QminusQbar for lot of timestep.')

%initTic = tic;

%findqminusqbarTic = tic;
%sprintf('%s','findqminusqbar')
for c = 1:ncs  % crosssection
for t = 1:ntimesteps % time
  [ qMinusQbar ]=FindqMinusQbar(t,c,myPreFft,avgPreFft,qMinusQbar,"efficient");
end %t
end %c
%elapse = ["minutes elapsed" num2str(toc(findqminusqbarTic)/60)]

end % f

%function [vecTutkunEq8]=doTutkinEq8(t,c,fftTimeQminusQbar)
%  % find difference AND take fft.
%[ntimesteps rMin ,rMax, ss ,ncs ,plotOn ,azimuthalSet, azimuthalSetSize ,printStatus, lags]=constants();
%
%% initialize vecTut
%for tt=1:ntimesteps
%  vecTutkunEq8(tt).dat = zeros(540,1079);
%  end % tt
%
%for ii=1:540
%for jj=1:1079
%for tt=1:ntimesteps
%  timeVecPreIntegrate(tt) = fftTimeQminusQbar(tt).dat(ii,jj);
%  end % tt
%  ad =  fft(timeVecPreIntegrate);
%
%for ff=1:ntimesteps %% define uHat = uHat(r,theta,f)
%  vecTutkunEq8(ff).dat(ii,jj) =  ad(ff);
%end % tt
%  end % ii
%  end % jj
%toc
%end %fc

function [qq]=fftStreamwise(qMinusQbar, qq, doStr)
  % find difference AND take fft.
[ntimesteps rMin ,rMax, ss ,ncs ,plotOn ,azimuthalSet, azimuthalSetSize ,printStatus, lags]=constants();

if doStr=="populate"
parfor t=1:ntimesteps% do this. first pod mode = 1st col of eigenvalue = Lspod.
for p=1:540% do this. first pod mode = 1st col of eigenvalue = Lspod.
for jj=1:azimuthalSetSize % just get every 50th azimuthal angle
  csVec = [];
for c = 1:ncs  % crosssection
  jjIndex = azimuthalSet(jj);
  ad =  qMinusQbar(c).t(t).circle(p).dat(1,jjIndex);
  csVec = [csVec,ad];
end % c
qq(t).RadialCircle(p).azimuth(jj).dat = csVec;
end %jj
end %p
end %t
%qq = streamwiseStruct;


elseif doStr=="populateXcorr"
ad=0;
for t=1:ntimesteps% do this. first pod mode = 1st col of eigenvalue = Lspod.
    radVec = zeros(1,540);
for c = 1:ncs  % crosssection
for jj=1:azimuthalSetSize - 1 % may16, i had to subtract 1.. % just get every 50th azimuthal angle
%radVec = [];
for p=1:540%
  % note, i had to subtract one.. (may 16..), jjIndex = azimuthalSet(jj) ;

  jjIndex = azimuthalSet(jj) ;
  ad =  qMinusQbar(c).t(t).circle(p).dat(1,jjIndex);
  %radVec = [radVec,ad];
  radVec(p) = ad;

end % c
%radialXcorrStruct(t).RadialCircle(p).azimuth(jj).dat = radVec;
%wasradialXcorrStruct(t).crossSec(c).azimuth(jj).dat = radVec;
%qq(t).t(c).crossSec(jj).azimuth = radVec;
qq(t).crossSec(c).azimuth(jj).dat = radVec;


%shouldlooklike 
%radialXcorrStruct(3).t(2).crossSec(271).azimuth  
end %jj
end %p
end %t
%qq = streamwiseStruct; % eg radialXcorrStruct



elseif doStr=="fftStreamwise"
[streamwiseFft]=initData2("streamwiseFft"); % initialize avg struct

%sprintf('%s','calculating streamwise fft')

parfor t=1:ntimesteps% do this. first pod mode = 1st col of eigenvalue = Lspod.
for p=1:540% do this. first pod mode = 1st col of eigenvalue = Lspod.
for jj=1:azimuthalSetSize % just get every 50th azimuthal angle
  ad = streamwiseStruct(t).RadialCircle(p).azimuth(jj).dat;
ae = fft(ad);
streamwiseFft(t).RadialCircle(p).azimuth(jj).dat = ae;

end %j
end % p
end % t
qq=streamwiseFft;

end
%vecTutkunEq8 = [];
end %fc

% form cross-spectra eq 9
%function [Stilda]=doTutkinEq9(t,c,vecTutkunEq8)
%  % find difference AND take fft.
%[ntimesteps rMin ,rMax, ss ,ncs ,plotOn ,azimuthalSet, azimuthalSetSize ,printStatus, lags]=constants();
%% initilaize Stilda. this is a struct organized such that
%for jj=azimuthalSet
%for tt=1:ntimesteps
%  Stilda(tt).azimuth(jj).dat =zeros(540,540);
%end %tt
%end %jj
%%=====================
%% Eq 9, calc Stilda.
%%for jj=1:1079 % azimuth
%for tt=1:ntimesteps
%for jj= azimuthalSet
%  %sprintf('%s%d%s%d','*L317 Stilda-calc, *tt = ',tt,'jj=',jj);
%for ii=1:540
%for iiPrime=1:540
%  ad = vecTutkunEq8(tt).dat(ii,jj);
%  af = ctranspose(vecTutkunEq8(tt).dat(iiPrime,jj));
%  pd = ad*af;
%  Stilda(tt).azimuth(jj).dat(ii,iiPrime) = pd;
%  zRadius = vecTutkunEq8(tt).dat(:,jj);
%  zAzimuth = vecTutkunEq8(tt).dat(ii,:);
%  zCorr = xcorr(zRadius,zAzimuth);
%
%end %iiPrime
%end %ii
%
%end %tt
%end %jj
%end %fc






% form cross-spectra eq 9
function [XcorrData,lags]=DoXcorrRadial(radialXcorrStruct,XcorrData,isGraph)
  % find difference AND take fft.
[ntimesteps rMin ,rMax, ss ,ncs ,plotOn ,azimuthalSet, azimuthalSetSize ,printStatus, lags]=constants();
% initilaize Stilda. this is a struct organized such that
parfor tt=1:ntimesteps
for c = 1:ncs  % local loop
for jj= 1:azimuthalSetSize
  %sprintf('%s%d%s%d','*L317 Stilda-calc, *tt = ',tt,'jj=',jj);
  aa= radialXcorrStruct(tt).crossSec(c).azimuth(jj).dat;

  [ab,lags] = xcorr(aa,"normalized");
  XcorrData(tt).crossSec(c).azimuth(jj).dat = ab;
  if isGraph=="graph"
  hold on;
  plot(lags,ab);
  elseif isGraph=="graphPause"
  hold on;
  plot(lags,ab);
  pause(1)
  else
  end

end %jj
end %c
end %tt

end %fc

function [structPost]=DoFftXcorr(structPre,structPost,setupVecOrRun,fftDir,isGraph,lags)
[ntimesteps rMin ,rMax, ss ,ncs ,plotOn ,azimuthalSet, azimuthalSetSize ,printStatus, lags]=constants();
if setupVecOrRun=="setupVec"
    if fftDir=="xDir" %setup
        parfor t=1:ntimesteps%
        vec = zeros(1,ncs);

        for r=1:1079 % size xcorr
        for m=1:azimuthalSetSize%
        for c=1:ncs
          %a= XcorrData(t).crossSec(c).azimuth(m).dat(1,r);
          a= structPre(t).crossSec(c).azimuth(m).dat(1,r);
          %vec = [a,vec];
          vec(c) = a;

        end %c
        structPost(t).radial(r).azimuth(m).dat =vec;
        end %m
        end %r
        end %t
        %structPost = XcorrDonePreCsFft;
    elseif fftDir=="azimDir" % set up
        parfor t=1:ntimesteps%
        vec = zeros(1,azimuthalSetSize);

        for r=1:1079 % size xcorr
        %for m=1:azimuthalSetSize%
        for c=1:ncs
          %vec=[];
        for m=1:azimuthalSetSize%
          %a=  XcorrDonePostCsFft(t).crossSec(r).azimuth(m).dat = zeros(1,ncs);
          a=  structPre(t).radial(r).azimuth(m).dat(1,c);
          %a= structPre(t).crossSec(c).azimuth(m).dat(1,r);
          %vec = [a,vec];
          vec(m) = a;

        end %c
        %XcorrDonePreCsFft(t).crossSec(r).azimuth(m).dat =vec;
        %XcorrDoneCsFftDonePreAzimFft(t).crossSec(r).azimuth(c).dat = vec;
        structPost(t).radial(r).azimuth(c).dat = vec;
%XcorrDoneCsFftDonePreAzimFft(t).crossSec(r).azimuth(c).dat = zeros(1,azimuthalSetSize); % 28
        end %m
        end %r
        end %t
        %structPost = XcorrDonePreCsFft;
        %structPost = XcorrDoneCsFftDonePreAzimFft;
 elseif fftDir=="timeDir" % set up time integral
        % take the .dat(azimuthalData) and arrange in .dat(timedata)..
        for r=1:1079 % size xcorr
        vec = zeros(1,ntimesteps);

        for c=1:ncs
        for m=1:azimuthalSetSize%
          %vec=[];
        for t=1:ntimesteps%

          a= structPre(t).crossSec(r).azimuth(c).dat(1,m);

          vec(t) = a;

          end % for
          structPost(m).radial(r).crosssection(c).dat = vec; % the problem
          end % m
          end %c
          end %r
 elseif fftDir=="Skmr" % set up Skmr
        % take the .dat(azimuthalData) and arrange in .dat(timedata)..
        %for m=1:azimuthalSetSize%
        for c=1:ncs
        vec = zeros(1,1079);

        for m=1:azimuthalSetSize%
          %vec=[];
        for r=1:1079 % size xcorr
         % a=  structPre(t).radial(r).crosssection(c).dat(1,m);
          a=structPre(m).radial(r).crosssection(c).dat;
          %vec = [a,vec];
          vec(r) = a;

          end % for
        structPost(m).crosssection(c).dat = vec;
          end % m
          end %c
        %structPost = Skmr;

elseif fftDir=="SrrPrForFourier" % set up Skmr
        % take the .dat(azimuthalData) and arrange in .dat(timedata)..
        %for m=1:azimuthalSetSize%
        for t=1:ntimesteps
        vec = zeros(1,1079);

        %for r=1:1079 % pre has this form
        for m=1:azimuthalSetSize%
        for c=1:ncs% size xcorr
        %vec=[];
        for r=1:1079 % pre has this form
          a=structPre(t).radial(r).azimuth(m).dat(1,c);
          %vec = [a,vec];
          vec(r) = a;

          end % r
          % structPost(1).t(1).azimuthal(1).dat  
        structPost(c).t(t).azimuthal(m).dat = vec;
          end % c
          end % m
          end % t
       % structPost = SkSrrPrForFouriermr;
    %end % end setups.

    end % end setups.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif setupVecOrRun=="runFft"
    if fftDir=="xDir" % run
    % structPre is
        parfor t=1:ntimesteps%
        for r=1:1079 % size xcorr
        for m=1:azimuthalSetSize%
          aa=   structPre(t).radial(r).azimuth(m).dat;
          bb= fft(aa);
          structPost(t).radial(r).azimuth(m).dat = bb;
        % take fft
        end %m
        end %r
        end %t
    elseif fftDir=="azimDirCaseA" % run % Case A: just call fft
        parfor t=1:ntimesteps%
        for r=1:1079 % size xcorr
        %for m=1:azimuthalSetSize%
        for c=1:ncs
            %structPre(4).radial(1079).azimuth(2).dat  
          aa = structPre(t).radial(r).azimuth(c).dat;
          % take fft
          bb= fft(aa);
          %structPost(4).crossSec(1079).azimuth(2).dat  
          structPost(t).crossSec(r).azimuth(c).dat=bb;
        end %m
        end %r
        end %t

        elseif fftDir=="SrrPrForFourier" % RUN -> fourier series
          %deltaTheta = 1.32841328413    % 360/271
          deltaTheta = 1/271;
        % calculates the fourier Series
        % NOT using any Dft, although that can be done by using folding - however direct calculation is done here.
        % structPost(c).t(t).azimuthal(m).dat = vec;
        for t=1:ntimesteps
        %for r=1:1079 % pre has this form
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
          b= b +a*exp(j*sum_m*m)*deltaTheta;
        end % sum
          structPost(c).t(t).azimuthal(m).dat = b; % load S(r,r'; k,m) init memory for all r
          %sprintf('%s','pause');

        end %m
        end %c
        end %t
        %sprintf('%s','pause');

%


    elseif fftDir=="timeDir" % run
        % take the .dat(azimuthalData) and arrange in .dat(timedata)..
        for r=1:1079 % size xcorr
        for c=1:ncs
        for m=1:azimuthalSetSize%
        aa = structPre(m).radial(r).crosssection(c).dat;
        ab = trapz(aa);
        structPost(m).radial(r).crosssection(c).dat = ab;
        end %m
        end %c
        end %r
    end % if direction
end % if setup
end
%llllll

function plotSkmr(plotObject,isGraph)
[ntimesteps rMin ,rMax, ss ,ncs ,plotOn ,azimuthalSet, azimuthalSetSize ,printStatus, lags]=constants();
if isGraph=="graph"
  f=figure('Renderer', 'painters', 'Position', [10 10 1900 900])

  A=linspace(0,1,541)
  xlabel('radius $\frac{r}{R}$','interpreter','latex')
  ylabel("$S_{ii}(k,m;r,r')$",'interpreter','latex')  
  %xlabel('radius r');
  %ylabel('S');
  hold on;
  title("Time-averaged Correlation $S_{ii}(k,m;r,r')$",'FontName','capitana','FontSize',12,'interpreter','latex')

      %for t=1:ntimesteps
      for m=2:11
      for c=1:ncs
      labelStr = ['(m,k)=(', num2str(azimuthalSet(m)),',',num2str(c),')'];
      pp=plot(A,real(plotObject(m).crosssection(c).dat((end-1)/2:end) )/ntimesteps,"DisplayName",labelStr)
      %pp=plot(A,real(plotObject(c).t(t).azimuthal(m).dat((end-1)/2:end) )/ntimesteps,"DisplayName",labelStr)
                    %SrrPrForFourierPost(c).t(t).azimuthal(m).dat
      if mod(c,4)==0
        pp.LineStyle='-';
      elseif mod(c,4)==1
        pp.LineStyle='--';
      elseif mod(c,4)==2
        pp.LineStyle=':';
      elseif mod(c,4)==3
        pp.LineStyle='-.';
      end
      hold on;
      %pause(1);
      end
      end
     % end %t
      %legend( );
      %saveas(gcf,'Sij.png','res')
      %sprintf('%s','pause');
elseif isGraph=="graphPause"
  hold on;
    for m=2:38
    for c=1:ncs
    plot(real(plotObject(m).crosssection(c).dat(end/2:end) )/ntimesteps)
    hold on;
    pause(1);
    end
    end
    %sprintf('%s','pause');
      pause(1)
else
end % if
end % f


%%% calculate spatial correlation matrix
%%% No spectral estimation or smoothing version
%%% See references on Fourier Methods
%%% eg Chatfield, Proakis and Monolakis, Bloomfield
%%% See also  https://www.fil.ion.ucl.ac.uk/~wpenny/course/course.pdf # chapter 7
%%% on the equivalence of this function call to using eg xcorr
%function [Stilda]=doTutkinEq9innerProduct(t,c,vecTutkunEq8,Stilda,deltaTheta)
%  % find difference AND take fft.
%[ntimesteps rMin ,rMax, ss ,ncs ,plotOn ,azimuthalSet, azimuthalSetSize ,printStatus, lags]=constants();
%  azimuthalSetMinusOne = azimuthalSet;
%  azimuthalSetMinusOne(end) =[]; % chop off end element 1079. Ends at 1050
%  azimuthCounter=1;
%jj=1;
%if deltaTheta == 1
%  deltaThetaFix = 0;
%else
%  deltaThetaFix = deltaTheta;
%end
%for ii=1:540
%  vvv1(ii) = vecTutkunEq8(t).RadialCircle(ii).azimuth(jj).dat(1,c);
%  vvv2(ii) = vecTutkunEq8(t).RadialCircle(ii).azimuth(jj+deltaThetaFix).dat(1,c);
%end % ii
%aa=vvv1.*conj(vvv2)
%hold on;
%plot(aa)
%%for ii=1:2*540-1
%for ii=1:540
%Stilda(c).time(t).azimuth(deltaTheta).dat(ii,1)=aa(ii);
%%end %jj
%end %ii
%%
%
%end %f

%function [Shellstrom2dot2]=doHellstromEq2dot2(t,k,deltaTheta,u_mk)
%  % find difference AND take fft.
%[ntimesteps rMin ,rMax, ss ,ncs ,plotOn ,azimuthalSet, azimuthalSetSize ,printStatus, lags]=constants();
%  azimuthalSetMinusOne = azimuthalSet;
%  azimuthalSetMinusOne(end) =[]; % chop off end element 1079. Ends at 1050
%  azimuthCounter=1;
%jj=1;
%if deltaTheta == 1
%  deltaThetaFix = 0;
%else
%  deltaThetaFix = deltaTheta;
%end
%for ii=1:540
%  %vvv1(ii) = u_mk(k).time(t).RadialCircle(ii).azimuth(jj).dat(1,k);
%  vvv1(ii) = u_mk(k).time(t).RadialCircle(ii).azimuth(jj).dat(1,1);
%  %vvv2(ii) = u_mk(k).time(t).RadialCircle(ii).azimuth(jj+deltaThetaFix).dat(1,k);
%end % ii
%aa=vvv1.*conj(vvv1)
%%hold on;
%%plot(aa)
%%for ii=1:2*540-1
%for ii=1:540
%Shellstrom2dot2(k).time(t).azimuth(deltaTheta).dat(ii,1)=aa(ii);
%%end %jj
%end %ii
%%
%
%end %f

% * needs t,c loop
% * make this operate on different thetas!
%% Read in fft-x (cross-section dir) transformed data,
%% compute correlation tensor
%function [Stilda]=doTutkinEq9ReduxThree(t,c,vecTutkunEq8,Stilda,deltaTheta)
%  % find difference AND take fft.
%[ntimesteps rMin ,rMax, ss ,ncs ,plotOn ,azimuthalSet, azimuthalSetSize ,printStatus, lags]=constants();
%  azimuthalSetMinusOne = azimuthalSet;
%  azimuthalSetMinusOne(end) =[]; % chop off end element 1079. Ends at 1050
%  azimuthCounter=1;
%%for jj=1:azimuthalSetSize - 1 % this is Delta s.
%jj=1;
%if deltaTheta == 1
%  deltaThetaFix = 0;
%else
%  deltaThetaFix = deltaTheta;
%end
%% form StildaMat. Its form is a matrix -> r and r'. It varies with parameter DeltaTheta.
%cc=zeros(1,540);
%for i=1:540 % r
%aa=vecTutkunEq8(t).RadialCircle(i).azimuth(1,1).dat(c); % not deltaTheta for the first
%bb=vecTutkunEq8(t).RadialCircle(i).azimuth(1,deltaTheta).dat(c);
%cc(i)= aa*conj(bb);
%end % i
%Stilda(t).crossSec(c).azimuth(deltaTheta).dat =  cc;
%%sprintf('%s','doTutkinEq10');
%end %fc
%
%function [Sij]=doTutkinEq10Redux(t,c,Stilda_av,Sij, deltaTheta)
%[ntimesteps rMin ,rMax, ss ,ncs ,plotOn ,azimuthalSet, azimuthalSetSize ,printStatus, lags]=constants();
%%blocksize=size(Stilda,1);
%rad=deltaTheta/180*pi;
%azimuthalSetMinusOne = azimuthalSet;
%azimuthalSetMinusOne(end) =[]; % chop off end element 1079. Ends at 1050
%NtwiceDelta = 2*deltaTheta;
%sumSij=zeros(1,540);
%
%% sum over m=0:N , where N is twice the number of angular separation. See comment in Tutkin.
%for mm=1:(azimuthalSetSize-1)*2 %
%        %        S_{ij} (r ,r' , \deltaTheta) * exp ...
%        sumSij=Stilda_av(t).azimuth(deltaTheta).dat*exp(-1i*mm*rad)*deltaTheta/180*pi+sumSij;
%end %for mm % sum
%    Sij(t).azimuth(deltaTheta).dat=sumSij/(2*pi); % rethink maybe this step..
%%end % ii
%end %fc
%
%
%function [u_mk]=doTutkinEq10Redux_u(t,c,r,streamwiseFft,u_mk, deltaTheta)
%[ntimesteps rMin ,rMax, ss ,ncs ,plotOn ,azimuthalSet, azimuthalSetSize ,printStatus, lags]=constants();
%%blocksize=size(Stilda,1);
%rad=deltaTheta/180*pi;
%azimuthalSetMinusOne = azimuthalSet;
%azimuthalSetMinusOne(end) =[]; % chop off end element 1079. Ends at 1050
%NtwiceDelta = 2*deltaTheta;
%sumSij=zeros(1079,1);
%
%% sum over m=0:N , where N is twice the number of angular separation. See comment in Tutkin.
%for mm=1:(azimuthalSetSize-1)*2 %
%        %        S_{ij} (r ,r' , \deltaTheta) * exp ...
%        %sumSij=Stilda_av(t).azimuth(deltaTheta).dat*exp(-1i*mm*rad)*deltaTheta/180*pi+sumSij;
%        %sumSij=streamwiseFft(t).azimuth(deltaTheta).dat(1,c)*exp(-1i*mm*rad)*deltaTheta/180*pi+sumSij;
%        sumSij=streamwiseFft(t).RadialCircle(r).azimuth(deltaTheta).dat(1,c)*exp(-1i*mm*rad)*deltaTheta/180*pi+sumSij;
%end %for mm % sum
%    %Sij_u(t).azimuth(deltaTheta).dat=sumSij/(2*pi); % rethink maybe this step..
%     u_mk(c).time(t).RadialCircle(r).azimuth(deltaTheta).dat =sumSij/(2*pi); % rethink maybe this step..
%
%%end % ii
%end %fc
%
%
%
%
%
%%function [Stilda]=correlat(t,c,vecTutkunEq8,Stilda,deltaTheta)
%function [Stilda]=correlateVecs(t,c,vvv1,vvv2)
%  % find difference AND take fft.
%[ntimesteps rMin ,rMax, ss ,ncs ,plotOn ,azimuthalSet, azimuthalSetSize ,printStatus, lags]=constants();
%sigma2 = var(vvv1)*var(vvv2);
%% Compute / plot correlation coefficient
%%n = 1; R_E(n) = mean(u.^2)/sigma2; % Initialize
%%n = 1; R_E(n) = mean(vvv1.*vvv2)/sigma2; % Initialize
%%n = 1; R_E(n) = mean(vvv1.^2)/sigma2; % Initialize
%n = 1; R_E(n) =  mean(vvv1.^2)
%
%while R_E(n) > 0 % Compute while positive
%    bb = vvv1(1:end-n+1).*vvv2(n:end);
%    R_E(n) = mean(vvv1(1:end-n+1).*vvv2(n:end))/sigma2;
%    hold on
%    plot(n,R_E(n),'k.')
%    plot(n,bc(n),'r.')
%    n = n + 1;
%end % while
%
%end % fc
%
%
%
%
%%===================================
%% bpod
%%
%% Classic POD
%function hellstrom2016(Sij)
%  % load constantsPOD
%  [ntimesteps M rMax radMax ncs plotOn azimuthalSet azimuthalSetSize printStatus lags]=constantsPOD();
%
%  % initialize data
%[F Fi eigval_spod lambdaSqrt PhiSave isOrthog ]=initDataPOD();
%struct('Phi',repmat({zeros(radMax,1)},rMax,1));
%struct('PhiSave',repmat({zeros(radMax,1)},rMax,1));
%struct('PhiNorm',repmat({zeros(radMax,1)},rMax,1));
%%%%%% init
%
%PODtype="c"; % c for classical, s for snapshot
%
%if PODtype=="c" % run pod as classical type POD.
%% in a r,c loop, read fft data
%% for all timesteps and 540 points,
%%for r=[1,5,10,15]  % azimuthal loop
%
%for r=[1,2,3,4]  % azimuthal loop
%for n= 1:rMax % pod modes called rMax. <- rename rMax, misleading.
%PS(r).dat(n).dat = zeros(540,1);
%end % n
%end % r
%
%for r=[1,2,3,4]  % azimuthal loop
%for c= 1:ncs % crosssection loop
%
%
%tic
%%sprintf('%s%d%s%d','***Azimuth and crossSec: ',r,',',c)
%
%% store read in azimutal data vec u.Nb for fixed azimuthal mode r and crosssection c.
%% u is the 540xntimesteps dimension.
%%[u]=readAzimuthalMode(r,c);
%%[u]=smallTestAzimuthalMode(r,c);
%%u = Sij(r);
%
%% Calculate the *integrand of SBar* described in Hellstrom16.Eq(3.5)
%%[tim]=SBarIntegrandClassic(u);
%% Caclulate now, the integral in Eq.3.5
%
%% take tim to be Sij(r):
%%tim = Sij(r).azimuth;
%%tim = Sij(r).azimuth;
%
%%[intIJ]=SBarIntegralClassic(tim);
%%[intIJ]=SBarIntegralClassic(Sij);
%%[intIJ]=SBarIntegralClassic(Sij);
%[Bij]=CitrinitiFindBij(Sij)
%
%
%% Calulate eigenvlaue of Eq.3.4
%[eigVec, eigVal]=eigCalc(intIJ,PODtype);
%
%% and normalize by r^{-/2} in Eq.3.6
%[PsiR]=rMinusHalfClassic(eigVec);
%
%
%% find the max amplitude of the eig. If negative, flip it.
%[PhiSave]=MakeEigVecPositivePeak(PsiR,PhiSave,c);
%
%
%
%% check if normal, if not, normalize.
%[aa bb dd PhiSave]=checkOrthonormal(PhiSave,r,c); % error
%%[aa bb dd Phi]=checkOrthonormal(Phi,r,c); % error
%
%
%%Error in hellstrom2016>checkOrthonormal (line 462)
%%   sum = sum + jj*ctranspose(Phi(1).dat(jj,1))*Phi(1).dat(jj,1);
%%[aa bb dd PhiSave]=checkOrthonormal(PsiR,r,c);
%isOrthog(r).cs(c).Orthog(1).dat = aa ;% Phi1 check normal
%isOrthog(r).cs(c).Orthog(2).dat = bb ;% Phi2 check normal
%% check if the POD modes Phi1 and Phi2 orthogonal
%isOrthog(r).cs(c).Orthog(3).dat = dd ;% Phi1,Phi2 Orthogonal
%
%% plot
%for jj=1:rMax %
%myPlots( PhiSave(1).dat,PhiSave(2).dat,c); % not averaged?
%%figure(55);
%end
%for nn=1:rMax
%for jjj=1:radMax
%%PS(r).cs(c).dat(nn).dat(jjj,1) = PS(r).cs(c).dat(nn).dat(jjj,1) + PhiSave(r).dat(jjj,1);
%PS(r).dat(nn).dat(jjj,1) = PS(r).dat(nn).dat(jjj,1) + PhiSave(nn).dat(jjj,1);
%end % jjj
%end % nn
%
%
%%sprintf('%s%d%s%d','***Ending mode and crosssection: ',r,',',c)
%toc
%end % c
%%myPlots(PS(r).dat(1).dat,PS(r).dat(2).dat,c);
%end % r
%%end % if % classical POD
%
%%sprintf('%s','***done')
%
%%=======================================================================
%
%% snapshot POD, exactly as described in hellstrom and schmid 2017
%%
%elseif PODtype=="s" % run POD as snapshot type
%% in a r,c loop, read fft data
%% for all timesteps and 540 points,
%  %sprintf('%s','hi');
%
%for r=[1,5,10,15]  % azimuthal loop
%for c= 1:ncs % crosssection loop
%tic
%%sprintf('%s%d%s%d','***Azimuth and crossSec: ',r,',',c)
%% store read in azimutal data vec u.Nb for fixed azimuthal mode r and crosssection c.
%% u is the 540xntimesteps dimension.
%[u]=readAzimuthalMode(r,c);
%%
%% Calculate the *integrand of SBar* described in Royal.Eq(2.4.b)
%[tim]=RIntegrandSnap(u);
%
%% Caclulate now, the integral in Eq.2.4.b to give R.
%[intIJ]=RIntegralSnap(tim);
%
%% Calulate eigenvlaue of Royal.2.4. Use uniform weight w_i=1 approximation
%% -> nb can replace this with eg trapazoidal but would need to be manual calculation maybe.
%[eigVec, eigVal]=eigCalc(intIJ,PODtype);
%
%% calculate the POD mode Phi, Royal.(Eq.2.5), by
%% doing the integration int u * ctranspose(eigVec_i),
%% then dividing this by lambda_i
%Phi=eq2dot4Snap(u,eigVec,eigVal);
%toc(bigCLoopTic)
%
%end % c
%end % r
%end % if % snapshot
%
%
%
%
%
%end % hellstrom2016
%
%% common functions
%
%function myPlots(Phi1,Phi2,c)
%[ntimesteps M rMax radMax ncs plotOn azimuthalSet azimuthalSetSize printStatus lags]=constantsPOD();
%
%subplot(2,2,1);
%hold on;
%%plot(real(PhiSave(1).dat(:,1)/c));
%plot(real(Phi1)/c);
%title('$Re\phi_1$','interpreter','latex')
%legend('Azim1','Azim5','Azim10','Azim15')
%subplot(2,2,2);
%hold on;
%%plot(imag(PhiSave(1).dat(:,1)/c));
%plot(imag(Phi1)/c);
%title('$Im\phi_1$','interpreter','latex')
%legend('Azim1','Azim5','Azim10','Azim15')
%
%%lS1 = ['Phi_1' num2str(r)]
%subplot(2,2,3);
%hold on;
%%plot(real(PhiSave(2).dat(:,1)/c));
%plot(real(Phi2)/c);
%title('$Re\phi_2$','interpreter','latex')
%legend('Azim1','Azim5','Azim10','Azim15')
%
%subplot(2,2,4);
%hold on;
%%plot(imag(PhiSave(2).dat(:,1)/c));
%plot(imag(Phi2)/c);
%title('$Im\phi_2$','interpreter','latex')
%legend('Azim1','Azim5','Azim10','Azim15')
%end % function myPlots()
%
%%
%% For given azimuthal mode r and crosssection c, read in data for given timestep range [0,tMax].
%%
%function [u]=readAzimuthalMode(r,c)
%  [ntimesteps M rMax radMax ncs plotOn azimuthalSet azimuthalSetSize printStatus lags]=constantsPOD();
%  rrr = [1,5,10,15];
%  %rrr = [5,10,15];
%%function readAzimuthalMode(r,c)
% F = [];
% Fi = [];
%x=[0:radMax-1]/radMax;
% for time=[0:ntimesteps-1]/1
%               cc = %sprintf( '%04d', c - 1) ;
%               rr = %sprintf( '%04d', rrr(r)) ;
%               tt = %sprintf( '%04d', time ) ;
%
%               fpathFft = '/home/mi/podData/fft/refeb8/';
%               fpathFfti = '/home/mi/podData/fft/imfeb8/';
%               fftFilename = [ fpathFft 'm' num2str(rr) '_c' num2str(cc) '_t_' num2str(tt) '.dat']; % cq
%               fftFilenamei = [ fpathFfti 'm' num2str(rr) '_c' num2str(cc) '_t_' num2str(tt) '.dat']; % cq
%               %FFTdata = flip(importdata(fftFilename));
%               %FFTdatai = flip(importdata(fftFilenamei));
%               %sprintf('%s', fftFilename);
%               FFTdata = importdata(fftFilename) ;
%               FFTdatai =importdata(fftFilenamei);
%
%               fVal = FFTdata;    % flip dat data
%               fVali= FFTdatai;    % flip dat data
%               %FFTdatai = importdata(fftFilenamei);
%               fVal = fVal(:,4); % change to 4 for normal fft files, 1 for 1 col file
%               fVali = fVali(:,4);
%               %hold on;
%               %plot(fVal);
%                F = [F , fVal ];%
%                Fi = [Fi , fVali];%
% end %time
% u =(F + j*Fi);
%end % function readAzimuthalMode()
%
%
%function [u]=smallTestAzimuthalMode(r,c)
%  [ntimesteps M rMax radMax ncs plotOn azimuthalSet azimuthalSetSize printStatus lags]=constantsPOD();
%  rrr = [1,5,10,15];
%  %rrr = [5,10,15];
%%function readAzimuthalMode(r,c)
% F = [];
% Fi = [];
%x=[0:radMax-1]/radMax;
% for time=1:ntimesteps
% for jj=1:radMax
%   u(jj,time) = time*(sin(jj) + j*cos(jj))*randi(100)*0.001;
%   %u(jj,time) = time*(sin(jj) + j*cos(jj));
% end % jj
% end % t
%end % function readAzimuthalMode()
%
%
%
%%cte
%function [ntimesteps M rMax radMax ncs plotOn azimuthalSet azimuthalSetSize printStatus lags]=constantsPOD()
%plotOn=0;
%ntimesteps=300; % 692
%M = 1/ntimesteps;
%rMax=2; % lambda vec one
%%rMax=20; % lambda vec one
%radMax=540;
%%radMax=rMax; %54o one
%ncs=20;
%%azimuthalSet=[1,50,100,150,200,250,300,350,400,450,500,550,600,650,700,750,800,850,900,950,1000,1050,1079]; % azimuthal, but verkurzt
%azimuthalSet=[1,40,80,120,160,200,240,280,320,360,400,440,480,520,560,600,640,680,720,760,800,840,880,920,960,1000,1040,1080];
%azimuthalSetSizeb=size(azimuthalSet);
%azimuthalSetSize=azimuthalSetSizeb(2);
%
%end
%




%function [F Fi eigval_spod lambdaSqrt PhiSave isOrthog]=initDataPOD()
%[ntimesteps M rMax radMax ncs plotOn azimuthalSet azimuthalSetSize printStatus lags]=constantsPOD();
%F=zeros(radMax,ntimesteps);
%Fi=zeros(radMax,ntimesteps);
%eigval_spod=zeros(1,ntimesteps);
%lambdaSqrt=zeros(1,ntimesteps);
%
%%struct('Phi',repmat({zeros(radMax,1)},rMax,1));
%%struct('PhiSave',repmat({zeros(radMax,1)},rMax,1));
%%struct('PhiNorm',repmat({zeros(radMax,1)},rMax,1));
%
%for jj=1:rMax % do this. first pod mode = 1st col of eigenvalue = Lspod.
%  PhiSave(jj).dat = zeros(radMax,1);
%end % jj
%
%if plotOn==1
%% turn on/off zgf
% fig=   figure('Position',[ 97,41,1583,882],'Color',[.9 .9 .9],'visible','on');
% ty= tiledlayout(1,2); % Requires R2019b or later % for rms
% %tT= tiledlayout(1,2); % Requires R2019b or later % for rms
% hold on
%end
%
%for r=1:rMax % do this. first pod mode = 1st col of eigenvalue = Lspod.
%for c=1:ncs% do this. first pod mode = 1st col of eigenvalue = Lspod.
%for jj=1:3% do this. first pod mode = 1st col of eigenvalue = Lspod.
%  isOrthog(r).cs(c).Orthog(jj).dat= -666.0;
%end % jj
%end %c
%end %r
%
%
%
%end % function

%function [eigVec,eigVal]=eigCalc(intIJ,PODtype)
%  if PODtype=="c"
%[ntimesteps M rMax radMax ncs plotOn azimuthalSet azimuthalSetSize printStatus lags]=constantsPOD();
% [Psi_tmp,lambda_tmp]=eig(intIJ); % <------------------------------
% [d,ind] = sort(diag(lambda_tmp),'descend');
% lambda=lambda_tmp(ind,ind);
% %Psi= Psi_tmp(:,ind);
% eigVec= Psi_tmp(:,ind);
% %for i=1:ntimesteps
% for i=1:radMax
% eigVal(i) = lambda(i,i);
% %lambdaSqrt(i)=sqrt(lambda(i,i));
% end % i
%  elseif PODtype=="s"
%
%[ntimesteps M rMax radMax ncs plotOn azimuthalSet azimuthalSetSize printStatus lags]=constantsPOD();
% [Psi_tmp,lambda_tmp]=eig(intIJ); % <------------------------------
% [d,ind] = sort(diag(lambda_tmp),'descend');
% lambda=lambda_tmp(ind,ind);
% %Psi= Psi_tmp(:,ind);
% eigVec= Psi_tmp(:,ind);
% %for i=1:ntimesteps
% %for i=1:radMax
% for i=1:ntimesteps% radMax exceeds bounds.
% eigVal(i) = lambda(i,i);
% %lambdaSqrt(i)=sqrt(lambda(i,i));
% end % i
%
% end % if
%end % function
%
%
%
%function [PhiSave]=MakeEigVecPositivePeak(PsiR,PhiSave,c)
%[ntimesteps M rMax radMax ncs plotOn azimuthalSet azimuthalSetSize printStatus lags]=constantsPOD();
%%clear PhiSave;
%for jj=1:rMax %
% aaa= PsiR(:,jj); %eq (31).
% %  %
%  [M,ind] = max(abs(aaa));
%  if aaa(ind)<0
%  aaa = -aaa;
%  end %if
% Phi(jj).dat = aaa; % Phi holds the jth (eg 1st or 2nd) POD mode.
% %PhiSave(jj).dat = PhiSave(jj).dat + aaa; % sum crosssections!
% PhiSave(jj).dat = + aaa; % sum crosssections!
% % plot here
%%myPlots( PhiSave,c);
%end % jj
%end %fcn
%
%
%
%% classical POD related functions
%%
%function [tim]=SBarIntegrandClassic(u)
%  [ntimesteps M rMax radMax ncs plotOn azimuthalSet azimuthalSetSize printStatus lags]=constantsPOD();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculate the tensor SBar described in Hellstrom16.Eq(3.5)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% - involves time quadrature.
%% - for this, integrate the tensor each (i,j) coordinate at a time, for t=[0,tMax]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% the integrand needs to be a tensor. the spatial varation of each product-ed
%% one needs to be different.
%Cmat = zeros(ntimesteps,ntimesteps);
%Sintegrand3dot2 = zeros(radMax,ntimesteps);
%% eq 3.2
%for mIndex=1:ntimesteps
%for ii=1:radMax
%for jj=1:radMax
%  SCorrMat(ii,jj) = power(ii,0.5)*u(ii,mIndex)*ctranspose(u(jj,mIndex))*power(jj,0.5); % H16.eq.3.5 integrand
%end %jj
%end %ii
%tim(mIndex).dat = SCorrMat;
%end % mIndex
%end % end function Sbar
%
%
%% find time averaged two-point correlation tensor (following hell2016.eq.3.5)
%function [intIJ]=SBarIntegralClassic(Sij)
%[ntimesteps M rMax radMax ncs plotOn azimuthalSet azimuthalSetSize printStatus lags]=constantsPOD();
%
%% organzie by ti and tj, then integrate each by t
%intTimeMz =[];
%intIJ = zeros(radMax,radMax);
%for ii=1:radMax
%for jj=1:azimuthalSetSize - 1 % max azimuthal mode
%    %sprintf('%s%d%d%s','time int for ', ii, jj, 'is');
%  tVec = zeros(ntimesteps,1);
%
%% load each i,j coordiante of S, for all time, into a vector,
%% and then integrate that wrt t.
%for mIndex=1:ntimesteps
%  tVec(mIndex) =  Sij(mIndex).azimuth(jj).dat(ii,1);
%end % time % done loading all timesteps, now integrate for a given i,j. over t
%%plot(real(tVec))
%%hold on;
%%plot(imag(tVec))
%
%intIJ(ii,jj)=M*trapz(tVec); % this is Hell16.(eq.3.5).
%%sprintf('%s','bp');
%end % ii
%end % jj
%%sprintf('%s','bp');
%end % function
%
%% find time averaged two-point correlation tensor (following hell2016.eq.3.5)
%function [Bij]=CitrinitiFindBij(Sij)
%[ntimesteps M rMax radMax ncs plotOn azimuthalSet azimuthalSetSize printStatus lags]=constantsPOD();
%
%% organzie by ti and tj, then integrate each by t
%%intTimeMz =[];
%%intIJ = zeros(radMax,radMax);
%%
%
%for mIndex=1:ntimesteps % freq
%for jj=1:azimuthalSetSize - 1 % azimuthal mode
%
%for ii=1:radMax % r
%for iiPrime=1:radMax % rPrime
%    %sprintf('%s%d%d%s','time int for ', ii, jj, 'is');
%  Bij(mIndex).azimuth(mIndex).dat(ii,iiPrime) =  Sij(mIndex).azimuth(jj).dat(ii,1);
%end % ii
%end % iiPrime
%
%end % jj
%end % time % done loading all timesteps, now integrate for a given i,j. over t
%%sprintf('%s','bp');
%end % function
%
%
%function [PsiR]=rMinusHalfClassic(eigVec)
%[ntimesteps M rMax radMax ncs plotOn azimuthalSet azimuthalSetSize printStatus lags]=constantsPOD();
%Psi = eigVec;
% PsiR = zeros(radMax,rMax);
% for jj=1:rMax % do this. first pod mode = 1st col of eigenvalue = Lspod.
% for ii=1:radMax % do this. first pod mode = 1st col of eigenvalue = Lspod.
% PsiR(ii,jj) = power(ii,-0.5)*Psi(ii,jj); %eq (31).
%end % jj
%end % rmax
%end % function
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%% snapshot functions
%
%
%function [tim]=RIntegrandSnap(u)
%  [ntimesteps M rMax radMax ncs plotOn azimuthalSet azimuthalSetSize printStatus lags]=constantsPOD();
%% the integrand needs to be a tensor after Royale.Eq.2.4:
%% The cross-correlation tensor $\mathbf{R}$ is defined as
%% $\mathbf{R}\left(k ; m ; t, t^{\prime}\right)=
%% \int_{r} \mathbf{u}(k ; m ; r, t) \mathbf{u}^{*}\left(k ; m ; r, t^{\prime}\right) r d r$.
%%
%Cmat = zeros(ntimesteps,ntimesteps);
%Sintegrand3dot2 = zeros(radMax,ntimesteps);
%% eq 3.2
%for ii=1:radMax
%for ti=1:ntimesteps
%for tj=1:ntimesteps
%  % integrand of Royale.2.4.(b)
%  SCorrMat(ti,tj) = u(ii,ti)*ctranspose(u(ii,tj))*ii; % Royale.2.4.b.integrand.
%end %jj
%end %ii
%%Sintegrand3dot2(:,mIndex) = SCorrMat;
%tim(ii).dat = SCorrMat;
%end % m index
%end % end function Sbar
%
%
%
%function [intIJ]=RIntegralSnap(tim)
%[ntimesteps M rMax radMax ncs plotOn azimuthalSet azimuthalSetSize printStatus lags]=constantsPOD();
%% organzie by ti and tj, then integrate each by <-- r ! <- check.
%intTimeMz =[];
%intIJ = zeros(ntimesteps,ntimesteps);
%for ti=1:ntimesteps
%for tj=1:ntimesteps
%    %%sprintf('%s%d%d%s','time int for ', ii, jj, 'is');
%  tVec = zeros(radMax,1);
%% load each i,j coordiante of S, for all time, into a vector, and then integrate that wrt t.
%for ii=1:radMax
%  tVec(ii) =  tim(ii).dat(ti,tj);
%end % time % done loading all timesteps, now integrate for a given i,j. over t
%intIJ(ti,tj)=trapz(tVec); % Royale.2.4.b.integral
%%sprintf('%s','bp');
%end % ti
%end % tj
%%sprintf('%s','bp');
%
%end % function
%
%
%% eq Royale.(Eq.2.5)
%function [Phi]=eq2dot4Snap(u,eigVec,eigVal)
%[ntimesteps M rMax radMax ncs plotOn azimuthalSet azimuthalSetSize printStatus lags]=constantsPOD();
%% LHS of eq.2.5
%phiVec2dot5 = zeros(rMax,radMax);
% for rr=1:rMax
% eq2dot5lhsIntegrand = zeros(radMax,radMax);
% intTvec = zeros(1,radMax);
% for jj=1:radMax%
% myTvec = zeros(1,ntimesteps);
% for ti=1:ntimesteps%
%   myTvec(ti) = u(jj,ti)*ctranspose(eigVec(ti,ti));
%end % ti
% % integrate in t dir:
% intTvec(jj) = M*trapz(myTvec);
%end % jj
% % end r loop, put eq.2.5 calcualted eigVec into phiVec
% eigValMode = eigVal(rr) ;
% %phiVec2dot5(rr,:) = intTvec/eigValMode;
% Phi(rr,:) = intTvec/eigValMode;
%end %rr
% Phi = Phi';
%end % function
%
%function [a b d Phi] = checkOrthonormal(Phi,r,c)
%[ntimesteps M rMax radMax ncs plotOn azimuthalSet azimuthalSetSize printStatus lags]=constantsPOD();
%% use inner product in r direction, \int_r r_i dot(a,b) dr,
%% in order to check if two vectors a and b are orthogonal.
%
%% check if phi_1 normis normal.
%  sum = 0;
% for jj=1:radMax%
%   sum = sum + jj*ctranspose(Phi(1).dat(jj,1))*Phi(1).dat(jj,1);
%end % jj
% a=sum;
% if a ~= 1 %
%   Phi(1).dat = Phi(1).dat/sqrt(sum); % normalize if not normal.
%   %Phi(1).dat = Phi(1).dat/sum; % normalize if not normal.
%    sum = 0;
%   % reprint result.
%    for jj=1:radMax%
%    sum = sum + jj*ctranspose(Phi(1).dat(jj,1))*Phi(1).dat(jj,1);
%    end % jj
%    a=sum;
% end
%
%% check if phi_2 is normal.
%  sum = 0;
% for jj=1:radMax%
%   %sum = sum + jj*Phi(2).dat(jj,1)*Phi(2).dat(jj,1);
%   sum = sum + jj*ctranspose(Phi(2).dat(jj,1))*Phi(2).dat(jj,1);
%end % jj
% b=sum;
% if b ~= 1 %
%   Phi(2).dat = Phi(2).dat/sqrt(sum); % normalize if not normal.
%   %Phi(1).dat = Phi(1).dat/sum; % normalize if not normal.
%    sum = 0;
%   % reprint result.
%    for jj=1:radMax%
%    sum = sum + jj*ctranspose(Phi(2).dat(jj,1))*Phi(2).dat(jj,1);
%    end % jj
%    b=sum;
% end
%
%
%% check if phi_2 is orthog to ph1_1
%  sum = 0;
% for jj=1:radMax%
%   %sum = sum + jj*Phi(2).dat(jj,1)*Phi(1).dat(jj,1);
%   sum = sum + jj*ctranspose(Phi(2).dat(jj,1))*Phi(1).dat(jj,1);
%end % jj
% d=sum;
%
% %isOrthog(r).cs(c).dat(1) = sum; % struct(1) correspond to normal
%
%
%
%
%  %plot sum for each pod orthogonal sum check.
%end % fc
