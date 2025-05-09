


% Check permissions in current folder
fileName = 'Delivery';
[fid,errmsg] = fopen(fileName, 'w');
if ~isempty(errmsg)&&strcmp(errmsg,'Permission denied') 
    fprintf('\nError: You do not have write permission to the folder containing (%s).\n',fileName);
    fprintf('\nPlease make a copy of the original workshop folder and navigate to it.\n');
else
   
    % Add files to path
    addpath(fullfile(pwd,'helperFiles'));
    addpath(genpath('helperFiles'));
    addpath("C:\Users\ashih\OneDrive\Desktop\Quadcopter_DigitalTwin_Workshop\helperFiles\Libraries")

    
    % Initialize parameters
    Quadcopter_EMech_param_Ex2;
    initial_x = 0;
    initial_y = 0;
    % Open Simulink model
    open_system('Delivery');
    
    warning('off','all')

    torqueFault1 = 0;
    torqueFault2 = 0;
    torqueFault3 = 0;
    torqueFault4 = 0;
    tFault1 = 1;
    tFault2 = 1;
    tFault3 = 1;
    tFault4 = 1;
end

