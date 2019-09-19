%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Generates many stage cost trajectories from a single initial 
%   condition and confidence level using the default random number 
%   generator seed.
%           
% INPUT:
%   Zs: transition fo the confidence level under optimal policy
%	mus: optimal controllers
%	x0: initial state vector
%	l0: initial confidence level
%   n: number of stage cost trajectories to sample 
%   perturbed: boolean, should the probabilities be perturbed?
% OUTPUT: 
%   stage_cost_trajectories: a matrix of stage cost time series
%       (each sample is an individual row, each column is a time
%       coordinate)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stage_cost_trajectories = generate_reproducible_stage_cost_trajectories(Zs, mus, x0, l0, n, perturbed)
    
    
    global ambient;
    global scenario; 
    global config; 
    
    amb = ambient;
    cfg = config; 
    scn = scenario; 
    
    if  perturbed
        scn.P = perturb_discrete_probabilities(scn.P, scn.ws); 
    end
    
    % for reproducibility
    rng('default'); 
    
    if scenario.dim == 2
    
        x_index = find(ambient.xcoord(:,1) == x0(1) & ambient.xcoord(:,2) == x0(2),1);
    
    else 
        
        x_index = find(ambient.xcoord(:,1) == x0); 
        
    end
    
    
    if strcmp(scenario.risk_functional, 'CVAR')
        
        l_index = find(config.ls == l0); 
        
    else
        
        l_index = 1;
        
    end
    
    stage_cost_trajectories = get_stage_cost_trajectories(Zs, mus, x_index, l_index, n, cfg, scn, amb);

end
                