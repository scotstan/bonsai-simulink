% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% Other bonsai-simulink samples use bonsaiAssess.m so that a Simulink model
% can be run inside the MATLAB application to view and troubleshoot
% execution with a trained brain.

% That approach is not necessary for this pure-matlab example because there
% is no Simulink model to run. bonsaiTrain.m can be used to register an
% unmanaged simulator and debug it during either training or assessment.