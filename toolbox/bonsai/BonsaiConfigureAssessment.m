% function to configure assessment of a Bonsai brain
% Copyright 2020 Microsoft

function BonsaiConfigureAssessment(config, mdl, episodeStartCallback)

    % configure session
    session = bonsai.Session.getInstance();
    session.configure(config, mdl, episodeStartCallback);

    % print success
    logger = bonsai.Logger('BonsaiConfigureAssessment', config.verbose);
    logger.log('Configuration for assessment complete.');

end
