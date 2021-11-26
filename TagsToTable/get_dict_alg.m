function dict_obj = get_dict_alg(bap_v)

dict_obj = [];
try
   
    % dictfilepath
    dict_tbl = readtable(strcat('dict_algorithm_bap_',string(bap_v),'.csv'));
    dict_obj.bap_v = bap_v;
    dict_obj.vshour = dict_tbl(dict_tbl.VS_Hourly_Statistics==1,1:4);
    dict_obj.onealg = dict_tbl(dict_tbl.One_Algorithm==1,1:4);
    dict_obj.twoalg = dict_tbl(dict_tbl.Two_Algorithms==1,1:4);
    dict_obj.tenmins = dict_tbl(dict_tbl.Ten_Mins==1,1:4);
    dict_obj.hctsa = dict_tbl(dict_tbl.HCTSA==1,1:4);
catch
    uiwait(msgbox(strcat(pwd,'\dict_algorithm_bap_',string(bap_v),'.csv not found in current folder'),"Error"));
end
if isempty(dict_obj)
    uiwait(msgbox("Empty algorithm dictionary", "Error"));
end


end