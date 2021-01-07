
#fp = r'C:\Users\juanvergara\Documents\PROJECTS\CPO - Solution Acceleration (Chemical Reactor)\rct_CSTR_bonsai_v12\rct_CSTR_bonsai_v12\chemical-plant-training.csv'

import pandas as pd

#d = r'C:\Users\juanvergara\Documents\PROJECTS\CPO - Solution Acceleration (Chemical Reactor)\sim_logs\\'
#fn = 'chemical-plant-training.csv'
#fp = d + fn

#fp = 'chemical-plant-training_v55.csv'
#fp = 'chemical-plant-training_v64.csv'
#fp = 'chemical-plant-training_v70.csv'
#fp = 'chemical-plant-training_v92.csv'
#fp = 'chemical-plant-training_v93.csv'
fp = 'chemical-plant-training_v94.csv'
#fp = 'chemical_plant_training_v95.csv'
#fp = 'chemical_plant_training_v96.csv'
#fp = 'chemical_plant_training_v97.csv'
#fp = 'chemical_plant_training_v103.csv'
#fp = 'chemical_plant_training_v106.csv'

df = pd.read_csv(fp)

#with open(fp) as f_csv:
#    reader = csv.reader(f_csv)
#    for row in reader:
#        print(row)



cols_of_interest = ['state.Cref_delta','state.Tref_delta']
functions_of_interest = ['mean', 'max'] #, 'min']

# Select transition states
transition_ini = 2
transition_end = 30

# Transform errors to absolute values
for col in cols_of_interest:
    df[col] = abs(df[col])

    
# Print number of episodes being considered
episode_start = df["Sim Time"] == 0
print("Episode Start:", len(df[episode_start]))
episode_finish = df["Sim Time"] == 45
print("Episode Finish:", len(df[episode_finish]))
print()

# Select transition states
select_trans_0 = df["Sim Time"] >= transition_ini
select_trans_1 = df["Sim Time"] <= transition_end
trans_iterations = select_trans_0 & select_trans_1

# All iterations (avoid Idle)
all_iterations = df["Sim Time"] >= 0
not_trans = [not trans for trans in trans_iterations]
not_trans_iterations = all_iterations & not_trans

# Split df into 2 regions
df_not_trans = df[not_trans_iterations]
df_trans = df[trans_iterations]


#functions_of_interest = ['mean', 'max', 'min']
#df.agg({'state.Cref_delta' : functions_of_interest, 'state.Tref_delta' : functions_of_interest})

# Extract results
print("\nNot Trans results:")
print(df_not_trans.agg(functions_of_interest)[cols_of_interest])

print("\nTrans results:")
print(df_trans.agg(functions_of_interest)[cols_of_interest])
