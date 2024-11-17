import numpy as np
import os
import bombcell.extract_raw_waveforms as erw
from pathlib import Path

def load_ephys_data(ehpys_path):
    """
    This function loads the necessary data from the spike sorting to run BombCell

    Parameters
    ----------
    ehpys_path : str
        The path to the KiloSorted output file

    Returns
    -------
    spike_times_samples : ndarray (n_spikes,)
        The array which gives each spike time in samples (*not* seconds)
    spike_templates : ndarray (n_spikes,)
        The array which assigns a spike to a cluster
    template_waveforms : ndarray (m_tempaltes, n_time_points, n_channels)
        The array of template waveforms for each tempalte and channel
    pc_features : ndarray (n_spikes, n_features_per_channel, n_pc_features)
        The array giving the PC values for each spike
    pc_feature_idx : ndarray (n_templates, n_pc_features)
        The array which specifies which channel contribute to each entry in dim 3 of the pc_features array
    channel_positions : ndarray (n_channels, 2)
        The array which gives the x and y coordinates of each channel
    good_channels: ndarray (n_channels,)
        The array defining the channels used by KiloSort, as some in-active channels are dropped during
        spike sorting
    """
    #in the ML version there is +1 which are not needed in python due to 0/1 indexing
    #load spike templaes
    if os.path.exists(os.path.join(ehpys_path, 'spike_templates.npy')):
        spike_templates = np.load(os.path.join(ehpys_path, 'spike_templates.npy'))
    else:
        spike_templates = np.load(os.path.join(ehpys_path, 'spike_clusters.npy'))
        #tempaltes = clusters < KS4, tempaltes ~=clusters KS4

    #load in spike times
    if os.path.exists(os.path.join(ehpys_path, 'spike_times_corrected.npy')):
        spike_times_samples = np.load(os.path.join(ehpys_path, 'spike_times_corrected.npy'))
    else:
        spike_times_samples = np.load(os.path.join(ehpys_path, 'spike_times.npy'))

    template_amplitudes = np.load(os.path.join(ehpys_path, 'amplitudes.npy')).astype(np.float64)

    #load and unwhiten templates
    tempalte_waveforms_whitened = np.load(os.path.join(ehpys_path, 'templates.npy'))
    winv = np.load(os.path.join(ehpys_path, 'whitening_mat_inv.npy'))
    tempaltes_waveforms = np.zeros_like(tempalte_waveforms_whitened)
    for t in range(tempaltes_waveforms.shape[0]):
        tempaltes_waveforms[t,:,:] = tempalte_waveforms_whitened[t,:,:].squeeze() @ winv

    if os.path.exists(os.path.join(ehpys_path, 'pc_features.npy')):
        pc_features = np.load(os.path.join(ehpys_path, 'pc_features.npy'))
        pc_features_idx = np.load(os.path.join(ehpys_path, 'pc_feature_ind.npy'))
    else:
        pc_features = np.nan
        pc_features_idx = np.nan

    channel_positions = np.load(os.path.join(ehpys_path, 'channel_positions.npy'))
    good_channels = np.load(os.path.join(ehpys_path, 'channel_map.npy'))
    
    return spike_times_samples, spike_templates, tempaltes_waveforms, template_amplitudes, \
           pc_features, pc_features_idx, channel_positions, good_channels

def get_gain_spikeglx(meta_path):
    """
    This function finds the probe type for the spike glx meta folder and also works out the gain

    Parameters
    ----------
    meta_path : str
        The path to the meta data folder 

    Returns
    -------
    float
        The scaling factor for the probe

    Raises
    ------
    Exception
        If the probe type is not handled
    """
    meta_dict = erw.read_meta(Path(meta_path))

    if np.isin('imDatPrb_type', list(meta_dict.keys())):
        probe_type = meta_dict['imDatPrb_type']
    elif np.isin('imProbeOpt', list(meta_dict.keys())):
        probe_type = meta_dict['imProbeOpt']
    else:
        #NOTE will have to update for new probes!
        print('Can not find imDatPrb_type or imProbeOpt in meta file')

    probe_type_1 = np.array(('1', '3', '0', '1020', '1030', '1100', '1120', '1121', '1122', '1123', '1200', '1300', '1110')) # NP1, NP2-like
    probe_type_2 = np.array(('21', '2003', '2004', '24', '2013', '2014', '2020')) #NP2, NP2-like

    if np.isin(probe_type, probe_type_1):
        bits_encoding = 2**10
        v_range = 1.2e6
        gain = 500
    elif np.isin(probe_type, probe_type_2):
        bits_encoding = 2**14
        v_range = 1e6
        gain = 80
    else:
        raise Exception('Probe type is not one of the know values please raise a GitHub issue or add the gain_to_uv manually')

    scaling_factor = v_range / bits_encoding / gain # is v_range / (bits_encoding * gain)
    return scaling_factor