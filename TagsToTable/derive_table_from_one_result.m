function derive_table_from_one_result(source_folder, save_folder, algname, output, dict, event_min, event_max)

%% --------- Description ------------
% Usage:
%     wrapping function to be called by GUI
%
% Input:
%     1. source folder for souce .mat files
%     2. save folder for result .csv
%     3. algorithm name
%     4. output: string of type of output table (3 types)
%     5. dict: selected BAP version dictioinary objectt


% Output:
%     1. csv table file
%     2. algorithm error folder containing -- errors/poor quality report and source file infomation in the algorithm results
%        for each subject, one .mat file per one patient

%% ----------------------------------

[source_folder, save_folder, output_obj, alg_dict] = derive_valid_inputs(source_folder, save_folder, algname, output, dict);

event_algname = alg_dict.algname;
event_vernum = alg_dict.vernum;
avail_algname = alg_dict.denom.algname;
avail_vernum = alg_dict.denom.vernum;

if strcmp(output_obj.name, "raw_utc_s") % second raw table
    derive_raw_tbl_utc_s_cohort(source_folder, save_folder, event_algname, event_vernum, event_min, event_max);
else
    derive_agg_tbl_cohort(source_folder, save_folder, avail_algname, avail_vernum, event_algname, event_vernum, output_obj, event_min, event_max);
end

end