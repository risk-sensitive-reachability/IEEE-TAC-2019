%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Defines the stage cost as an exponential of the signed distance w.r.t. constraint set 
% INPUT: 
%	globals: 
%		ambient struct 
%		config struct
%		scenario struct
% OUTPUT: Stage cost
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function c = initialize_stage_cost_matrix() 

global scenario 
global config
global ambient

% assumes cost is only based on X and not confidence-level y

gx = scenario.cost_function(ambient.xcoord, scenario); 

if strcmp(func2str(scenario.cost_function_aggregation),'max')
    col = config.beta * exp( config.m * gx);
else 
    col = gx; 
end

if strcmp(scenario.risk_functional, 'CVAR')
    c = repmat(col, [1,length(config.ls)]); 
else 
    c = col; 
end 