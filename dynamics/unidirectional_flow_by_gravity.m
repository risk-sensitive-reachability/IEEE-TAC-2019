%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: 
  %  In one dimension: defines discrete-time dynamics of pond discharging through an orifice
  %  In two dimensions: defines discret-time dynamics of pond discharging through an orifice into a stream
% INPUT:
    % xk : water elevation at time k [ft]
    % uk : valve setting at time k [no units]
    % wk : average surface runoff rate on [k, k+1) [ft^3/s]
    % config struct 
    % scenario struct 
% OUTPUT:
    % xkPLUS1 : water elevation at time k+1 [ft]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xkPLUS1 = unidirectional_flow_by_gravity( xk, uk, wk, config, scenario)

% xk is a row vector where
% xk(1) is x1 at current time step
% xk(2) is x2 at current time step

% Assumptions
%   discharge from pond s1 into stream s2 through controlled orifice (q_outlet)
%   s2 flows out of the model via q_stream

f = ones(scenario.dim,1);

SA = scenario.surface_area_s1;        % [ft^2]
R = scenario.outlet_radius_s1;        % [ft] 
Z = scenario.outlet_elevation_s1;     % [ft] from pond base

q_valve = q_outlet( xk(1), uk, R, Z );

% f is a column vector where
% f(1) is x1_dot
% f(2) is x2_dot

f(1) = (wk(1)-q_valve) /SA;  % time-derivative of x [ft/s]

if scenario.dim > 1
    if scenario.asymmetric_disturbance == false
        wk = [wk, wk]; 
    end
    f(2) = ( wk(2) - q_stream(xk(2), scenario) + q_valve) / (4 * scenario.stream_length); 
end

% xkPLUS1 is a row vector where
% xkPLUS1(1) is x1 at next time step
% xkPLUS1(2) is x2 at next time step

xkPLUS1 = xk + f'*config.dt;


        
        
