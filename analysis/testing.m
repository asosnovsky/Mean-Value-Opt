clear
clc
sRisks = [];

% First we simulate some assets
MarketAssets = [ random('gam',200,2,1,ceil(random('unif',0,60,1,1)))...
               random('gam',2,10,1,ceil(random('unif',0,60,1,1)))...
                random('gam',20,7,1,ceil(random('unif',0,60,1,1)))];
nPeriods = 365;

% % Select a starting point for the portfolio
     P = [];
     Wp = [];
% % Next we select our fixed return and a limit for the assets
     mp = 0.25;
     n = 10;
     
%for iTime = 1:3;
iTime =1;
 % Add new period
  MarketAssets = [ MarketAssets ; repmat(MarketAssets(size(MarketAssets,1),:),nPeriods,1) ] + ...
       [ zeros(size(MarketAssets)); repmat(random('pois',random('unif',0,30),nPeriods,1),1,size(MarketAssets,2)).*cumsum(random('norm',0,1,nPeriods,size(MarketAssets,2))) ]+repmat([ zeros(size(MarketAssets,1),1); random('pois',random('unif',0,30),nPeriods,1).*random('norm',0,1,nPeriods,1)],1,size(MarketAssets,2));

 % Then we comoute their returns
     MarketReturns = (MarketAssets(2:30,:)-MarketAssets(1:29,:))./MarketAssets(1:29,:);
        
 % Then we find their mean and covariance
     Ret = mean(MarketReturns);
     CoRisk = cov(MarketReturns);

 % % Now we optimize them
     [P, Wp, lRisk, cRisk, sRisk] = optimizePort( Ret, CoRisk, mp, n, P, Wp );
     sRisks = [ sRisks; sRisk];
%end
%%
figure('Name','Optimization'); clf;
for iSim = 1:size(sRisks,2)
    h(iSim) = plot(1, sRisks(1,iSim), 'YDataSource', 'yi', 'XDataSource', 'xi');
    hold on;
end
for k = 20:size(sRisks,1)
    for iSim = 1:size(sRisks,2)
        set(h(iSim),'Xdata',1:k,'YData',sRisks(1:k,iSim));
        hold on;
    end
    drawnow;
end;
hold off
%%
figure('Name','Performace');
mP= Wp'*MarketAssets(:,P)'
mean((mP(2:1096) - mP(1:1095))./mP(1:1095))
plot(mP)