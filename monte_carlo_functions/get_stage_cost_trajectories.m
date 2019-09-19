%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Generates many stage cost trajectories from a single initial 
%   condition and confidence level. Should be called from
%   generate_reproducible_stage_cost_trajectories, which will set
%   the appropriate x_index and l_index. 
%           
% INPUT:
%   Zs: transition fo the confidence level under optimal policy
%	mus: optimal controllers
%	x_index: index of the initial state to use
%	l_index: index of the confidence level to use
%   nt: number of stage cost trajectories to sample 
%   cfg: struct containing configuration (created with get_configuration)
%   scn: struct containing scenario (created with get_sceanrio)
%   amb: struct containing ambient informatino (created with
%       calculate_ambient_variables)
% OUTPUT: 
%   stage_cost_trajectories: a matrix of stage cost time series
%       (each sample is an individual row, each column is a time
%       coordinate)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stage_cost_trajectories = get_stage_cost_trajectories(Zs, mus, x_index, l_index, nt, cfg, scn, amb)

    zInterpolants = get_z_interpolants(Zs);
    muInterpolants = get_mu_interpolants(mus); 

    nw = length(scn.ws); tick_P = zeros( nw + 1, 1 );                     % nw : number of possible values of wk

    for i = 1 : nw, tick_P(i+1) = tick_P(i) + scn.P(i); end               % tick_P = [ 0, P(1), P(1)+P(2), ..., P(1)+...+P(nw-1), 1 ]

    nl = length(cfg.ls); 
    
    if strcmp(scn.risk_functional,'EXP')
       nl = 1;  
    end

    N = cfg.T / cfg.dt; % number of timesteps per trial
    
    stage_cost_trajectories = zeros(1, 1, nt, N+1); 
    
    disp('start time:');
    display(datestr(datetime('now'),'HH:MM:SS'));
     
    y = cfg.ls(l_index);
             
    stage_costs_by_trial = zeros(N+1, nt); 
             
    for q = 1:nt
                    
        [myTraj, myConf, myCtrl, myCosts] = sample_trajectory(amb.xcoord(x_index,:), y, tick_P, muInterpolants, zInterpolants, scn, cfg, amb);  % get trajectory sample
        stage_costs_by_trial(:, q) = myCosts; 
                    
    end
    
    disp('end time:');
    display(datestr(datetime('now'),'HH:MM:SS'));
                
    % (nl, ambient.nx, nt, N)
    stage_cost_trajectories(1, 1, :, :) =  stage_costs_by_trial(:,:)'; 