% nchoosek with Repetition
%// Return number of multisubsets or actual multisubsets.
% Dev: Khursheed Ali
% Date: 23-09-2018
function combs = nmultichoosek(values, k)
if numel(values)==1 
    n = values;
    combs = nchoosek(n+k-1,k);
else
    n = numel(values);
    combs = bsxfun(@minus, nchoosek(1:n+k-1,k), 0:k-1);
    combs = reshape(values(combs),[],k);
end