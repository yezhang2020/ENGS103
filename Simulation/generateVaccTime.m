function r = generateVaccTime()
% r = exponential distribution with expected value of 3
    % inversion method is used
    randNum = rand();
    % rate = 1/15 patient/min
    r = -log(randNum)/(1/3);
    r = round(r);
end