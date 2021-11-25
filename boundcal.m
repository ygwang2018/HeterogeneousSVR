%%bound function
function Bound=boundcal(errors, alpha)
BoundU=quantile(errors,alpha/2);
BoundL=quantile(errors,1-alpha/2);
Bound=[BoundL BoundU];
end