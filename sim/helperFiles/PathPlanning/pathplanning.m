function [waypoints,timespot,way,T_stop] = pathplanning(a,b,start,goal)
% This function performs path planning for a given image
% Inputs: a -> scenario number
%         b -> number of waypoints
%         start -> vector for the initial location 
%         goal ->  vector for the end location
% Outputs: waypoints -> matrix with the coordinates x,y,z of waypoints
%          timespot -> vector with time stops needed in the Simulink model
%          way  -> vector that feeds into the attitude controller in
%          Simulink
%          T_stop -> Total time for the simulation
%

if (nargin < 4)
    goal = [5,8,6];   %Default goal location
end
if (nargin < 3)
    start = [-3,-5,6]; %Default start location 
end
if (nargin < 2)
    b=10;   %If no number of waypoints, use 10
end
if (nargin < 1)
    a=1;   %If no option is provided, assign first scenario
end

%Obtain filename
scenarioimg = ['imageMap' num2str(a) '.png'];

% Convert an image to a binary occupancy grid 
% This will be used for path planning.Import image.
image = imread(scenarioimg);
%Convert to grayscale and then black and white image based on given threshold value.
grayimage = rgb2gray(image);
bwimage = grayimage < 0.5;
%Use black and white image as matrix input for binary occupancy grid.
%Set the resolution to 10 cells per meter for this map
grid = binaryOccupancyMap(bwimage,10);
grid.GridLocationInWorld = [-12.5 -12.5];


% Plan Path Between Two States
% Create a state space
ss = stateSpaceSE2;
sv = validatorOccupancyMap(ss);
sv.Map = grid;
sv.ValidationDistance = 1.8;  
ss.StateBounds = [grid.XWorldLimits;grid.YWorldLimits; [0 25]]; 
% Use RRT to generate path
planner = plannerRRT(ss,sv);
planner.MaxConnectionDistance = 0.3;


rng(100,'twister'); % for repeatable result
[pthObj,solnInfo] = plan(planner,start,goal);

A = [pthObj.States(:,1),pthObj.States(:,2)];
num_points = size(A,1);
interval = ceil(num_points/b)+1;
waypoints_list = A(1:interval:end,:);


z_values = 6 + zeros(size(waypoints_list,1),1);

%Add z values
waypoints_final = [waypoints_list,z_values];
%Add the goal location as the last point
waypoints_final = [waypoints_final;goal]; 

waypoints = waypoints_final';

%Check the results visually
% fig = figure;
% set(fig, 'Visible', 'off');
% show(grid)
% hold('on')
% plot(solnInfo.TreeData(:,1),solnInfo.TreeData(:,2),'.-'); % tree expansion
% plot(pthObj.States(:,1),pthObj.States(:,2),'r-','LineWidth',2); % draw path
% plot(waypoints_list(:,1),waypoints_list(:,2),'g*');

% Generate timesteps vector
T_stop = 0;
x_waypt = waypoints(1,:)';
y_waypt = waypoints(2,:)';
z_waypt = waypoints(3,:)';
V_nominal = 1; % m/s
xTrajPts = [start(1);x_waypt];
yTrajPts = [start(2);y_waypt];
zTrajPts = [0.05;z_waypt];
timespot(1,1) = 0;
for i = 1:1:(length(x_waypt))
    dx = xTrajPts(i) - xTrajPts(i+1);
    dy = yTrajPts(i) - yTrajPts(i+1);
    dz = zTrajPts(i) - zTrajPts(i+1);
    tx = abs(dx)/V_nominal;
    ty = abs(dy)/V_nominal;
    tz = abs(dz)/V_nominal;
    timespot(1,i+1) = timespot(1,i) + max([tx ty tz]);
end
T_stop = timespot(1,end) + 3;

%Generate 'way' vector to feed into Attitude controller in Simulink
[ row,column] = size(waypoints);
way = zeros(1,row*column);
counter = 2;
for i = 1:column
    for j = 1:row
        way(counter) = waypoints(j,i);
        counter = counter+1;
    end
end


