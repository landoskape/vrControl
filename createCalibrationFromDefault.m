function createCalibrationFromDefault(default,target)
txt = importdata(default);
NL = size(txt,1);
names = cell(NL,1);
for nl = 1:NL
    names{nl} = txt{nl}(1:min([strfind(txt{nl},' '), strfind(txt{nl},'=')])-1);
    evalc(txt{nl});
end
save(target, names{:});
