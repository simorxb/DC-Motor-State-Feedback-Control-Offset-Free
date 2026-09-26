%% Plain state feedback (no integral state) under a constant load torque
% Shows the steady-state offset that the integral state removes.
% Same plant, reference and load step as the default init.m scenario.
init;

% Pole placement on the 3-state plant (no augmentation)
K_sf = place(A, B, [-15 -16 -17]);

% Reference gain for unit DC gain from r to theta
Kr = 1/((C - D*K_sf)/(-A + B*K_sf)*B + D);

% Load torque enters the speed equation: J*omega_dot = ... + tau_d
Bd = [0; 1/J; 0];

% Closed loop with inputs [r; tau_d], outputs [theta; voltage; current]
Acl = A - B*K_sf;
Bcl = [B*Kr, Bd];
Ccl = [C; -K_sf; 0 0 1];
Dcl = [0 0; Kr 0; 0 0];
sys_cl = ss(Acl, Bcl, Ccl, Dcl);

%% Simulate: step to stp at 1 s, 0.1 N*m load at 2.5 s
t = (0:tSamp:5)';
r_in = stp*(t >= 1);
tau_d = 0.1*(t >= 2.5);
y = lsim(sys_cl, [r_in, tau_d], t);

% Ideal response: three first-order lags at the closed-loop poles
G_id = tf(1, [1/15 1])*tf(1, [1/16 1])*tf(1, [1/17 1]);
theta_id = lsim(G_id, r_in, t);

fprintf('Kr = %.4f, K = [%s]\n', Kr, num2str(K_sf, 4));
fprintf('Steady-state offset: %.2f rad\n', r_in(end) - y(end, 1));

%% Plot
figure;

subplot(3, 1, 1);
plot(t, y(:, 1), 'LineWidth', 2);
hold on;
plot(t, r_in, '--', 'LineWidth', 2);
plot(t, theta_id, 'g--', 'LineWidth', 2);
hold off;
ylabel('Angle (rad)');
legend({'\theta', '\theta_{ref}', '\theta_{id}'}, 'FontSize', 12);
set(gca, 'FontSize', 12);
grid on;

subplot(3, 1, 2);
plot(t, y(:, 2), 'LineWidth', 2);
ylabel('Voltage (V)');
set(gca, 'FontSize', 12);
grid on;

subplot(3, 1, 3);
plot(t, y(:, 3), 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Current (A)');
set(gca, 'FontSize', 12);
grid on;
