function patientsData = extractLFP(patientsData, brainRegions, finalSelectedRegions, paths, logFilePath)
    % EXTRACTLFP Extracts LFP data from selected brain regions for each patient.
    %
    % Syntax:
    %   patientsData = extractLFP(patientsData, brainRegions, finalSelectedRegions, paths, logFilePath)
    %
    % Description:
    %   For each patient, identifies channels corresponding to the selected brain regions using
    %   regex patterns, extracts LFP data for each trial, and saves the updated patient data.
    %   Logs the status of each extraction operation.
    %
    % Inputs:
    %   patientsData - (struct) A structured container holding processed data for each patient.
    %   brainRegions - (struct) Structure containing brain region regex patterns.
    %   finalSelectedRegions - (string array) List of validated brain regions for processing.
    %   paths - (struct) A structure containing directory paths as defined by definePaths().
    %   logFilePath - (string) Path to the log file for recording LFP extraction status.
    %
    % Outputs:
    %   patientsData - (struct) Updated structured container with LFP data extracted.
    %
    % Example:
    %   patientsData = extractLFP(patientsData, brainRegions, ["HP", "A"], paths, '/path/to/logfile.txt');
    %
    % See Also:
    %   definePaths, setupLogging, logMessage
    
    % Retrieve the list of patient IDs
    fieldsList = fieldnames(patientsData);
    tempfinalSelectedRegions = cellstr(finalSelectedRegions); % For regex pattern matching
    
    % Iterate through each patient to extract LFP data
    for i = 1:length(fieldsList)
        patientID = fieldsList{i};  % Use the field name as patientID
        
        % Load the updated patient data with trial information
        preProcessedFilePath = fullfile(paths.preProcessedPath, sprintf('%s_allChanSpkRmvl_trialInfo.mat', patientID));
    
        % Validation check #1: Ensure file saved properly from previous step 
        if ~isfile(preProcessedFilePath)
            logMessage(sprintf('File not found: %s. Prior processing step failed. Skipping LFP extraction for patient %s.', preProcessedFilePath, patientID), logFilePath, 'WARNING');
            continue;  % Skip to the next patient
        end
    
        patient = load(preProcessedFilePath);
    
        % Validation check #2: If file is present, ensure required fields are also present
        requiredFields = {'trial', 'labels', 'channel'};
        missingRequired = false;
        for f = 1:length(requiredFields)
            if ~isfield(patient, requiredFields{f})
                logMessage(sprintf('Field not found: %s. Prior processing step failed. Skipping LFP extraction for patient %s.', requiredFields{f}, patientID), logFilePath, 'ERROR');
                missingRequired = true;
                break;  % Exit the loop early
            end
        end
        if missingRequired
            continue;  % Skip to the next patient
        end
        
        % ===============================================================================================
        % Define Brain Regions 
        % ===============================================================================================
                
        for j = 1:length(tempfinalSelectedRegions)
            region = tempfinalSelectedRegions{j};  
            pattern = brainRegions.(region);    % Regex pattern for the region
            
            % Find channels matching the current brain region pattern
            choi = regexp(patient.labels, pattern);
            channelMask = ~cellfun(@isempty, choi);
            
            % Define dynamic field names
            regionChanVar = sprintf('%s_chan', region);
            regionLabelsVar = sprintf('%s_labels', region);
            regionDataVar = sprintf('%s_selectedChanSpkRmvl', region);  
            
            % Extract channel indices and labels for the current region
            region_chan = patient.channel(channelMask, 1);  
            region_labels = patient.labels(channelMask, 1);  
            
            % Assign extracted data to dynamic fields without using eval
            patient.(regionChanVar) = region_chan;
            patient.(regionLabelsVar) = region_labels;
            
            % Initialize LFP_data
            LFP_data = cell(length(patient.trial),1); 
            
            cnt=1;
            % Extract LFP data for each trial
            for k = 1:length(patient.trial)
                trialData = patient.trial{k}; 
                LFP_data{cnt} = trialData(:, channelMask);
                cnt=cnt+1;
            end
            
            % Assign LFP_data to the dynamic field with updated naming
            patient.(regionDataVar) = LFP_data;
            
            % Clear LFP_data to prevent data leakage
            clear LFP_data;
        end
        
        % Remove the 'trial' field as it's no longer needed
        if isfield(patient, 'trial')
            patient = rmfield(patient, 'trial');
        end
        
        % Update the structured data container
        patientsData.(patientID) = patient;
    end
end
