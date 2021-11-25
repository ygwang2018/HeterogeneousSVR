
function NegativeValue=epilossBickel(Para, Y_hat, Y_Obers)
ep=Para(1);
phi=Para(2);
gamma=Para(3);
SD=(sqrt(phi*exp(gamma*Y_hat)))';%Bick el al.
res=Y_Obers-Y_hat';
l=length(Y_hat);
Llog=[];
for i=1:l
    if abs(res(i)/SD(i))<ep
        Llog(i)=0;
    else
       Llog(i)=abs(res(i)/SD(i))-ep;
    end
end
NegativeValue=sum(log(SD)+log(2*(1+ep))+Llog');
end
  
