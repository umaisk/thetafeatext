┌───────────────────────────────────────────────────────────────────────────────────────┐  
                            Codebase Author: Umais Khan          
                                               
    (for all .m files except the dependencies listed below and for RunBycycle.py file)                                                     
└───────────────────────────────────────────────────────────────────────────────────────┘  

┌───────────────────────────────────────────────────────────────────────────────────────┐  
                                  Description:                                               
                   
 This script processes intracranial EEG data collected in Ueli Rutishauser's Lab at                           
 Cedars-Sinai Medical Center, Department of Neurosurgery. The EEG processing here                               
 was used for analyses shown in Extended Figure 3c of the following publication.                                
└───────────────────────────────────────────────────────────────────────────────────────┘  

┌───────────────────────────────────────────────────────────────────────────────────────┐  
                                  Publication:                    
                                              
 Control of working memory by phase–amplitude coupling of human hippocampal neurons.                             
 Nature 629, 393–401 (2024). https://doi.org/10.1038/s41586-024-07309-z                                         
└───────────────────────────────────────────────────────────────────────────────────────┘  

┌───────────────────────────────────────────────────────────────────────────────────────┐  
                               Publication Authors:                 
                                            
 Jonathan Daume, Jan Kamiński, Andrea G. P. Schjetnan, Yousef Salimpour,                                          
 Umais Khan, Michael Kyzar, Chrystal M. Reed, William S. Anderson,                                              
 Taufik A. Valiante, Adam N. Mamelak, Ueli Rutishauser                                                          
└───────────────────────────────────────────────────────────────────────────────────────┘  

┌───────────────────────────────────────────────────────────────────────────────────────┐  
                               Python Dependencies:

Cole, S., & Voytek, B. (2019). Cycle-by-cycle analysis of neural oscillations. 
Journal of Neurophysiology, 122(2), 849-861. 
https://doi.org/10.1152/jn.00273.2019
ByCycle Documentation: https://bycycle-tools.github.io/bycycle/

Cole, S., Donoghue, T., Gao, R., & Voytek, B. (2019). NeuroDSP: A package for neural digital signal processing. 
Journal of Open Source Software, 4(36), 1272. 
https://doi.org/10.21105/joss.01272
NeuroDSP Documentation: https://neurodsp-tools.github.io/
└───────────────────────────────────────────────────────────────────────────────────────┘  

┌───────────────────────────────────────────────────────────────────────────────────────┐  
                   MATLAB Dependencies (Author: Jonathan Daume, 2020):  
                                               
 - defineTrialsStCat.m                                                                                          
 - defineStCATsessions.m                                                                                        
 - trialinfoSternbergCAT.m                                                                                    
 - closest.mexw64  

 *All four of these files have been omitted.*                   
└───────────────────────────────────────────────────────────────────────────────────────┘  

┌───────────────────────────────────────────────────────────────────────────────────────┐  
                               *IMPORTANT*  
                                                             
 A sample of the pipeline's final output is available to view here:     
                                         
 '.\data\cycle_features\PatientID1\BrainRegion2\PatientID1_BrainRegion2_bycycle_features_YYYYMMDD_#####_sample.csv'  

 A sample of MATLAB log file can be viewed inside '.\logs' and Python log file inside '.\RunBycycle.log'  

 This codebase is not intended to allow execution of the pipeline as all data and                             
 some core .m file dependencies have been omitted. It is assembled to provide the                                 
 user with a high-level understanding of the software architecture, including:         
                      
    - Error handling and validations                                                                             
    - Logging and modularity                                                                                     
    - Integration of Python-MATLAB environments                                                                   
    - Documentation practices                                                                                    
    - Clean, efficient vectorized code                                                                           
└───────────────────────────────────────────────────────────────────────────────────────┘  

┌───────────────────────────────────────────────────────────────────────────────────────┐  
                          Overview of Codebase Function:     
                                                        
 - Initializes the project setup by verifying file structures and dependencies                                  
 - Defines project paths and brain regions                                                                      
 - Loads session IDs (patients) and selects specific sessions/regions                                           
 - Declares and populates structured data containers with trial information                                     
 - Extracts LFP data from selected brain regions                                                                
 - Filters sessions based on LFP data availability                                                              
 - Initiates the Theta Burst Feature Extraction pipeline in Python using Bycycle and neuroDSP                               

                                                                                                        
 Note: The terms 'session' and 'patient' are used interchangeably throughout the codebase.                            
 Each session corresponds to one patient's data for a given recording/experimental                               
 session.                                                                                                       
└───────────────────────────────────────────────────────────────────────────────────────┘  

