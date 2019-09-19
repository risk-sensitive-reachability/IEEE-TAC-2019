%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Perturbs a discrete probability distribution and plots the 
%   new distribution and the old one originalP(i) is the (original) 
%   probability that ws(i) occurs newP(i) is the (perturbed) probability 
%   that ws(i) occurs.
%
% INPUTs: 
	% originalP is the vector of original probabilities corresponding to ws
	% ws is the vector of outcomes corresponding to originalP
% Outputs 
	% newP is a vector of perturbed probabilities corresponding to ws
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	

function newP = perturb_discrete_probabilities( originalP, ws )

	rng('default');
	    
	newP = originalP + randn(size(originalP))/100;
	    
	newP = max(newP, 0);

	extra_new_P = sum(newP) - 1;
	    
	[val, ind] = max(newP); % get max probability
	    
	newP(ind) = val - extra_new_P;
	    
	if sum(newP) ~= 1
	    error('perturbed distribution does not sum to 1!'); 
	elseif ~all(newP >= 0)
	    error('perturbed distribution is not nonnegative!')
	else

	end

end



