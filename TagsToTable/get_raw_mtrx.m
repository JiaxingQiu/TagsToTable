function raw_event_mtrx = get_raw_mtrx(unit, resultfile, algrow)

switch unit
    case 1024
        disp('generate matrix in second (1s = 1024ms)');
    case 1000
        disp('generate matrix in second (1s = 1000ms)');
    case 1
        disp('generate matrix in millisecond (ms)');
    otherwise
        error('invalid posixtime unit');
end


startcol = strcmp(resultfile.result_tagcolumns(algrow).tagname,'Start'); % Find out which row in the results file contains the tags of interest (Note: this won't be the same row for every file - so you should always use a function like this to find out the right row!)
start = floor(resultfile.result_tags(algrow).tagtable(:,startcol)/unit); % start times of data available (utc s)
stopcol = strcmp(resultfile.result_tagcolumns(algrow).tagname,'Stop'); % Find out which row in the results file contains the tags of interest (Note: this won't be the same row for every file - so you should always use a function like this to find out the right row!)
stop = floor(resultfile.result_tags(algrow).tagtable(:,stopcol)/unit); % stop times of data available (utc s)

raw_event_mtrx = [];
if ~isempty(start) && ~isempty(stop)
    raw_event_mtrx = [start, stop];
end

end