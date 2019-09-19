%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Gets a griddedInterpolant for the Zs
% INPUT:
    % Zs: transition of the confidence level under optimal policy
    % globals: 
    %   config struct 
    %   ambient struct 
    %   global struct 
% OUTPUT:
    % griddedInterpolant of the Zs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function F = get_z_interpolants(Zs)

    global config; 
    global ambient; 
    global scenario; 

    N = config.T/config.dt;

    F = cell(N, 1); 
    
    if scenario.dim == 1 || strcmp(scenario.risk_functional,'EXP') || strcmp(scenario.risk_functional, 'AC') || strcmp(scenario.risk_functional, 'AO')
        if strcmp(scenario.id,'TC') && strcmp(scenario.risk_functional,'CVAR')
            for i = 1:N
                Zs_k = Zs(i);
                Z_grid_k = ones(scenario.nw, ambient.nl, ambient.x1n); 
                for j = 1:ambient.nl
                    reverse = fliplr(1:ambient.nl);
                    % extracts column of Zs_k corresponding to a confidence level j
                    Zs_k_l = full([Zs_k{1}{:,j}]);
                    for q = 1:scenario.nw
                    % get the qth disturbance element across all x values at confidence level ls(j) at time i
                        Z_grid_k(q, reverse(j), :) = Zs_k_l(q,:);
                    end 
                end
                % map negative Zs (rounding error) to zero; you can run this to check this is true, max(Z_grid_k(Z_grid_k < 0))
                Z_grid_k(Z_grid_k < 0) = 0; 
                [W, L, X1] = ndgrid(scenario.ws, fliplr(config.ls'), ambient.x1s);   
                F{i} = griddedInterpolant(W, L, X1, Z_grid_k, 'linear');
            end
        else
            for i = 1:N
                F{i} = griddedInterpolant(ones(2), 'linear');
            end
        end
        
    else
    
        for i = 1:N

            Zs_k = Zs(i);

          %  if scenario.dim == 1
          %      Z_grid_k = ones(scenario.nw, ambient.nl, ambient.x1n); 
          %  else
                Z_grid_k = ones(scenario.nw, ambient.nl, ambient.x2n, ambient.x1n); 
          %  end
                for j = 1:ambient.nl

                    reverse = fliplr(1:ambient.nl);

                    % extracts column of Zs_k corresponding to a confidence
                    % level j
                    Zs_k_l = full([Zs_k{1}{:,j}]);

                    for q = 1:scenario.nw

                        % get the qth disturbance element across all x values
                        % at confidence level ls(j) at time i

             %           if scenario.dim == 1
                            Z_grid_k(q, reverse(j), :, :) = reshape(Zs_k_l(q,:), [ambient.x2n, ambient.x1n]); %                
             %           else
             %               Z_grid_k(q, reverse(j), :) = Zs_k_l(q,:);
             %           end

                    end 

                end

          % map negative Zs (rounding error) to zero
          % you can run this to check this is true
          %max(Z_grid_k(Z_grid_k < 0))
          Z_grid_k(Z_grid_k < 0) = 0; 

          [W, L, X2, X1] = ndgrid(scenario.ws, fliplr(config.ls'), ambient.x2s, ambient.x1s); 


          % to not allow extrapolation, need 'none'
          % unfortunately we need extrapolation to estimate ls = 0 or 1
          % F{i} = griddedInterpolant(W, L, X2, X1, Z_grid_k, 'linear', 'none');
          %    
          F{i} = griddedInterpolant(W, L, X2, X1, Z_grid_k, 'linear');


        end 

    end

end