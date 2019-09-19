%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Performs the CVaR Bellman backwards recursion, uk \in {0,1}
%   
%   This method attempts to group multiple sub-problems into larger linear programs
%   for efficiency. If the larger linear programs cannot be solved, they
%   are re-grouped into smaller programs and attempted gain. When no further 
%   reduction is possible and the atomic linear program of the smallest 
%   sub-problem still cannot be solved, the method throws an error. 
%
% INPUT: 
    % J_k+1 : optimal cost-to-go at time k+1, array
    % globals: 
    %   ambient struct
    %   config struct 
    %   scenario struct
% OUTPUT: 
    % J_k : optimal cost-to-go starting at time k, array
    % mu_k : optimal controller at time k, array
    % Zs_k : confidence level transitions under optimal policies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ Zs_k, J_k, mu_k ] = CVaR_Bellman_backup(J_kPLUS1)

    global ambient; 
    global config; 
    global scenario;

    amb = ambient; 
    cfg = config; 
    scn = scenario; 

    J_kPLUS1_grid = cell(length(config.ls),1); 
    F = cell(length(config.ls),1); 

    % setup Jk interpolants on the gridded state-space 
    if scenario.dim == 1
        for i = 1:length(config.ls)
            J_kPLUS1_grid{i} = J_kPLUS1(:,i); 
            F{i} = griddedInterpolant(ambient.x1g, J_kPLUS1_grid{i}); 
        end
    else 
        % in J_kPLUS1_grid{i} each column represents a fixed value of x1
        % and the values of x2 change along the entries of this column (rows)
        for i = 1:length(config.ls)
            J_kPLUS1_grid{i} = reshape(J_kPLUS1(:,i), [ambient.x2n, ambient.x1n]); 

            % F{i}([x2,x1]) finds the linear interpolated value of J_kPLUS1 at
            % state x1, x2
            F{i} = griddedInterpolant(ambient.x2g, ambient.x1g, J_kPLUS1_grid{i}); 
        end
    end

    % limit maximum number of confidence levels per LP to the total number
    % in the configuration
    if cfg.max_ls_per_LP > length(cfg.ls)
        cfg.max_ls_per_LP = length(cfg.ls);
    end

    % limit the maximum number of controls per LP to the total number in
    % the configuration
    if cfg.max_us_per_LP > amb.nu
        cfg.max_us_per_LP = amb.nu;
    end

    % initialization
    J_k = J_kPLUS1; 
    mu_k = J_kPLUS1; 
    stage_cost = ambient.c; 
    us = scenario.allowable_controls;

    while 1 == 1
       try 
            [ Zs_k, J_k, mu_k ] = attempt_CVAR_linear_program(J_kPLUS1, amb, cfg, scn, us, stage_cost, F); 
           break;
       catch e
           fprintf(1, 'There was an error! The message was:\n%s', e.message);
           disp(strcat('Failed to solve LP containing ', num2str(cfg.max_us_per_LP),' controls and ', num2str(cfg.max_ls_per_LP), ' confidence levels.'));

            if cfg.max_us_per_LP > 1 || cfg.max_ls_per_LP > 1
                if cfg.max_us_per_LP > 1
                    cfg.max_us_per_LP = cfg.max_us_per_LP - 1; 
                else
                    cfg.max_ls_per_LP = cfg.max_ls_per_LP - 1; 
                end
                config.max_ls_per_LP = cfg.max_ls_per_LP; % set new baseline
                config.max_us_per_LP = cfg.max_us_per_LP; % set new baseline
                disp(strcat('Attempting to solve LP containing ', num2str(cfg.max_us_per_LP),' controls and ', num2str(cfg.max_ls_per_LP), ' confidence levels.'));
            else
                error('LP cannot be further reduced. No solution found.');
            end

       end
       
    end

end