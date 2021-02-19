% -------------------------------
% c = cp of air (273 K) = 1005.4 J/kg-K
c = 1005.4;
% -------------------------------
% Enter the temperature of the heated air
% -------------------------------
% The air exiting the heater has a constant temperature which is a heater
% property. THeater = 50 deg C
THeater = 50;
% Air flow rate Mdot = 1 kg/sec = 3600 kg/hr
Mdot = 3600;  % hour is the time unit, multiply by n_rooms within sim
% -------------------------------
% Enter the cost of electricity and initial internal temperature
% -------------------------------
% Assume the cost of electricity is $0.09 per kilowatt/hour
% Assume all electric energy is transformed to heat energy
% 1 kW-hr = 3.6e6 J
% cost = $0.09 per 3.6e6 J
cost = 0.09/3.6e6;
% TinIC = initial indoor temperature = 20 deg C
TinIC = 20;

%% Air conditioner
dTac = 20*(5/9); % deg C
eta_ac = 0.85; % efficiency of air conditioner