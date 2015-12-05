function [ Wp, P, cSharpe ] = optimizeSelect( Ret, CoRisk, rfr, portlim )
%optimizeSelect Summary of this function goes here
%   Detailed explanation goes here

[~,P]   = min(diag(CoRisk));
Wp      = [1];
sharpe  = 0;

function addPort()
    for repNum = 1:portlim-length(P)
        % 'Unselected' List
        Unsel = setdiff(1:length(Ret),P);

        % Set Helpers
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
        P       = [P fID];
        Wp      = fW;
        sharpe  = fSha;
    end
end
function redPort()
    fSha    = 0;
    fIDs    = P;
    fW      = Wp;
    for portID = P
        % Get the reduced list
        redList = setdiff(P,portID);
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
    % Set a new Portfolio as our current
    P       = fIDs;
    Wp      = fW;
    sharpe  = fSha;
end

addPort();
lSharpe = sharpe;
cSharpe = 0;
while abs(lSharpe-cSharpe) > 1E-10
    lSharpe = sharpe;
    redPort();
    addPort();
    cSharpe = sharpe;
    %disp(cSharpe);
end

end

