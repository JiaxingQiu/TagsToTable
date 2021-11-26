function get_log_report(source_folder, save_folder)

% This checks to make sure an algorithm is not still present that should have been overwritten
logfilelist = dir(strcat(string(source_folder),'\*logmerged.mat'));
log_cohort_msg = []; % for BAP 2.0
log_cohort = []; % for BAP 2.1

f = waitbar(0,'Here we go!');
for i=1:length(logfilelist)
    waitbar(i/length(logfilelist),f,['Working on file ' num2str(i) ' of ' num2str(length(logfilelist))])
    
    logfilefullname = fullfile(logfilelist(i).folder, logfilelist(i).name);
    logfiledata = load(logfilefullname);
    
    log = logfiledata.log;
    for j = 1:length(log)
        if ~isempty(log(j).error)
            try % compatable with log style of BAP 2.0
                log_cohort_msg = [log_cohort_msg;[getReport(log(j).error, 'basic'), string(log(j).algorithm), log(j).filename]];
            catch ME
                disp(getReport(ME, 'basic'));
            end
            try % compatable with log style of BAP 2.1
                log_cohort = [log_cohort;[string(log(j).error), string(log(j).algorithm), log(j).filename, string(log(j).time)]];
            catch ME
                disp(getReport(ME, 'basic'));
            end
        end
    end
end
close(f);

writetable(table(log_cohort_msg), strcat(save_folder, '\', 'log_errors_msg.csv'));
writetable(table(log_cohort), strcat(save_folder, '\', 'log_errors.csv'));

end