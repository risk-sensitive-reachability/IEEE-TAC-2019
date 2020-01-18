%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Generates histograms of results from many random trajectories 
%   originating from the same initial condition (one for each initial
%   confidence level if using CVaR). 
% INPUTS:
%   scenarioID = the string id of the scenario to use    
%   configurationID = the numeric id of the configuration to use
%   x0 = vector of initial conditions
%   [file]
%       /staging/{configurationID}/{scenarioID}/Bellman_complete.mat : a
%       file containing results for all recursion steps  
% OUTPUTS:
%   [file](s)
%       /staging/{configurationID}/{scenarioID}/histogram_[x0][*].png :
%       Portable Network Graphics histogram(s)
%   [file](s) 
%       /staging/{configurationID}/{sceanrioID}/histogram_[x0][*].fig : 
%       Matlab histograms(s) 
%   [file](s)
%       /staging/{configurationID}/{sceanrioID}/summary_[x0][*].txt : 
%       a summary of results to accompany the histograms
%   [file](s)
%       /staging/{configurationID}/{sceanrioID}/stage_cost_trajectories_[x0][*].mat : 
%       a Matlab file containing the stage cost trajectories used to generate
%       the histogram
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = Plot_Histograms(scenarioID, configurationID, x0) 

    staging_area = get_staging_directory(scenarioID, configurationID); 
    bellman_file = strcat([staging_area,'Bellman_complete.mat']);
    
    
    % if bellman_file is available, load it, otherwise prompt to Run_Bellman_Recursion.
    if isfile(bellman_file)

       load(bellman_file); 

    else

       error('No results available for this scenario and configuration. Please Run_Bellman_Recursion.');

    end
    
    % load globals
    global scenario; 
    global ambient; 
    global config; 

    if strcmp(scenario.risk_functional, 'CVAR')
        confidence_levels_to_evaluate = config.histogram_levels;   
    else
        confidence_levels_to_evaluate = 1;  
    end
    
    for j = 1:length(confidence_levels_to_evaluate)
       
        l0 = confidence_levels_to_evaluate(j); 
        generate_histograms(scenarioID, configurationID, x0, l0, false); 
                
    end

end