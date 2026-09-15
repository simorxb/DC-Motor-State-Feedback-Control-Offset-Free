%% Compare back-calculation anti-windup vs no anti-windup
init;

% Saturating step (init.m uses a different default scenario)
stp = 15*pi;
v_max = 3.5;
Kaw_aw = 40;  % 0 disables AW

mdl = 'DC_motor_state_feedback_control';

%% Simulate without and with anti-windup
in(1) = Simulink.SimulationInput(mdl);
in(1) = in(1).setVariable('Kaw', 0);
in(1) = in(1).setVariable('stp', stp);
in(1) = in(1).setVariable('v_max', v_max);

in(2) = Simulink.SimulationInput(mdl);
in(2) = in(2).setVariable('Kaw', Kaw_aw);
in(2) = in(2).setVariable('stp', stp);
in(2) = in(2).setVariable('v_max', v_max);

out = sim(in, 'UseFastRestart', 'on');

%% Logged signals (out(1) = no AW, out(2) = AW)
theta = out(1).logsout.get('theta').Values.Data;
t_theta = out(1).logsout.get('theta').Values.Time;

theta_aw = out(2).logsout.get('theta').Values.Data;
t_theta_aw = out(2).logsout.get('theta').Values.Time;

theta_ref = out(1).logsout.get('theta_ref').Values.Data;
t_theta_ref = out(1).logsout.get('theta_ref').Values.Time;

theta_id = out(1).logsout.get('theta_id').Values.Data;
t_theta_id = out(1).logsout.get('theta_id').Values.Time;

voltage = out(1).logsout.get('voltage').Values.Data;
t_voltage = out(1).logsout.get('voltage').Values.Time;

voltage_aw = out(2).logsout.get('voltage').Values.Data;
t_voltage_aw = out(2).logsout.get('voltage').Values.Time;

current = out(1).logsout.get('current').Values.Data;
t_current = out(1).logsout.get('current').Values.Time;

current_aw = out(2).logsout.get('current').Values.Data;
t_current_aw = out(2).logsout.get('current').Values.Time;

%% Overlay no-AW vs AW
figure;

% Angle
subplot(3, 1, 1);
plot(t_theta, theta, 'LineWidth', 2);
hold on;
plot(t_theta_aw, theta_aw, 'LineWidth', 2);
plot(t_theta_ref, theta_ref, '--', 'LineWidth', 2);
plot(t_theta_id, theta_id, 'g--', 'LineWidth', 2);
hold off;
ylabel('Angle (rad)');
legend({'\theta no AW', '\theta AW', '\theta_{ref}', '\theta_{id}'}, 'FontSize', 12);
set(gca, 'FontSize', 12);
grid on;

% Voltage
subplot(3, 1, 2);
plot(t_voltage, voltage, 'LineWidth', 2);
hold on;
plot(t_voltage_aw, voltage_aw, 'LineWidth', 2);
hold off;
ylabel('Voltage (V)');
legend({'no AW', 'AW'}, 'FontSize', 12);
set(gca, 'FontSize', 12);
grid on;

% Current
subplot(3, 1, 3);
plot(t_current, current, 'LineWidth', 2);
hold on;
plot(t_current_aw, current_aw, 'LineWidth', 2);
hold off;
xlabel('Time (s)');
ylabel('Current (A)');
legend({'no AW', 'AW'}, 'FontSize', 12);
set(gca, 'FontSize', 12);
grid on;
