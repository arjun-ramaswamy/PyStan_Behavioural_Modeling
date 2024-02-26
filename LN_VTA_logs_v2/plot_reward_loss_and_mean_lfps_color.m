clear all; clc;

% Preprocessing Steps
subjects_vta = {'LN_VTA1','LN_VTA2', 'LN_VTA3', 'LN_VTA4', 'LN_VTA5', 'LN_VTA6', 'LN_VTA7', 'LN_VTA8', 'LN_VTA9', 'LN_VTA10', 'LN_VTA11', 'LN_VTA12', 'LN_VTA13', 'LN_VTA14'};
subjects = subjects_vta;
keep = 0;
fD = {};

for P = 1:14
    if P == 1
        [~, root, details] = vta_subjects(subjects{P});
    else
        [~, ~, root, details] = dbs_subjects_london(subjects{P}, 1);
    end

    cd(fullfile(root, 'SPMtask'));
    D = spm_eeg_load(spm_select('FPList', '.', '^rpe.*\.mat$'));

    S = [];
    S.D = D;
    S.channels = 'LFP';
    D = spm_eeg_crop(S);

    S = [];
    S.D = D;
    S.timewin = [-Inf 0];
    D = spm_eeg_bc(S);
    if ~keep
        delete(S.D);
    end

    S = [];
    S.D = D;
    S.type = 'butterworth';
    S.band = 'low';
    S.freq = 20;
    S.dir = 'twopass';
    S.order = 5;
    D = spm_eeg_filter(S);
    if ~keep
        delete(S.D);
    end

    S = [];
    S.D = D;
    S.fsample_new = 60;
    D = spm_eeg_downsample(S);
    if ~keep
        delete(S.D);
    end

    rms = sqrt(mean(D(:, :, 1).^2, 2));
    montage = [];
    montage.labelorg = D.chanlabels;
    montage.labelnew = {'mean', 'max', 'weighted'};
    montage.tra = ones(1, D.nchannels) / D.nchannels;
    [~, ind] = max(rms);
    montage.tra(2, ind) = 1;
    montage.tra(3, :) = rms(:)' ./ sum(rms);

    S = [];
    S.D = D;
    S.montage = montage;
    S.keepothers = 0;
    fD{P} = spm_eeg_montage(S);
end

% Remove any empty datasets
fD(any(cellfun(@isempty, fD')), :) = [];
cd('D:\home\Data\DBS-MEG\Results');
cD = {};
for i = 1
    S = [];
    S.D = fD;
    cD{i} = spm_eeg_merge(S);
end

% Plotting section
titles_to_use = {'rew', 'loss', 'mean'};
colors_to_use = {[0.12, 0.47, 0.71], [0.89, 0.55, 0.11], [0, 0, 0]};  % Blue, Orange, Green
figure;

for cond_idx = 1:length(titles_to_use)
    subplot(length(titles_to_use), 1, cond_idx);
    data = squeeze(cD{1}(cD{1}.indchannel('mean'), :, cD{1}.indtrial(titles_to_use{cond_idx})));
    
    if isempty(data)  % For 'mean' condition, it's the mean across all trials
        data = mean(squeeze(cD{1}(cD{1}.indchannel('mean'), :, :)), 2);
    end

    m = mean(data(cD{1}.time < 0, :));
    s = std(data(cD{1}.time < 0, :));
    data = (data - m) ./ s;

    h = shadedErrorBar(cD{1}.time, mean(data, 2), ...
        1.96 * squeeze(std(data, [], 2)) ./ sqrt(size(data, 2)));
    set(h.mainLine, 'Color', colors_to_use{cond_idx});
    set(h.patch, 'FaceColor', colors_to_use{cond_idx}, 'FaceAlpha', 0.2);
    set(h.edge, 'Color', 'none');
    
    hold on;
    plot(cD{1}.time, zeros(size(cD{1}.time)), 'k--');  % Zero line
    title(titles_to_use{cond_idx}, 'FontSize', 15);
    set(gca, 'FontSize', 15);
end
