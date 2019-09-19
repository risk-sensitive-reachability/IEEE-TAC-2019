%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Plots level sets for a particular scenario under a given configuration. 
% INPUT:
%   scenarioID = the string id of the scenario to use    
%   configurationID = the numeric id of the configuration to use
%   [file]
%       /staging/{configurationID}/{scenarioID}/Monte_Carlo_complete.mat : a
%       file containing Monte Carlo results for all confidence levels
% OUTPUTS:
%   [file](s)
%       /staging/{configurationID}/{scenarioID}/level_sets.png :
%       Portable Network Graphics figure for level sets
%   [file](s) 
%       /staging/{configurationID}/{sceanrioID}/level_sets.fig : 
%       Matlab figure for level sets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[] = Plot_Level_Sets(scenarioID, configurationID)

    staging_area = get_staging_directory(scenarioID, configurationID); 
    monte_carlo_file = strcat([staging_area,'Monte_Carlo_complete.mat']);
    
    % if MC file is available, load it, otherwise prompt to Run_Monte_Carlo.
    if isfile(monte_carlo_file)

       load(monte_carlo_file); 

    else

       error("No results available for this scenario and configuration. Please Run_Bellman_Recursion and Run_Monte_Carlo first.");

    end
    
    % load globals
    global scenario;
    global config;
    global ambient; 

    if scenario.dim == 2

        if strcmp(scenario.risk_functional, 'CVAR')
        
            for i = 1:length(config.monte_carlo_levels) 
                
                J0_MonteCarlo = J0_MC'; 
                J0_Bellman = Js{1};

                J0_MonteCarlo_grid = reshape(J0_MonteCarlo(:,i), [ambient.x2n, ambient.x1n]);
                
                index_bell = find(config.monte_carlo_levels(i) == config.ls);
                % index_bell is the index of config.ls that contains the value of config.monte_carlo_levels(i)
                % config.monte_carlo_levels(i) == config.ls is a 1x9 array with 0s everywhere except at the location of config.monte_carlo_levels(i)
                % find(x) returns the indices of the non-zero entries of x
                if ~(config.ls(index_bell) == config.monte_carlo_levels(i)), error('index bell is wrong'); end; 
                
                %J0_Bellman_grid = reshape(J0_Bellman(:,i), [ambient.x2n, ambient.x1n]); 
                J0_Bellman_grid = reshape(J0_Bellman(:,index_bell), [ambient.x2n, ambient.x1n]);
               
                % must have config.ls(index_bell) == config.monte_carlo_levels(i)

                % set all negative numbers to the smallest allowable positive
                % value (assume single precision double)
                % this second 'reset' is required due to the optional 'max' 
                % transformations that take place in the block above
                % since log(x) is -Inf when x = 0, it is possible that x
                % becomes small enough in the transformatino that log(x)
                % becomes -Inf. 
                if strcmp(func2str(scenario.cost_function_aggregation),'max')
                     J0_Bellman_grid = J0_Bellman_grid / config.beta; 
                     J0_Bellman_grid(J0_Bellman_grid <= 0) = realmin('single'); % need to be greater than 0 to take log
                     J0_Bellman_grid = log(J0_Bellman_grid); 
                     J0_Bellman_grid = J0_Bellman_grid / config.m; 
                end


                % begin plotting section
                set(gcf,'color','w');
                subplot(1, length(config.monte_carlo_levels), i);
                %J0_Bellman_grid(J0_Bellman_grid <= 0) = realmin('single'); 
                rs_to_show = [1.25, 1.5]; %rs_to_show = [1, 1.25, 1.49];
                % [C, h] = contour(ambient.x2g, ambient.x1g, J0_cost_sum_grid, [0.25,0.5,0.75,1,1.25,1.5]);
                [C, h] = contour(ambient.x2g, ambient.x1g, J0_Bellman_grid, rs_to_show);
                clabel(C,h);
                h.LineWidth = 1; 
                h.LineColor = 'magenta';
                hold on;         
                %[C, h] = contour(ambient.x2g, ambient.x1g, J0_cost_max_grid, [0.25,0.5,0.75,1,1.25,1.5]);

                [C, h] = contour(ambient.x2g, ambient.x1g, J0_MonteCarlo_grid, rs_to_show);
                clabel(C,h);
                h.LineWidth = 1; 
                h.LineColor = 'blue';
                h.LineStyle = '--';
                title(['$\alpha$ = ', num2str(config.monte_carlo_levels(i)), ', $r \in \{$', num2str(rs_to_show(1)), ', ',num2str(rs_to_show(2)), '\}'], 'Interpreter','Latex', 'FontSize', 22); 

                legend({'$\partial\hat{\mathcal{U}}_\alpha^r$', '$\partial \hat{\mathcal{S}}_\alpha^r$'},'Interpreter','Latex','FontSize', 22, 'Location','northeast');
                xlabel('$x_2$','Interpreter','Latex','FontSize', 20);
                ylabel('$x_1$','Interpreter','Latex','FontSize', 20);
                grid on;

                hold off; 
            end
        
            path_to_png = strcat(staging_area,'level_sets.png');
            path_to_fig = strcat(staging_area,'level_sets.fig');
            saveas(gcf,path_to_png);
            saveas(gcf,path_to_fig);
            
        else 
            
        end

    else
        
        J0_cost_sum = Js{1}';

        if strcmp(func2str(scenario.cost_function_aggregation),'max')
            J0_cost_sum = J0_cost_sum / config.beta; 
            J0_cost_sum = log(J0_cost_sum);
            J0_cost_sum = J0_cost_sum / config.m; 
        end
        
        J0_cost_sum(J0_cost_sum <= 0) = 0.00001; 
        
        J0_cost_max = J0_MC;

        rs = linspace( 1.5, 0.25, 6 ); % risk levels to be plotted, choose min to be slightly bigger than min(min(J0_cost_max))
        rs = [rs(1), rs(4), rs(2), rs(5), rs(3), rs(6)]; % so risk levels decrease sequentially along each column in figure
        
        nl = length(config.monte_carlo_levels); % # discretized confidence levels
        nr = length(rs); % # discretized risk levels
        
        for r_index = 1 : nr, r = rs(r_index); subplot(nr/2, 2, r_index);
    
            for l_index = 1 : nl, y = config.monte_carlo_levels(l_index); U_ry = []; S_ry = []; 

                for x_index = 1 : length(ambient.x1s)

                    if J0_cost_sum(l_index, x_index) <= r,   U_ry = [ U_ry, ambient.x1s(x_index) ]; end

                    if J0_cost_max(l_index, x_index) <= r,   S_ry = [ S_ry, ambient.x1s(x_index) ]; end

                end

                if ~isempty(U_ry), plot(U_ry, ones(size(U_ry))*y, 'o', 'MarkerFaceColor', 'r'); hold on; end; U{r_index}{l_index} = U_ry;

                plot(S_ry, ones(size(S_ry))*y, 'ob', 'linewidth', 1); hold on; S{r_index}{l_index} = S_ry;

            end
            % legend placement is hard-coded
            if r_index==2, legend('x \in U_y^r','x \in S_y^r'); end % put legend for an rs, where U_ry is not empty

            title(['r = ', num2str(r)]); xlabel('Water level, x (ft)'); ylabel('Confidence level, y');

            index_xup = find(ambient.x1s>2.5,1); xs_short = ambient.x1s(1: index_xup);

            axis([min(ambient.x1s) max(xs_short) min(config.monte_carlo_levels) max(config.monte_carlo_levels)]); grid on; yticks(sort(config.monte_carlo_levels)); xticks(xs_short);

            % hard-coded
            xticklabels({'0','','','','','0.5','','','','','1','','','','','1.5','','','','','2','','','','','2.5'});   
            
            
        end
        
        path_to_png = strcat(staging_area,'/level_sets.png');
        path_to_fig = strcat(staging_area,'/level_sets.fig');
        saveas(gcf,path_to_png);
        saveas(gcf,path_to_fig);
        
    
    end

end