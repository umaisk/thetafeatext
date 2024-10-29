function verifyProcessedDataFiles(selectedPatientIDs, selectedBrainRegions, projectPaths, logFilePath)
    % VERIFYPROCESSEDDATAFILES Checks the existence of processed data files for selected patients.
    %
    % Inputs:
    %   selectedPatientIDs   - (string array) List of selected patient session IDs.
    %   selectedBrainRegions - (string array) List of selected brain regions.
    %   projectPaths         - (struct) Structure containing directory paths.
    %   logFilePath          - (string) Path to the log file.
    %
    % Outputs:
    %   None. Logs the verification status of each processed data file.

    % Define required processed data suffixes
    % "_allChanSpkRmvl.mat" and "_<SelectedBrainRegions concatenated>_selectedChanSpkRmvl.mat"
    concatenatedRegions = strjoin(selectedBrainRegions, '_');
    requiredProcessedSuffixes = ["_allChanSpkRmvl.mat", "_" + concatenatedRegions + "_selectedChanSpkRmvl.mat"];

    % Iterate through each selected patient
    for i = 1:length(selectedPatientIDs)
        patientID = selectedPatientIDs(i);

        % Iterate through each required suffix
        for j = 1:length(requiredProcessedSuffixes)
            suffix = requiredProcessedSuffixes(j);
            fileName = strcat(patientID, suffix);
            filePath = fullfile(projectPaths.preProcessedPath, fileName);

            if isfile(filePath)
                logMessage(['Verified processed data file exists: ' filePath], logFilePath, 'INFO');
            else
                logMessage(['Missing processed data file for patient "' patientID '": ' filePath], logFilePath, 'ERROR');
                error(['Missing processed data file for patient "' patientID '": ' filePath]);
            end
        end
    end

    % Verify consolidated LFP data file
    % Assuming a single consolidated file for all selected patients and regions
    concatenatedPatientIDs = strjoin(selectedPatientIDs, '_');
    consolidatedFileName = strcat(concatenatedPatientIDs, "_" + concatenatedRegions + "_selectedChanSpkRmvlConsolidated.mat");
    consolidatedFilePath = fullfile(projectPaths.preProcessedPath, consolidatedFileName);

    if isfile(consolidatedFilePath)
        logMessage(['Verified consolidated LFP data file exists: ' consolidatedFilePath], logFilePath, 'INFO');
    else
        logMessage(['Missing consolidated LFP data file: ' consolidatedFilePath], logFilePath, 'ERROR');
        error(['Missing consolidated LFP data file: ' consolidatedFilePath]);
    end
end
