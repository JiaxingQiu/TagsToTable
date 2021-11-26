function result_sbj = derive_find_overlap(tag1_mtrx, tag2_mtrx)

%% ------------------- Description -----------------------
% find overlap between tag result 1 and  tag result 2
% result matrix column 1 = start array; column 2 = stop array
%% ---------------------------------------------------------

result_sbj = [];

% sort tag1 matrix and tag 2 matrix by  start time (column 1)
tag1_mtrx = sortrows(tag1_mtrx);
tag2_mtrx = sortrows(tag2_mtrx);

% save 4 arrays
tag1.start = reshape(tag1_mtrx(:,1), 1, size(tag1_mtrx,1));
tag1.stop = reshape(tag1_mtrx(:,2), 1, size(tag1_mtrx,1));
tag2.start = reshape(tag2_mtrx(:,1), 1, size(tag2_mtrx,1));
tag2.stop = reshape(tag2_mtrx(:,2), 1, size(tag2_mtrx,1));


i = 1; % i_th event in tag 1 result table
j = 1; % j_th event in tag 2 result table
while (true)
    % exit condition
    if i>length(tag1.start) || j>length(tag2.start)
        break
    end
    % initiate
    overlap.start = NaN;
    overlap.stop = NaN;
    % compare starts and find valid/comparable event indices
    if tag1.start(i) < tag2.start(j)
        if tag1.stop(i) < tag2.start(j)
            i=i+1;
            continue
        end
    end
    if tag1.start(i) > tag2.start(j)
        if tag1.start(i) > tag2.stop(j)
            j=j+1;
            continue
        end
    end
    % assign overlap start and stop
    overlap.start = max(tag1.start(i),tag2.start(j));
    overlap.stop = min(tag1.stop(i),tag2.stop(j));
    % update event indices
    if tag1.stop(i) == overlap.stop
        i=i+1;
    end
    if tag2.stop(j) == overlap.stop
        j=j+1;
    end
    % append to subject-wise result
    result_sbj = [result_sbj;[overlap.start, overlap.stop]];
end

end