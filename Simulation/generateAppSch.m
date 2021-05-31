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