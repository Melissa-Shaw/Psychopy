function analyse_receptive_field(stimID_filename,neuropix) % eg. stimID_filename = 'M230322_A_MS_230322'

% Add necessary filepaths
addpath('S:\cortical_dynamics\Shared\Code\matlib\IO\');

% Find files to load
startingfolder = 'C:\SGL_DATA\';
disp('Select the LFP file to be analysed.')
[file,path] = uigetfile('*.bin');
LFPfile = [path file];
disp('Select the NIDQ file to be analysed.')
[file,path] = uigetfile('*.bin');
NIDQfile = [path file];

% Set parameters
if strcmp(neuropix,'NP1')
  SR = 2500; % sampling rate for NP1
elseif strcmp(neuropix,'NP24')
  SR = 30000; % sampling rate for NP2
else
  disp('Need to specify probe version being used.')
end

%stimIDfile = 'S:\cortical_dynamics\User\ms1121\Code\Psychopy\rec_map_stimID.csv';
%stimDetfile = 'S:\cortical_dynamics\User\ms1121\Code\Psychopy\rec_map_stim_details.csv';
stimIDfile = ['S:\cortical_dynamics\User\ms1121\Code\Psychopy\rec_map_stimID_' stimID_filename '.csv'];
stimDetfile = ['S:\cortical_dynamics\User\ms1121\Code\Psychopy\rec_map_stim_details_' stimID_filename '.csv'];
vStimSR = 9057.971014;
stim_length = 1000; 
buffer = 1500;
totalchans = 384+1;
stim_types = [1,2]; % horizontal position (vertical stripes) and vertical position (horizontal stripes)
LFP_channels = [24:48:360];
%LFP_channels = [24 169 217 361];

% Get frame times for stimulus
figure
set(gcf, 'Position', get(0, 'Screensize'));
[frameTimes, ~] = detectViStim(NIDQfile, 9, vStimSR); 
frameTimes = round(frameTimes*1000); % change to ms for 1kHz 

% Load stimID and stim_details
stimID = load(stimIDfile);
stimDet = load(stimDetfile);

% Load LFP data for each channel
for i = 1:numel(LFP_channels)
    lfpchan = LFP_channels(i);
    LFP  = getContinuousDataFromDatfile(LFPfile, totalchans, 0, +inf, lfpchan, SR); % load raw LFP
    LFP  = resample(LFP(1:end-1), 1000, SR);% from 2500Hz to 1KHz resolution
    disp(['LFP loaded for file chan: ' num2str(lfpchan)]);

    % Subtract the mean
    LFP = LFP - mean(LFP);

    % Find stim centre coords of all stim positions for visual stim mapping
    centre_coord = NaN(size(stimDet,1),2);
    for stim = 1:size(stimDet,1)
      x_coord = stimDet(stim,3)-0.5*(stimDet(stim,3)-stimDet(stim,6));
      y_coord = stimDet(stim,4)-0.5*(stimDet(stim,4)-stimDet(stim,7));
      centre_coord(stim,:) = [x_coord y_coord];
    end

    % Check stimulus triggered LFP for all stimulus
    [lfp_M_allstim] = find_mean_lfp_stim(LFP,frameTimes,stim_length,buffer);
    
    % Find stimulus triggered LFP for each stim type
    figure
    set(gcf, 'Position', get(0, 'Screensize'));
    t = tiledlayout(2,5);
    for cond = stim_types
      axs = [];
      cond_ID = stimDet(stimDet(:,2)==cond,1);
      for ID = 1:numel(cond_ID)
        ID_frameTimes = frameTimes(stimID==cond_ID(ID));
        [lfp_M] = find_mean_lfp_stim(LFP,ID_frameTimes,stim_length,buffer);
        ax1 = nexttile;
        plot(lfp_M_allstim,'color',[0.5,0.5,0.5]);
        hold on
        plot(lfp_M,'b');
        xline(buffer);
        xline(buffer+stim_length);
        title(['ID: ' num2str(cond_ID(ID)) ' Cond: ' num2str(cond) ' Centre: ['...
          num2str(centre_coord(cond_ID(ID),1)) ',' num2str(centre_coord(cond_ID(ID),2)) ']'])
        axs = [axs,ax1];
      end
    end
    linkaxes(axs,'xy');
    title(t,['LFPchan: ' num2str(lfpchan)]);
end

end
 

