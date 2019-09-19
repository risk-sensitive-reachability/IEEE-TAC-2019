%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Script to generate probability distribution of surface 
%       runoff into first pond using design storm stats
%       Pr{wk = ws(i)} = P(i)
%       Fix possible values of wk & expected value of wk to generate P.
%
% INPUTS:
%   ws: sample of emperical disturbance distribution to assign
%   probabilities to
%
%   Mymean: mean of disturbances in the emperical distribution
%   Myvariance: variance of disturbances in the emperical distribution
%   Mysknewness: skewness of distirubances in the emprical distribution
%   
% Author: Victoria Cheng
% Developed for the Risk-Sensitive-Reachability Project
%   https://github.com/Risk-Sensitive-Reachability
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function myP = get_disturbance_probabilities( ws, Mymean, Myvariance, Myskewness )

nw = length(ws); 

cvx_solver mosek;

cvx_begin quiet

variables P(nw,1)

    minimize ( 1 )

    subject to
    
        ws*P == Mymean; % expected value of ws
        (ws-Mymean).^2*P == Myvariance; %variance of ws
        (ws-Mymean).^3*P == Myskewness*Myvariance^(3/2); %skewness of ws 
        
        P>=0.0001;
        
        P<=1;
        
        sum(P) == 1;
    
cvx_end

myP = P;

end


