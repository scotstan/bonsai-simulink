function [M, Req] = determine_room_params(numWindows)
    % -------------------------------
    % Define the room geometry
    % -------------------------------
    % convert radians to degrees
    r2d = 180/pi;
    % Room length = 30 m
    lenRoom = 30;
    % Room width = 10 m
    widRoom = 10;
    % Room height = 4 m
    htRoom = 4;
    % Roof pitch = 40 deg
    pitRoof = 40/r2d;
    % Number of windows = 6
    numWindows = numWindows;
    % Height of windows = 1 m
    htWindows = 1;
    % Width of windows = 1 m
    widWindows = 1;
    windowArea = numWindows*htWindows*widWindows;
    wallArea = 2*lenRoom*htRoom + 2*widRoom*htRoom + ...
               2*(1/cos(pitRoof/2))*widRoom*lenRoom + ...
               tan(pitRoof)*widRoom - windowArea;
    % -------------------------------
    % Define the type of insulation used
    % -------------------------------
    % Glass wool in the walls, 0.2 m thick
    % k is in units of J/sec/m/C - convert to J/hr/m/C multiplying by 3600
    kWall = 0.038*3600;   % hour is the time unit
    LWall = .2;
    RWall = LWall/(kWall*wallArea);
    % Glass windows, 0.01 m thick
    kWindow = 0.78*3600;  % hour is the time unit
    LWindow = .01;
    RWindow = LWindow/(kWindow*windowArea);
    % -------------------------------
    % Determine the equivalent thermal resistance for the whole building
    % -------------------------------
    Req = RWall*RWindow/(RWall + RWindow);
    % -------------------------------
    % Determine total internal air mass = M
    % -------------------------------
    % Density of air at sea level = 1.2250 kg/m^3
    densAir = 1.2250;
    M = (lenRoom*widRoom*htRoom+tan(pitRoof)*widRoom*lenRoom)*densAir;
end