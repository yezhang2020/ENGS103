%% ENGS103 Final Project

% Description------------------------------------------------------------
% loop through different combinations of # reg stations and # vaccination
% stations to acquire watetime
% Author: Ye Zhang
% 05/30/3031

numRuns = 1000;
pctFull = 1;
result = zeros(6,6);

for regNum = 1:6
    for vaccNum = 1:6
        result(regNum,vaccNum) = runSim(regNum,vaccNum,pctFull,numRuns);
    end
end

result