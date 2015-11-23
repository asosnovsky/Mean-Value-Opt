function [ sharpe, P, Wp, sharpes, mps, risks ] = optimizeSharpPort( Ret, CoRisk, rfr, portlim, SUPPMSG )
%optimizeSharpPort Optimize a portfolio based on a list of expected returns and
%the covariance matrix. Using the MVP method adn Sharpe-minimization.

if (nargin < 5 || ~SUPPMSG)
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
limmp = [max([min(Ret(Ret>0)) rfr]) max(Ret)]; 
clc
sharpes = [Inf 0];
c = 2;
if(~SUPPMSG); disp('Initializing.... (first computation takes more time)');end;
function [] = optimo()
    m0 = limmp(1);
    mk = limmp(2);
    while abs(sharpes(c)-sharpes(c-1))> 1E-10
        ud = [ mk<m0 mk>m0 ];%if mk > m0 then limmp([0 1])=max else limmp([1 0])=min
        m0 = median(limmp);
        mk = median([m0 limmp(ud)]);
                                
        [P, Wp] = optimizePort( Ret, CoRisk, m0, portlim, P, Wp  );
        sharpes(c) = sharpe(P,Wp,rfr);
        [P, Wp, lRisk] = optimizePort( Ret, CoRisk, mk, portlim, P, Wp  );
        
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

