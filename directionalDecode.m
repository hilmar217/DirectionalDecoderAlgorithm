function outputSignal = directionalDecode(stereoInputSignal,beamAngle, beamWidth, beamHalflevel)
% directionalDecode: extracts the signal compontent associated with a
% specific direction from an surrund encoded stereo audio signal
% outputSignal = directionalDecode(stereoInputSignal,beam_angle, beam_width, beam_half_level)
%     stereoInputSignal: stereo input signal assumed to be surround encoded
%            beamAngle: location of desired direction in degrees
%            beamWidth: one sided width of the detector in degrees
%       beamHalfLlevel: sensitity of the detector at half the beam width in
%                        dB. Typically -3. 
% Copyright (c) 2020, Hilmar Lehnert consulting.

%% rotate signal
encodingAngle = pi/4- beamAngle/180*pi/2;
rotatedSignal = zeros(size(stereoInputSignal));
rotatedSignal(:,1) =  stereoInputSignal(:,1)*cos(encodingAngle) + stereoInputSignal(:,2)*sin(encodingAngle);
rotatedSignal(:,2) = -stereoInputSignal(:,1)*sin(encodingAngle) + stereoInputSignal(:,2)*cos(encodingAngle);


%% Beam management: cut of angle and beamWidth variables
cCut = cos(beamWidth/180*pi);
cCutHalf = cos(beamWidth/180*pi/2);
cCutQuarter = cos(beamWidth/180*pi/4);
beamHalfWidthGain = exp(beamHalflevel/20*log(10));
beamWidthPower = (log(beamHalfWidthGain)-log(cCutQuarter))/ ...
  log((cCutHalf-cCut)./(1-cCut));
 

%% detect energies and calcualte gain
Energies = sum(rotatedSignal.^2,1);
ETotal = sum(Energies);

% create the normalized energy metric. this maps from +1 to -1
ENorm = (Energies(1)-Energies(2))/ETotal;
% map the energy metric to the cutoff angle
gain = max((ENorm-cCut)./(1-cCut),0);
% dial in half angle level
gain = gain.^beamWidthPower;

%% create Output
outputSignal = gain*rotatedSignal(:,1);

% Copyright (c) 2020, Hilmar Lehnert consulting.