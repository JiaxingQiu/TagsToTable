function agg_tbl_sbj = derive_agg_tbl(id, srcfile, result_clean_avail, result_clean_event, unit)

        % ----- Aggregate information -----
        % denominator
        if unit == 3600
            timekey_avail = string(datetime(result_clean_avail.tagtable_clean.start_posixtime_s, 'ConvertFrom','posixtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH'));% key
        elseif unit == 86400
            timekey_avail = string(datetime(result_clean_avail.tagtable_clean.start_posixtime_s, 'ConvertFrom','posixtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy'));% key
        end
        dur_tbl_avail = groupsummary(table(timekey_avail, result_clean_avail.tagtable_clean.stop_posixtime_s - result_clean_avail.tagtable_clean.start_posixtime_s), 'timekey_avail', {'nnz','sum'}, 'Var2');
        agg_tbl_avails = table(unique(timekey_avail), dur_tbl_avail.sum_Var2);
        agg_tbl_avails.Properties.VariableNames = {'timekey_avail_utc', 'total_avail_duration_s'};

        % numerator
        if unit == 3600
            timekey_event = string(datetime(result_clean_event.tagtable_clean.start_posixtime_s, 'ConvertFrom','posixtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH'));% key
        elseif unit == 86400
            timekey_event = string(datetime(result_clean_event.tagtable_clean.start_posixtime_s, 'ConvertFrom','posixtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy'));% key
        end
        min_tbl_event = groupsummary(table(timekey_event, result_clean_event.tagtable_clean.start_posixtime_s), 'timekey_event', {'min'}, 'Var2');
        max_tbl_event = groupsummary(table(timekey_event, result_clean_event.tagtable_clean.stop_posixtime_s), 'timekey_event', {'max'}, 'Var2');
        dur_tbl_event = groupsummary(table(timekey_event, result_clean_event.tagtable_clean.stop_posixtime_s - result_clean_event.tagtable_clean.start_posixtime_s), 'timekey_event', {'nnz','sum'}, 'Var2');
        agg_tbl_events = table(dur_tbl_event.timekey_event, dur_tbl_event.nnz_Var2, dur_tbl_event.sum_Var2, min_tbl_event.min_Var2, max_tbl_event.max_Var2);
        agg_tbl_events.Properties.VariableNames = {'timekey_event_utc', 'events_count', 'total_event_duration_s', 'first_event_start_utc_s', 'last_event_stop_utc_s'};

        % ---- Merge denominator and nominator ----
        agg_tbl_sbj = outerjoin(agg_tbl_avails, agg_tbl_events, ...
                'LeftKeys','timekey_avail_utc','RightKeys','timekey_event_utc', ...
                'Type','left',...
                'MergeKeys',true);
        agg_tbl_sbj.id = repmat(id, height(agg_tbl_sbj), 1); % add id column
        agg_tbl_sbj.srcfile = repmat(srcfile, height(agg_tbl_sbj), 1); % add id column
        agg_tbl_sbj.Properties.VariableNames = {'timekey_utc', 'total_avail_duration_s', 'events_count', 'total_event_duration_s', 'first_event_start_utc_s', 'last_event_stop_utc_s', 'id','srcfile'};
        agg_tbl_sbj.first_start_utc_datetime = string(datetime(agg_tbl_sbj.first_event_start_utc_s, 'ConvertFrom','posixtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS'));
        agg_tbl_sbj.last_stop_utc_datetime = string(datetime(agg_tbl_sbj.last_event_stop_utc_s, 'ConvertFrom','posixtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS'));
        
        % no events for this subject
        if isempty(agg_tbl_sbj.events_count)
            agg_tbl_sbj.events_count = NaN(height(agg_tbl_sbj),1);
        end
        if isempty(agg_tbl_sbj.total_avail_duration_s)
            agg_tbl_sbj.total_avail_duration_s = NaN(height(agg_tbl_sbj),1);
        end
        if isempty(agg_tbl_sbj.total_event_duration_s)
            agg_tbl_sbj.total_event_duration_s = NaN(height(agg_tbl_sbj),1);
        end
        if isempty(agg_tbl_sbj.first_event_start_utc_s)
            agg_tbl_sbj.first_event_start_utc_s = NaN(height(agg_tbl_sbj),1);
        end
        if isempty(agg_tbl_sbj.last_event_stop_utc_s)
            agg_tbl_sbj.last_event_stop_utc_s = NaN(height(agg_tbl_sbj),1);
        end
        % no-event time unit for this subject
        agg_tbl_sbj.events_count(isnan(agg_tbl_sbj.events_count)) = 0;
        agg_tbl_sbj.total_event_duration_s(isnan(agg_tbl_sbj.total_event_duration_s)) = 0;
        agg_tbl_sbj.total_avail_duration_s(isnan(agg_tbl_sbj.total_avail_duration_s)) = 0;
       
        
        
        % raise an error if a duration is larger than a time unit
        if sum(agg_tbl_sbj.total_event_duration_s > unit)>0
            error_row = agg_tbl_sbj(agg_tbl_sbj.total_event_duration_s > unit,[7:8,1:4,9:10]);
            for r=1:size(error_row,1)
                disp(strcat(strjoin(string(table2array(error_row(r,:))),' | '), ' -- event duration over', string(unit)));
            end
        end
        
        % select final columns to return
        agg_tbl_sbj =  agg_tbl_sbj(:,[7:8,1:4,9:10]);
        
end