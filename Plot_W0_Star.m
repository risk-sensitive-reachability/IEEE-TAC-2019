%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Plots W0* for a particular scenario under a given configuration. 
% INPUT:
%   scenarioID = the string id of the scenario to use    
%   configurationID = the numeric id of the configuration to use
% OUTPUTS:
%   [file](s)
%       /staging/{configurationID}/{scenarioID}/W0[*].png :
%       Portable Network Graphics figure(s) for W0*
%   [file](s) 
%       /staging/{configurationID}/{sceanrioID}/W0[*].fig : 
%       Matlab figure(s) for W0*
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Plot_W0_Star(scenarioID, configurationID)

    staging_area = get_staging_directory(scenarioID, configurationID); 
    mc_file = strcat([staging_area,'Monte_Carlo_complete.mat']);
    
    % if mc_file is available, load it, otherwise prompt to Run_Monte_Carlo.
    if isfile(mc_file)

       load(mc_file); 

    else

       error('No results available for this scenario and configuration. Please Run_Monte_Carlo first.');

    end

    % load globals
    global scenario; 
    global ambient; 
    global config; 

    if scenario.dim == 1

        if strcmp(scenario.risk_functional, 'CVAR') && strcmp(func2str(scenario.cost_function_aggregation), 'max')

        [X, L] = ndgrid(ambient.x1s, config.ls); 

        for k = 1:1
            figure(k); 

            set(gcf,'color','w');
            set(gcf,'defaultlinelinewidth',2)
            set(gcf,'DefaultTextFontName', 'Arial')
            set(gcf,'DefaultTextFontSize', 12)
            set(gcf,'defaultaxesfontsize',12)
            set(gcf,'defaultaxesfontname','Arial')

            mesh(X, L, J0_MC' );
            title('Monte Carlo (max)');
            xlabel('State, x'); ylabel('Confidence level, y'); zlabel(['Estimate of J_{', num2str(k-1), '}(x,y)']);
        end

            path_to_png = strcat(staging_area,'W0.png');
            path_to_fig = strcat(staging_area,'W0.fig');
            saveas(gcf,path_to_png);
            saveas(gcf,path_to_fig);
        else 
            disp('Plotting not implemented for this combination of config. and scenario.')
        end

    else 
        figure; FigureSettings; 
        if strcmp(scenario.risk_functional, 'CVAR')
            for j = 1:length(config.monte_carlo_levels)
                 
                subplot(1, length(config.monte_carlo_levels), j);
                mesh(ambient.x2g, ambient.x1g, reshape(J0_MC(j,:), [ambient.x2n, ambient.x1n]));
                view(-19,43)

                xlabel('$x_2$', 'Interpreter','Latex','FontSize', 16); ylabel('$x_1$', 'Interpreter','Latex','FontSize', 16);
                zlim([0 2]); ylim([0 5]); xlim([0 6.5]); % THIS IS X2
                title(['$W_0^*([x_1, x_2]^T,\alpha)$ at $\alpha$ = ', num2str(config.monte_carlo_levels(j))],'Interpreter','Latex','FontSize', 16);
                 
                drawnow

            end

            path_to_png = strcat(staging_area, 'W0.png');
            path_to_fig = strcat(staging_area, 'W0.fig');
            saveas(gcf,path_to_png);
            saveas(gcf,path_to_fig);

        else
                figure; FigureSettings; mesh(ambient.x2g, ambient.x1g, reshape(J0_MC, [ambient.x2n, ambient.x1n]));
                view(-19,43)
                title('Dyn. Programming');
                xlabel('X1'); ylabel('X2'); zlabel(['Estimate of W_0^*(x1,x2) at theta =', num2str(scenario.theta)]);
                drawnow

                path_to_png = strcat(staging_area, strcat(['W0', '_', num2str(scenario.theta), '_', '.png']));
                path_to_fig = strcat(staging_area, strcat(['W0', '_', num2str(scenario.theta), '_', '.fig']));
                saveas(gcf,path_to_png);
                saveas(gcf,path_to_fig);
            
        end
    end
end