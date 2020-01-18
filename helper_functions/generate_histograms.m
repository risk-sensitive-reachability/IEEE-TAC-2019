%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: A helper function that generates histograms of results from 
%   many random trajectories. It is intended to be called from
%   Plot_Histograms or Plot_Perturbed_Histograms. 
% INPUTS:
%   scenarioID = the string id of the scenario to use    
%   configurationID = the numeric id of the configuration to use
%   x0 = initial conditions
%   l0 = initial confidence level
%   perturbed: boolean, should the probabilities be perturbed?
%   [file]
%       /staging/{configurationID}/{scenarioID}/Bellman_complete.mat : a
%       file containing results for all recursion steps  
% OUTPUTS:
%   [file](s)
%       /staging/{configurationID}/{scenarioID}/[perturbed_]histogram_[x0][*].png :
%       Portable Network Graphics histogram(s)
%   [file](s) 
%       /staging/{configurationID}/{sceanrioID}/[perturbed_]histogram_[x0][*].fig : 
%       Matlab histograms(s) 
%   [file](s)
%       /staging/{configurationID}/{sceanrioID}/[perturbed_]summary_[x0][*].txt : 
%       a summary of results to accompany the histograms
%   [file](s)
%       /staging/{configurationID}/{sceanrioID}/[perturbed_]stage_cost_trajectories_[x0][*].mat : 
%       a Matlab file containing the stage cost trajectories used to generate
%       the histogram
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
function [] = generate_histograms(scenarioID, configurationID, x0, l0, perturbed) 
       
        staging_area = get_staging_directory(scenarioID, configurationID); 
        bellman_file = strcat([staging_area,'Bellman_complete.mat']);

        % if bellman_file is available, load it, otherwise prompt to Run_Bellman_Recursion.
        if isfile(bellman_file)

           load(bellman_file); 

        else

           error('No results available for this scenario and configuration. Please Run_Bellman_Recursion.');

        end
        
        global scenario;
        global config; 
        global ambient; 

        stage_cost_trajectories = generate_reproducible_stage_cost_trajectories(Zs, mus, x0, l0, config.histogram_trials, perturbed);
        stage_cost_trajectories = squeeze(stage_cost_trajectories); 
                
        % save stage cost trajectories
        if strcmp(scenario.risk_functional, 'CVAR')
            path_to_stage_cost_file = strcat(['stage_cost_trajectories_',mat2str(x0),'_',num2str(l0),'.mat']);
        else
            path_to_stage_cost_file = strcat(['stage_cost_trajectories_',mat2str(x0),'.mat']);
        end
        
        if perturbed
            path_to_stage_cost_file = strcat(['perturbed_',path_to_stage_cost_file]);
        end
        
        path_to_stage_cost_file = strcat([staging_area, path_to_stage_cost_file]);
        
        save(path_to_stage_cost_file, 'stage_cost_trajectories'); 
            
        %  generate histogram
        figure; set_figure_properties; 
        NBINS = 200; 
        cumulative_costs = sum(stage_cost_trajectories,2); 
        mymean = mean(cumulative_costs); 
        mystd = std(cumulative_costs);
    
        histogram(cumulative_costs,NBINS); 
        hold on; plot(mymean,0,'*r','Linewidth',3); hold on; 
        plot([mymean + mystd, mymean + 2*mystd], [0 0], '*g','Linewidth',3); hold on;
        plot([mymean - mystd, mymean - 2*mystd], [0 0], '*g','Linewidth',3);
    
        xlabel('$C_{0:T}$','Interpreter', 'Latex', 'FontSize', 16); ylabel('\# Samples per bin','Interpreter', 'Latex', 'FontSize', 16); 
        if strcmp(scenario.risk_functional,'CVAR')
            title(['Histogram of $C_{0:T}$ via CVaR, $\alpha_0$ = ', num2str(l0)], 'Interpreter', 'Latex', 'FontSize', 16); 
        elseif strcmp(scenario.risk_functional, 'EXP')
            title(['Histogram of $C_{0:T}$ via E-exp, $\theta$ = ', num2str(scenario.theta)], 'Interpreter', 'Latex', 'FontSize', 16); 
        elseif strcmp(scenario.risk_functional, 'AO')
            title('Histogram of $C_{0:T}$ via Always Open Policy', 'Interpreter', 'Latex', 'FontSize', 16); 
        elseif strcmp(scenario.risk_functional, 'AC')
            title('Histogram of $C_{0:T}$ via Always Closed Policy', 'Interpreter', 'Latex', 'FontSize', 16); 
        end

        alpha_for_CVaR_BIG = 0.01; % evaluate empirical cvar for alpha = 0.01 always for comparison purposes (relevance threshold)
        alpha_for_CVAR_SMA = 0.001;
        
        %fill summary results
        results.N = config.histogram_trials;
        results.Mean = mymean; 
        results.Variance = var(cumulative_costs); 
        results.Max = max(cumulative_costs); 
        results.Min = min(cumulative_costs); 

        results.Value_At_Risk_BIG = quantile(cumulative_costs, 1-alpha_for_CVaR_BIG); 
        results.CVaR_BIG = estimate_CVaR_from_emperical_data(cumulative_costs, alpha_for_CVaR_BIG, results.Value_At_Risk_BIG); 
        results.alpha_for_CVaR_BIG = alpha_for_CVaR_BIG; 

        results.Value_At_Risk_SMA = quantile(cumulative_costs, 1-alpha_for_CVAR_SMA); 
        results.CVaR_SMA = estimate_CVaR_from_emperical_data(cumulative_costs, alpha_for_CVAR_SMA, results.Value_At_Risk_SMA); 
        results.alpha_for_CVAR_SMA = alpha_for_CVAR_SMA; 

        ha = annotation('textbox', [0.55 0.4 0.35 0.5], 'LineStyle', 'none','Interpreter', 'latex', 'FontSize', 14);
        cs = ['\begin{tabular}{ll}  CVaR$_{',num2str(alpha_for_CVaR_BIG),'}$ &', num2str(results.CVaR_BIG),...
            '\\', 'VaR$_{',num2str(alpha_for_CVaR_BIG),'}$ &', num2str(results.Value_At_Risk_BIG),... 
            '\\', 'Mean &', num2str(mymean),...
            '\\', 'Variance &', num2str(results.Variance),...
            '\\', 'Max &', num2str(results.Max),...
            '\\', 'Min &', num2str(results.Min),'\end{tabular}'];

        set(ha, 'String', cs)
        
        if perturbed
            mha = annotation('textbox', [0.60, 0.1 0.35 0.2], 'LineStyle', 'none', 'Interpreter', 'latex', 'FontSize', 14);
            mcs = ['Perturbed $P(d_t)$'];
                
        set(mha, 'String', mcs);
            
        end
        
        
        if strcmp(scenario.risk_functional, 'CVAR')
            path_to_png = strcat(['histogram_',mat2str(x0),'_',num2str(l0),'.png']);
            path_to_fig = strcat(['histogram_',mat2str(x0),'_',num2str(l0),'.fig']);
            path_to_tbl = strcat(['summary_',mat2str(x0),'_',num2str(l0),'.txt']);
        else
            path_to_png = strcat(['histogram_',mat2str(x0),'.png']);
            path_to_fig = strcat(['histogram_',mat2str(x0),'.fig']);
            path_to_tbl = strcat(['summary_',mat2str(x0),'.txt']);
        end
        
        
        if perturbed
            path_to_png = strcat(['perturbed_', path_to_png]); 
            path_to_fig = strcat(['perturbed_', path_to_fig]); 
            path_to_tbl = strcat(['perturbed_', path_to_tbl]); 
        end
        
        path_to_png = strcat([staging_area, path_to_png]);
        path_to_fig = strcat([staging_area, path_to_fig]); 
        path_to_tbl = strcat([staging_area, path_to_tbl]); 
        
        % convert results struct to pretty printed table
        arr = struct2array(results); 
        tab1 = struct2table(results); 
        tab2 = array2table(arr.'); 
        tab2.Properties.RowNames = tab1.Properties.VariableNames; 
        tab2.Properties.VariableNames = {'Summary'}; 
        TString = evalc('disp(tab2)'); 
        TString = strrep(TString,'<strong>','');
        TString = strrep(TString,'</strong>',''); 
        fileID = fopen(path_to_tbl,'w'); 
        fprintf(fileID, TString); 
        fclose(fileID); 

        saveas(gcf, path_to_png); 
        saveas(gcf, path_to_fig); 
end