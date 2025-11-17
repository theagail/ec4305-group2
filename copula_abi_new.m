%% read in data
data = readtable('bitcoin_gld.csv');
btc = data.bitcoin;
gld = data.gld;
u_returnbtc = data.u_returnbtc;
u_returngld = data.u_returngld;

%% Copula Testing (Fit Selected Copulas)
conD = [u_returnbtc, u_returngld];

[theta_gaussian, LL_gaussian] = copulafit_myown('gaussian', conD);
[theta_t,        LL_t]        = copulafit_myown('t',        conD);
[theta_clayton,  LL_clayton]  = copulafit_myown('clayton',  conD);

%% simple correlation tests
% Simple correlation
r = corr(u_returnbtc, u_returngld);
disp('Correlation between BTC and Gold pseudo-observations:');
disp(r);

% Print copula parameters
disp('Gaussian theta:');
disp(theta_gaussian);

disp('t copula theta:');
disp(theta_t);

disp('Clayton theta:');
disp(theta_clayton);

% Histogram
figure;
histogram(u_returnbtc, 20);
xlabel('BTC pseudo-observations');
ylabel('Frequency');
title('Histogram of BTC Pseudo-Observations');

%% Simulate from Fitted Copulas
nSim = 3000;

u_gaussian = copularnd('gaussian', theta_gaussian, nSim);

rho_t = theta_t(1);
nu_t  = theta_t(2);
u_t = copularnd('t', rho_t, nu_t, nSim);

u_clayton = copularnd('clayton', theta_clayton, nSim);

%% Plot Pseudo-Observations (Empty Circles)
figure;
scatter(u_returnbtc, u_returngld, 25, 'o', ...
        'MarkerFaceColor','none', ...
        'MarkerEdgeColor','k');
title('Actual Pseudo-Observations');
xlabel('BTC'); ylabel('Gold');

% Simulated Gaussian
figure; hold on;
% Actual
scatter(u_returnbtc, u_returngld, 25, 'o', 'MarkerFaceColor','none', 'MarkerEdgeColor','k');
% Simulated
scatter(u_gaussian(:,1), u_gaussian(:,2), 20, 'o', 'MarkerFaceColor','none', 'MarkerEdgeColor',[0.2 0.4 0.8]);
title('Actual vs Simulated Gaussian Copula');
xlabel('BTC'); ylabel('Gold');
legend({'Actual','Simulated'}, 'Location','best');
grid on;
hold off;

% Simulated t Copula
figure; hold on;
% Actual
scatter(u_returnbtc, u_returngld, 25, 'o', 'MarkerFaceColor','none', 'MarkerEdgeColor','k');
% Simulated
scatter(u_t(:,1), u_t(:,2), 20, 'o', 'MarkerFaceColor','none', 'MarkerEdgeColor',[0.8 0.2 0.2]);
title('Actual vs Simulated t Copula');
xlabel('BTC'); ylabel('Gold');
legend({'Actual','Simulated'}, 'Location','best');
grid on;
hold off;

% Simulated Clayton
figure; hold on;
% Actual
scatter(u_returnbtc, u_returngld, 25, 'o', 'MarkerFaceColor','none', 'MarkerEdgeColor','k');
% Simulated
scatter(u_clayton(:,1), u_clayton(:,2), 20, 'o', 'MarkerFaceColor','none', 'MarkerEdgeColor',[0.2 0.7 0.4]);
title('Actual vs Simulated Clayton Copula');
xlabel('BTC'); ylabel('Gold');
legend({'Actual','Simulated'}, 'Location','best');
grid on;
hold off;

%% Combined Plot (all empty circles)
figure; hold on;

% Actual
scatter(u_returnbtc, u_returngld, 22, 'o', ...
        'MarkerFaceColor','none','MarkerEdgeColor','k');

% Gaussian
scatter(u_gaussian(:,1), u_gaussian(:,2), 14, 'o', ...
        'MarkerFaceColor','none','MarkerEdgeColor',[0.2 0.4 0.8], ...
        'MarkerEdgeAlpha',0.5);

% t
scatter(u_t(:,1), u_t(:,2), 14, 'o', ...
        'MarkerFaceColor','none','MarkerEdgeColor',[0.85 0.3 0.3], ...
        'MarkerEdgeAlpha',0.5);

% Clayton
scatter(u_clayton(:,1), u_clayton(:,2), 14, 'o', ...
        'MarkerFaceColor','none','MarkerEdgeColor',[0.3 0.7 0.4], ...
        'MarkerEdgeAlpha',0.5);

xlabel('BTC'); ylabel('Gold');
title('Simulated Copulas vs Actual Pseudo-Observations');
legend({'Actual','Gaussian','t','Clayton'}, 'Location','best');
grid on;

hold off;

%% === MLE Model Selection ===
LLs = [
    LL_gaussian;
    LL_t;
    LL_clayton
];

models = {'Gaussian','t','Clayton'};

[bestLL, bestIdx] = max(LLs);

fprintf('\n=== Copula Model Selection (MLE) ===\n');
for i = 1:length(models)
    fprintf('%s copula LL = %.4f\n', models{i}, LLs(i));
end

fprintf('\nBest model under MLE: %s (LL = %.4f)\n', ...
    models{bestIdx}, bestLL);

%% === AIC and BIC (for all 3 models) ===
n = length(u_returnbtc);

% parameter counts:
% Gaussian = 1
% t = 2
% Clayton = 1
k = [1, 2, 1];

AIC = -2*LLs + 2*k';
BIC = -2*LLs + log(n)*k';

fprintf('\n=== AIC and BIC ===\n');
for i = 1:length(models)
    fprintf('%s: AIC = %.4f   BIC = %.4f\n', models{i}, AIC(i), BIC(i));
end

[~, bestAIC] = min(AIC);
[~, bestBIC] = min(BIC);

fprintf('\nBest by AIC: %s\n', models{bestAIC});
fprintf('Best by BIC: %s\n', models{bestBIC});
