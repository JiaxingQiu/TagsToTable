function mtrx_sorted = fix_sort_chunks(raw_event_mtrx)

% check input matrix has 3 columns
if size(raw_event_mtrx,2)~=3
    error('invalid input matrix');
end


first_rows = raw_event_mtrx(raw_event_mtrx(:,3)-[0;raw_event_mtrx(1:end-1,3)]==1,:);
first_rows = sortrows(first_rows);

mtrx_sorted = [];
for i = 1:size(first_rows,1)
    chunk_id = first_rows(i,3);
    mtrx_sorted = [mtrx_sorted;raw_event_mtrx(raw_event_mtrx(:,3)==chunk_id,:)];
end

end