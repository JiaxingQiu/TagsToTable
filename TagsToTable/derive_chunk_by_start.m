function [raw_event_mtrx, error_mtrx] = derive_chunk_by_start(raw_event_mtrx)
% ---- Fix raw event matrix error : start time is not in ascending order ---- 

% if start time is not ascending
% find all chunks of sorted matrices 
% label the order of chunks in a new column 
% return labeled raw event matrix


% initiate chunk order by 0
raw_event_mtrx(:,3) = zeros(size(raw_event_mtrx,1),1);

order = 1;
raw_event_mtrx(1,3) = order;
for i=2:size(raw_event_mtrx,1)
    
    if raw_event_mtrx(i,1) < raw_event_mtrx(i-1,1)
        order = order+1;
    end
    
    raw_event_mtrx(i,3) = order;
    
end

% find jumps and their neighbors
idx = raw_event_mtrx(:,3)-[1;raw_event_mtrx(1:end-1,3)]==1 | raw_event_mtrx(:,3)-[raw_event_mtrx(2:end,3);raw_event_mtrx(end,3)]==-1;
error_mtrx = raw_event_mtrx(idx,:);

end