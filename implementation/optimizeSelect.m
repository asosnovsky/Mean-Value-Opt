function [ Wp, P, sharpe ] = optimizeSelect( Ret, CoRisk, rfr, portlim )
%optimizeSelect builds the most optimal portfolio, given a limit, a
%risk-free-rate, and the Covariance matrix and vector mean.
%   [Inputs/Outputs]
%   `Ret`       a `vector` of the means of a given market
%   `CoRisk`    the Covariance `matrix` of a given market
%   `rfr`       a `double` containing the risk free rate
%   `portlim`   a `double` containing the limit for this portfolio
%   `Wp`        a `vector` contating the final selected weights
%   `P`         a `vector` containing the final selected indexes of the given assests
%   `sharpe`   a `double` containing the sharpe ratio
%

% Initialize algorothimn
[~,P]   = min(diag(CoRisk));
Wp      = [1];
sharpe  = 0;

% Helpers

% function addPort, will add assets to the portfolio,
% untill a limit is reached
function addPort()
    %Begin by generating a loop equalling the total number of empty "spots"
    for repNum = 1:portlim-length(P)
        % Generated a list of Unselected assets
        Unsel = setdiff(1:length(Ret),P);

        % Set local variables
        fSha  = 0;
        fID   = [];
        fW    = Wp;
        
        % For every unselected asset
        c = 0;
        for assID = Unsel
            c = c+1;
            % Get the Expected Returns
            M = Ret([P assID]);
            % Get Covariance Matrix and count the current number of assets
            S = CoRisk([P assID],[P assID]);
            % Computing Sharpe
            [ s, w ] = optimizeSupreme( M, S, rfr );
            % Determine if Portfolio is optimal
            if (~isempty(w) && s(end) > fSha)
                fID     = assID;
                fSha    = s(end);
                fW      = w;
            end
        end
        % save results
        P       = [P fID];
        Wp      = fW;
        sharpe  = fSha;
    end
end

% fucntion redPort will generate all potential portfolios containing one
% less asset, and then select the one with the highest sharpe.
function redPort()
    % Initialize local variables
    fSha    = 0;
    fIDs    = P;
    fW      = Wp;
    % run loop on every selected index
    for portID = P
        % Get a reduced list ( a list without the currently selected asset)
        redList = setdiff(P,portID);
        % check in case empty
        if(~isempty(redList))
            % Get variables
            M   = Ret(redList);
            S   = CoRisk(redList,redList);
            
            % Computing Sharpe
            [ s, w ] = optimizeSupreme( M, S, rfr );
            
            % Determine if Portfolio is optimal
            if (~isempty(w) && s(end) > fSha)
                fSha    = s(end);
                fIDs    = redList;
                fW      = w;
                sharpes = [s; fSha];
            end
        end
    end
    % Set the selected Portfolio as our current
    P       = fIDs;
    Wp      = fW;
    sharpe  = fSha;
end

% Run initial addition
addPort();

% initialize watchers
lSharpe = 0;
% run loop until a divergence occurs
while abs(lSharpe-sharpe) > 1E-10
    lSharpe = sharpe;
    redPort();
    addPort();
end

end

