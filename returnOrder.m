function idxActive = returnOrder(order, active)
if length(order) ~= length(active), error('Failure...'); end
idxActive = find(active);
idxActive = idxActive(order(idxActive));
