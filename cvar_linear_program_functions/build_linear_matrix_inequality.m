
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Computes the parameters for linear matrix inequality given x and u
% INPUT: 
    % z : index of the current state in the statespace
    % u : control action 
    % J_k+1 : optimal cost-to-go at time k+1, array         (DEPRECATED & UNUSED)
    % F : griddedInterpolant of J_k+1 over the entire state-space
    % config struct
    % scenario struct 
    % ambient struct 
% OUTPUT: A = blkdiag( A1, ..., And ), b = [b1; ...; bnd], nd = # disturbance values
%             |A1 0  .. 0   |                |b1 |
%           = |0  ..... 0   |              = |...|
%             |0  0  .. And |                |bnd|
% NOTE:
    % Ai & bi are column vectors that encode the linear interpolation of y*J_k+1( x_k+1, y ) vs. y, given x and u
        % at the ith realization of x_k+1 = pond_dynamics_dt( x, u, ws(i), dt, area_pond )
    % max_t,y { t | A1(j)*y + b1(j) >= t, confidence level line segment j } is equivalent to 
        % max_y { g(y) := min_j A1(j)*y + b1(j), confidence level line segment j }                                          
    % g(y) = linear interpolation of y*J_k+1(x,y) vs. y, at fixed x (and u); concave & piecewise linear in y
    % uses Chow, et al. NIPS 2015 to manage continuous confidence level
    % uses linear interpolation to manage continuous state space
% AUTHOR: Margaret Chapman
% DATE: October 11, 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ A, b ] = build_linear_matrix_inequality(z, u, J_kPLUS1, F, config, scenario, ambient)


% # disturbance realizations        # confidence levels
nd = length(scenario.ws);           nl = length(config.ls);

A = []; b_mat = zeros(nl-1,nd); % to contain [b1 b2 ... bnd]

for i = 1 : nd % for each disturbance realization

    x_kPLUS1 = scenario.dynamics(ambient.xcoord(z,:), u, scenario.ws(:,i), config, scenario);       % get next state realization
    
    x_kPLUS1 = snap_to_boundary( x_kPLUS1, ambient );                                                   % snap to grid on boundary            
    
    Ai = zeros(nl-1,1); bi = zeros(nl-1,1);                                                         % one entry per confidence level line segment
        
    for j = nl-1: -1: 1 % for each confidence level line segment, [l_j+1, l_j], e.g., ls = [l_1 = 0.95, l_2 = 1/2, l_3 = 0.05] 
                        % [l_3, l_2] = [0.05, 1/2] 
                        % [l_2, l_1] = [1/2, 0.95]
        
        % F{i} is the griddedInterpolant of JKPlus1 at confidence level i
        % F{i} (x2, x1) gives the interpolated value of JKPlus1 at the
        % state (x1, x2). 
        
        % We are using fliplr here because when we have two dimensions
        % the elements of x_KPLUS1 are (x1, x2) and we need to reverse the
        % order of these elements to query F{i}. This is because in F{i}
        % each row corresponds to a fixed value of x2 and each column
        % corresponds to a fixed value of x1. 
        
        J_jPLUS1 = F{j+1}(fliplr(x_kPLUS1));               
        % approximates J_k+1(x_k+1, l_j+1) using J_k+1(xL, l_j+1) and J_k+1(xU, l_j+1), xL <= x_k+1 <= xU

        % see comment above about user of fliplr
        J_j = F{j}(fliplr(x_kPLUS1)); 
        
        Ai(j) = ( config.ls(j)*J_j - config.ls(j+1)*J_jPLUS1 )/( config.ls(j)-config.ls(j+1) ); 
        % approx. slope of jth line segment of linear_interp( y*J_k+1( x_k+1, y ) vs. y ) 
        
        bi(j) = config.ls(j+1) * (J_jPLUS1 - Ai(j));                       
        % approx. y-int of jth line segment of linear_interp( y*J_k+1( x_k+1, y ) vs. y )        
        
    end  
    A = blkdiag( A, Ai ); b_mat(:,i) = bi; %fillup matrix column by column   
end
b = vec(b_mat); % vectorizes matrix
