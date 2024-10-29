function [filteredPatientsData, metaDataExt] = filterPatientsLFP(patientsData, finalSelectedRegions, paths, logFilePath)
    % FILTERPATIENTS Filters out patients missing LFP data from any selected brain regions.
    %
    % Syntax:
    %   [filteredPatientsData, metaDataExt] = filterPatients(patientsData, finalSelectedRegions, paths, logFilePath)
    %
    % Description:
    %   Evaluates each patient's data to ensure they have complete LFP information across all
    %   selected brain regions. Excludes patients with missing data and logs the exclusion reasons.
    %
    % Inputs:
    %   patientsData - (struct) A structured container holding processed data for each patient.
    %   finalSelectedRegions - (string array) List of validated brain regions for processing.
    %   paths - (struct) A structure containing directory paths as defined by definePaths().
    %   logFilePath - (string) Path to the log file for recording patient filtering status.
    %
    % Outputs:
    %   filteredPatientsData - (struct) A structured container holding data for patients with complete LFP data.
    %   metaDataExt - (struct) Extended metadata containing paths, selections, and patient inclusion/exclusion information.
    %
    % Example:
    %   [filteredData, extendedMeta] = filterPatients(patientsData, ["HP", "A"], paths, '/path/to/logfile.txt');
    %
    % See Also:
    %   definePaths, setupLogging, logMessage
    
    % Retrieve the list of patient IDs
    fieldsList = fieldnames(patientsData);
    tempfinalSelectedRegions = cellstr(finalSelectedRegions); % For regex pattern matching
    
    % Initialize containers for filtered and excluded patients
    filteredPatientIndices = [];
    excludedPatients = struct();
    
    % Iterate through each patient to check for missing regions
    for i = 1:length(fieldsList)
        patientID = fieldsList{i};
        patient = patientsData.(patientID);
        
        % Initialize missingRegions as empty string array
        missingRegions = strings(1,0);
        
        % Check each selected brain region for available channels
        for j = 1:length(tempfinalSelectedRegions)
            region = tempfinalSelectedRegions{j};
            regionChanField = sprintf('%s_chan', region);
            
            if ~isfield(patient, regionChanField) || isempty(patient.(regionChanField))
                missingRegions(end+1) = region; %#ok<AGROW>
            end
        end
        
        % Determine if the patient should be included or excluded
        if isempty(missingRegions)
            filteredPatientIndices(end+1) = i; %#ok<AGROW>
        else
            reason = sprintf('Missing Brain Regions: %s', strjoin(missingRegions, ', '));
            logMessage(sprintf('Patient "%s" is missing data.\nReason: %s.\nPatient "%s" excluded from further processing and analysis.', ...
                patientID, reason, patientID), logFilePath, 'WARNING');
            excludedPatients.(patientID).missingRegions = missingRegions;
        end
    end
    
    % Extract the filtered patients data
    filteredPatientsData = struct();
    selectedRegionsStr = strjoin(finalSelectedRegions, '_');
    
    if ~isempty(filteredPatientIndices)
        for idx = filteredPatientIndices
            currentField = fieldsList{idx};
            filteredPatientData = patientsData.(currentField);
            filteredPatientDataFileName = sprintf('%s_%s_selectedChanSpkRmvl.mat', currentField, selectedRegionsStr);
            filteredPatientDataFilePath = fullfile(paths.preProcessedPath, filteredPatientDataFileName);
            % Save the updated patient data with selected channels
            save(filteredPatientDataFilePath,'filteredPatientData', '-v7.3');
            logMessage(sprintf('Extracted LFP data from [%s] and saved for patient [%s] to: [%s].', ...
                selectedRegionsStr, currentField, filteredPatientDataFilePath), logFilePath, 'INFO');
            filteredPatientsData.(currentField) = filteredPatientData;
        end
    end
    
    % Log the final list of filtered patients with complete LFP data
    selectedRegionsStr = strjoin(finalSelectedRegions, '_');
    filteredPatientsStr = strjoin(fieldsList(filteredPatientIndices), '_');
    
    if isempty(filteredPatientIndices)
        logMessage('No patients have complete LFP data for the selected brain region(s).', logFilePath, 'WARNING');
    elseif length(filteredPatientIndices) > 1
        newFileName = sprintf('%s_%s_selectedChanSpkRmvlConsolidated.mat', filteredPatientsStr, selectedRegionsStr);
        newFilePath = fullfile(paths.preProcessedPath, newFileName);
        
        save(newFilePath, '-struct', 'filteredPatientsData', '-v7.3');
        logMessage(sprintf('Consolidated LFP data from [%s] and saved for patient(s) [%s] to: [%s].', ...
            selectedRegionsStr, filteredPatientsStr, newFilePath), logFilePath, 'INFO');
    else
        logMessage(sprintf('Single patient with complete LFP data for the selected brain region(s).'), logFilePath, 'INFO');
    end
    
    % Prepare extended metadata
    metaDataExt = struct();
    metaDataExt.projectPaths = paths;
    metaDataExt.finalSelectedRegions = finalSelectedRegions;
    metaDataExt.allPatientIDs = fieldnames(patientsData);
    metaDataExt.includedPatientIDs = fieldnames(filteredPatientsData);
end
