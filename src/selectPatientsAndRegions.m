function [selectedPatients, selectedRegions] = selectPatientsAndRegions(metaData, brainRegions, selectedPatientIDs, selectedBrainRegions, logFilePath)
    % SELECTPATIENTSANDREGIONS Selects patients and brain regions based on user input.
    %
    % Syntax:
    %   [selectedPatients, selectedRegions] = selectPatientsAndRegions(metaData, brainRegions, selectedPatientIDs, selectedBrainRegions, logFilePath)
    %
    % Description:
    %   Filters and validates user-selected patients and brain regions. Handles cases where
    %   selected items are invalid or undefined.
    %
    % Inputs:
    %   metaData - (struct) Metadata structure containing session IDs.
    %   brainRegions - (struct) Structure containing brain region regex patterns.
    %   selectedPatientIDs - (string array) User-selected patient IDs or "all" for all patients.
    %   selectedBrainRegions - (string array) User-selected brain regions or "all" for all regions.
    %   logFilePath - (string) Path to the log file for recording selection status.
    %
    % Outputs:
    %   selectedPatients - (string array) Validated list of patient IDs for processing.
    %   selectedRegions - (string array) Validated list of brain regions for processing.
    %
    % Example:
    %   [patients, regions] = selectPatientsAndRegions(metaData, brainRegions, ["P60cs"], ["HP", "A"], '/path/to/logfile.txt');
    %
    % See Also:
    %   definePaths, setupLogging, logMessage
    
    % Determine Selected Patients
    if ismember("all", selectedPatientIDs)
        selectedPatients = metaData.sessionID;
        logMessage("All patients selected for processing.", logFilePath, 'INFO');
    else
        validPatientMask = ismember(selectedPatientIDs, metaData.sessionID);
        validPatients = selectedPatientIDs(validPatientMask);
        invalidPatients = selectedPatientIDs(~validPatientMask);
        
        selectedPatients = string(validPatients);  % Ensure string array
        
        for j = 1:length(invalidPatients)
            logMessage(sprintf('Patient "%s" is not defined. Skipping.', invalidPatients(j)), logFilePath, 'WARNING');
        end
    end
    
    % Determine Selected Brain Regions
    if ismember("all", selectedBrainRegions)
        selectedRegions = string(fieldnames(brainRegions));
        logMessage("All brain regions selected for processing.", logFilePath, 'INFO');
    else
        validRegionMask = ismember(selectedBrainRegions, string(fieldnames(brainRegions)));
        validRegions = selectedBrainRegions(validRegionMask);
        invalidRegions = selectedBrainRegions(~validRegionMask);
        
        selectedRegions = string(validRegions);  % Ensure string array
        
        for j = 1:length(invalidRegions)
            logMessage(sprintf('Brain region "%s" is not defined. Skipping.', invalidRegions(j)), logFilePath, 'WARNING');
        end
    end
    
    % Confirmation of Selections
    patientsStr = strjoin(selectedPatients, ', ');
    regionsStr = strjoin(selectedRegions, ', ');
    
    logMessage(sprintf('Selected Patient(s): "%s"', patientsStr), logFilePath, 'INFO');
    logMessage(sprintf('Selected Brain Region(s): "%s"', regionsStr), logFilePath, 'INFO');
    
    % Validate Selections
    if isempty(selectedPatients)
        logMessage('No valid patients selected. Terminating script.', logFilePath, 'ERROR');
        error('No valid patients selected.');
    end
    
    if isempty(selectedRegions)
        logMessage('No valid brain regions selected. Terminating script.', logFilePath, 'ERROR');
        error('No valid brain regions selected.');
    end
end
