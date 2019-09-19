%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Fills several fields of scenario struct for therm_ctrl_load system
% INPUT:
    % scenarioId = the string id of the scenario to use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function scenario = fill_scenario_fields_thermsys(scenarioId)

	scenario = []; scenario.dim = 1; scenario.id = scenarioId;

	scenario.title = ['Scenario ', scenarioId];

	scenario.ws = linspace(-0.5, 0.5, 11);

	scenario.P = [0.001; 0.003; 0.006; 0.05; 0.11; 0.18; 0.17; 0.145; 0.12; 0.11; 0.105];

	scenario.nw = length(scenario.ws); 

	scenario.allowable_controls = 0: 0.1: 1;

	scenario.cost_function_aggregation = str2func('sum');

	scenario.cost_function = str2func('stage_cost_temp');  
	% Kmax, Kmin are set properly for the temperature example at the end of get_scenario.; 
	% safe set is set inside stage_cost_temp.

	scenario.dynamics = str2func('therm_ctrl_load');

end