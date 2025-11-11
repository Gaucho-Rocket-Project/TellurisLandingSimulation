% Rocket Second Engine Optimization by Elijah H
clear; clc; close all;

h0 = 8;              % initial height (m)
v0 = 0;              % initial velocity (m/s)
m = 1.5;             % mass of rocket (kg)
g = 9.81;            % gravity bru (m/s^2)
dt = 0.01;           % time step (s)
t_max = 10;          % max simulation time (s)
totalBurnTime = 3.0; % total 2nd stage engine burn time (s)

% Calculate bounds for optimization
F_max_initial = 22.0;  
F_max_sustained = 17.0; 

% Calculate if rocket can even hover
fprintf('=== Hover Check ===\n');
fprintf('Mass: %.2f kg\n', m);
fprintf('Max thrust: %.2f N (initial), %.2f N (sustained)\n', F_max_initial, F_max_sustained);

if F_max_sustained < m * g
    fprintf('WARNING: Sustained thrust (%.2f N) < Weight (%.2f N)\n', F_max_sustained, m*g);
    fprintf('Rocket cannot hover - landing may be impossible :( \n\n');
else
    fprintf('Rocket can hover - landing is doable\n\n');
end

% free fall time w/ no ignition
t_freefall = sqrt(2 * h0 / g);

% time bounds:
t_start_min = 0.01;
t_start_max = t_freefall * 0.95;

fprintf('=== Begin Optimizing Engine Start Time ===\n');
fprintf('Free fall time (no engine): %.3f s\n', t_freefall);
fprintf('Searching for optimal start time between %.3f and %.3f seconds...\n\n', t_start_min, t_start_max);

% objective -> returns impact velocity
objective = @(startTime) simulate_rocket_landing(startTime, h0, v0, m, g, dt, t_max, totalBurnTime);

% optimization using fminbnd 
options = optimset('TolX', 0.0001, 'MaxFunEvals', 100, 'Display', 'iter');
[optimal_startTime, min_impact_velocity] = fminbnd(objective, t_start_min, t_start_max, options);

fprintf('\n=== Optimization Result ===\n');
fprintf('Optimal engine start time: %.4f s\n', optimal_startTime);
fprintf('Minimum impact velocity: %.4f m/s\n', min_impact_velocity);

% warning for beng at time boundry
if abs(optimal_startTime - t_start_min) < 0.01
    fprintf('WARNING: Optimal time is at lower bound\n');
elseif abs(optimal_startTime - t_start_max) < 0.01
    fprintf('WARNING: Optimal time is at upper bound\n');
end

% final params
[~, t, h, v, a, F_rocketPulse, t_impact, v_impact] = simulate_rocket_landing(optimal_startTime, h0, v0, m, g, dt, t_max, totalBurnTime, true);


% ------------------ ai code for visualization ------------------

%fprintf('\nGenerating optimization landscape...\n');
startTime_range = linspace(t_start_min, t_start_max, 150);
impact_velocities = zeros(size(startTime_range));

for i = 1:length(startTime_range)
    impact_velocities(i) = simulate_rocket_landing(startTime_range(i), h0, v0, m, g, dt, t_max, totalBurnTime);
end

% Find all local minima in the landscape
local_minima_idx = find(diff(sign(diff(impact_velocities))) > 0) + 1;
%fprintf('Found %d local minima in search range\n', length(local_minima_idx));

% Create comprehensive visualization
figure('Position', [50, 50, 1400, 900]);

