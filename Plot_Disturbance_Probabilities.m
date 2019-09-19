%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Plots the perturbed and unperturbed probability distrubtions
%   associated with the given scenario. 
% INPUTS:
%   scenarioID = the string id of the scenario to use    
%   configurationID = the numeric id of the configuration to use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = Plot_Disturbance_Probabilities(scenarioID) 

    scn = get_scenario(scenarioID);

    perturbedP = perturb_discrete_probabilities(scn.P, scn.ws);
    
    plot(scn.ws, scn.P, '*k'); hold on; plot(scn.ws, perturbedP, 'or');
    grid on; legend('Original','Perturbed');
    xlabel('$d_t$', 'Interpreter', 'Latex', 'FontSize', 16); 
    ylabel('$P(d_t)$', 'Interpreter', 'Latex', 'FontSize', 16);
    
end