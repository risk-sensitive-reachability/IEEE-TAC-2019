%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: For each i, approximates max_R\inRiskEnvelope { E[ R*J_k+1(x_k+1,ls(i)*R) | x_k, ls(i), u_k ] }
%              Uses Chow 2015 linear interpolation method on confidence level
%              Uses change of variable, Z := y*R 
% INPUT: 
    % J_k+1 : optimal cost-to-go at time k+1, array
    % z : index of the state in the state-space
    % F : griddedInterpolant of J_kPLUS1 for the entire state-space 
    % config struct
    % scenario struct 
    % ambient struct 
    % us: control actions
    % ls: confidence levels 
% OUTPUT: 
    % zStars :  a vector of confidence level transitions under optimal policy
    % CTG(i) : cost to go
    %          ~= max_R\inRiskEnvelope { E[ R*J_k+1(x_k+1,ls(i)*R) | x_k, ls(i), u_k ] }
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [zStars, CTG] = estimate_CTG_and_zStar(J_kPLUS1, z, F, config, scenario, ambient, us, ls)
        
nd = scenario.nw; % number of discrete disturbance realizations
nl = length(ls);  % number of confidence levels
nu = length(us);  % number of control actions to evaluate

f_full = zeros(nd,nl); 
for i = 1 : nl, f_full(:,i) = scenario.P/config.ls(i); end
f_full = vec(f_full); 
f_full = repmat(f_full, nu, 1);

nrows = nl*nd*(length(config.ls)-1); 
bus = zeros(nrows,nu); 
fus = ones(nrows,nu);          % scaling factor (DEPRECATED)
Aus = []; 


% aggregate linear matrix inequalities for each control considered
for j = 1 : nu
    
     % encodes linear interpolation of y*J_k+1( x_k+1, y ) versus y, given us(j) and x
    [ Au, bu ] = build_linear_matrix_inequality(z, us(j), J_kPLUS1, F, config, scenario, ambient);

    for i = 1 : nl, Aus = blkdiag(Aus, Au); end
    
    bus(:,j) = repmat(bu, nl, 1); fus(:,j) = fus(:,j);

end
bus = vec(bus); fus = vec(fus);

% solves the LP ane extracts zStar and tStar
[zStar, tStar] = solve_linear_program( f_full, Aus, bus, scenario.P, ls, length(config.ls)-1, length(ls), nd, nu, fus, z ); % column vector

% initialize containers for optimal cost to go (CTG) and zStars
CTG = zeros(nl, nu);
zStars = cell(nl, nu); 

for j = 1 : nu
    
    tStar_j = tStar( 1 + (j-1)*nl*nd : j*nl*nd ); % extract optimal arg for us(j)
    zStar_j = zStar( 1 + (j-1)*nl*nd : j*nl*nd ); % extract z's for us(j)

    for i = 1 : nl
        
        % extract optimal CTG for us(j), ls(i)
        CTG(i,j) = (scenario.P/ls(i))' * tStar_j( (i-1)*nd + 1 : i*nd ); 
        
        % extract zStars associated with optimal CTG for us(j), ls(j)
        zStars{i,j} = zStar_j((i-1)*nd + 1 : i*nd); 
    
    end 
    
end



