function [avgPreFft]=findQbar(t,~,myPreFft,avgPreFft,lastStr)
[ntimesteps, rMin, rMax, ss, ncs, plotOn, azimuthalSet ,azimuthalSetSize ,printStatus ,lags, blocLength]=constants();
      for m=1:540 % m=1:540
      if lastStr=="notLast"
        avgPreFft(m).dat=avgPreFft(m).dat + myPreFft(t).circle(:,m).dat; % myPreFft needs to make sure its correct dir -> or v
      elseif lastStr=="last"
        avgPreFft(m).dat= (avgPreFft(m).dat + myPreFft(t).circle(:,m).dat)/(blocLength*ntimesteps); % myPreFft needs to make sure its correct dir -> or v
      end % if
      end % for
end % fc
