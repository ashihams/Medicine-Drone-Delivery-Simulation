%function [waypoints, timespot, way] = appPathPlanning(app, nWaypoints, options)
function [waypoints, timespot, way, T_stop,scenario] = appPathPlanning(app, options)
    arguments
        app PathPlanner
        %nWaypoints double
        options.start (1, 3) {mustBeNumeric} = [-3, -5, 6]
        options.goal (1, 3) {mustBeNumeric} = [5, 8, 6];
    end
    
    %b = nWaypoints;
    b = 10;
    start = options.start;
    goal = options.goal;

    %Update value for scenario variable in workspace
    if app.NoobstaclesButton.Value   %where "Button1" is the name of the first radio button
        scenario = 1;
    elseif app.OneobstacleButton.Value
        scenario = 2;
    else
        scenario = 3; 
    end
    %Convert to grayscale and then black and white image based on given threshold value.
    grayimage = rgb2gray(app.MapImage);
    bwimage = grayimage < 0.5;
    %Use black and white image as matrix input for binary occupancy grid.
    %Set the resolution to 10 cells per meter for this map
    grid = binaryOccupancyMap(bwimage,10);
    grid.GridLocationInWorld = [-12.5 -12.5];
    
    %% Plan Path Between Two States

    %Create a state space

    ss = stateSpaceSE2;
    sv = validatorOccupancyMap(ss);
    sv.Map = grid;
    sv.ValidationDistance = 1.8;
    %ss.StateBounds = [grid.XWorldLimits;grid.YWorldLimits; [0 250]];  
    ss.StateBounds = [grid.XWorldLimits;grid.YWorldLimits; [0 25]]; 
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
    %fig = uifigure;
    %ax = uiaxes(fig);
    %hold(ax,'on')
    fig = app.UIAxes;
%     set(fig, 'Visible', 'off');
    show(grid, 'Parent', fig)
    hold(fig, 'on');
    plot(fig, solnInfo.TreeData(:,1),solnInfo.TreeData(:,2),'.-'); % tree expansion
    plot(fig, pthObj.States(:,1),pthObj.States(:,2),'r-','LineWidth',2); % draw path
    plot(fig, waypoints_list(:,1),waypoints_list(:,2),'g*');
    hold(fig, 'off');
    

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
end
