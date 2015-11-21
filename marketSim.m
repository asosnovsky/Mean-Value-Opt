function [ St, at, mt ] = marketSim( nStocks, rfr, nPeriods, S0, at, mt )

% Unchanging Variables
if nargin  < 4 || isempty(S0)
    St = [random('gam',200,2,1,nStocks)];
    at = []; mt = [];
else
    St = [S0];
end
if size(St,2) ~= nStocks
    nStocks = size(St,2);
   warning('nStock was not equal to size(St,2), setting it equal');
end

for t = (size(St,1)) + (1:nPeriods)
    % Changing variables
    at = [at; random('norm',0,1,1,nStocks)];
    mt = [mt; random('norm',0,2,1,1)];
    rinc = (1+rfr/365).^(0:t-2);
    pi = (St(t-1,:)./sum(St(t-1,:))).*random('gam',200,0,1,nStocks);
    phi = random('uniform',0.008,0.01,1,nStocks).*St(t-1,:);
    
    St = [St; (((1+rfr/365)^t).*St(1,:)+(rinc*at).*phi+rinc*mt.*pi)];
    St(t,:) = St(t,:).*(St(t,:)>0);
end

end

