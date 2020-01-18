%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Returns optimal argument to compute for each i,
%                   max_R\inRiskEnvelope { E[ R*J_k+1(x_k+1,ls(i)*R) | x_k,ls(i), u_k ]
%              Uses Chow 2015 linear interpolation method on confidence level
%              Uses change of variable, Z := y*R
% INPUT:
    % f_full = [P/ls(1); P/ls(2); ...; P/ls(end)] column vec
    % A (matrix), b (col vector) : encode linear interpolation of y*J_k+1( x_k+1, y ) vs. y given x and u
    % P(i): probability that w_k = ws(i)
    % ls(i): ith confidence level
    % ns = number of line segments
    % nl = number of confidence levels
    % nd = number of disturbance values, length of P
    % nu = number of control options 
    % fus = scaling factor
    % xindx = index of the current state in the state space
% OUTPUT:
    % [t1; t2; ...] (col vector) that maximizes 1/ls(1)P'*t1 + 1/ls(2)P'*t2 + ...
    	% subject to constraints
   	% zStar a vector of confidence level transitions under optimal policy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [zStar, tStar] = solve_linear_program( f_full, bigA, bigb, P, ls, ns, nl, nd, nu, fus, xindx)

%cvx_solver mosek;
for j = 1:2
cvx_begin quiet
    if j==1, cvx_precision best; else, cvx_precision default; end
    
    variables Z(nd,nl*nu) t(nl*nd*nu,1)
    
    maximize( f_full' * t )    
    subject to
                
        bigA * vec(Z) + bigb >= fus.*vec( repmat(t', ns, 1) ); %bigA, bigb have fus incroporated
        P' * Z == repmat( ls', 1, nu );                         %ls is a column vector
        Z <= 1;
        Z >= 0;

cvx_end

if strcmpi(cvx_status, 'Solved') && ~isinf(cvx_optval) && ~isnan(cvx_optval)
    tStar = t; 
    zStar = vec(Z./repmat(ls',nd,nu));
    break;
elseif j == 2
    disp('Failed to solve at location: xindx = '); 
    disp(xindx);
    error('maxExp.m: cvx not solved.');
end
end


