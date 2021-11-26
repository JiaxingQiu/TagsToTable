function [result_clean, result_error] = derive_raw_tbl_utc_s(resultfile, algname, vernum)


%% ---------------------------------------------- Description ------------------------------------------------

% Usage: get raw table for a subject
% 1. prepare a cleaned table as a field 'tagtable_clean' in result_clean struct, the 1st column is start utc posixtime,
% 2nd column is stop utc posixtime
% 2. error and quality check results saved in result_error struct
%
% Input: 
% 1. resultfile = resultmerged file data 
% 2. algname: algorithm name (string)
% 3. vernum: version number (numeric)
%        
% Output: 
% 1. result_clean: cleaned result data in a matlab structure
% 2. detected error and poor quality result data in a matlab structure

%% -----------------------------------------------------------------------------------------------------------


id = resultfile.id;
srcfile = resultfile.srcfile;

result_clean.id = id;
result_clean.srcfile = srcfile;
result_clean.algorithm = strcat(algname,' v',string(vernum));
result_clean.tagtable_clean = [];
result_clean.message = [];

result_error.id = id;
result_clean.srcfile = srcfile;
result_error.algorithm = strcat(algname,' v',string(vernum));
result_error.message = [];
result_error.jump = [];
result_error.jump_source = [];
result_error.midnight = [];
result_error.midnight_source = [];
result_error.duplicate = [];
result_error.duplicate_source = [];

%% %%%%%%%%%%%%%%%%%%%%%%%% Get [start,stop] matrix from algorithm result structure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---- locate algorithm row ----
algrow = get_algname_row(resultfile, algname, vernum);
if isempty(algrow)
    result_clean.message = strcat(string(id),' -- ',string(algname),'v',string(vernum),' -- not run.');
    result_error.message = strcat(string(id),' -- ',string(algname),'v',string(vernum),' -- not run.');
    disp(result_clean.message);
    return
end

% ---- generate raw event matrix ( column 1 = starttime, column 2 = stoptime ) ----
raw_event_mtrx = get_raw_mtrx(1000, resultfile, algrow);
if isempty(raw_event_mtrx)
    result_clean.message = strcat(string(id),' -- ',string(algname),'v',string(vernum),' -- have 0 event in result.');
    result_error.message = strcat(string(id),' -- ',string(algname),'v',string(vernum),' -- have 0 event in result.');
    disp(result_clean.message);
    return
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Split error and clean matrices %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---- ERROR 1 : split jumps from raw matrix ----
[mtrx_clean, mtrx_jump] = derive_chunk_by_start(raw_event_mtrx);
mtrx_clean = fix_sort_chunks(mtrx_clean);

% ---- ERROR 2 : split pass midnight errors ----
[mtrx_clean, mtrx_mid] = fix_break_utc_dates(mtrx_clean);

% ---- ERROR 3 : split duplicate errors ----
[mtrx_clean, mtrx_dup] = fix_union_dup(mtrx_clean);

% ---- ERROR SOURCE : source file information -----
mtrx_source_jump = get_error_source(mtrx_jump,resultfile);
mtrx_source_mid = get_error_source(mtrx_mid,resultfile);
mtrx_source_dup = get_error_source(mtrx_dup,resultfile);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% Append readable table to result_error and result_clean structure %%%%%%%%%%%%%%%%%%%%%%%%%%%

% individual final cleaned table
if ~isempty(mtrx_clean)
    start_datetime = datetime(mtrx_clean(:,1), 'ConvertFrom','posixtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS');
    stop_datetime = datetime(mtrx_clean(:,2), 'ConvertFrom','posixtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS');
    result_clean.tagtable_clean = table(start_datetime, stop_datetime, mtrx_clean(:,1), mtrx_clean(:,2), mtrx_clean(:,3));
    result_clean.tagtable_clean.Properties.VariableNames = {'start_datetime','stop_datetime','start_posixtime_s','stop_posixtime_s','sorted_chunk_id'};
end


% individual jump starts error table
if ~isempty(mtrx_jump)
    start_datetime = string(datetime(mtrx_jump(:,1), 'ConvertFrom','posixtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS'));
    stop_datetime = string(datetime(mtrx_jump(:,2), 'ConvertFrom','posixtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS'));
    result_error.jump = [start_datetime, stop_datetime ,string(mtrx_jump(:,1)),string(mtrx_jump(:,2)),string(mtrx_jump(:,3))];
    result_error.jump = array2table(result_error.jump);
    result_error.jump.Properties.VariableNames = {'start_datetime','stop_datetime','start_posixtime_s','stop_posixtime_s','sorted_chunk_id'};
end

% individual across midnight error table
if ~isempty(mtrx_mid)
    start_datetime = string(datetime(mtrx_mid(:,1), 'ConvertFrom','posixtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS'));
    stop_datetime = string(datetime(mtrx_mid(:,2), 'ConvertFrom','posixtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS'));
    result_error.midnight = [start_datetime, stop_datetime ,string(mtrx_mid(:,1)),string(mtrx_mid(:,2)),string(mtrx_mid(:,3))];
    result_error.midnight = array2table(result_error.midnight);
    result_error.midnight.Properties.VariableNames = {'start_datetime','stop_datetime','start_posixtime_s','stop_posixtime_s','sorted_chunk_id'};
end

% individual duplicate table
if ~isempty(mtrx_dup)
    start_datetime = string(datetime(mtrx_dup(:,1), 'ConvertFrom','posixtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS'));
    stop_datetime = string(datetime(mtrx_dup(:,2), 'ConvertFrom','posixtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS'));
    result_error.duplicate = [start_datetime,stop_datetime ,string(mtrx_dup(:,1)),string(mtrx_dup(:,2)),string(mtrx_dup(:,3))];
    result_error.duplicate = array2table(result_error.duplicate);
    result_error.duplicate.Properties.VariableNames = {'start_datetime','stop_datetime','start_posixtime_s','stop_posixtime_s','sorted_chunk_id'};
end

% individual jump source file info table
if ~isempty(mtrx_source_jump)
    result_error.jump_source = array2table(mtrx_source_jump);
    result_error.jump_source.Properties.VariableNames = {'start_datetime','stop_datetime','info_row', 'file_name','zero_datenum'};
    result_error.jump_source.zero_datestr_utc = datestr(datenum(str2double(result_error.jump_source.zero_datenum)));
end

% individual midnight source file info table
if ~isempty(mtrx_source_mid)
    result_error.midnight_source = array2table(mtrx_source_mid);
    result_error.midnight_source.Properties.VariableNames = {'start_datetime','stop_datetime','info_row', 'file_name','zero_datenum'};
    result_error.midnight_source.zero_datestr_utc = datestr(datenum(str2double(result_error.midnight_source.zero_datenum)));
end

% individual dup source file info table
if ~isempty(mtrx_source_dup)
    result_error.duplicate_source = array2table(mtrx_source_dup);
    result_error.duplicate_source.Properties.VariableNames = {'start_datetime','stop_datetime','info_row', 'file_name','zero_datenum'};
    result_error.duplicate_source.zero_datestr_utc = datestr(datenum(str2double(result_error.duplicate_source.zero_datenum)));
end
   


end