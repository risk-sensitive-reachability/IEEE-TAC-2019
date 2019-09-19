%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Compute open channel flow for triangular cross-section via Manning's equation 
% INPUTS: 
%	x = stream flow depth vector [ft]
%	scenario struct 
% OUTPUT: 
%	open channel flow vector [ft^3/s]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function q = q_stream(x, scenario)

sisl = scenario.side_slope;  % side slope, stream
m = 1 / sisl;                % side slope inverse
n = scenario.mannings_n;     % Manning's roughness coefficient [s/m^(1/3)]
S = scenario.stream_slope;   % slope [ft/ft]
Z = scenario.outlet_elevation_stream;

r = (m/( 2*sqrt(1 + m^2) )) * x;        % hydraulic radius [ft]

a = m * x.^2;                           % flow area [ft^2]

q_forBigX = a .* r.^(2/3) * (1.486/n*sqrt(S));

q_forSmallX = 0;

q = ( x >= Z ).*q_forBigX + ( x < Z ).*q_forSmallX;