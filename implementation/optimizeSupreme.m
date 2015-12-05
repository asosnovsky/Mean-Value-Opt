function [ sharpe, Wp, sharpes, Wps ] = optimizeSupreme( M, S, rfr )
%optimizeSupreme Summary of this function goes here
%   Detailed explanation goes here

% Globals
M = M -rfr;
n = length(M);

% Helpers
sharpe = @(w) (M*w)/sqrt(w'*S*w);

function w = optimo(mp)
    % Optimize weights
     w = [ 2*S M' ones(n,1); M 0 0 ; ones(1,n) 0 0 ]\[ zeros(n,1); mp; 1 ];
     w = w(1:end-2);
    %disp(abs(w)<1);
end

% Containers
Wps = zeros(1,n);
sharpes = [Inf 0];

% Variables
limmp = [max([min(abs(M)) rfr]) max(abs(M))]; 
c = 2;
m0 = limmp(1);
mk = limmp(2);
while (abs(sharpes(c)-sharpes(c-1))> 1E-200 && c < 500)
    %disp(sharpes);
    ud = [ mk<m0 mk>m0 ];%if mk > m0 then limmp([0 1])=max else limmp([1 0])=min
    m0 = median(limmp);
    mk = median([m0 limmp(ud)]);
                            
    Wp = optimo(m0);
    sharpes(c) = sharpe(Wp);
    Wp = optimo(mk);
    
    sharpes(c+1) = sharpe(Wp);
    Wps(c,:) = Wp;
    if(sharpes(c+1) < sharpes(c))
        limmp(ud) = mk;
    else
        limmp(~ud) = m0;
    end
    c = c+1;
end
    sharpe = sharpes(end);
end

