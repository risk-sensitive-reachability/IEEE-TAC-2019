
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Approximates max_R\inRiskEnvelope { E[ R*J_k+1(x_k+1,myl*R) | x_k, myl, myu ] }
%              Uses Chow 2015 linear interpolation method on confidence level
%              Uses change of variable, S := myl*R 
% INPUT: 
    % J_k+1 : optimal cost-to-go at time k+1, array
    % xind : index of the state in the state-space
    % F : griddedInterpolant of J_kPLUS1 for the entire state-space 
    % config struct
    % scenario struct 
    % ambient struct 
    % myu: ONE control action to evaluate in LP
    % myl: ONE level to evaluate in LP
% OUTPUT: bigexp ~= max_R\inRiskEnvelope { E[ R*J_k+1( x_k+1, myl*R ) | x_k, myl, myu ] }
%         rStar ~= maximizing R, such that R(j) corresponds to jth disturbance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% # controls = 1 & # levels = 1 to include in LP in this implementation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ rStar, bigexp ] = estimate_CTG_and_zStar( xind, F, config, scenario, ambient, myu, myl )

nd = scenario.nw;   % # disturbance values        
nl = length(myl);   % # levels to evaluate in LP = 1               
nu = length(myu);   % # controls to evaluate in LP = 1

if nl ~= 1, error('This parallel implementation only supports LPs containing one confidence level.'); end

% f_full = -[ 0; P(1)/myl; 0; P(2)/myl; ...; 0; P(nd)/myl ] (col vector)
f_full = zeros( 2*nd, 1 ); 
f_full( 2:2:end ) = -scenario.P/myl;

% lower_bound = [ 0; -Inf; 0; -Inf; ..., 0; -Inf ] (col vector)
lower_bound = zeros( 2*nd, 1 ); 
lower_bound( 2:2:end ) = -Inf;

% upper_bound = [ 1; Inf; 1; Inf; ..., 1; Inf ] (col vector)
upper_bound = ones( 2*nd, 1 ); 
upper_bound( 2:2:end ) = Inf;

% Aeq = [ P(1) 0 P(2) 0 ... P(nd) 0 ] (row vector)
Aeq = zeros( 1, 2*nd );
Aeq( 1:2:end ) = transpose(scenario.P); 

beq = myl; 

if nu ~= 1, error('This parallel implementation only supports LPs containing one control.'); end

[ A, B ] = build_linear_matrix_inequality( xind, myu, F, config, scenario, ambient );
% A is a block-diagonal matrix, containing matrices A(i)
% A(i) is of the form = [ -a1(i) 1;
%                         -a2(i) 1;
%                         ...
%                         -aL(i) 1;],
% where al(i) = slope of line segment l, disturbance value i
% B is a vector, containing vectors B(i)
% B(i) is of the form = [ b1(i); ...; bL(i) ],
% where bl(i) = vertical intercept of line segment l, disturbance value i

[ opt_sol, opt_obj_func, exitflag, output ] = linprog( f_full, A, B, Aeq, beq, lower_bound, upper_bound);
% opt_sol = [ s1; t1; ...; snd; tnd ]
% where sj = myl * rj

% MOSEK linprog exit flags
% exitflag < 0 : the problem is likely either primal or dual infeasible
% exitflag = 0 : the maximum number of iterations were reached
% exitflag > 0 : optimal solution found
if exitflag <= 0, error('linprog could not find a solution.'); end

bigexp = -opt_obj_func;              % approximates max_R { E[ R*J_k+1(x_k+1,myl*R) | x_k, myl, myu ]

sStar = opt_sol( 1:2:end );          % [ s1; ...; snd ], where sj = myl * rj

rStar{1,1} = sStar / myl;                 % approximates optimal R, where R(j) corresponds to jth disturbance
