function derive_table_from_two_results(source_folder, save_folder, algname1, algname2, output, dict)
%% --------- Description ------------
% Usage:
%     wrapping function to be called by GUI
%
% Input:
%     1. source folder for souce .mat files
%     2. save folder for result .csv
%     3. algorithm name
%     4. output: string of type of output table (4 types)
%     5. bap_v: selected BAP version


% Output:
%     1. csv table file or 
%     2. a foler of derived intersection result .mat files, one per
%          subject

%% ----------------------------------
% validate input and prepare function local objects
[~, ~, ~, alg_dict1] = derive_valid_inputs(source_folder, save_folder, algname1, output, dict);
[source_folder, save_folder, output_obj, alg_dict2] = derive_valid_inputs(source_folder, save_folder, algname2, output, dict);



% call function by output type
derive_joint_data_cohort(source_folder, save_folder, alg_dict1, alg_dict2, output_obj)


end