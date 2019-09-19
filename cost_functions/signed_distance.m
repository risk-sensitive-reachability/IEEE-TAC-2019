%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Defines the signed distance function w.r.t. the constraint set
% INPUT: 
%	State vector X
%	Scenario struct 
% OUTPUT: Signed distance w.r.t. constriants K
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function gx = signed_distance(x, scenario)

% signed distance with respect to the constraint set
% one-sided signed distance since we only care about overflowing and x will never be <0

if scenario.dim > 1
    gx = max(x - scenario.K_max',[],2);
else 
    gx = x - scenario.K_max;  
end