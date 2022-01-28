function derive_joint_data_cohort(source_folder, save_folder, alg_dict1, alg_dict2, output_obj, event_min, event_max)

% specify 2 algorithm and their denominator algorithms
event_algname1 = alg_dict1.algname;
event_vernum1 = alg_dict1.vernum;
avail_algname1 = alg_dict1.denom.algname;
avail_vernum1 = alg_dict1.denom.vernum;

event_algname2 = alg_dict2.algname;
event_vernum2 = alg_dict2.vernum;
avail_algname2 = alg_dict2.denom.algname;
avail_vernum2 = alg_dict2.denom.vernum;


% load files in one folder
allfileinfo = dir(strcat(string(source_folder),'\*resultsmerged.mat'));

% create save file name fashion
algname1_array_event = regexp(string(event_algname1),'(\w+)','match');
algname2_array_event = regexp(string(event_algname2),'(\w+)','match');
algname_joint_event = strcat(strjoin(algname1_array_event(2:end),"_"),'_v',string(event_vernum1),'_X_',strjoin(algname2_array_event(2:end),"_"),'_v',string(event_vernum2));
algname1_array_avail = regexp(string(avail_algname1),'(\w+)','match');
algname2_array_avail = regexp(string(avail_algname2),'(\w+)','match');
algname_joint_avail = strcat(strjoin(algname1_array_avail(2:end),"_"),'_v',string(avail_vernum1),'_X_',strjoin(algname2_array_avail(2:end),"_"),'_v',string(avail_vernum2));
joint_folder = strcat(save_folder,'\joint_',algname_joint_event);

raw_joint_tbl_avail_cohort = [];
raw_joint_tbl_event_cohort = [];
agg_joint_tbl_cohort = [];

