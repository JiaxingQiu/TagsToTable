function [mtrx_clean, mtrx_error] = fix_union_dup(raw_event_mtrx)

% ---- take the union of duplicate overlapping pieces ----

mtrx_error = [];
mtrx_clean = [];

% locate and save error 
clear err_idx
err_idx = raw_event_mtrx(:,1)<[0;raw_event_mtrx(1:size(raw_event_mtrx,1)-1,2)];
err_idx_left = [err_idx(2:end,1);false];
mtrx_error = raw_event_mtrx(err_idx | err_idx_left, :); 

% fix current stop time 
mtrx_clean = raw_event_mtrx;

%    if current stop time is later than next stop time, fix next stop time by replacing next stop with current stop time
clear err_idx
err_idx = [0;mtrx_clean(2:end,2)-mtrx_clean(1:end-1,2)]<0;
mtrx_clean(err_idx, 2) = mtrx_clean([err_idx(2:end,1);false], 2);

%    if current stop time is later than next start time, fix current stop time by replaceing current stop time with next start time
clear err_idx
err_idx = [mtrx_clean(1:end-1,2)-mtrx_clean(2:end,1); 0]>0;
mtrx_clean(err_idx, 2) = mtrx_clean([false;err_idx(1:end-1,1)], 1);

disp('Fixing duplicates by taking union.');

end