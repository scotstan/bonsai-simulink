# Using the Toolbox

This document covers connecting a Simulink Cartpole model with the platform using the Bonsai3 Simulink Toolbox.

## Prerequisites–PleaseCompleteBeforehand
- []   InstallMATLABandSimulinkonyourlocalmachine:https://www.mathworks.com/help/install/ug/install-mathworks-software.html
- []   Getthelatestcopyofthetoolbox,bonsai.mltbxfromtheFileExchangeorAdd-onStore
- []   CreateanAzureaccountandadda“Bonsai”resourceintoyourAzureAccount.

Once you have completed the above, download the Cartpole or Moab model from the "examples" tab and open it up in your desktop. It should have several files:

1. **bonsaiConfig.m**
2. **bonsaiTrain.m**
3. **bonsaiAssessData.m**


The above five files are necessary to upload your own Simulink model to Bonsai to allow us to read and scale the Simulink model. The files have the below properties: 

1. **bonsaiConfig.m**
**bonsaiConfig.m** requires two pieces of information - your workspace ID and your access key. To grab your workspace ID, first provision a Bonsai application in your Microsoft Azure account. Once it has been created at http://preview.bons.ai, visit "Workspace Settings" under your user profile dropwdown. This will have the Workspace ID, and you can also generate an Access Key. Generate an Access Key and copy it in `config.AccessKey`. 

:warning: NOTE: You can only copy an Access Key once! If you you have closed the window once it pops up, generate another and keep it safe somewhere.



**bonsaiConfig.m** also allows you to set verbosity of logs (change `config.verbose` to 'True') and configure your model timeout. If your model takes longer than 60 seconds to complete a loop, edit the value `config.timeout` to be greater than 60 seconds. 

2. **bonsaiTrain.m**

**bonsaiTrain.m** is our script which validates that the model has all the appropriate dependencies in the project folder and begins training. Note that `mdl` defines the model file, and fast restart is turned on. The script checks that all the appropriate configuration is set in **bonsaiConfig.m**. Make sure to run this from your desktop once to ensure the Simulink toolbox is hooked up correctly.


3. **bonsaiAssessData.m**

bonsaiAssessData sets the values necessary for a user to initiate assessment of a trained model. 

Once you have the three scripts in place, you can configure your model using the Bonsai Simulink Toolbox. These are the fields that you should hook up with your model: 

1.  STATE:Statedefinitiondescribesvariablesthatrepresentthestateofthesystemateachtimestep.ExamplesfromHVAC:currenttemperature,humidityinsideandoutsidethebuilding,desiredtemperature.[]
2.  ACTION:Thereshouldbeidentifiableactionsthatanagentcancontrol.E.g.inasimulationofamanufacturingmachine,controlactionsaffectwhetherthepartismadecorrectly.
4.  HALTED:thisisasignaltotheservicethatthesimhasreachedacompletionofaloop,notdrivenbyoutcomessetduringmachineteaching,butratherthosecomingdirectlyfromthemodel.
5.  RESET:thislogicrestartsthemodelfromtheinitialconfiguration

Once you have configured the toolbox and the above into the block integrated with your model, run `bonsaiTrain` from the Matlab console. This will initiate a training session that you must "attach" to a brain. The name of the model will show up in 'Simulators' as "unmanaged".