┌───────────────────────────────────────────────────────────────────────────────────────┐  
                                 Instructions to Execute: 
                                                            
 1. Ensure that all function files (.m) and .mex file are present in the current                                
    directory. Additionally, verify that RunBycycle.py and requirements.txt (with                                
    Python dependencies) are also located in the same directory.                                                 
 2. Configure the selectedPatientIDs and selectedBrainRegions variables as                                       
    needed. All selected brain regions will be analyzed for the specified patients.  
 3. Open MATLAB in ADMINISTRATOR MODE, navigate to the project directory containing `MAIN.m` 
    (e.g., C:\Users\your-username\Desktop\ThetaFeatureExtraction) using the MATLAB command window to execute MAIN.m

    '''matlab
    cd C:\your-project-path
    MAIN
    '''  
                          
 4. This script will automatically:                                                       
    • Organize code and data files into their respective subfolders.                                             
    • Verify the correct placement of each required file.                                                         
    • Check that all Python dependencies listed in requirements.txt are installed with                           
      the appropriate versions.                                                                                  
 5. All subsequent function calls will be accessed from the 'src' directory,                                     
    which will be added to the MATLAB Path automatically.                                                        
 6. Review the detailed MATLAB log in .\logs directory. Each setup execution creates                               
    a uniquely named log file (e.g., MATLAB-console-log_YYYYMMDD_HHMMSS.log) that                                
    contains comprehensive information about the setup process, including any errors                             
    or warnings encountered. An additional Python log file will be created inside of .\RunBycycle.log                                         
└───────────────────────────────────────────────────────────────────────────────────────┘  

┌───────────────────────────────────────────────────────────────────────────────────────┐  
                           Python Engine Setup:     
                                                            
 This script requires the MATLAB-Python Engine to run the Theta Burst Feature                                    
 Extraction pipeline via the Bycycle package in Python:      
                                                    
 https://github.com/bycycle-tools/bycycle                                                                        
───────────────────────────────────────────────────────────────────────────────────────  

┌───────────────────────────────────────────────────────────────────────────────────────┐  
                         Step 1: Install Python (version 3.x)   
                                                 
 - Ensure a compatible version of Python is installed from: 
                                                     
   https://www.python.org/downloads/ 
                                                                            
 - Enable the "Add Python to PATH" option during installation                                                   
└───────────────────────────────────────────────────────────────────────────────────────┘  

┌───────────────────────────────────────────────────────────────────────────────────────┐  
                      Step 2: Verify Python Installation       
                                                  
 - Open a terminal (or Command Prompt on Windows) and run:
                                                       
   python --version  
                                                                                            
 - Ensure the version matches the one required by MATLAB                                                         
└───────────────────────────────────────────────────────────────────────────────────────┘  

┌───────────────────────────────────────────────────────────────────────────────────────┐  
                   Step 3: Install MATLAB Engine for Python     
                                                 
 - Navigate to the MATLAB Python engine directory, for example:    
                                              
   '''bash
   cd "C:\Program Files\MATLAB\R2024b\extern\engines\python"
   '''  

 - Install the engine using:                                  
                                                   
   '''bash
   python setup.py install
   '''  
└───────────────────────────────────────────────────────────────────────────────────────┘  

┌───────────────────────────────────────────────────────────────────────────────────────┐  
                   Step 4: Verify the MATLAB Engine Installation   
                                              
 - Open a Python interpreter and try importing the MATLAB engine:            
                                    
   '''python
   import matlab.engine
   '''

 - If the import is successful, the installation is complete                                                     
└───────────────────────────────────────────────────────────────────────────────────────┘  

┌───────────────────────────────────────────────────────────────────────────────────────┐  
                             Troubleshooting Guide      
                                                         
 - If issues arise with Python Engine, ensure both Python and MATLAB are added to your system’s PATH.                                                                                           
 - Refer to MATLAB-Python integration documentation for further help: 
                                           
   https://www.mathworks.com/help/matlab/matlab-engine-for-python.html     
                                      
 - Each function contains its own docstring, accessible for additional clarification.                            
 - Verify that all directories and file paths in definePaths.m are correctly                                     
   defined and accessible.                                                                                        
 - Ensure the Python Engine path is correctly defined and accessible within MAIN.m.                              
 - Verify that each session (patient) has the following four .mat files:     
                                    
     <PatientID>_allChanSpkRmvl.mat                                                                              
     <PatientID>_highAmp4_highDiff10.mat                                                                         
     <PatientID>_highAmp4_highDiff10_corr.mat                                                                    
     <PatientID>_suaInfo.mat                                    
                                             
 - Ensure these .mat files along with metaData.mat are present in the current directory.  
                                                                                                
 - Review the generated log files for detailed error messages and processing steps. 

 *All .mat files containing patient data and metaData.mat file have been omitted.*                                                     
└───────────────────────────────────────────────────────────────────────────────────────┘  
