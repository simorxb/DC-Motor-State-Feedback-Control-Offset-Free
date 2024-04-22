% Access the signals from out.logsout

theta = out.logsout.get('theta').Values.Data;
t_theta = out.logsout.get('theta').Values.Time;

theta_ref = out.logsout.get('theta_ref').Values.Data;
t_theta_ref = out.logsout.get('theta_ref').Values.Time;

theta_id = out.logsout.get('theta_id').Values.Data;
t_theta_id = out.logsout.get('theta_id').Values.Time;

voltage = out.logsout.get('voltage').Values.Data;
t_voltage = out.logsout.get('voltage').Values.Time;

current = out.logsout.get('current').Values.Data;
t_current = out.logsout.get('current').Values.Time;

omega = out.logsout.get('omega').Values.Data;
t_omega = out.logsout.get('omega').Values.Time;


% Create the first figure
figure;

% Subplot for theta
subplot(3, 1, 1);
plot(t_theta, theta, 'LineWidth', 2);
hold on;
plot(t_theta_ref, theta_ref, '--', 'LineWidth', 2);
plot(t_theta_id, theta_id, 'g--', 'LineWidth', 2);
hold off;
%xlabel('Time (s)');
ylabel('Angle (rad)');
legend({'\theta', '\theta_{ref}', '\theta_{id}'}, 'FontSize', 12);
set(gca, 'FontSize', 12);
grid on;

% Subplot for voltage
subplot(3, 1, 2);
plot(t_voltage, voltage, 'LineWidth', 2);
%xlabel('Time (s)');
ylabel('Voltage (V)');
set(gca, 'FontSize', 12);
grid on;

% Subplot for current
subplot(3, 1, 3);
plot(t_current, current, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Current (A)');
set(gca, 'FontSize', 12);
grid on;