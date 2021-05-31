%% ENGS103 Final Project

% Description------------------------------------------------------------
% runs the 3.5hr shift simulation for multiple times and return average W
% Author: Ye Zhang
% 05/30/3031

function meanW = runSim(numReg, numVacc,pct,simNumber)
    result = zeros(1,simNumber);
    for i = 1:simNumber
        % only one of the 1000 simulation data was saved for convenience
        index = 1;
        % to save all of the data
        % index = i
        result(i) = runSimOnce(numReg, numVacc,pct,index);
    end
    meanW = mean(result);
end