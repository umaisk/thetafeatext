%% Initialization
clearvars; clc; close all; tic;
addpath(genpath(pwd))

%% Define Python Engine Directory
% Modify to your needs
pythonEngineDir = 'C:\Program Files\MATLAB\R2024b\extern\engines\python';

%% Define Patient Selection
% To load specific patients, list their session IDs
% To load all patients, use ["all"]
% Note: All Patient Data has been omitted. 

% Modify to your needs
selectedPatientIDs = ["PatientID1", "PatientID2"];  

%% Define Brain Region Selection

% To process specific regions, list them, e.g., ["RegionName1", "RegionName2", "RegionName3", "RegionName4"]
% To process all regions, use ["all"]

% Modify to your needs
selectedBrainRegions = ["RegionName1", "RegionName2"];  

%% Project Setup
try
    projectPaths = setupProject(selectedPatientIDs);
catch ME
    fprintf('Project setup failed: %s\n', ME.message);
    return;  % Terminate further execution
end
logFilePath = projectPaths.logFilePath; 
%% Define Brain Regions with Regular Expressions
brainRegions = struct(...
    'HP', "[RL](.?HP*\d)", ...            % Hippocampus
    'A', "[RL]A\d", ...                   % Amygdala
    'SMA', "[RL].*SMA\d", ...             % Supplementary Motor Area
    'OF', "[RL]OF\d", ...                 % Orbitofrontal Cortex
    'AC', "[RL]AC\d" ...                  % Anterior Cingulate Cortex
    );

logMessage("Brain regions (regex patterns) have been defined.", logFilePath, 'INFO');

%% Load All Session (Patient) IDs
metaData = loadMetaData(projectPaths, logFilePath);

%% Select Patients and Brain Regions
[selectedPatients, selectedRegions] = selectPatientsAndRegions(...
    metaData, brainRegions, selectedPatientIDs, selectedBrainRegions, logFilePath);

%% Populate Structured Data Containers for Patients Dynamically and Save
patientsData = processPatients(selectedPatients, projectPaths, logFilePath);

%% Extract LFP from Selected Brain Regions
patientsData = extractLFP(patientsData, brainRegions, selectedRegions, projectPaths, logFilePath);

%% Filter out Patients Missing LFP from Any of the Selected Brain Regions
[filteredPatientsData, metaDataExt] = filterPatientsLFP(patientsData, selectedRegions, projectPaths, logFilePath);

%% Update MetadataExt
metaDataExt.allPatientIDs = metaData.sessionID;
metaDataExt.trialInfoLabels = metaData.trialInfoLabels;
metaDataExt.bycycleTableLabels = metaData.bycycleTableLabels;
metaDataExt.projectPaths.metaDataExtPath = fullfile(projectPaths.dataPath, 'metaDataExt.mat');
metaDataExt.projectPaths.pythonEngineDir = pythonEngineDir;
metaDataExt.projectPaths.logFilePath = logFilePath;
metaDataExt.selectedRegions = {selectedRegions};

%% Create Recycle Directory and Move Original metaData.mat
recycleMetaData(projectPaths, logFilePath);

%% Decompose Structure of all .mat Files into Nested Trees inside .txt Files

%extractMatFilesToText(pwd, 1);

% extractMatFilesToText.m included in codebase though not used here.

%% Save and Validate MetaDataExt 
[metaDataExtFilePath, logFilePath] = saveExtendedMetadata(metaDataExt, logFilePath);

%% Clean Up Workspace
clearvars -except metaDataExtFilePath logFilePath

%% Log Completion and Initialize Python Pipeline
currentDateTimeStr = datestr(now, 'dd-mmm-yyyy HH:MM:SS');
elapsedTime = toc();  

% Log MATLAB pre-processing completion
logMessage("MATLAB pre-processing complete.", logFilePath, 'INFO');

% Create a log entry for initializing the Python pipeline
message = sprintf('%s Initializing theta burst feature extraction pipeline in Python... Elapsed time: %.4f seconds', ...
    currentDateTimeStr, elapsedTime);
logMessage(message, logFilePath, 'INFO');

%% Initialize Theta Burst Feature Extraction Pipeline in Python using Bycycle package
call_python_bycycle(metaDataExtFilePath, logFilePath);
