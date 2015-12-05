function [ sharpe, Wp, sharpes, Wps ] = optimizeSupreme( M, S, rfr )
%optimizeSupreme finds the most optimal sharpe value using the bisection
%method.
%   [Input/Output]
%   `M`         a `vector` with the means of all the assets
%   `S`         the Covariance `matrix` for all the assets
%   `rfr`       a `double` with the risk-free-rate
%   `sharpe`    a `double` containing the most optimal sharpe
%   `Wp`        a `vector` with the most optimal weights
%   `sharpes`   a `vector` with all attempted sharpes (can be used to generate an efficiency frontier)
%   `Wps`       a `vector` with all attempted weights
%
%

% Globals to this function
M = M -rfr;% Note, E[P] - rfr = E[w_1*X_1+w_2*X_2] - rfr*(w_1+w_2) = E[w_1(X_1-rfr)+w_2(X_2-rfr)]
n = length(M);

% this function will compute the sharpe ratio for us
sharpe = @(w) (M*w)/sqrt(w'*S*w);

% optimo is the lagrangian method, will take a fixed return `mp` and return
% optimal weights
function w = optimo(mp)
    % Optimize weights
     w = [ 2*S M' ones(n,1); M 0 0 ; ones(1,n) 0 0 ]\[ zeros(n,1); mp; 1 ];
     w = w(1:end-2);% this will get rid of the `lambda` values
end

% Containers
Wps = zeros(1,n);
sharpes = [Inf 0];

% Variables
limmp = [max([min(abs(M)) rfr]) max(abs(M))];% initial limit, abs is taken in case of negative returns. This way shorting will not be penalized
c = 2;% initial starting point
m0 = limmp(1);
mk = limmp(2);
while (abs(diff(limmp))> 1E-200 && c < 500)
    %disp(sharpes);
    ud = [ mk<m0 mk>m0 ];%if mk > m0 then limmp([0 1])= max else limmp([1 0])= min <- this is done, in case negative values are enetered and the max, min are not in any given order
    m0 = median(limmp);% compute first median [----*----]
    mk = median([m0 limmp(ud)]);% compute second median [--*--|----]
                            
    Wp = optimo(m0);% find optimal weights
    sharpes(c) = sharpe(Wp);% store them
    
    Wp = optimo(mk);% compute the next optimal weights
    sharpes(c+1) = sharpe(Wp);% store them
    
    Wps(c,:) = Wp;% save weights
    
    % Test
    if(sharpes(c+1) < sharpes(c))
        limmp(ud) = mk;
    else
        limmp(~ud) = m0;
    end
    c = c+1;
end
    % store resultig sharpe
    sharpe = sharpes(end);
end

