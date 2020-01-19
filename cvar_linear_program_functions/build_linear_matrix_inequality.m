%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Computes the parameters for linear matrix inequality given x and u
% INPUT: 
    % z : index of the current state in the statespace
    % u : control action 
    % F : griddedInterpolant of J_k+1 over the entire state-space
    % config struct
    % scenario struct 
    % ambient struct 
% OUTPUT: A = blkdiag( A(1), ..., A(nd) ), B = [B(1); ...; B(nd)], nd = # disturbance values
% NOTE:
    % A(i) and B(i) encode the linear interpolation of s*J_k+1( x_k+1, s ) vs. s, given x and u
        % at ith disturbance
    % uses Chow, et al. NIPS 2015 to manage continuous confidence level
    % uses linear interpolation to manage continuous state space
% AUTHOR: Margaret Chapman
% DATE: December 5, 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ A, B ] = build_linear_matrix_inequality(z, u, F, config, scenario, ambient)

nd = length(scenario.ws);  % # disturbances          
nl = length(config.ls);    % # levels in total
L = nl - 1;                % # line segments

A = []; B = [];

for i = 1 : nd % for each disturbance realization

    x_kPLUS1 = scenario.dynamics(ambient.xcoord(z,:), u, scenario.ws(i), config, scenario); % get next state realization
    
    x_kPLUS1 = snap_to_boundary( x_kPLUS1, ambient );                                       % snap to grid on boundary            
    
    Ai = ones(L,2); Bi = zeros(L,1);                                                        % one entry per confidence level line segment
        
    for j = L : -1: 1 % for each confidence level line segment, [l_j+1, l_j], e.g., ls = [l_1 = 0.95, l_2 = 1/2, l_3 = 0.05] 
                            % [l_3, l_2] = [0.05, 1/2] 
                            % [l_2, l_1] = [1/2, 0.95]
        
        % F{i} is the griddedInterpolant of JKPlus1 at confidence level i
        % F{i}(x2, x1) gives the interpolated value of JKPlus1 at the state (x1, x2). 
        
        % We are using fliplr here because when we have two dimensions
        % the elements of x_KPLUS1 are (x1, x2) and we need to reverse the
        % order of these elements to query F{i}. This is because in F{i}
        % each row corresponds to a fixed value of x2 and each column
        % corresponds to a fixed value of x1. 
        
        J_jPLUS1 = F{j+1}(fliplr(x_kPLUS1));               
        % approximates J_k+1(x_k+1, l_j+1) using J_k+1(xL, l_j+1) and J_k+1(xU, l_j+1), xL <= x_k+1 <= xU

        % see comment above about user of fliplr
        J_j = F{j}(fliplr(x_kPLUS1));
        
        myslope_j = ( config.ls(j)*J_j - config.ls(j+1)*J_jPLUS1 )/( config.ls(j)-config.ls(j+1) );
        % approx. slope of jth line segment of linear_interp( s*J_k+1( x_k+1, s ) vs. s )
        
        Ai(j,1) = -myslope_j; 
        
        Bi(j) = config.ls(j+1) * (J_jPLUS1 - myslope_j);                       
        % approx. vertical-int of jth line segment of linear_interp( y*J_k+1( x_k+1, y ) vs. y )        
        
    end  
    
    A = blkdiag( A, Ai ); B = [ B; Bi ]; % stack Bi's vertically
    
end