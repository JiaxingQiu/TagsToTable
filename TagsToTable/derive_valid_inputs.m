function [source_folder, save_folder, output_obj, alg_dict] = derive_valid_inputs(source_folder, save_folder, algname, output, dict)

%% ------------------------------------------- Description --------------------------------------------

% Usage: make valid input argumants from APP

% Input:
%      0. 'dict_algorithm.csv' under same folder (pwd)
%      1. source_folder: source result merged file folder path
%      2. save_folder: save table file path
%      3. algname: target algorithm name
%      4. vernum: target algorithm version number 
%      5. output: output table type (one of 3 strings "raw_utc_s", "agg_hourly", "agg_daily")
%      6. bap_v: result files bap version

% Output:
%      1. source_folder: valid source_folder string
%      2. save_folder: valid save_folder string
%      3. output_obj: output structure object
%              3.1 output_obj.name: one of 3 strings -- "raw_utc_s", "agg_hourly", "agg_daily"
%              3.2 output_obj.unit: pair with name in seconds -- 1, 3600, 86400
%      4. alg_dict: algorithm and version dictionary struct object
%              4.1 alg_dict.algname: algorithm name
%              4.2 alg_dict.vernum: algorithm version number
%              4.3 alg_dict.denom.algname: denominator of this algorithm's algorithm name 
%              4.4 alg_dict.denom.vernum: denominator of this algorithm's version number

%% -----------------------------------------------------------------------------------------------------

% ---- make inputs all string ----
try
    source_folder = string(source_folder);
    save_folder = string(save_folder);
    output = string(output);
    algname = string(algname);
catch
    uiwait(msgbox("Coerce arguments to string failed", 'Error'));
end

% ---- derive valid output structure object ----
try
    output_obj.name = output;
    if strcmp(output_obj.name, "raw_utc_s")
        output_obj.unit = 1;
    elseif strcmp(output_obj.name, "agg_hourly")
        output_obj.unit = 3600;
    elseif strcmp(output_obj.name, "agg_daily")
        output_obj.unit = 86400;
    elseif strcmp(output_obj.name, "derived_mat")
        output_obj.unit = 1;
    end
catch
    uiwait(magbox("Invalid string argument -- output", "Error"));
end

% nominator
try
    idx_nom = strcmp(algname, dict.Result_Name);
catch
    uiwait(msgbox("No algorithm display name found in the dictionary","Error"));
end
try
    alg_dict.algname = string(dict.Result_Name(idx_nom));
catch
    uiwait(msgbox("No algorithm result name found in the dictionary","Error"));
end
try
    alg_dict.vernum = string(dict.Version(idx_nom));
catch
    uiwait(msgbox("No algorithm version number found in the dictionary","Error"));
end

% prep denominator
try
    alg_dict.denom.algname = string(dict.Denominator_Result_Name(idx_nom));
catch
    uiwait(msgbox("No denominator algorithm result name found in the dictionary","Error"));
end
try
    alg_dict.denom.vernum = string(dict.Version(strcmp(alg_dict.denom.algname,dict.Result_Name)));
catch
    uiwait(msgbox("No denominator algorithm version number found in the dictionary","Error"));
end

end