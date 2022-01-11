function [nPeaks, nTroughs, axonal] = bc_troughsPeaks(thisWaveform, ephys_sample_rate, plotThis)
% JF, Get the number of troughs and peaks for each waveform, and determine
% whether waveform is likely axonal (biggest peak before biggest trough)
% ------
% Inputs
% ------
% thisWaveform: nTemplates × nTimePoints × nChannels single matrix of
%   template waveforms for each template and channel
% ------
% Outputs
% ------
% maxChannels: nTemplates * 1 vector of max channels for each template
% 
minProminence = 0.2 * max(abs(squeeze(thisWaveform))); % minimum threshold to detcet peaks/troughs

[PKS, LOCS] = findpeaks(squeeze(thisWaveform), 'MinPeakProminence', minProminence); % get peaks

[TRS, LOCST] = findpeaks(squeeze(thisWaveform)*-1, 'MinPeakProminence', minProminence); % get troughs

if isempty(TRS) % if there is no detected trough, just take minimum value as trough
    TRS = min(squeeze(thisWaveform));
    nTroughs = numel(TRS);
    LOCST_all = find(squeeze(thisWaveform) == TRS);
        if numel(TRS) > 1 % if more than one trough, take the first (usually the correct one) %QQ should change to better:
            % by looking for location where the data is most tightly distributed
            TRS = TRS(1);
        end
    
    LOCST = find(squeeze(thisWaveform) == TRS);
else
    nTroughs = numel(TRS);
end
if isempty(PKS) % if there is no detected peak, just take maximum value as peak
    PKS = max(squeeze(thisWaveform));
    nPeaks = numel(PKS);
    LOCS_all = find(squeeze(thisWaveform) == PKS);
        if numel(PKS) > 1 % if more than one peak, take the first (usually the correct one) %QQ should change to better:
            % by looking for location where the data is most tightly distributed
            PKS = PKS(1);
        end
    LOCS = find(squeeze(thisWaveform) == PKS);
else
    nPeaks = numel(PKS);
end


peakLoc = LOCS(PKS == max(PKS));
if numel(peakLoc) > 1
    peakLoc = peakLoc(1);

end
troughLoc = LOCST(TRS == max(TRS));
if numel(troughLoc) > 1
    troughLoc = troughLoc(1);
end

if peakLoc > troughLoc
    axonal = 1;
else
    axonal = 0;
end

if plotThis
    figure();
    clf;
    % hacky way of plotting - but hey it works
    pbad = plot(1e3*((0:size(thisWaveform, 2) - 1) / ephys_sample_rate), ...
        thisWaveform);
    hold on;
    mm = max(thisWaveform);
    pbb = pbad;
    pbb.XData(1:end) = NaN;
    pbad = plot(1e3*((0:size(thisWaveform, 2) - 1) / ephys_sample_rate), ...
        thisWaveform);

    pbb.XData([LOCS, LOCST]) = pbad.XData([LOCS, LOCST]);
    %pbb.YData(~[PKS,-TRS])=NaN;

    set(pbb, 'Marker', 'v');
    xlabel('time (ms)')
    ylabel('amplitude (a.u.)')
    legend('detected peaks/troughs')
    makepretty;
end

end