# Skewness-based functional connectivity (SFC)
This is the example processing pipeline for the skewness-based functional connectivity (SFC) analysis for epileptic tissue localization. SFC mainly includes 4 steps:

1. **Data processing**: include bandpass filtering in high-frequency band (80-500 Hz), notch filtering, envelope extraction;

2. **Skewness extraction**: describe the asymmetry in the amplitude distribution between high-frequency oscillations (HFOs) / high-frequency activity (HFA) and background activity

3. **Construction of connectivity matrix** : capture the channel-wise asymmetry correlation across time based on Spearman rank correlation

4. **Quantification of connectivity strength**: use the absolute sum of edge weights from the connectivity matrix between one channel and the other channels for epileptic tissue localization

The manuscript entitled **"Epileptic Tissue Localization through Skewness-Based Functional Connectivity in High-Frequency Band of Intracranial EEG"** is currently under review.