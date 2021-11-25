%% nonlinear simulation1
clc,clear
close all
load NASDQD
data=nasdqd(1:2600,:);
count=1;
BasicOutputs=[];
HeterOutputs1=[];
HeterOutputs2=[];
FinalPredictions=[];
for type=[1 2 4]
Feature=normalize(data(:,1:6),1);
Response=data(:,6+type)/1000;
%Response=(data(:,6+type)-data(:,4));
for j=1:300
nobs=2300+j-1;
X_Input=Feature(1:nobs,:);
Y_Output=Response(1:nobs);
%hold on
%plot(X_Input,Y_Output,'or')
%% initial model training
%basic one
C=quantile(abs(Y_Output),0.95);
g=0.001;
Epsilon=iqr(Y_Output)/13.49;
[Alpha, Flag, B]=BasicSVR(X_Input',Y_Output', Epsilon, C,g);
BasicFitting=SVRPred(Alpha,Flag,B,X_Input',g, X_Input');
Y_Obers=Y_Output;
%% parameter estimation
FixFitting=BasicFitting;
%% Fix variance
for i=1:2
Y_hat=FixFitting;   
x0=[1 1];
lb=[0 0];
ub=[];
A = [];
b = [];
Aeq = [];
beq = [];
ParameterEstor=fmincon(@(Para)epilossFix(Para, Y_hat, Y_Obers),x0,A,b,Aeq,beq,lb,ub);
ep3(j)=ParameterEstor(1);
SD(j)=ParameterEstor(2);
% scale parameter
SigmaValue=SD(j);
CH=quantile(abs(Y_Output./SigmaValue),0.95);
%% fix-model
sigmaH=SigmaValue*ones(1,nobs);
EpsilonH=ep3(j);
[AlphaH3, FlagH3, BH3]=HeterSVR(X_Input',Y_Output',EpsilonH,CH,g,sigmaH);
FixFitting=SVRPred(AlphaH3, FlagH3, BH3,X_Input',g, X_Input');
end
%%Bickel et al
Heter1Fitting=FixFitting;
Heter2Fitting=FixFitting;
%%Bickel et al
for i=1:2
Y_hat=Heter1Fitting;   
x0=[1 1 1];
lb=[0 0 0];
ub=[];
A = [];
b = [];
Aeq = [];
beq = [];
ParameterEstor=fmincon(@(Para)epilossBickel(Para, Y_hat, Y_Obers),x0,A,b,Aeq,beq,lb,ub);
ep1(j)=ParameterEstor(1);
phi1(j)=ParameterEstor(2);
gamma1(j)=ParameterEstor(3);
% scale parameter
%Bickel
SigmaValue=(sqrt(phi1(j)*exp(gamma1(j)*Y_hat)))';
CH=quantile(abs(Y_Output./SigmaValue),0.95);
%% heter-model
sigmaH=SigmaValue';
EpsilonH=ep1(j);
[AlphaH1, FlagH1, BH1]=HeterSVR(X_Input',Y_Output',EpsilonH,CH,g,sigmaH);
Heter1Fitting=SVRPred(AlphaH1, FlagH1, BH1,X_Input',g, X_Input');
end
%figure(2)
%subplot(1,3,count)
%plot(Heter1Fitting,(Heter1Fitting-Y_Obers'),'.b')
%% Box Hill
for i=1:2
Y_hat=Heter2Fitting;   
x0=[1 1 1];
lb=[0 0 0];
ub=[];
A = [];
b = [];
Aeq = [];
beq = [];
ParameterEstor=fmincon(@(Para)epilossBox(Para, Y_hat, Y_Obers),x0,A,b,Aeq,beq,lb,ub);
gamma2(j)=ParameterEstor(3);
ep2(j)=ParameterEstor(1);
phi2(j)=ParameterEstor(2);
% scale parameter
%Box & Hill
SigmaValue=sqrt(phi2(j)*(abs(Y_hat).^gamma2(j)))';
CH=quantile(abs(Y_Output./SigmaValue),0.95);
%% heter-model
sigmaH=SigmaValue';
EpsilonH=ep2(j);
[AlphaH2, FlagH2, BH2]=HeterSVR(X_Input',Y_Output',EpsilonH,CH,g,sigmaH);
Heter2Fitting=SVRPred(AlphaH2, FlagH2, BH2,X_Input',g, X_Input');
end
%%Test results
X_Input_Test=Feature(nobs+1,:);
% R1
BasicPred=SVRPred(AlphaH3,FlagH3,BH3,X_Input', g,X_Input_Test');
BasicOutputs(j)=BasicPred;
% R2
HeterPred1=SVRPred(AlphaH1,FlagH1,BH1,X_Input', g,X_Input_Test');
HeterOutputs1(j)=HeterPred1;
% R3
HeterPred2=SVRPred(AlphaH2,FlagH2,BH2,X_Input',g, X_Input_Test');
HeterOutputs2(j)=HeterPred2;
j
end
%% Parameter
Basic_ep(type)=mean(ep3)
Basic_scale(type)=mean(SD)
Bickel_ep(type)=mean(ep1)
Bickel_phi(type)=mean(phi1)
Bickel_gamma(type)=mean(gamma1)
Box_ep(type)=mean(ep2)
Box_phi(type)=mean(phi2)
Box_gamma(type)=mean(gamma2)
%% Index
Y_Output_Mean_Test=Response(2301:end);
BasicRMSE(type)=sqrt(mean((BasicOutputs-Y_Output_Mean_Test').^2))
HeterRMSE1(type)=sqrt(mean((HeterOutputs1-Y_Output_Mean_Test').^2))
HeterRMSE2(type)=sqrt(mean((HeterOutputs2-Y_Output_Mean_Test').^2))
BasicMAE(type)=mean(abs(BasicOutputs-Y_Output_Mean_Test'))
HeterMAE1(type)=mean(abs(HeterOutputs1-Y_Output_Mean_Test'))
HeterMAE2(type)=mean(abs(HeterOutputs2-Y_Output_Mean_Test'))
BasicMRE(type)=mean(abs(BasicOutputs-Y_Output_Mean_Test')./Y_Output_Mean_Test')
HeterMRE1(type)=mean(abs(HeterOutputs1-Y_Output_Mean_Test')./Y_Output_Mean_Test')
HeterMRE2(type)=mean(abs(HeterOutputs2-Y_Output_Mean_Test')./Y_Output_Mean_Test')
A=[BasicOutputs',HeterOutputs1',HeterOutputs2',Y_Output_Mean_Test]
FinalPredictions=[FinalPredictions,A];
end
ParamterEstimator=[Basic_ep,Basic_scale,Bickel_ep,Bickel_phi,Bickel_gamma,Box_ep,Box_phi,Box_gamma];
csvwrite('FinalPredictions.csv',FinalPredictions);
csvwrite('ParamterEstimator.csv',ParamterEstimator);



