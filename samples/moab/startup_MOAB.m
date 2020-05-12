folder_pathlist = {...
    'CAD'...
    'Images'...
    'Scripts_Data'...
    };
addpath(pwd);
for i=1:length(folder_pathlist)
    addpath([pwd filesep folder_pathlist{i}]);
end

MOAB_PARAMS

open_system('MOAB');

