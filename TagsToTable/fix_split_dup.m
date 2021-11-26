function [mtrx_clean, mtrx_error] = fix_split_dup(raw_event_mtrx)

% initiate
mtrx_clean = [];
mtrx_error = [];

mtrx_clean = raw_event_mtrx(1,:);
j = 1; % j is the last valid index to compare with following i
i = j + 1;
% loop through each row of raw event matrix
while i <= size(raw_event_mtrx,1)
    if raw_event_mtrx(i,1) < raw_event_mtrx(j,2)
        mtrx_error = [mtrx_error; raw_event_mtrx((i-1):i,:)];% append duplicate row and its left neighbors to dup matrix
        i = i + 1;
        continue
    end
    mtrx_clean = [mtrx_clean; raw_event_mtrx(i,:)];% append valid row to clean matrix
    j = i;
    i = j + 1;
end

disp('Fixing duplicates by removing them');

end