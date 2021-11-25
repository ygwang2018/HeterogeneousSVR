clc,clear
close all
load NASDQD
data=nasdqd(2301:2600,:);
load Preds_Outputs
TrueChange=(data(:,[7,8,10])-data(:,4))/1000;
BasicChange=BasicOutputs-data(:,4)/1000;
Heter1Change=HeterOutputs1-data(:,4)/1000;
Heter2Change=HeterOutputs2-data(:,4)/1000;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BasicRMSE=sqrt(mean((BasicChange-TrueChange).^2))
BasicMAE=mean(abs(BasicChange-TrueChange))
%
for j=1:3
    a=0;
for i=1:300
    if BasicChange(i,j)*TrueChange(i,j)>0
        a=a+1;
    end
end
count(j)=a;
end
count
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Heter1RMSE=sqrt(mean((Heter1Change-TrueChange).^2))
Heter1MAE=mean(abs(Heter1Change-TrueChange))
for j=1:3
    a=0;
for i=1:300
    if Heter1Change(i,j)*TrueChange(i,j)>0
        a=a+1;
    end
end
count1(j)=a;
end
count1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Heter2RMSE=sqrt(mean((Heter2Change-TrueChange).^2))
Heter2MAE=mean(abs(Heter2Change-TrueChange))

for j=1:3
    a=0;
for i=1:300
    if Heter1Change(i,j)*TrueChange(i,j)>0
        a=a+1;
    end
end
count2(j)=a;
end
count2