f = waitbar(0,'Here we go!');
for i=1:length(allfileinfo)
    waitbar(i/length(allfileinfo),f,['Working on file ' num2str(i) ' of ' num2str(length(allfileinfo))])
    
    
    % Prepare input result file data for subject
    resultfiledata = get_result_file(allfileinfo(i));
    
    % initiate result_joint object to return
    id = resultfiledata.id;
    srcfile = resultfiledata.srcfile;
    result_joint_avail.id = id;
    result_joint_avail.srcfile = srcfile;
    result_joint_avail.algorithm = algname_joint_avail;
    result_joint_avail.tagtable_clean = [];
    result_joint_avail.message = [];
    
    result_joint_event.id = id;
    result_joint_event.srcfile = srcfile;
    result_joint_event.algorithm = algname_joint_event;
    result_joint_event.tagtable_clean = [];
    result_joint_event.message = [];
    
    % Prepare cleaned result object for algorithm 1 
    try
        [result_clean_avail1, ~] = derive_raw_tbl_utc_s(resultfiledata, avail_algname1, avail_vernum1, 0, 86400);% denominator
        if strcmp(avail_algname1, event_algname1)
            result_clean_event1 = result_clean_avail1;
        else
            [result_clean_event1, ~] = derive_raw_tbl_utc_s(resultfiledata, event_algname1, event_vernum1, event_min, event_max);% nominator
        end
    catch
        error(strcat('Error preparing cleaned result matrix for algorithm',avail_algname1,' on file ', string(i)));
    end
    % Prepare cleaned result object for algorithm 2 
    try
        [result_clean_avail2, ~] = derive_raw_tbl_utc_s(resultfiledata, avail_algname2, avail_vernum2, 0, 86400);% denominator
        if strcmp(avail_algname2, event_algname2)
            result_clean_event2 = result_clean_avail2;
        else
            [result_clean_event2, ~] = derive_raw_tbl_utc_s(resultfiledata, event_algname2, event_vernum2, event_min, event_max);% nominator
        end
    catch
        error(strcat('Error preparing cleaned result matrix for algorithm',avail_algname2,' on file ', string(i)));
    end
    
    
    % Prepare [start, stop] matrix for algorithm 1
    if ~isempty(result_clean_avail1.tagtable_clean) && ~isempty(result_clean_event1.tagtable_clean)
        mtrx_clean_avail1 = [result_clean_avail1.tagtable_clean.start_posixtime_s, result_clean_avail1.tagtable_clean.stop_posixtime_s];
        mtrx_clean_event1 = [result_clean_event1.tagtable_clean.start_posixtime_s, result_clean_event1.tagtable_clean.stop_posixtime_s];
    else
        continue
    end
    % Prepare [start, stop] matrix for algorithm 2
    if ~isempty(result_clean_avail2.tagtable_clean) && ~isempty(result_clean_event2.tagtable_clean)
        mtrx_clean_avail2 = [result_clean_avail2.tagtable_clean.start_posixtime_s, result_clean_avail2.tagtable_clean.stop_posixtime_s];
        mtrx_clean_event2 = [result_clean_event2.tagtable_clean.start_posixtime_s, result_clean_event2.tagtable_clean.stop_posixtime_s];
    else
        continue
    end
    
    % Find overlap for denominator matrices in utc second
    mtrx_joint_avail = derive_find_overlap(mtrx_clean_avail1, mtrx_clean_avail2);
    % Find overlap for numerator matrices in utc second
    mtrx_joint_event = derive_find_overlap(mtrx_clean_event1, mtrx_clean_event2);
    
    % individual denominator joint result
    if ~isempty(mtrx_joint_avail)
        start_datetime = datetime(mtrx_joint_avail(:,1), 'ConvertFrom','posixtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS');
        stop_datetime = datetime(mtrx_joint_avail(:,2), 'ConvertFrom','posixtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS');
        result_joint_avail.tagtable_clean = table(start_datetime, stop_datetime, mtrx_joint_avail(:,1), mtrx_joint_avail(:,2), ones(size(mtrx_joint_avail,1),1));
        result_joint_avail.tagtable_clean.Properties.VariableNames = {'start_datetime','stop_datetime','start_posixtime_s','stop_posixtime_s','sorted_chunk_id'};
    end
    
    % individual nominator joint result
    if ~isempty(mtrx_joint_event)
        start_datetime = datetime(mtrx_joint_event(:,1), 'ConvertFrom','posixtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS');
        stop_datetime = datetime(mtrx_joint_event(:,2), 'ConvertFrom','posixtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS');
        result_joint_event.tagtable_clean = table(start_datetime, stop_datetime, mtrx_joint_event(:,1), mtrx_joint_event(:,2), ones(size(mtrx_joint_event,1),1));
        result_joint_event.tagtable_clean.Properties.VariableNames = {'start_datetime','stop_datetime','start_posixtime_s','stop_posixtime_s','sorted_chunk_id'};
    end
    
    
    if strcmp(output_obj.name, "raw_utc_s")
        
        if ~isempty(result_joint_event.tagtable_clean) 
            raw_joint_tbl_event = table( ...
            string(result_joint_event.tagtable_clean.start_datetime),...% start date time
            string(result_joint_event.tagtable_clean.stop_datetime),... % stop date time
            result_joint_event.tagtable_clean.stop_posixtime_s -  result_joint_event.tagtable_clean.start_posixtime_s, ... % durtation in seconds
            repmat(result_joint_event.id, height(result_joint_event.tagtable_clean), 1),... % id
            repmat(result_joint_event.srcfile, height(result_joint_event.tagtable_clean), 1)... % id
            );
            raw_joint_tbl_event.Properties.VariableNames = {'start_date_time', 'stop_date_time', 'duration_s', 'id','srcfile'};
            % concat vertically with cohort table
            raw_joint_tbl_event_cohort = vertcat(raw_joint_tbl_event_cohort, raw_joint_tbl_event);
        end
        if ~isempty(result_joint_avail.tagtable_clean) 
            raw_joint_tbl_avail = table( ...
            string(result_joint_avail.tagtable_clean.start_datetime),...% start date time
            string(result_joint_avail.tagtable_clean.stop_datetime),... % stop date time
            result_joint_avail.tagtable_clean.stop_posixtime_s -  result_joint_avail.tagtable_clean.start_posixtime_s, ... % durtation in seconds
            repmat(result_joint_avail.id, height(result_joint_avail.tagtable_clean), 1),... % id
            repmat(result_joint_avail.srcfile, height(result_joint_avail.tagtable_clean), 1)... % id
            );
            raw_joint_tbl_avail.Properties.VariableNames = {'start_date_time', 'stop_date_time', 'duration_s', 'id', 'srcfile'};
            % concat vertically with cohort table
            raw_joint_tbl_avail_cohort = vertcat(raw_joint_tbl_avail_cohort, raw_joint_tbl_avail);
        end
        
    elseif strcmp(output_obj.name, "agg_hourly")
        if ~isempty(result_joint_event.tagtable_clean) && ~isempty(result_joint_avail.tagtable_clean)
            agg_tbl_sbj = derive_agg_tbl(id, srcfile, result_joint_avail, result_joint_event, output_obj.unit);
            agg_joint_tbl_cohort = [agg_joint_tbl_cohort;agg_tbl_sbj];
        end
    elseif strcmp(output_obj.name, "agg_daily")
        if ~isempty(result_joint_event.tagtable_clean) && ~isempty(result_joint_avail.tagtable_clean)
            agg_tbl_sbj = derive_agg_tbl(id, srcfile, result_joint_avail, result_joint_event, output_obj.unit);
            agg_joint_tbl_cohort = [agg_joint_tbl_cohort;agg_tbl_sbj];
        end
    elseif strcmp(output_obj.name, "derived_mat")
        % save error objects for this subject
        result_joint.denom = result_joint_avail;
        result_joint.nomin = result_joint_event;
        save(strcat(joint_folder, '\',string(id),'_joint_',algname_joint_event,'.mat'),'result_joint');
    end
    
    
end
close(f)


if ~isempty(raw_joint_tbl_avail_cohort)
    writetable(raw_joint_tbl_avail_cohort, strcat(save_folder, '\', algname_joint_event, '_',output_obj.name,'_avail.csv'));
end

if ~isempty(raw_joint_tbl_event_cohort)
    writetable(raw_joint_tbl_event_cohort, strcat(save_folder, '\', algname_joint_event, '_',output_obj.name,'_event.csv'));
end

if ~isempty(agg_joint_tbl_cohort)
    writetable(agg_joint_tbl_cohort, strcat(save_folder, '\', algname_joint_event, '_',output_obj.name,'.csv'));
end


end

