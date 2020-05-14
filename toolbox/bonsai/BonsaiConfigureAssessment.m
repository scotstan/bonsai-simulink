% function to configure assessment of a Bonsai brain
% Copyright 2020 Microsoft

function BonsaiConfigureAssessment(config, mdl, episodeStartCallback)

    % configure session
    session = bonsai.Session.getInstance();
    session.configure(config, mdl, episodeStartCallback);
end
