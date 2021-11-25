clc,clear
close all
load NASDQD
data=nasdqd(2301:2600,:);
load Preds_Outputs
TrueChange=(data(:,[7,8,10])-data(:,4))/1000;
BasicChange=BasicOutputs-data(:,4)/1000;
Heter1Change=HeterOutputs1-data(:,4)/1000;
Heter2Change=HeterOutputs2-data(:,4)/1000;
%%MAE
BasicMAE=mean(abs(BasicChange-TrueChange))
Heter1MAE=mean(abs(Heter1Change-TrueChange))
Heter2MAE=mean(abs(Heter2Change-TrueChange))
%%RMSE
BasicRMSE=sqrt(mean((BasicChange-TrueChange).^2))
Heter1RMSE=sqrt(mean((Heter1Change-TrueChange).^2))
Heter2RMSE=sqrt(mean((Heter2Change-TrueChange).^2))

for i=1:3
subplot(3,1,i)    
plot(TrueChange(:,i),'k')
hold on
plot(Heter1Change(:,i),'b')
hold on
plot(Heter2Change(:,i),'r')
end

