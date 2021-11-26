function [mtrx_clean, mtrx_error] = fix_break_utc_dates(raw_event_mtrx)

mtrx_clean = [];
mtrx_error = [];

starts_event = raw_event_mtrx(:,1);
stops_event = raw_event_mtrx(:,2);

% generate breaks between 2 days
breaks_end_event = posixtime(datetime(strcat(string(datestr(floor(datenum(1970,1,1) + starts_event/86400))),' 23:59:59'))); % end of the first date
breaks_start_event = posixtime(datetime(strcat(string(datestr(ceil(datenum(1970,1,1) + starts_event/86400))),' 00:00:00'))); % start of the second date

% add corrected stop and starts to raw event matrx
raw_event_mtrx1 = raw_event_mtrx;
raw_event_mtrx2 = raw_event_mtrx1(stops_event > breaks_end_event,:);
mtrx_error = raw_event_mtrx2;
raw_event_mtrx2(:,1) = breaks_start_event(stops_event > breaks_end_event);
raw_event_mtrx1(stops_event > breaks_end_event,2) = breaks_end_event(stops_event > breaks_end_event);
mtrx_clean = [raw_event_mtrx1; raw_event_mtrx2];

% sort matrix by starts column (1)
mtrx_clean = sortrows(mtrx_clean);

end