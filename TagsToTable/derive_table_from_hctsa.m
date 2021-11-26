function derive_table_from_hctsa(source_folder, save_folder, tsname, dict_obj)
%% ------------------------------------- Description ----------------------------------------
% Usage:
%     wrapping function to be called by GUI
%
% Input:
%     1. source folder for souce .mat files
%     2. save folder for result .csv
%     3. ccname: minute value-based result name
%     4. dict_obj: dictionary object for a bap version


% Output:
%     1. csv table file 

%% ------------------------------------------------------------------------------------------
source_folder = string(source_folder);
save_folder = string(save_folder);
tsname = string(tsname);
tsname_array = regexp(string(tsname),'(\w+)','match');
tsname = tsname_array(end);
dict = dict_obj.hctsa;
% find all the algorithms containing ccname (algnames and vernums)
algnames = string(dict.Result_Name(contains(dict.Result_Name,tsname))');
vernums = string(dict.Version(contains(dict.Result_Name,tsname))');
value_colnames = {'id','srcfile', 'start_date_time', 'stop_date_time', 'duration_avail_s', 'value'};


tbl_value_cohort = [];
errors = struct('iter', {}, 'message', {});

allfileinfo = dir(strcat(string(source_folder),'\*resultsmerged.mat'));



f = waitbar(0,'Here we go!');
for i=1:length(allfileinfo)
        
    waitbar(i/length(allfileinfo),f,['Working on file ' num2str(i) ' of ' num2str(length(allfileinfo))])
    
    try
    resultfile = get_result_file(allfileinfo(i));
    
    
    algrow = get_algname_row(resultfile,algnames(1),vernums(1));
    startcol = strcmp(resultfile.result_tagcolumns(algrow).tagname,'Start'); % Find out which row in the results file contains the tags of interest (Note: this won't be the same row for every file - so you should always use a function like this to find out the right row!)
    start = floor(resultfile.result_tags(algrow).tagtable(:,startcol)/1000); % start times of data available (utc s)
    start_datetime = datetime(start, 'ConvertFrom','posixtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS');

    stopcol = strcmp(resultfile.result_tagcolumns(algrow).tagname,'Stop'); % Find out which row in the results file contains the tags of interest (Note: this won't be the same row for every file - so you should always use a function like this to find out the right row!)
    stop = floor(resultfile.result_tags(algrow).tagtable(:,stopcol)/1000); % stop times of data available (utc s)
    stop_datetime = datetime(stop, 'ConvertFrom','posixtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS');
    
    dur_avail = stop - start;
    
    value_col = strcmp(resultfile.result_tagcolumns(algrow).tagname,'Value'); 
    value = resultfile.result_tags(algrow).tagtable(:,value_col);
    
    tbl_value_sbj = array2table([string(repmat(resultfile.id,size(start_datetime,1),1)), string(repmat(resultfile.srcfile,size(start_datetime,1),1)), string(start_datetime),string(stop_datetime), dur_avail, value]);
    tbl_value_sbj.Properties.VariableNames = value_colnames;
    
    % concat vertically with cohort table
    tbl_value_cohort = vertcat(tbl_value_cohort, tbl_value_sbj);
    
    catch ME
       errors(end + 1).iter = i;
       errors(end).message  = ME.message;
    end
end
close(f)

% save daily tables to target folder
if ~isempty(tbl_value_cohort)
    % add warnings column for warning messages
    tbl_value_cohort.warnings = repmat({''},size(tbl_value_cohort,1),1);
    error_idx = str2double(tbl_value_cohort.duration_avail_s)>600;
   
    tbl_value_cohort.warnings(error_idx) = {'duration overflow'};
    writetable(tbl_value_cohort, strcat(save_folder, '\', tsname,'_hctsa_values_bap_v',dict_obj.bap_v,'.csv'));
end

end