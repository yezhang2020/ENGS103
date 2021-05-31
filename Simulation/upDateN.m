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