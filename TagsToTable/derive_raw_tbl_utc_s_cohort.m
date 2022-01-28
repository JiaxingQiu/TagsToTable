function derive_raw_tbl_utc_s_cohort(source_folder, save_folder, algname, vernum, event_min, event_max)
%% ---------------------------------------------- Description ------------------------------------------------

% Usage: concat raw table for a cohort in a folder
% 1. prepare a cleaned table as a field 'tagtable_clean' in result_clean struct, the 1st column is start utc posixtime,
% 2nd column is stop utc posixtime
% 2. error and quality check results saved in result_error struct
%
% Input: 
% 1. source_folder: source folder path of all resultmerged cohort file data (string) 
% 2. save_folder: save folder path to save result csv table (string)
% 2. algname: algorithm name (string)
% 3. vernum: version number (numeric)
%        
% Output: save to save folder 
% 1. raw_clean_tbl_cohort: concat cohot cleaned result csv table

%% -----------------------------------------------------------------------------------------------------------


allfileinfo = dir(strcat(string(source_folder),'\*resultsmerged.mat'));
algname_array = regexp(string(algname),'(\w+)','match');
savename = strcat(strjoin(algname_array(2:end),"_"),'_v',string(vernum));

raw_clean_tbl_cohort = [];

f = waitbar(0,'Here we go!');
for i=1:length(allfileinfo)
    waitbar(i/length(allfileinfo),f,['Working on file ' num2str(i) ' of ' num2str(length(allfileinfo))])
     
    try
        % ----- Prepare result data for subject -----
        resultfiledata = get_result_file(allfileinfo(i));
        
        % ---- Prepare cleaned results and error results in utc seconds ----
        [result_clean, ~] = derive_raw_tbl_utc_s(resultfiledata, algname, vernum, event_min, event_max);

        % ---- Create table for this subject ----
        if ~isempty(result_clean.tagtable_clean) 
            raw_clean_tbl = table( ...
            string(result_clean.tagtable_clean.start_datetime),...% start date time
            string(result_clean.tagtable_clean.stop_datetime),... % stop date time
            result_clean.tagtable_clean.stop_posixtime_s -  result_clean.tagtable_clean.start_posixtime_s, ... % durtation in seconds
            repmat(result_clean.id, height(result_clean.tagtable_clean), 1),... % id
            repmat(result_clean.srcfile, height(result_clean.tagtable_clean), 1)... % id
            );
            raw_clean_tbl.Properties.VariableNames = {'start_date_time', 'stop_date_time', 'duration_s', 'id','srcfile'};

            % concat vertically with cohort table
            raw_clean_tbl_cohort = vertcat(raw_clean_tbl_cohort, raw_clean_tbl);
        end
    catch
        warning(strcat('Problem generating raw table from file-- ',string(i),' --',savename));
    end
   
   
    
end
close(f)


% save daily tables to target folder
if ~isempty(raw_clean_tbl_cohort)
    writetable(raw_clean_tbl_cohort, strcat(save_folder, '\', savename, '_raw_utc_s.csv'));
end


end