%% ENGS103 Final Project

% Description------------------------------------------------------------
% Simulaitos one day of COVID vaccination at Dartmouth Thompson Arena
% Author: Ye Zhang
% 05/30/3031

% Constants and variable declaration---------------------------------------

% registration and arrival details
regPreiod = 10;
pplPerReg = 10;
pctRegFull = 0.6;
simLength = 300;    %length of a day, in minutes, 300min is 5hr. 

% capacity of queue/servers
regqMax = 30;
regMax = 5;
vaccqMax = 5;
vaccMax = 5;
obserMax = 60;

% 5 places patient can be 
% an array with record of N for each minute during the day
% first element is 0-1 min, last element is 299-300min
% N is created to have large enough size in case the clinic lasts longer
% than planned
NregqArr = zeros(1,simLength+100); 
NregArr = zeros(1,simLength+100);
NvaccqArr = zeros(1,simLength+100);
NvaccArr = zeros(1,simLength+100);
NobserArr = zeros(1,simLength+100);


% initialize--------------------------------------------------------------

% generate appointmnt schedule based on 60% full and available slots
appSchArr = generateAppSch(regPreiod,simLength,pplPerReg,pctRegFull);
numPpl = length(appSchArr);

% generate accural arrival schedule
tArrivalArr = zeros(1,numPpl);
for i = 1: length(appSchArr)
    tArrivalArr(i) = appSchArr(i)+ generateAppDiff();
    % make sure smallest arrival time is 0
    tArrivalArr(i) = max(tArrivalArr(i),1);
end 

% sort actual arrival time from low to high to be able to start with
% patiens that arrives earlier.
tArrivalArr = sort(tArrivalArr);

% array to store other crutial time stamps for each patient
tTSABgnArr = zeros(1,numPpl);
tTSACmpltArr = zeros(1,numPpl);
tRegBgnArr = zeros(1,numPpl);
tRegCmpltArr = zeros(1,numPpl);
tVaccBgnArr = zeros(1,numPpl);
tVaccCmpltArr = zeros(1,numPpl);
tsfArr = zeros(1,numPpl);



% Main Simulation Loop ---------------------------------------------------
% looped through each patient
for n = 1: length(appSchArr)
    
    % TSA and Paperwork---------------------
    % upon arrival
    % if registration queue less than 30 people, start filling TSA and
    % paperwork
    % else, tsa will start until less than 30 people in the queue
    t = tArrivalArr(n);
    while NregqArr(t)>= regqMax
        t = t+1;
    end
    tTSABgnArr(n) = t;
    
    % generate TSA filling time
    tTSACmpltArr(n)=tTSABgnArr(n)+ generatePaperTime();
    
    % registration-----------------------------
    % next regitration, will only start registration when there are less
    % than 5 people in registration AND less than 5 people in the
    % vaccine queue
    t = tTSACmpltArr(n);
    while (NregArr(t)>= regMax || NvaccqArr(t) >= vaccqMax)
        t = t+1;
    end
    tRegBgnArr(n) = t;
    
    % generate rsgistration time
    tRegCmpltArr(n) = tRegBgnArr(n) + generateRegTime();
    
    % vaccination ----------------------------------------
    % vaccination starts after vaccination slots empty and observation
    % slots not filled
    t = tRegCmpltArr(n);
    while (NvaccArr(t)>= vaccMax || NobserArr(t) >= obserMax)
        t = t+1;
    end
    tVaccBgnArr(n) = t;
    
    % generate vaccination time
    tVaccCmpltArr(n) = tVaccBgnArr(n) + generateVaccTime();
    
    % observation -------------------------------------------
    % as last stage guaranteed there are always spots open for observation
    % just add the time
    tsfArr(n) = tVaccCmpltArr(n)+ generateObserTime();
    
    
    % update N ---------------------------------------------
    % last but not least, update number of people in each state, the N
    % arrays
    [NregqArr,NregArr,NvaccqArr,NvaccArr,NobserArr]=...
    upDateN(n,NregqArr,NregArr,NvaccqArr,NvaccArr,NobserArr,tTSABgnArr,...
    tRegBgnArr,tRegCmpltArr,tVaccBgnArr,tVaccCmpltArr, tsfArr);
    
end

% result calculation ----------------------------------------------------
averageTime = mean(tsfArr-tArrivalArr)


% functions used ----------------------------------------------------------

function appArr = generateAppSch(period,length,pplPerSlot,pctFull)
    % example [ 0 0 0 0 0 0 10 10 10 10 10 10] for multiple slots at the
    % same time
    appArr = [];
    for i = 1:period:length-period
        tempArr = ones(1,generatePeoplePerReg(pplPerSlot,pctFull));
        tempArr = tempArr*i;
        appArr = [appArr tempArr];
    end
end

function r = generatePeoplePerReg(pplPerSlot,pctFull)
    r = binornd(pplPerSlot,pctFull);
end

function r = generateAppDiff()
    r = randi([-10 10]);
end

function r = generatePaperTime()
% r = exponential distribution with expected value of 3
    % inversion method is used
    randNum = rand();
    % rate = 1/15 patient/min
    r = -log(randNum)/(1/3);
    % round to nearest minute
    r = round(r);
end

function r = generateRegTime()
    % r = 2 for P = 4/5; r = 10 for P = 1/5
    randNum = rand();
    if randNum <=0.1
        r = 5;
    else
        r = 2;
    end
end 

function r = generateVaccTime()
% r = exponential distribution with expected value of 3
    % inversion method is used
    randNum = rand();
    % rate = 1/15 patient/min
    r = -log(randNum)/(1/1);
    r = round(r);
end

function r = generateObserTime()
    r = 15;
end 

% update number of people in each state with given person
function [NregqArrNew,NregArrNew,NvaccqArrNew,NvaccArrNew,NobserArrNew]=...
    upDateN(n,NregqArr,NregArr,NvaccqArr,NvaccArr,NobserArr,tTSABgnArr,...
    tRegBgnArr,tRegCmpltArr,tVaccBgnArr,tVaccCmpltArr, tsfArr)

% initialize
    NregqArrNew = NregqArr;
    NregArrNew = NregArr;
    NvaccqArrNew = NvaccqArr;
    NvaccArrNew = NvaccArr;
    NobserArrNew = NobserArr;
    
    
    for t = 1: length(NregqArr)
        if (t >= tTSABgnArr(n) && t < tRegBgnArr(n))  % registraton queue
            NregqArrNew(t) = NregqArr(t)+1;
        elseif (t >= tRegBgnArr(n) && t < tRegCmpltArr(n))  %reg
            NregArrNew(t) = NregArr(t)+1;   
        elseif (t >= tRegCmpltArr(n) && t < tVaccBgnArr(n))  % vacc queue
            NvaccqArrNew(t) = NvaccqArr(t)+1;
        elseif (t >= tVaccBgnArr(n) && t < tVaccCmpltArr(n))  % vacc
            NvaccArrNew(t) = NvaccArr(t)+1;
        elseif (t >= tVaccCmpltArr(n) && t < tsfArr(n))  % vacc
            NobserArrNew(t) = NobserArr(t)+1;
        end
        
    end


end
