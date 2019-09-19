## Overview
This repository contains the code used to run the analysis presented in a recent submission to _IEEE Transactions on Automatic Control_ entitled "Risk-sensitive safety specifications for stochasticsystems using Conditional Value-at-Risk."

## Dependencies
### Computational Environment
Running the code in this repository requires a recent version of Matlab. We have tested this repository using [__Matlab 2018a__](https://www.mathworks.com/products/matlab.html) on Windows 10 and Red Hat Enterprise Linux Server release 6.9 (Santiago). 

### Solver Packages
We are grateful to the authors of the following solver packages which made this project possible. You will need to install these packages to run the code in this repository. 

#### MOSEK
[MOSEK](https://www.mosek.com) is an optimization package created by MOSEK ApS. Running MOSEK requires a license, but MOSEK ApS grants [free licenses](https://www.mosek.com/products/academic-licenses/) to faculty, students, and staff at degree-granting academic institutions. We tested this code against [MOSEK 8.0.0.60](https://www.mosek.com/downloads/8.0.0.60/). Please follow the latest instructions on MOSEK's site for obtaining a license and installing MOSEK on your machine. 

#### CVX
[CVX](http://cvxr.com/) is a Matlab-based modeling framwork for convex optimization created by CVX Research. Its goal is to provide a modeling language for Matlab that supports [disciplined convex programming](http://cvxr.com/dcp/). We tested this code against [CVX Version 2.1, Build 1127 (95903bf)](http://cvxr.com/cvx/download/). Please follow the latest instructions on CVX Research's site for installing CVX on your machine. 

## Setup Instructions
### Install Dependencies
See the list above for required dependencies. 

### Download a Copy of this Repository
Using [git](https://git-scm.com/) is the easiest way to download a copy of all the files you need to get up and running in Matlab. We tested these instructions against git v2.8.2.396. 

The files will be downloaded to a folder named __IEEE-TAC-2019__. 

From a command line interface, navigate to the directory where you would like to download __IEEE-TAC-2019__. 

Then execute the following command: 
```
git clone https://github.com/risk-sensitive-reachability/IEEE-TAC-2019
```
![git clone](https://github.com/risk-sensitive-reachability/IEEE-TAC-2019/raw/master/misc/GitClone.gif)

### Setup Your Matlab Workspace
To setup your Matlab workspace: 
 - navigate to the parent directory containing __IEEE-TAC-2019__
 - from the left-hand file tree, right click on __IEEE-TAC-2019__ and select __Add To Path > Selected Folders and Subfolders__.
![add_to_path](https://github.com/risk-sensitive-reachability/IEEE-TAC-2019/raw/master/misc/AddToPath.gif)

### Run Bellman Recursion
The first step in the analysis of a particular configuration and scenario combination is to call `Run_Bellman_Recursion`. The first argument is a string identifying the scenario to run and the second argument is an integer identifying the simulator configuration to use. See the scenarios and configurations section below for more details. Note that running this will create files in the {Matlab_Working_Directory}/staging/ directory. These include both 'checkpoint' files that save results periodically and 'complete' files that are created once the entire recursion is finished. Once you have obtained a 'Bellman_complete.mat' file you may run the Monte Carlo analysis. Note: this process can take several days to complete. 

![run_Bellman_recursion](https://github.com/risk-sensitive-reachability/IEEE-TAC-2019/raw/master/misc/RunBellmanRecursion.gif)


### Run Monte Carlo Analysis
The second step in the analysis of a particular configuration and scenario combination is to call `Run_Monte_Carlo`. This assumes you have already called `Run_Bellman_Recursion` and that process completed by producing a 'Bellman_complete.mat' file. The first argument to `Run_Monte_Carlo` is a string identifying the scenario to run and the second argument is an integer identifying the simulator configuration to use. See the scenarios and configurations section below for more details. Note that running this will create files in the {Matlab_Working_Directory}/staging/ directory. These include both 'checkpoint' files that save results periodically and 'complete' files that are created once the entire Monte Carlo analysis is finished. Once you have obtained a 'Monte_Carlo_complete.mat' you may move on to visualizing the results. Note: this process can take several days to complete. 

### Visualize Results
The final step in the analysis of a particular configuration and scenario combination is to call the various plotting functions. This assumes you have already called `Run_Monte_Carlo` and that process completed by producing a 'Monte_Carlo_complete.mat' file for each scenario and configuration of interest. The first argument to `Plot_Level_Sets`, `Plot_J0`, and `Plot_W0_Star` is a string identifying the scenario to run and the second argument is an integer identifying the simulator configuration to use. `Plot_Histograms` and `Plot_Perturbed_Histograms` take a third argument, which is a vector of initial conditions (these must be gridpoints defined for the scenario). The `Plot_Disturbance_Probabilities` method takes only a single string argument identifying the scenario.

#### Plot_Level_Sets
Example plot produced by `Plot_Level_Sets`.

![example level_set](https://github.com/risk-sensitive-reachability/IEEE-TAC-2019/raw/master/misc/example_level_set.png)

#### Plot J0
Example plot produced by `Plot_J0`.

![example J0](https://github.com/risk-sensitive-reachability/IEEE-TAC-2019/raw/master/misc/example_J0.png)

#### Plot W0*
Example plot produced by `Plot_W0_Star`. 

![example W0*](https://github.com/risk-sensitive-reachability/IEEE-TAC-2019/raw/master/misc/example_W0_star.png)

#### Generate Histograms
This method generates many sample trajectories from a single initial condition and plots histograms of the results (one for each confidence level considered). `Generate_Histograms` takes an additional third parameter that is a vector of initial conditions. Because this method generates the samples just prior to plotting, it may take some time to complete (< 30 minutes for 1,000,000 samples). 

Example plot produced by `Generate_Histograms`. 

![example histogram](https://github.com/risk-sensitive-reachability/IEEE-TAC-2019/raw/master/misc/example_histogram.png)

#### Generate Perturbed Histograms
Similar to `Generate_Histograms` this method generates many sample trajectories from a single initial condition and plots histograms of the results (one for each confidence level considered). However, `Generate_Perturbed_Histograms` perturbs the probability distribution (making it different than what the controller was trained on) prior to taking samples. This tests the robustness of the optimal controller. `Generate_Perturbed_Histograms` takes an additional third parameter that is a vector of initial conditions. Because this method generates the samples just prior to plotting, it may take some time to complete (< 30 minutes for 1,000,000 samples). 

Example plot produced by `Generate_Perturbed_Histograms`. 

![example perturbed](https://github.com/risk-sensitive-reachability/IEEE-TAC-2019/raw/master/misc/example_perturbed.png)

#### Plot Disturbance Probabilities
The `Plot_Disturbance_Probabilities` method takes only a single string argument identifying the scenario. It then plots the unperturbed and perturbed probability distributions associated with the disturbances.  

Example plot produced by `Plot_Disturbance_Probabilities`.

![example prob_dist](https://github.com/risk-sensitive-reachability/IEEE-TAC-2019/raw/master/misc/example_disturbance_probabilities.png)


## Figure Mappings

This table provides a mapping between the figures presented in the paper and the command that can be used to generate them (sans some annotations that were added manually). 

| Figure | Position      | Scenario | Configuration | Plotting Command                         |
|--------|---------------|----------|---------------|------------------------------------------|
| 2      | Top Left      | B        | 1             | Plot_Level_Sets('B',1)                   |
| 2      | Top Center    | B        | 1             | Plot_Level_Sets('B',1)                   |
| 2      | Top Right     | B        | 1             | Plot_Level_Sets('B',1)                   |
| 2      | Middle Left   | B        | 1             | Plot_J0('B',1)                           |
| 2      | Middle Center | B        | 1             | Plot_J0('B',1)                           |
| 2      | Middle Right  | B        | 1             | Plot_J0('B',1)                           |
| 2      | Bottom Left   | B        | 1             | Plot_W0_Star('B',1)                      |
| 2      | Bottom Center | B        | 1             | Plot_W0_Star('B',1)                      |
| 2      | Bottom Right  | B        | 1             | Plot_W0_Star('B',1)                      |
| 4      | Top Left      | CM       | 1             | Plot_Histograms('CM', 1, [0, 1])         |
| 4      | Top Center    | CM       | 1             | Plot_Histograms('CM', 1, [0, 1])         |
| 4      | Top Right     | CM       | 1             | Plot_Histograms('CM', 1, [0, 1])         |
| 4      | Bottom Left   | GM       | 1             | Plot_Histograms('GM', 1, [0, 1])         |
| 4      | Bottom Center | FM       | 1             | Plot_Histograms('FM', 1, [0, 1])         |
| 4      | Bottom Right  | EM       | 1             | Plot_Histograms('EM', 1, [0, 1])         |
| 5      | -             | TC       | -             | Plot_Disturbance_Probabilities('TC')     |
| 6      | Top Left      | TC       | 2             | Plot_Histograms('TC', 2, 20.1)           |
| 6      | Top Center    | TC       | 2             | Plot_Histograms('TC', 2, 20.1)           |
| 6      | Top Right     | TC       | 2             | Plot_Histograms('TC', 2, 20.1)           |
| 6      | Bottom Left   | TG       | 2             | Plot_Histograms('TG', 2, 20.1)           |
| 6      | Bottom Center | TF       | 2             | Plot_Histograms('TF', 2, 20.1)           |
| 6      | Bottom Right  | TE       | 2             | Plot_Histograms('TE', 2, 20.1)           |
| 7      | Top Left      | TC       | 2             | Plot_Histograms('TC', 2, 20.5)           |
| 7      | Top Center    | TC       | 2             | Plot_Histograms('TC', 2, 20.5)           |
| 7      | Top Right     | TC       | 2             | Plot_Histograms('TC', 2, 20.5)           |
| 7      | Bottom Left   | TG       | 2             | Plot_Histograms('TG', 2, 20.5)           |
| 7      | Bottom Center | TF       | 2             | Plot_Histograms('TF', 2, 20.5)           |
| 7      | Bottom Right  | TE       | 2             | Plot_Histograms('TE', 2, 20.5)           |
| 8      | Left          | TC       | 2             | Plot_Perturbed_Histograms('TC', 2, 20.1) |
| 8      | Right         | TF       | 2             | Plot_Perturbed_Histograms('TF', 2, 20.1) |
