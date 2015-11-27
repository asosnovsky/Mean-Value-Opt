function [ sharpe, P, Wp, sharpes, mps, risks ] = optimizeSharpPort( Ret, CoRisk, rfr, portlim, posWps, SUPPMSG )
%optimizeSharpPort Optimize a portfolio based on a list of expected returns and
%the covariance matrix. Using the MVP method adn Sharpe-minimization.
%  [ P , Wp ] = optimizePort( Ret, CoRisk, rfr, portlim, posWps, SUPPMSG  )
%  
%  REQUIRED ENTRIES
%   `Ret` is a vector of expected returns, `CoRisk` is the covariance matrix
%  of the assets. `rfr` is the risk free rate. `portlim` is the
%  limit on the number of securities that are allowed to be in the
%  portfolio.
%
%  OPTIONAL ENTRIES / OUTPUT
%  `postWps` if set to true will only return positive weights, i.e. 0<Wp<1.
%  `SUPPMSG` if set to true will disable all messages sent by this function

if (nargin < 5 || posWps )
    posWps = true;
else
    posWps = false;
end
if (nargin < 6 || ~SUPPMSG)
    SUPPMSG = false;
else
    SUPPMSG = true;
end
% Select a starting point for the portfolio
P = [];
Wp = [];

% Helper
sharpe = @(P,Wp,rfr) (Ret(P)*Wp-rfr)/sqrt(Wp'*CoRisk(P,P)*Wp);

mps = [0];
risks = [0];
limmp = [max([min(abs(Ret)) rfr]) max(abs(Ret))]; 
clc
sharpes = [Inf 0];
c = 2;
if(~SUPPMSG); disp('Initializing.... (first computation takes more time)');end;
function [] = optimo()
    m0 = limmp(1);
    mk = limmp(2);
    while abs(sharpes(c)-sharpes(c-1))> 1E-20
        ud = [ mk<m0 mk>m0 ];%if mk > m0 then limmp([0 1])=max else limmp([1 0])=min
        m0 = median(limmp);
        mk = median([m0 limmp(ud)]);
                                
        [P, Wp] = optimizePort( Ret, CoRisk, m0, portlim, P, Wp, posWps  );
        sharpes(c) = sharpe(P,Wp,rfr);
        [P, Wp, lRisk] = optimizePort( Ret, CoRisk, mk, portlim, P, Wp, posWps );
        
        disp(Ret(P)*Wp);
        disp(mk);
        sharpes(c+1) = sharpe(P,Wp,rfr);
        mps(c) = mk;
        risks(c) = lRisk;
        if(sharpes(c+1) < sharpes(c))
            limmp(ud) = mk;
        else
            limmp(~ud) = m0;
        end
        c = c+1;
        % <Text>
        if ~SUPPMSG
            %clc
            fprintf('\n> (%d) %2.7f\n', length(sharpes(2:end)) ,sharpes(end));
            fprintf('   mp: %2.7f in [%2.7f,%2.7f] \n', mk, limmp(1), limmp(2)); 
            fprintf('   risk: %2.7f\n', risks(end));
        end
        % <Text> 
    end
end
optimo();
sharpe = sharpes(end);
sharpes = sharpes(2:end);
if(~SUPPMSG); disp('[ << DONE >> ]'); end;
end