% Plot 1: Optimization Landscape
subplot(2,3,1);
plot(startTime_range, impact_velocities, 'b-', 'LineWidth', 2);
hold on;
plot(optimal_startTime, min_impact_velocity, 'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
% Mark any local minima
if ~isempty(local_minima_idx)
    plot(startTime_range(local_minima_idx), impact_velocities(local_minima_idx), 'mx', 'MarkerSize', 10, 'LineWidth', 2);
end
xlabel('Engine Start Time (s)');
ylabel('Impact Velocity (m/s)');
title('Optimization Landscape');
if ~isempty(local_minima_idx)
    legend('Impact Velocity', 'Global Optimum', 'Local Minima', 'Location', 'best');
else
    legend('Impact Velocity', 'Optimal Point', 'Location', 'best');
end
grid on;
ylim([0, max(impact_velocities)*1.1]);

% Plot 2: Height vs Time
subplot(2,3,2);
plot(t, h, 'b-', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Height (m)');
title(sprintf('Height vs Time (Start: %.3f s)', optimal_startTime));
grid on;
hold on;
plot(t_impact, 0, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
xline(optimal_startTime, 'g--', 'Engine Start', 'LineWidth', 1.5);

% Plot 3: Velocity vs Time
subplot(2,3,3);
plot(t, v, 'r-', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Velocity (m/s)');
title('Velocity vs Time');
grid on;
hold on;
yline(0, 'k--', 'LineWidth', 1);
xline(optimal_startTime, 'g--', 'Engine Start', 'LineWidth', 1.5);

% Plot 4: Acceleration vs Time
subplot(2,3,4);
plot(t, a, 'w-', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Acceleration (m/s^2)');
title('Acceleration vs Time');
grid on;
hold on;
xline(optimal_startTime, 'g--', 'Engine Start', 'LineWidth', 1.5);

% Plot 5: Thrust Force vs Time
subplot(2,3,5);
plot(t, F_rocketPulse, 'm-', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Thrust Force (N)');
title('Rocket Thrust vs Time');
grid on;
hold on;
xline(optimal_startTime, 'g--', 'Engine Start', 'LineWidth', 1.5);

% Plot 6: Trajectory visualization
subplot(2,3,6);
time_indices = 1:50:length(t);
for i = time_indices
    if h(i) > 0
        plot(0, h(i), 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
        hold on;
    end
end
plot(0, h(1), 'go', 'MarkerSize', 12, 'MarkerFaceColor', 'g');
plot(0, 0, 'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
ylim([-1, h0+2]);
xlim([-1, 1]);
ylabel('Height (m)');
title('Rocket Trajectory');
legend('Rocket Path', 'Start', 'Landing', 'Location', 'best');
grid on;

sgtitle('Optimized Rocket Landing Analysis', 'FontSize', 14, 'FontWeight', 'bold');


% ------------------ end of visualization ------------------


% ------------------ simulation function ------------------
function [impact_velocity, t, h, v, a, F_rocketPulse, t_impact, v_impact] = simulate_rocket_landing(startTime, h0, v0, m, g, dt, t_max, totalBurnTime, returnAll)
    if nargin < 9
        returnAll = false;
    end
    
    t = 0:dt:t_max;
    
    % init 
    h = zeros(size(t));
    v = zeros(size(t));
    a = zeros(size(t));
    F_rocketPulse = zeros(size(t));

    h(1) = h0;
    v(1) = v0;

    for i = 1:length(t)-1
        % check for ground impact
        if h(i) <= 0
            h(i) = 0;
            v(i) = 0;
            a(i) = 0;
            h(i+1:end) = 0;
            v(i+1:end) = 0;
            a(i+1:end) = 0;
            break;
        end
        
        % rocket pulse
        if (t(i) < startTime + 0.5 && t(i) < startTime + totalBurnTime && t(i) > startTime)
            F_rocketPulse(i) = 22.0;
        elseif (t(i) < startTime + totalBurnTime && t(i) > startTime)
            F_rocketPulse(i) = 17.0;
        else
            F_rocketPulse(i) = 0;
        end
        
        % positive is downward***

        a(i) = g - F_rocketPulse(i)/m;

        v(i+1) = v(i) + a(i) * dt;
        h(i+1) = h(i) - v(i) * dt - 0.5 * a(i) * dt^2;
    end
    
    % find impact time + velocity
    impact_idx = find(h <= 0, 1);
    if ~isempty(impact_idx)
        t_impact = t(impact_idx);
        v_impact = abs(v(impact_idx-1));
    else
        t_impact = NaN;
        v_impact = 10;  % not landing -> large penalty
    end

    if t_impact - startTime < 3 && returnAll
        fprintf("WARNING: LANDING NOT POSSIBLE, rocket engine has %.2f seconds left\n", totalBurnTime - (t_impact - startTime));
        fprintf("ERROR: rocket weight and max height create impossible landing conditions")
    end

    impact_velocity = v_impact;
    
    % return requested arrays
    if ~returnAll
        t = [];
        h = [];
        v = [];
        a = [];
        F_rocketPulse = [];
    end
end
