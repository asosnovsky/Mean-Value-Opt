clear
clc

h = animatedline;
MarketAssets = [ random('gam',200,2,1,ceil(random('unif',0,10,1,1)))...
               random('gam',2,4,1,ceil(random('unif',0,10,1,1)))...
                random('gam',50,3,1,ceil(random('unif',0,10,1,1)))];

nPeriods = 365;
MarketAssets = [ MarketAssets ; repmat(MarketAssets(size(MarketAssets,1),:),nPeriods,1) ] + [ zeros(size(MarketAssets));...
    cumsum(random('norm',0,1,nPeriods,size(MarketAssets,2))) ];
plot(MarketAssets)

%%
clear
clc
h = animatedline;

X = random('gam',200,2,1,1);
X = [X ; X+cumsum(random('norm',0,10,3650,1))];

for k = 1:length(X)
    addpoints(h,k,X(k));
    drawnow
end

%%
clear
clc
MarketAssets = [ random('gam',200,2,1,ceil(random('unif',0,20,1,1)))...
               random('gam',2,10,1,ceil(random('unif',0,20,1,1)))...
                random('gam',20,7,1,ceil(random('unif',0,20,1,1)))];
nPeriods = 365;

% Add new period
   MarketAssets = [ MarketAssets ; repmat(MarketAssets(size(MarketAssets,1),:),nPeriods,1) ] + ...
       [ zeros(size(MarketAssets)); repmat(random('pois',random('unif',0,30),nPeriods,1),1,size(MarketAssets,2)).*cumsum(random('norm',0,1,nPeriods,size(MarketAssets,2))) ]+repmat([ zeros(size(MarketAssets,1),1); random('pois',random('unif',0,30),nPeriods,1).*random('norm',0,1,nPeriods,1)],1,size(MarketAssets,2))

  
figure(1); clf;
for iSim = 1:size(MarketAssets,2)
    h(iSim) = plot(1, MarketAssets(1,iSim), 'YDataSource', 'yi', 'XDataSource', 'xi');
    hold on;
end
for k = 20:size(MarketAssets,1)
    for iSim = 1:size(MarketAssets,2)
        set(h(iSim),'Xdata',1:k,'YData',MarketAssets(1:k,iSim));
        hold on;
    end
    drawnow;
end;

%%
clear
clc
IBM = fetch(yahoo,'IBM','2/1/2010','2/1/2014');
AAPL = fetch(yahoo,'AAPL','2/1/2010','2/1/2014');
GOOGL = fetch(yahoo,'GOOGL','2/1/2010','2/1/2014');

MarketAssets = [ IBM(:,2) AAPL(:,2) GOOGL(:,2) ];

figure(1); clf;
for iSim = 1:size(MarketAssets,2)
    h(iSim) = plot(1, MarketAssets(1,iSim), 'YDataSource', 'yi', 'XDataSource', 'xi');
    hold on;
end
for k = 20:size(MarketAssets,1)
    for iSim = 1:size(MarketAssets,2)
        set(h(iSim),'Xdata',1:k,'YData',MarketAssets(1:k,iSim));
        hold on;
    end
    drawnow;
end;

%%


figure(1); clf;
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