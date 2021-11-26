function algrow = get_algname_row(resultfiledata,algname,vernum)
% Find the tag index that matches the algorithm and version number of interest
    if ~isempty(resultfiledata.result_tagtitle)
        algnamerow = strcmp(resultfiledata.result_tagtitle(:,1),algname);
        vernumrow = strcmp(string(resultfiledata.result_tagtitle(:,2)), string(vernum));
        algrow = find(algnamerow & vernumrow);
    else
        algrow = [];
    end
end