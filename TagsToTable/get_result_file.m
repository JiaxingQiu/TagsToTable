function resultfiledata = get_result_file(resultfileinfo)
%% ---------------------------------------------- Description ------------------------------------------------

% Usage: Load resultfile from result file info struct, check whether 'id' is a field of a single merged result file
% structure, if not, assign id by checking naming fashion of a file, if all
% fashion fail, assign filename as unique id.
%
% Input: 
% 1. resultfileinfo = result file info struct
%        
% Output: 
% 1. resultfile data object with id field in it

%% -----------------------------------------------------------------------------------------------------------

resultfilefullname = fullfile(resultfileinfo.folder,resultfileinfo.name);
resultfiledata = load(resultfilefullname);

% ---- check / assign id ----
if isfield(resultfiledata, 'id')
    resultfiledata = rmfield(resultfiledata,'id');
end
if ~isfield(resultfiledata, 'id')
    if(strcmp(resultfileinfo.name(5),'_'))
        id = resultfileinfo.name(1:4);
        resultfiledata.id = id;
        %save(resultfilefullname,'id','-append');
    elseif(strcmp(resultfileinfo.name(15),'_'))
        id = resultfileinfo.name(16:19);
        resultfiledata.id = id;
        %save(resultfilefullname,'id','-append');
    else
        id = strjoin(regexp(string(resultfileinfo.name),'(\w+)','match'),"_");
        resultfiledata.id = id;
        disp(['Assign file name to id for file -- ' resultfilefullname]);
    end
end

% ---- check / assign srcfile ----
if isfield(resultfiledata, 'srcfile')
    resultfiledata = rmfield(resultfiledata,'srcfile');
end
if ~isfield(resultfiledata, 'srcfile')
    srcfile = strjoin(regexp(string(resultfileinfo.name),'(\w+)','match'),"_");
    resultfiledata.srcfile = srcfile;
    %disp(['Assign file name to srcfile for file -- ' resultfilefullname]);
end


end