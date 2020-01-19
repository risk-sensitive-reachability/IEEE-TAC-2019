%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Create a structure containing scenario-agnostic simulation information
% INPUT:
%   configId = the numeric id of the configuration to use
% OUTPUT:
%   config = a structure containing scenario-agnostic simulation information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function config = get_config(configId)

    config = [];

    % Maximum number of controls to attempt to
    % attempt a solution for in a single LP
    
    % NOTE: The parallel implementation only supports 1 control per LP. 
    config.max_us_per_LP = 1;                       
    
    % Maximum number of confidence levels (y in state space)
    % to attempt a solution for in a single LP
    
    % NOTE: The parallel implementation only supports 1 confidence level
    % per LP. 
    config.max_ls_per_LP = 1;                       

    % discretized confidence levels
    % n.b. descending order matters when you get to the stage where you interpolate  markov policies
    % 
    % VERY_FINE_LS and LESS_FINE_LS, put in more points around 0.99, 0.05, 0.01, compared with
    % STANDARD_LS since we care about these levels most
    % use VERY_FINE_LS for temperature system
    % use LESS_FINE_LS for pond system to compensate for more states
    VERY_FINE_LS = [ 0.999, 0.995, 0.99, 0.95, 0.9, 0.8, 0.7, 0.5, 0.3, 0.2, 0.1, 0.07, 0.05, 0.03, 0.01, 0.005, 0.001 ]';
    LESS_FINE_LS = [ 0.999, 0.995, 0.99, 0.95:-0.15:0.2, 0.07, 0.05, 0.03, 0.01, 0.005, 0.001]';
    STANDARD_LS = [ 0.999, 0.95:-0.15:0.05, 0.001 ]';

    config.monte_carlo_trials = 100000; 				% number of trials per grid point for W_0* estimation
    config.monte_carlo_levels = [ 0.99, 0.05, 0.01 ];	% ls to at which to estimate W_0*

    config.histogram_trials = 1000 * 1000;              % number of samples to use when generating histogram
    config.histogram_levels = [ 0.99, 0.05, 0.01 ];     % ls at which to initialize histogram 
    
    config.dt = 300;                                	% Duration of [k, k+1) [sec], 5min = 300sec
    config.T = 3600*4;                              	% Design storm length [sec], 4h = 4h*3600sec/h

    config.grid_upper_buffer = 1.5;                		% [ft]
    config.grid_lower_buffer = 0; 
    
    config.solver_path = which('linprog'); 

    switch configId

        case 0
            config.id = '0';
            config.grid_spacing = 1/10;        % [ft] state discretization interval
            config.ls = STANDARD_LS;
            config.m = 10;
            config.beta = 10^(-3);
            config.monte_carlo_levels = STANDARD_LS;

        case 1
            config.id = '1';
            config.grid_spacing = 1/10;        % [ft] state discretization interval
            config.beta = 0.00000000002;
            config.m = 13;
            config.ls = LESS_FINE_LS;

        case 2                                 %temperature example
            config.id = '2';
            config.grid_spacing = 1/10;        % [degrees C]
            config.dt = 5/60;                  % Duration of [k, k+1) in hours, 5 min = 5/60 h
            config.T = 1;                      % length of time horizon in hours, 60 min = 1 h
            config.grid_upper_buffer = 2;      % [deg C]
            config.grid_lower_buffer = 2;      % [deg C]
            config.ls = VERY_FINE_LS;          % column vector

        otherwise
            disp('error loading config')

    end

end