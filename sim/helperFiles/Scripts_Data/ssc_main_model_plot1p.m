% Code to plot simulation results from ssc_main_model
%% Plot Description:
%
% Plot "Cylinder Pressures" shows how the cylinder pressure varies during
% simulation.  It corresponds with the opening of the valve.  The
% opening of the valve is set by the controller so that the actuator tracks
% a reference signal.

% Copyright 2019 The MathWorks, Inc.

% Generate simulation results if they don't exist
if ~exist('simlog_ssc_main_model', 'var')
    sim('ssc_main_model')
end

% Reuse figure if it exists, else create new figure
if ~exist('h1_ssc_main_model', 'var') || ...
        ~isgraphics(h1_ssc_main_model, 'figure')
    h1_ssc_main_model = figure('Name', 'ssc_main_model');
end
figure(h1_ssc_main_model)
clf(h1_ssc_main_model)

% Get simulation results
temp_pCylA = simlog_ssc_main_model.Hydraulic_Actuator.Hydraulic_Cylinder.Chamber_A.A.p.series;
temp_pCylB = simlog_ssc_main_model.Hydraulic_Actuator.Hydraulic_Cylinder.Chamber_B.A.p.series;
temp_aValve = simlog_ssc_main_model.Hydraulic_Actuator.Custom_2_Way_Valve.Calculate_Orifice_Area.PS_Saturation.O.series;

% Plot results
ah(1) = subplot(2,1,1);
plot(temp_pCylA.time,temp_pCylA.values,'LineWidth',1);
hold on
plot(temp_pCylB.time,temp_pCylB.values,'LineWidth',1);
hold off
grid on
title('Cylinder Pressures');
ylabel('Pressure (Pa)');
legend({'Side A','Side B'},'Location','Best');
ah(2) = subplot(2,1,2);
plot(temp_aValve.time,temp_aValve.values,'LineWidth',1);
grid on
title('Valve Opening vs. Time');
ylabel('Opening (m^2)');
xlabel('Time (s)');

linkaxes(ah,'x');

% Remove temporary variables
clear temp_pCylA temp_pCylB temp_aValve ah
