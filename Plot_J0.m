%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Plots J0 for a particular scenario under a given configuration. 
% INPUTS:
%   scenarioID = the string id of the scenario to use    
%   configurationID = the numeric id of the configuration to use
%   [file]
%       /staging/{configurationID}/{scenarioID}/Bellman_complete.mat : a
%       file containing results for all recursion steps  
% OUTPUTS:
%   [file](s)
%       /staging/{configurationID}/{scenarioID}/J0[*].png :
%       Portable Network Graphics figure(s) for J0
%   [file](s) 
%       /staging/{configurationID}/{sceanrioID}/J0[*].fig : 
%       Matlab figure(s) for J0 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Plot_J0(scenarioID, configurationID)

    staging_area = get_staging_directory(scenarioID, configurationID); 
    bellman_file = strcat([staging_area,'Bellman_complete.mat']);
    
    % if bellman_file is available, load it, otherwise prompt to Run_Bellman_Recursion.
    if isfile(bellman_file)

       load(bellman_file); 

    else

       error('No results available for this scenario and configuration. Please Run_Bellman_Recursion first.');

    end

    % load globals
    global scenario; 
    global ambient; 
    global config; 

    if scenario.dim == 1
        if strcmp(scenario.risk_functional, 'CVAR') && strcmp(scenario.cost_function_aggregation == str2func('max'))
            [X, L] = ndgrid(ambient.x1s, config.ls); 

            for k = 1:1
                figure(k);
                
                set(gcf,'color','w');
                set(gcf,'defaultlinelinewidth',2)
                set(gcf,'DefaultTextFontName', 'Arial')
                set(gcf,'DefaultTextFontSize', 12)
                set(gcf,'defaultaxesfontsize',12)
                set(gcf,'defaultaxesfontname','Arial')
                
                mesh(X, L, Js{k} );
                title(['Dyn. Programming (soft-max, m = ', num2str(config.m),')']);
                xlabel('State, x'); ylabel('Confidence level, y'); zlabel(['Estimate of J_{', num2str(k-1), '}(x,y)']);
            end
     
            path_to_png = strcat(staging_area,'J0.png');
            path_to_fig = strcat(staging_area,'J0.fig');
            saveas(gcf,path_to_png);
            saveas(gcf,path_to_fig);
        else 
            disp('Plotting not implemented for this combination of config. and scenario.')
        end
    else 
        if strcmp(scenario.risk_functional, 'CVAR')
            figure; set_figure_properties;
            monte_level = 1;
            for j = 1:length(config.ls)

                % only plot configured levels
                if (config.monte_carlo_levels(monte_level) == config.ls(j))

                for k = 1:1
                    subplot(1, length(config.monte_carlo_levels), monte_level);
                    mesh(ambient.x2g, ambient.x1g, reshape( Js{k}(:,j), [ambient.x2n, ambient.x1n]));
                    view(-19,43)
                    xlabel('$x_2$', 'Interpreter','Latex','FontSize', 20); ylabel('$x_1$', 'Interpreter','Latex','FontSize', 20);
                    ylim([0 5]); xlim([0 6.5]); % XDIM IS X2
                    zlim([-0.01 0.3]);
                    title(['$J_0([x_1, x_2]^T,\alpha)$ at $\alpha$ = ', num2str(config.ls(j))],'Interpreter','Latex','FontSize', 22);
                    drawnow

                    path_to_png = strcat(staging_area,strcat(['J0','_',num2str(config.ls(j)),'_','.png']));
                    path_to_fig = strcat(staging_area,strcat(['J0','_',num2str(config.ls(j)),'_','.fig']));

                    saveas(gcf,path_to_png);
                    saveas(gcf,path_to_fig);
                end
                monte_level = monte_level+1;
                end
                if monte_level > length(config.monte_carlo_levels)
                    break;
                end
            
            end
            
        else
                figure; FigureSettings; mesh(ambient.x2g, ambient.x1g, reshape(Js{1}(:), [ambient.x2n, ambient.x1n]));
                view(-19,43)
                title('Dyn. Programming');
                xlabel('X1'); ylabel('X2'); zlabel(['Estimate of J_{0}(x1,x2) at theta =', num2str(scenario.theta)]);
                drawnow

                path_to_png = strcat(staging_area,strcat(['J0','_',num2str(scenario.theta),'_','.png']));
                path_to_fig = strcat(staging_area,strcat(['J0','_',num2str(scenario.theta),'_','.fig']));

        end
    end

end
