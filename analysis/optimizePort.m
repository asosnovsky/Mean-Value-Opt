function [ P , Wp, lRisk, cRisk, sRisk ] = optimizePort( Ret, CoRisk, mp, portlim, P, Wp, posWps  )
%optimizePort Optimize a portfolio based on a list of expected returns and
%the covariance matrix. Using the MVP method
%  [ P , Wp ] = optimizePort( Ret, CoRisk, mp, portlim, P, Wp  )
%  
%  REQUIRED ENTRIES
%   `Ret` is a vector of expected returns, `CoRisk` is the covariance matrix
%  of the assets. `mp` is the required rate of return. `portlim` is the
%  limit on the number of securities that are allowed to be in the
%  portfolio.
%
%  OPTIONAL ENTRIES / OUTPUT
%  `P` is the index of the existing assets in the portfolio. `Wp` is the weight of each asset. 
%
% [[Example]]:
% (Please note that depending on your `mp`, this example may fail
% at times) 
% 
% % First we simulate some assets
% MarketAssets = [ random('gam',200,2,30,4)...
%                random('gam',20,2,30,2)...
%                random('gam',50,7,30,5)];
%
% % Then we comoute their returns
% MarketReturns = (MarketAssets(2:30,:)-MarketAssets(1:29,:))./MarketAssets(1:29,:);
%
% % Then we find their mean and covariance
% Ret = mean(MarketReturns);
% CoRisk = cov(MarketReturns);
%
% % Next we select our fixed return and a limit for the assets
% mp = 0.05;
% n = 5;
%
% % *Optional, select a starting point for the portfolio
% P = [ 1 3 ];
% Wp = [1/2 1/2];
%
% % Now we optimize them
% [P, Wp] = optimizePort( Ret, CoRisk, mp, n, P, Wp )
%
% [[End of Example]]

% Paremters
Risk = diag(CoRisk);

% Deal with nargin
switch nargin
    case 4
        % Get the location of the lowest risk asset
        [~,P] = min(Risk);

        % Build the first portfolio
        Wp = ones(length(P),1)./length(P);
        
        % Quadprog Settings
        Wlow = @(n) -ones(n,1);
    case 5
        if isempty(P)
            [~,P] = min(Risk);
        end
        Wp = ones(length(P),1)./length(P);
        % Quadprog Settings
        Wlow = @(n) -ones(n,1);
    case 6
        if isempty(P) || isempty(Wp)
            [~,P] = min(Risk);
            Wp = ones(length(P),1)./length(P);
        end
        if size(Wp,1) == 1
            Wp = Wp';
        end
        % Quadprog Settings
        Wlow = @(n) -ones(n,1);
    case 7
        % Quadprog Settings
        if(posWps)
            Wlow = @(n) zeros(n,1);
        else
            Wlow = @(n) -ones(n,1);
        end
        if isempty(P) || isempty(Wp)
            [~,P] = min(Risk);
            Wp = ones(length(P),1)./length(P);
        end
        if size(Wp,1) == 1
            Wp = Wp';
        end
end
% Mean checker
mpmod = false;
if mp >= max(Ret) 
    mp = max(Ret)*0.95;
    mpmod = true;
elseif mp <= min(Ret(Ret > 0))
    mp = mean(Ret(Ret > 0));
    mpmod = true;
end


% Helpers
RetP = @(p,w) Ret(p)*w;
RisP = @(p,w) w'*CoRisk(p,p)*w;
sRisk = [RisP(P,Wp)];

function OUTPUT()
    disp('---------------------------------');
    fprintf('The Current Portfolio consists of the following Assets:\n\n');
    fprintf('> Asset %3.0f: w=%1.4f, E[X%G]=%1.4f, Var[X%G]=%1.4f\n',[P ; Wp'; P; Ret(P); P; Risk(P)']);
    fprintf('\n> E[P] = %1.4f, Var[P] = %1.4f\n', [RetP(P,Wp) RisP(P,Wp)]);
end
function addPort()
    for repNum = 1:portlim-length(P)
        % 'Unselected' List
        Unsel = setdiff(1:length(Ret),P);
        % Set Helpers
        temp = Inf;
        fID = P;
        fW = Wp;
        % Find next best Portfolio
        for portID = Unsel
        % Get the Expected Returns
        M = Ret([P portID]);
            % Test if its possible to form a portfolio with the given assets
            if mp < max(M) && mp > min(M)
                % Get Covariance Matrix and count the current number of assets
                S = CoRisk([P portID],[P portID]);
                n = length(M);
                % Optimize weights
                w = quadprog(2.*S,[],[],[],[ M ; ones(1,n)],[mp;1],...
                    Wlow(n),ones(n,1),...
                    [],optimoptions('quadprog','Algorithm','interior-point-convex','Display','off'));
                % Determine if Portfolio is optimal
                if RisP([P portID],w) < temp
                    fID = portID;
                    temp = RisP([P portID],w);
                    fW = w;
                    sRisk = [sRisk; temp];
                end
            end
        end
        % Set a new Portfolio as our current
        P = [P fID];
        Wp = fW;
    end
    OUTPUT();
end
function redPort()
    temp = Inf;
    fIDs = P;
    fW   = Wp;
    for portID = P
        % Create a reduced list
        redList = setdiff(P,portID);

        % Get Mean, Covariance Matrix, and number of assets
        M = Ret(redList);
        % Test if its possible to form a portfolio with the given assets
            if mp < max(M) && mp > min(M)
                S = CoRisk(redList,redList);
                n = length(M);

                % Optimize weights
                w = quadprog(2.*S,[],[],[],[ M ; ones(1,n)],[mp;1],...
                    Wlow(n),ones(n,1),...
                    [],optimoptions('quadprog','Algorithm','interior-point-convex','Display','off'));
                % Determine if Portfolio is optimal
                if RisP(redList,w) < temp
                    temp = RisP(redList,w);
                    fIDs = redList;
                    fW = w;
                    sRisk = [sRisk; temp];
                end
            end
    end
    % Set a new Portfolio as our current
    P   = fIDs;
    Wp  = fW;
    OUTPUT();
end

addPort();
lRisk = RisP(P,Wp);
cRisk = 0;
c = 0;
%fprintf('\n(%G).\n',c);
OUTPUT();
while abs(lRisk-cRisk) > 1E-20
    c = c+1;
    %fprintf('\n(%G).\n',c);
    lRisk = RisP(P,Wp);
    redPort();
    OUTPUT();
    addPort();
    P = P(abs(Wp)>1E-7);
    Wp = Wp(abs(Wp)>1E-7);
    cRisk = RisP(P,Wp);
    OUTPUT();
end
    if(mpmod)
        warning('Using a modified mp, as the orginal one, was outside the bounds of the min/max of Returns');
    end
    if length(P) < portlim
        warning('Most optimal portfolio can only be done with less assets then conditioned');
    end
end

