%simState struct (must be named simState)
simState.myArray = [0,0,0,0,0];
simState.cart.position = 0;
simState.cart.velocity = 0;
simState.pole.angle = 0; 
simState.pole.rotation = 0;

%brainAction struct (must be named brainAction)
brainAction.command = 0;