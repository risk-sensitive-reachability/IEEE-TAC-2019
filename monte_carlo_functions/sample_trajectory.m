%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Generates one sample trajectory, pond dynamics
% INPUT:
    % x0 : initial state, real number
    % l0 : initial confidence level, (0-1)
    % tick_P = [ 0, P(1), P(1)+P(2), ..., P(1)+...+P(nw-1), 1 ], nw = length(ws)
        % P(i) : probability that wk = ws(i)
    % muInterpolants : a vector of N cells containing gridded interpolant of 
        % the optimal policy for each timestep
    % zInterpolants : a vector of N cells containing gridded interpolant of
        % the risk envelope for each timestep
    % globals
    %   scenario struct 
    %   config struct 
    %   ambient struct 
% OUTPUT:
    % myTraj(1) = x0, myTraj(2) = x1, ..., myTraj(N+1) = xN
    % myConf(1) = l0, myConf(2) = l1, ..., myConf(N+1) = lN
    % myCtrl(1) = u1, myCtrl(2) = u2, ..., myCtrl(N) = uN
    % myCost(1) = cost(x0); myCost(2) = cost(x2); ..., myCost(N+1) = cost(xN)
% If xk+1 > max(xs), we set xk+1 = max(xs). This ensures that scenario tree is equivalent to that used in dynamic programming.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [myTraj, myConf, myCtrl, myCosts] = sample_trajectory( x0, l0, tick_P, muInterpolants, zInterpolants, scenario, config, ambient )       

N = config.T/config.dt;

myConf = [ l0; zeros( N, 1 ) ]; 
myCtrl = zeros(N, 1); 
myCosts = [ scenario.cost_function(x0, scenario) ; zeros(N, 1)];

if scenario.dim == 1
    myTraj = [ x0; zeros(N, 1) ];                                 % initialize trajectory 
else    
    myTraj = [ x0; zeros(N, 2) ];
end

for k = 0 : N-1                                                 % for each time point
    
    xk = myTraj(k+1,:);                                         % state at time k
    
    lk = myConf(k+1); 
    
    wk = sample_disturbance(scenario.ws, tick_P );                       % sample the disturbance at time k according to P

    if scenario.dim == 1
        if strcmp(scenario.risk_functional, 'CVAR')    % CVAR & 1D
            u = muInterpolants{k+1}(lk, xk(1));         
        elseif strcmp(scenario.risk_functional, 'EXP') % EXP & 1D
            u = muInterpolants{k+1}(xk(1));
        else
            error('scenario.risk_functional not defined properly in 1D case!');
        end
    elseif scenario.dim == 2
        if strcmp(scenario.risk_functional, 'CVAR')     % CVAR & 2D
            u = muInterpolants{k+1}(lk, xk(2), xk(1));  
        elseif strcmp(scenario.risk_functional, 'EXP')  % EXP & 2D                                        
            u = muInterpolants{k+1}(xk(2), xk(1));
        else
            error('scenario.risk_functional not defined properly in 2D case!');
        end
    else
        error('scenario.dim not defined properly!');
    end
    
    if u > 1
        u = 1; 
    end
    
    if u < 0
        u = 0; 
    end
    
    myCtrl(k+1) = u; 
                                                                % get next state realization
    x_kPLUS1 = scenario.dynamics(xk, u, wk, config, scenario);
                                                                
    x_kPLUS1 = snap_to_boundary( x_kPLUS1, ambient );               % snap to grid on boundary
    
    if scenario.dim == 1 || strcmp(scenario.risk_functional,'EXP')  || strcmp(scenario.risk_functional, 'AC') || strcmp(scenario.risk_functional, 'AO')
        if strcmp(scenario.id,'TC') && strcmp(scenario.risk_functional,'CVAR') % temperature example
            l_kPLUS1 = zInterpolants{k+1}(wk, lk, xk(1)) * lk;
        else
        % the value of l is irrelavant to the EXP calculation, so we just return 1
        % and treat it as a dummy variable. 
            l_kPLUS1 = zInterpolants{k+1}(1, 1);
        end
    else 
        l_kPLUS1 = zInterpolants{k+1}(wk, lk, xk(2), xk(1)) * lk;    
    end
    
    if l_kPLUS1 > max(config.ls), l_kPLUS1 = max(config.ls); end;
    if l_kPLUS1 < min(config.ls), l_kPLUS1 = min(config.ls); end;
    
    myTraj(k+2,:) = x_kPLUS1;                                   % state at time k+1
    
    myCosts(k+2) = scenario.cost_function(x_kPLUS1, scenario);  % stage cost at time k+1
    
    myConf(k+2) = l_kPLUS1;                                     % confidence at time k+1
    
end