#%%
import pandas as pd
import numpy as np
import math
from gurobipy import *

# %%
## Create a list of workers and shifts
shiftList = ['May5-1','May5-2','May5-3','May6-1','May6-2', 'May6-3']
vaccinationList = ['V1','V2','V3','V4','V5','V6','V7','V8','V9','V10', 'V11', 'V12', 
                    'V13', 'V14', 'V15','V16', 'V17'] 
registrationList = ['R1','R2','R3','R4','R5','R6','R7','R8','R9','R10', 'R11']

## Define shift requirements
# 6v+6r for all three shifts
"""
scenarioNum = 1
vacReq = [4,4,4,4,4,4]
regReq = [5,5,4,5,5,4]
"""
"""
scenarioNum = 2
vacReq = [6,6,6,6,6,6]
regReq = [5,5,6,5,5,6]
"""
"""
scenarioNum = 3
vacReq = [6,6,6,6,6,6]
regReq = [4,5,6,4,5,6]
"""
"""
scenarioNum = 4
vacReq = [6,6,6,6,6,6]
regReq = [6,6,6,6,6,6]
"""
scenarioNum = 5
vacReq = [3,4,4,3,4,4]
regReq = [3,4,5,3,4,5]

shiftReq = [vacReq[i]+regReq[i] for i in range(len(shiftList))]
vacReq = [vacReq[i] for i in range(len(shiftList))]
shiftRequirements  = { s : shiftReq[i] for i,s in enumerate(shiftList) }
vacRequirements  = { s : vacReq[i] for i,s in enumerate(shiftList) }

#%%
## Clarify worker availability
# Assume everyone is available
Vavailability = pd.DataFrame(np.ones((len(vaccinationList), len(shiftList))), index=vaccinationList, columns=shiftList)
Ravailability = pd.DataFrame(np.ones((len(registrationList), len(shiftList))), index=registrationList, columns=shiftList)

# For illustration, assume following people are unavailable: EE02 on Tuesday1, EE05 on Saturday2, EE08 on Thursday1
Vavailability.at['V1','May5-1'] = 0
Vavailability.at['V2','May6-1'] = 0
Vavailability.at['V3','May6-2'] = 0
Ravailability.at['R1','May5-1'] = 0
Ravailability.at['R2','May6-1'] = 0
Ravailability.at['R3','May6-3'] = 0
# Create dictionary of final worker availability
Vavail = {(w,s) : Vavailability.loc[w,s] for w in vaccinationList for s in shiftList}
Ravail = {(w,s) : Ravailability.loc[w,s] for w in registrationList for s in shiftList}

## Specify who is a manager and who isn't
vecMgmtList = ['V1','V2','V3','V4','V5','V6','V7','V8','V9','V10', 'V11', 'V12']
regMgmtList = ['R1','R2','R3']
VnonmgmtList = [x for x in vaccinationList if x not in vecMgmtList]
RnonmgmtList = [x for x in registrationList if x not in regMgmtList]


#%%
## Define total shift cost per worker
# Cost of vac and reg staff
vaccinationCost = [30,30,30,30,30,30,30,30,30,30,30,30,
                    0,0,0,0,0]
registrationCost = [15,15,15,10,10,10,10,10,10,10,10]

# Create dictionaries with costs
vaccinationCost  = { w : vaccinationCost[i] for i,w in enumerate(vaccinationList) }
registrationCost  = { w : registrationCost[i] for i,w in enumerate(registrationList) }

## Input assumptions
# Range of shifts that every workers is required to stay between
minShifts = 0
maxShifts = 2

#%%
model = Model("scheduling")

x = model.addVars(vaccinationList, shiftList, ub=Vavail, vtype=GRB.BINARY, name='x')
y = model.addVars(registrationList, shiftList, ub=Ravail, vtype=GRB.BINARY, name='y')

# Ensure total number of workers are scheduled
shiftReq = model.addConstrs(((x.sum('*',s) + y.sum('*',s)== shiftRequirements[s] for s in shiftList)), 
                                name='shiftRequirement')
# Ensure number of vaccine staff are no less than the requirement
vacReq = model.addConstrs((x.sum('*',s) >= vacRequirements[s] for s in shiftList), 
                                name='vecRequirement')

for w in vaccinationList:
    model.addConstr((quicksum(x.sum(w,s) for s in shiftList[:3]) >= minShifts), name='vminShifts1')
    model.addConstr((quicksum(x.sum(w,s) for s in shiftList[3:]) >= minShifts), name='vminShifts2') 
    model.addConstr((quicksum(x.sum(w,s) for s in shiftList[:3]) <= maxShifts), name='vmaxShifts1') 
    model.addConstr((quicksum(x.sum(w,s) for s in shiftList[3:]) <= maxShifts), name='vmaxShifts2')  

for s in shiftList:
    model.addConstr((quicksum(x.sum(m,s) for m in VnonmgmtList) <= 2), name='vecManagement'+str(s))
for s in shiftList:
    model.addConstr((quicksum(y.sum(m,s) for m in regMgmtList) >= 1), name='regManagement'+str(s))

#%%
# Minimize total cost, accounting for pay difference between veccination staff and registration staff

model.ModelSense = GRB.MINIMIZE

Cost = (quicksum(vaccinationCost[w]*x[w,s] for w in vaccinationList for s in shiftList))+(quicksum(registrationCost[w]*y[w,s] for w in registrationList for s in shiftList))

model.setObjective(Cost)
# %%
model.optimize()
# %%
model.write("Optimized_Scheduling.lp")
file = open("Optimized_Scheduling.lp", 'r')
print(file.read())
#%%
sol = pd.DataFrame(data={'Solution':model.X}, index=model.VarName)

dashboard = pd.DataFrame(index = vaccinationList+registrationList, columns = shiftList)
for w in vaccinationList:
    for s in shiftList:
        dashboard.at[w,s] = sol.loc['x['+w+','+s+']',][0]
for w in registrationList:
    for s in shiftList:
        dashboard.at[w,s] = sol.loc['y['+w+','+s+']',][0]     
dashboard = dashboard.append(['cost',str(model.ObjVal)])
dashboard.to_csv(r'/Users/banban/Documents/Dartmouth/Coursework/Spring 2021/ENGS103/project/result/'+ str(scenarioNum) +'.csv')
