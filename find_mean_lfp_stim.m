function [lfp_M] = find_mean_lfp_stim(LFP,frameTimes,stim_length,buffer)
  lfp_stim = NaN(numel(frameTimes),(buffer+stim_length+buffer));
  for frame = 1:numel(frameTimes)
    start_time = frameTimes(frame)-buffer+1;
    end_time = frameTimes(frame)+stim_length+buffer;
    lfp_stim(frame,:) = LFP(start_time:end_time);
  end
  lfp_M = nanmean(lfp_stim,1);
end