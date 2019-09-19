%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Create a structure containing scenario-specifc details
% INPUT:
    % scenarioID = the string id of the scenario to use
% OUTPUT:
    % scenario = a structure containing scenario-specific details
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\

function scenario = get_scenario(scenarioID)

    scenario = [];

    scenario.outlet_elevation_s1 = 1;   % [ft] from pond base
    scenario.surface_area_s1 = 28292;   % [ft^2]
    scenario.outlet_radius_s1 = 1/3;    % [ft]

    scenario.stream_slope = 0.01;
    scenario.mannings_n = 0.1;            % Manning's roughness coefficient [s/m^(1/3)]
    scenario.stream_length = 1820;        % [ft]
    scenario.side_slope = 1/4;            % side slope, stream [dimensionless]
    scenario.outlet_elevation_stream = 1; % [ft]

    scenario.runoff_mean = 12.16;         % [cfs]
    scenario.runoff_variance = 3.22;      % [(cfs)^2]
    scenario.runoff_skewness = 1.68;      % [dimensionless]

    scenario.asymmetric_disturbance = false; % true => each storage unit receive 
                                            % an independent disturbance
                                            % realization

                                            % false => each storage unit should
                                            % receive the same disturbance
                                            % realization
    scenario.nw = 10;                                                                                                    % number possible runoff realizations
    scenario.ws_max = scenario.runoff_mean + 2.5 * sqrt(scenario.runoff_variance);                                       % max possible runoff realization [cfs]
    scenario.ws_min = scenario.runoff_mean - 2 * sqrt(scenario.runoff_variance);                                         % min possible runoff realization [cfs]
    scenario.ws = linspace(scenario.ws_min, scenario.ws_max, scenario.nw);                                               % possible runoff realizations [cfs]
    scenario.P = get_disturbance_probabilities(scenario.ws, scenario.runoff_mean, scenario.runoff_variance, scenario.runoff_skewness); 

    scenario.cost_function_aggregation = str2func('max'); 
    scenario.risk_functional = 'CVAR'; 

    switch scenarioID

        % Kmax, Kmin are set properly for the temperature example at the end of
        % get_scenario.; safe set is set inside stage_cost_temp.

        % TCL example, CVAR(Sum)
        case 'TC' 
            scenario = fill_scenario_fields_thermsys('TC');
            scenario.risk_functional = 'CVAR';      % Conditional Value at Risk

        % TCL example, exponential disutility (theta = -0.99)
        case 'TE' 
            scenario = fill_scenario_fields_thermsys('TE');
            scenario.risk_functional = 'EXP';       % Exponential Disutility
            scenario.theta = -0.99;

        % TCL example, exponential disutility (theta = -0.95)
        case 'TF' 
            scenario = fill_scenario_fields_thermsys('TF');
            scenario.risk_functional = 'EXP';        % Exponential Disutility
            scenario.theta = -0.95;

        % TCL example, exponential disutility (theta = -0.01)
        case 'TG' 
            scenario = fill_scenario_fields_thermsys('TG');
            scenario.risk_functional = 'EXP';         % Exponential Disutility
            scenario.theta = -0.01;

        % Two tank example - valve always open, CVAR(Sum)
        case 'AO'
            scenario.dim = 2; 
            scenario.id = 'AO';
            scenario.title = 'Scenario AO'; 

            % 0 => 0% of Possible Flow Area
            % 1 => 100% of Possible Flow Area
            scenario.allowable_controls = 1;  

            scenario.risk_functional = 'CVAR';          % Conditional Value at Risk
            scenario.cost_function = str2func('max_flood_level'); 
            scenario.dynamics = str2func('bidirectional_flow_by_gravity'); 
            scenario.cost_function_aggregation = str2func('sum');  
            scenario.theta = 0; 

        % Two tank example - valve always closed, CVAR(Sum)
        case 'AC'
            scenario.dim = 2; 
            scenario.id = 'AC';
            scenario.title = 'Scenario AC'; 

            % 0 => 0% of Possible Flow Area
            % 1 => 100% of Possible Flow Area
            scenario.allowable_controls = 0;  

            scenario.risk_functional = 'CVAR';          % Conditional Value at Risk
            scenario.cost_function = str2func('max_flood_level'); 
            scenario.dynamics = str2func('bidirectional_flow_by_gravity'); 
            scenario.cost_function_aggregation = str2func('sum'); 
            scenario.theta = 0; 


        % ACC 2019 Scenario - Single tank example, CVAR(Max)
        case 'A'
            scenario.dim = 1; 
            scenario.id = 'A'; 
            scenario.title = 'Scenario A'; 

            % 0 => 0% of Possible Flow Area
            % 1 => 100% of Possible Flow Area
            scenario.allowable_controls = [0, 1];    

            scenario.cost_function = str2func('signed_distance');
            scenario.dynamics = str2func('unidirectional_flow_by_gravity');

        % Two tank example, CVAR(Max)
        case 'B'
            scenario.dim = 2; 
            scenario.id = 'B';
            scenario.title = 'Scenario B'; 

            % 0 => 0% of Possible Flow Area
            % 1 => 100% of Possible Flow Area
            scenario.allowable_controls = 0: 0.1: 1;  

            scenario.cost_function = str2func('max_flood_level'); 
            scenario.dynamics = str2func('bidirectional_flow_by_gravity'); 

         % Two tank example, CVAR(Sum)
         case 'CM'
            scenario.dim = 2; 
            scenario.id = 'CM';
            scenario.title = 'Scenario CM'; 

            % 0 => 0% of Possible Flow Area
            % 1 => 100% of Possible Flow Area
            scenario.allowable_controls = 0: 0.1: 1;  

            scenario.cost_function = str2func('max_flood_level'); 
            scenario.dynamics = str2func('bidirectional_flow_by_gravity'); 
            scenario.cost_function_aggregation = str2func('sum'); 

        % Two tank example, exponential disutility (theta = -0.99)
        case 'EM'
            scenario.dim = 2; 
            scenario.id = 'EM';
            scenario.title = 'Scenario EM'; 

            % 0 => 0% of Possible Flow Area
            % 1 => 100% of Possible Flow Area
            scenario.allowable_controls = 0: 0.1: 1;  

            scenario.cost_function = str2func('max_flood_level'); 
            scenario.dynamics = str2func('bidirectional_flow_by_gravity'); 
            scenario.cost_function_aggregation = str2func('sum');  
            scenario.risk_functional = 'EXP';      % Exponential Disutility
            scenario.theta = -0.99;

        % Two tank example, exponential disutility (theta = -0.95)
        case 'FM'
            scenario.dim = 2; 
            scenario.id = 'FM';
            scenario.title = 'Scenario FM'; 

            % 0 => 0% of Possible Flow Area
            % 1 => 100% of Possible Flow Area
            scenario.allowable_controls = 0: 0.1: 1;  

            scenario.cost_function = str2func('max_flood_level'); 
            scenario.dynamics = str2func('bidirectional_flow_by_gravity'); 
            scenario.cost_function_aggregation = str2func('sum');  
            scenario.risk_functional = 'EXP';         % Exponential Disutility
            scenario.theta = -0.95;   

        % Two tank example, exponential disutility (theta = -0.01)     
        case 'GM'
            scenario.dim = 2; 
            scenario.id = 'GM';
            scenario.title = 'Scenario GM'; 

            % 0 => 0% of Possible Flow Area
            % 1 => 100% of Possible Flow Area
            scenario.allowable_controls = 0: 0.1: 1;  

            scenario.cost_function = str2func('max_flood_level'); 
            scenario.dynamics = str2func('bidirectional_flow_by_gravity'); 
            scenario.cost_function_aggregation = str2func('sum');  
            scenario.risk_functional = 'EXP';            % Exponential Disutility
            scenario.theta = -0.01;    

    end

    switch scenario.risk_functional
        case 'CVAR'
            scenario.bellman_backup_method = str2func('CVaR_Bellman_backup'); 
        case 'EXP'
            scenario.bellman_backup_method = str2func('exponential_disutility_Bellman_backup');
    end

    switch scenario.dim
        case 1
            scenario.K_min = zeros( 1, 1 );  % [ft]
            scenario.K_max = 5 ;  % [ft]

        case 2
            scenario.K_min = zeros( 2, 1 );  % [ft]
            scenario.K_max = [ 3.5; 5 ];      % [ft]

            scenario.outlet_radius_s1 = 1;      % [ft]   
            scenario.inlet_elevation_s2 = 2.5;  % [ft] from pond base
            scenario.outlet_elevation_s2 = 1;   % [ft] from pond base
            scenario.surface_area_s2 = 25965;   % [ft^2]
            scenario.outlet_radius_s2 = 2/3;    % [ft] 

            if scenario.asymmetric_disturbance == true
                [p1, p2] = meshgrid(scenario.P, scenario.P);
                scenario.P = [p1(:) p2(:)]; 

                % assume events are independent
                % p1 is P(w1 = wka)
                % p2 is P(w2 = wkb)
                %
                % the probability of the joint event 
                % p is P(w1 = wka & w2 = wkb)
                %   is simply p1 * p2
                scenario.P = scenario.P(:,1).*scenario.P(:,2); 

                [d1, d2] = meshgrid(scenario.ws, scenario.ws);
                scenario.ws = [d1(:) d2(:)]';
                scenario.nw = (scenario.nw)^2;
            end
    end

    % temperature example with CVaR or exponential disutility cost
    % the if-statement below must follow the "switch scenario.dim" statement
    % since scenario.K_min = 0 from the "switch scenario.dim" statement
    if strcmp(scenario.id, 'TC') || strcmp(scenario.id, 'TE') || strcmp(scenario.id, 'TF') || strcmp(scenario.id, 'TG')
        scenario.K_max = 21;  % [deg C]
        scenario.K_min = 20;  % [deg C]
    end

end



