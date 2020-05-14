
% Run this script to set your bonsai configuration and initialize variables
% required by the model.

% configure session
config = bonsaiConfig;
session = bonsai.Session.getInstance();
session.configure(config);

% initial data required by the model
initialPos = 0;
