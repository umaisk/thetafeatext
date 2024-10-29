function patientsData = processPatients(filteredSelectedPatients, paths, logFilePath)
    % PROCESSPATIENTS Processes each selected patient and populates patientsData structure.
    %
    % Syntax:
    %   patientsData = processPatients(filteredSelectedPatients, paths, logFilePath)
    %
    % Description:
    %   Iterates through the list of selected patients, loads their data, defines trials,
    %   handles SUA information, and saves the processed data to the pre-processed directory.
    %   Logs the status of each patient processing with exhaustive logging.
    %
    % Inputs:
    %   filteredSelectedPatients - (cell array) List of validated patient IDs for processing.
    %   paths - (struct) A structure containing directory paths as defined by definePaths().
    %   logFilePath - (string) Path to the log file for recording patient processing status.
    %
    % Outputs:
    %   patientsData - (struct) A structured container holding processed data for each patient.
    %
    % Example:
    %   patientsData = processPatients({"P60cs"}, paths, '/path/to/logfile.txt');
    %
    % See Also:
    %   defineTrialsStCat, definePaths, setupLogging, logMessage

    % Start processing and initialize the patientsData structure
    logMessage('Initializing patientsData structure.', logFilePath, 'INFO');
    patientsData = struct();

    % Verify the presence of 'defineTrialsStCat' function
    logMessage('Verifying presence of "defineTrialsStCat" function.', logFilePath, 'INFO');
    if ~exist('defineTrialsStCat', 'file')
        logMessage('Function "defineTrialsStCat" not found in MATLAB path. Terminating script.', logFilePath, 'ERROR');
        error('Function "defineTrialsStCat" not found.');
    end
    
    % Iterate through each selected patient
    logMessage('Starting patient processing loop.', logFilePath, 'INFO');
    for i = 1:length(filteredSelectedPatients)
        patientID = filteredSelectedPatients{i};  % Access patient ID from cell array
        logMessage(sprintf('Performing preliminary processing of patient: %s.', patientID), logFilePath, 'INFO');
        
        try
            % Load patient data from the 'raw' directory
            patientDataFilePath = fullfile(paths.rawDataPath, sprintf('%s_allChanSpkRmvl.mat', patientID));
            logMessage(sprintf('Attempting to load patient data from: %s.', patientDataFilePath), logFilePath, 'INFO');
            
            if ~isfile(patientDataFilePath)
                logMessage(sprintf('Patient data file not found: %s. Skipping patient %s.', patientDataFilePath, patientID), logFilePath, 'WARNING');
                continue;  % Skip to the next patient
            end
            patientData = load(patientDataFilePath);
            logMessage(sprintf('Loaded patient data for %s successfully.', patientID), logFilePath, 'INFO');
            
            % Define trials using the custom function 'defineTrialsStCat'
            logMessage('Defining trials using "defineTrialsStCat" function.', logFilePath, 'INFO');
            [patientData.trial, patientData.time, patientData.timestamps, patientData.trialinfo] = defineTrialsStCat(patientData, "CAT");
            logMessage('Trial definition completed successfully.', logFilePath, 'INFO');
            
            % Check and remove 'datasamples' field if it exists
            if isfield(patientData, 'datasamples')
                logMessage('Removing "datasamples" field from patient data.', logFilePath, 'INFO');
                patientData = rmfield(patientData, 'datasamples');
            end
            
            % Load SUA (Single Unit Activity) information from the 'raw' directory
            suaInfoFilePath = fullfile(paths.rawDataPath, sprintf('%s_suaInfo.mat', patientID));
            logMessage(sprintf('Checking for SUA info file at: %s.', suaInfoFilePath), logFilePath, 'INFO');
            
            if isfile(suaInfoFilePath)
                logMessage('Loading SUA info.', logFilePath, 'INFO');
                suaData = load(suaInfoFilePath);
                patientData.sua = suaData;
                logMessage('SUA info loaded successfully.', logFilePath, 'INFO');
            else
                logMessage(sprintf('SUA info file not found: %s. Proceeding without SUA data for patient %s.', suaInfoFilePath, patientID), logFilePath, 'WARNING');
                patientData.sua = [];
            end
            
            % Assign the updated patient data to the structured container
            logMessage(sprintf('Assigning pre-processed data to patientsData structure for patient %s.', patientID), logFilePath, 'INFO');
            patientsData.(patientID) = patientData;
    
            % Save the updated patient data to the 'pre-processed' directory
            outputFileName = sprintf('%s_allChanSpkRmvl_trialInfo.mat', patientID);
            preProcessedFilePath = fullfile(paths.preProcessedPath, outputFileName);
            logMessage(sprintf('Saving initial pre-processed data to: %s.', preProcessedFilePath), logFilePath, 'INFO');
            save(preProcessedFilePath, '-struct', 'patientData', '-v7.3');
            
            % Log successful processing of the patient data
            logMessage(sprintf('Successfully completed preliminary processing and saved data for patient "%s" at: %s.', patientID, preProcessedFilePath), logFilePath, 'INFO');
        
        catch ME
            % Log any errors encountered during processing
            logMessage(sprintf('Error processing patient %s: %s', patientID, ME.message), logFilePath, 'ERROR');
        end
    end

    % Log the end of processing
    logMessage('Completed preliminary pre-processing of all patients.', logFilePath, 'INFO');
end
