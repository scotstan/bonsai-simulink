function simState = copyFromWorkspace(workspaceState)%,simState)

    fromStruct = workspaceState;
    %toStruct = simState;
    simState = struct();
    
    fields = fieldnames(fromStruct);
    
    for fn = 1:numel(fields)
        f1 = fromStruct.(fields{fn});
        %f2 = toStruct.(fields{fn});
        
        if isstruct(f1)
            simState.(fields{fn}) = copyFromWorkspace(f1);%,f2);
        else
            simState.(fields{fn}) = f1.data(end);
        end
    end
end 
