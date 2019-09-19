%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Attempts solving the full LP by breaking it into smaller 
%   LPs, solving the LPs and reassembling the results. 
%
% INPUTs:
%   J_k+1 : optimal cost-to-go at time k+1, array  
%   amb: ambient struct 
%   cfg: config struct
%   scn: scenario struct
%   us: control options
%   stage_cost: pre-initialized stage cost matrix
%   F: gridded interpolant of J_kPLUS1 for the entire state-space
%
% OUTPUTS:
%   J_k : optimal cost starting at time k, array
%   mu_k : optimal controller at time k, array
%   Zs_k : confidence level transitions under optimal policies 
%           (not applicable to exponential disutility)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ Zs_k, J_k, mu_k ] = attempt_CVAR_linear_program(J_kPLUS1, amb, cfg, scn, us, stage_cost, F)

    J_k = J_kPLUS1; mu_k = J_kPLUS1; % initialization
    
    Zs_k = cell(size(J_k));

    for i = 1 : amb.nx     % <--x's change along columns of J_k, X, L-->
        
        % disable warnings
        warning('off','all');
        
        % initialize empty containers for results
        CTG_us = [];     % cost to go under a given control
        zStars_us = {};  % zStars associated with a given control
        
        % uset defines the batching of controls to consider at once
        for uset = 1:cfg.max_us_per_LP:length(us)
            
            % initialize empty containers for temporary results
            CTG_us_t = [];
            zStars_us_t = {}; 
            
            % remaining set of controls to evaluate
            rem_us = length(us) - uset; 
            
            % if we have more controls to evaluate than will fit in a
            % single LP, then evaluate next batch
            if rem_us >= cfg.max_us_per_LP
                
                % lset defines the batching of confidence levels to
                % consider at once
                for lset = 1:cfg.max_ls_per_LP:length(cfg.ls)
                
                    % remaining set of confidence levels to evaluate
                    rem_ls = length(cfg.ls) - lset; 
                    
                    % if we have more confidence levels than will fit in a
                    % single LP, then evaluate next batch
                    if rem_ls >= cfg.max_ls_per_LP
                        [zStars_us_ls, cvar_us_ls] = estimate_CTG_and_zStar(J_kPLUS1, i, F, cfg, scn, amb, us(uset:uset+(cfg.max_us_per_LP-1)), cfg.ls(lset:lset+(cfg.max_ls_per_LP-1)));
                    
                    % else all of the remaining confidence levels will fit in
                    % a single LP, so evaluate all remaining
                    else
                        [zStars_us_ls, cvar_us_ls] = estimate_CTG_and_zStar(J_kPLUS1, i, F, cfg, scn, amb, us(uset:uset+(cfg.max_us_per_LP-1)), cfg.ls(lset:lset+rem_ls));
                    end
                    
                    % store temporary results
                    CTG_us_t = [CTG_us_t; cvar_us_ls];
                    zStars_us_t = [zStars_us_t; zStars_us_ls];
                end
                
            % else, the remaining controls to evaluate will all fit in single
            % LP, so evaluate all remaining
            else
                
                % lset defines the batching of confidence levels to
                % consider at once
                for lset = 1:cfg.max_ls_per_LP:length(cfg.ls)
                    
                    % remaining set of confidence levels to evaluate
                    rem_ls = length(cfg.ls) - lset; 
                    
                    % if we have more confidence levels than will fit in a
                    % single LP, then evaluate next batch
                    if rem_ls >= cfg.max_ls_per_LP
                        [zStars_us_ls, cvar_us_ls] = estimate_CTG_and_zStar(J_kPLUS1, i, F, cfg, scn, amb, us(uset:uset+rem_us), cfg.ls(lset:lset+(cfg.max_ls_per_LP-1)));
                    
                    % else all of the remaining confidence levels will fit in
                    % a single LP, so evaluate all remaining
                    else
                        [zStars_us_ls, cvar_us_ls] = estimate_CTG_and_zStar(J_kPLUS1, i, F, cfg, scn, amb, us(uset:uset+rem_us), cfg.ls(lset:lset+rem_ls));
                    end
                    
                    % store temporary results
                    CTG_us_t = [CTG_us_t; cvar_us_ls];
                    zStars_us_t = [zStars_us_t; zStars_us_ls];
                end
            end
            
            % aggregate results
            CTG_us = [CTG_us, CTG_us_t]; 
            zStars_us = [zStars_us, zStars_us_t];
        end

        % cvar_us(i,j) = cvar, given state x, confidence level ls(i), and control us(j)
        [ optCTG, optInd ] = min( CTG_us, [], 2 ); % col vector, 1 entry per confidence level

        % J_k = stage cost + optimal cost to go 
        J_k(i,:) = stage_cost(i,:) + optCTG';

        % optimal control 
        mu_k(i,:) = us(optInd)'; 
        
        % extract and restructure Zs associated with optimal controls
        zTemp = cell(length(optInd),1); 
        for y = 1:length(optInd)
            zTemp(y) = zStars_us(y,optInd(y));
        end
        Zs_k(i,:) = zTemp; 
                
    end
end