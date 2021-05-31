function r = generateRegTime()
     % inversion method is used
    randNum = rand();
    % rate = 1/15 patient/min
    r = -log(randNum)/(1/4);
    r = round(r);
end 