function derive_agg_tbl_cohort(source_folder, save_folder, avail_algname, avail_vernum, event_algname, event_vernum, output_obj, event_min, event_max)


%% ---------------------------------------------- Description ------------------------------------------------

% Usage: aggregate event information for a cohort of subjects per given time unit
%
% Input: 
%        0. resultfiledata = subject-wise-merged event result file
%        1. source_folder: source resultmerged filed folder path
%        2. save_folder: folder path to save output table
%        3. avail_algname, avail_vernum: denominator algorithm name and version
%        4. event_algname, event_vernum: numerator algorithm name and version
%        5. unit: unit of aggregation (86400s for daily, 3600s for hourly)

%        
% Output: save to a folder 
%        0. agg_tbl_cohort = aggregated per unit cohort result table
%        1. subject-wise aggregated information of events in a cohort(count, total duration)
%        2. a folder with all error information detected per subject resultmerged file


%% -----------------------------------------------------------------------------------------------------------

unit = output_obj.unit;
outname = string(output_obj.name);

allfileinfo = dir(strcat(string(source_folder),'\*resultsmerged.mat'));
algname_array = regexp(string(event_algname),'(\w+)','match');
savename = strcat(strjoin(algname_array(2:end),"_"),'_v',string(event_vernum));
error_folder = strcat(string(save_folder),'\error_',savename);
mkdir(error_folder);

% Initiate daily table object for all subjects(cohort)
agg_tbl_cohort = [];
alg_avail_not_run = [];
alg_event_not_run = [];
error = [];


f = waitbar(0,'Here we go!');
for i=1:length(allfileinfo)
    waitbar(i/length(allfileinfo),f,['Working on file ' num2str(i) ' of ' num2str(length(allfileinfo))])
    
    try
        % ----- Prepare result data for subject -----
        resultfiledata = get_result_file(allfileinfo(i));
        id = resultfiledata.id;
        srcfile = resultfiledata.srcfile;
        % ---- Prepare cleaned results and error results in utc seconds ----
        [result_clean_avail, result_error_avail] = derive_raw_tbl_utc_s(resultfiledata, avail_algname, avail_vernum, 0, 86400);% denominator

        if strcmp(avail_algname, event_algname)
            result_clean_event = result_clean_avail;
            result_error_event = result_error_avail;
        else
            [result_clean_event, result_error_event] = derive_raw_tbl_utc_s(resultfiledata, event_algname, event_vernum, event_min, event_max);% nominator
        end

        if isempty(result_clean_avail.tagtable_clean)
            alg_avail_not_run = [alg_avail_not_run; string(resultfiledata.id); string(resultfiledata.srcfile)];
            continue
        end
        if isempty(result_clean_event.tagtable_clean)
            alg_event_not_run = [alg_event_not_run; string(resultfiledata.id); string(resultfiledata.srcfile)];
            continue
        end
         
        
        % ---- Derive aggregated result table object for this subject ----
        agg_tbl_sbj = derive_agg_tbl(id, srcfile, result_clean_avail, result_clean_event, unit);
        
        % ---- Vertical concat individual table with all subejects ----
        agg_tbl_cohort = vertcat(agg_tbl_cohort, agg_tbl_sbj);

        % save error objects for this subject
        error.denom = result_error_avail;
        error.nomin = result_error_event;
        save(strcat(error_folder, '\',string(resultfiledata.id),'_', savename,'_',outname,'_error.mat'),'error');
    
    catch ME
        rethrow(ME);
        %warning(strcat('Problem aggregate table -- ',outname,' for file-- ', string(i),' --',savename));
    end
    

end
close(f)


% save daily tables to target folder
if ~isempty(agg_tbl_cohort)
    writetable(agg_tbl_cohort, strcat(save_folder, '\', savename, '_',outname,'.csv'));
end

if ~isempty(alg_avail_not_run)
    writetable(table(alg_avail_not_run),strcat(error_folder, '\', savename, '_denom_not_run.csv'));
end
if ~isempty(alg_event_not_run)
    writetable(table(alg_event_not_run),strcat(error_folder, '\', savename, '_nomin_not_run.csv'));
end

end




