% Code to plot simulation results from ssc_main_model
%% Plot Description:
%
% Plot "Cylinder Pressure, Solver Types" shows the effect of solver type on
% simulation results.  The variable-step simulation uses smaller simulation
% steps to accurately capture the system dynamics.  The fixed-step
% simulation results are close but do not exactly match the variable-step
% simulation results, for the solver is not permitted to adjust its step
% size.  The fixed-step solver settings should be adjusted until the
% fixed-step simulation results are within an acceptable range of the
% variable-step simulation results.

% Copyright 2015 The MathWorks, Inc.

% Reuse figure if it exists, else create new figure
if ~exist('h2_ssc_main_model', 'var') || ...
        ~isgraphics(h2_ssc_main_model, 'figure')
    h2_ssc_main_model = figure('Name', 'ssc_main_model');
end
figure(h2_ssc_main_model)
clf(h2_ssc_main_model)


temp_solverBlockPth = find_system(bdroot, 'SubClassName', 'solver');

set_param(char(temp_solverBlockPth), 'UseLocalSolver','off');
sim('ssc_main_model');
data_varstep = simlog_ssc_main_model;
set_param(char(temp_solverBlockPth), 'UseLocalSolver','on');
sim('ssc_main_model');
data_fixstep = simlog_ssc_main_model;

% Get simulation results
temp_pCylAfix = data_fixstep.Hydraulic_Actuator.Hydraulic_Cylinder.Chamber_A.A.p.series;
temp_pCylAvar = data_varstep.Hydraulic_Actuator.Hydraulic_Cylinder.Chamber_A.A.p.series;

% Plot results
ah(1) = subplot(2,1,1);
plot(temp_pCylAvar.time,temp_pCylAvar.values,'LineWidth',2);
hold on
stairs(temp_pCylAfix.time,temp_pCylAfix.values,'k','LineWidth',1);
hold off
grid on
title('Cylinder Pressure, Solver Types');
ylabel('Pressure (Pa)');
legend({'Side A, Variable Step','Side A, Fixed Step'},'Location','NorthEast');
ah(2) = subplot(2,1,2);
varstep_time = temp_pCylAvar.time;
semilogy(varstep_time(1:end-1),diff(varstep_time),'LineWidth',1);
hold on
semilogy([0 varstep_time(end-1)],[ts ts],'k--','LineWidth',1)
hold off
grid on
title('Simulation Step Size');
legend({'Variable Step','Fixed Step'},'Location','Best');
ylabel('Step Size (s)');
xlabel('Time (s)');

set(ah,'XLim',[1.795 1.83])
linkaxes(ah,'x');

% Remove temporary variables
clear temp_pCylAvar temp_pCylBvar temp_pCylAfix temp_pCylBfix varstep_time temp_solverBlockPth ah
clear data_varstep data_fixstep