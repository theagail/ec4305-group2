%% read in data
data = readtable('bitcoin_gld.csv');   % returns a table
btc = data.bitcoin;                     % column vector
gld = data.gld;
u_returnbtc = data.u_returnbtc;
u_returngld = data.u_returngld;


%% copula testing
conD = [u_returnbtc, u_returngld];     % combine into Nx2 matrix
[theta_gaussian, LL_gaussian] = copulafit_myown('gaussian', conD);
[theta_t, LL_t] = copulafit_myown('t', conD);
[theta_clayton, LL_clayton] = copulafit_myown('clayton', conD);
%[theta_frank, LL_frank] = copulafit_myown('frank', conD);
%[theta_gumbel, LL_gumbel] = copulafit_myown('gumbel', conD);


%% Simulate from Fitted Copulas 
nSim = 1500;  % number of simulated points

% Gaussian
u_gaussian = copularnd('gaussian', theta_gaussian, nSim);
% t-copula
rho_t = theta_t(1); nu_t = theta_t(2);
u_t = copularnd('t', rho_t, nu_t, nSim);
% Clayton
u_clayton = copularnd('clayton', theta_clayton, nSim);

%% Plot Pseudo-Observations vs Simulations
figure;
scatter(u_returnbtc, u_returngld, 'filled'); 
title('Actual Pseudo-Observations');
xlabel('BTC'); ylabel('Gold');

figure;
scatter(u_gaussian(:,1), u_gaussian(:,2), 'filled');
title('Simulated Gaussian Copula');

figure;
scatter(u_t(:,1), u_t(:,2), 'filled');
title('Simulated t Copula');




figure;
scatter(u_clayton(:,1), u_clayton(:,2), 'filled');
title('Simulated Clayton Copula');