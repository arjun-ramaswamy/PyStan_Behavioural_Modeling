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

% Plotting section for 'mean' condition
figure;
data = mean(squeeze(cD{1}(cD{1}.indchannel('mean'), :, :)), 2);

m = mean(data(cD{1}.time < 0));
s = std(data(cD{1}.time < 0));
data_normalized = (data - m) / s;

shadedErrorBar(cD{1}.time, data_normalized, ...
    1.96 * std(data_normalized) ./ sqrt(size(data, 2)));
hold on;
plot(cD{1}.time, zeros(size(cD{1}.time)), 'k');
title('Mean', 'FontSize', 15);
set(gca, 'FontSize', 15);
%legend('Data', '95% Confidence Interval', 'Location', 'best');
