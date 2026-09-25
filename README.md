# Offset-Free State Feedback Control - DC Motor Position

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=simorxb/DC-Motor-State-Feedback-Control-Offset-Free)

## Summary
This project implements offset-free state feedback control of DC motor angular position in MATLAB and Simulink. Integral augmentation of the plant model gives zero steady-state tracking error, and pole placement designs the feedback gain on the augmented system.

## Project Overview
A brushed DC motor is modeled with electrical and mechanical dynamics, and the measured states (angle, speed, and current) are fed back together with an integrator of the position error. The extra integral state rejects constant load-torque disturbances and reference offsets that plain state feedback cannot remove.

The control law is designed by pole placement on the 4th-order augmented linear model and applied to a nonlinear-looking Simulink plant built from the same first-principles equations. The applied voltage is sampled and can be saturated, which motivates the anti-windup extension in Part 2.

### Key Features
- **Offset-free position tracking** using integral state augmentation.
- **Pole placement** on the augmented DC-motor model.
- **Simulink plant** with voltage saturation and a load-torque disturbance.
- **Ideal closed-loop response** overlaid on the simulated angle for comparison.

## DC Motor Modeling

### Plant Model
The motor states are position $\theta$, angular velocity $\omega$, and armature current $i$. The input is the applied voltage $v$, and $\tau_d$ is a load-torque disturbance:

$$
\begin{aligned}
\dot{\theta} &= \omega \\
J\dot{\omega} &= k_t i - b\omega + \tau_d \\
L\dot{i} &= v - Ri - k_e\omega
\end{aligned}
$$

Where:
- $J$ is the rotor inertia
- $b$ is viscous friction
- $k_t$, $k_e$ are the torque and back-EMF constants
- $R$, $L$ are the armature resistance and inductance

In state-space form, with $x = [\theta,~\omega,~i]^T$ and $u = v$:

$$
\dot{x} = Ax + Bu, \qquad y = Cx
$$

### Parameters
- **Mass / radius** (disc inertia $J = \tfrac{1}{2}mr^{2}$): $m = 0.1$ kg, $r = 0.05$ m
- **Viscous friction**: $b = 9.5\times 10^{-6}$ N·m·s
- **Torque / back-EMF constants**: $k_t = 0.0187$ N·m/A, $k_e = 0.0191$ V·s/rad
- **Armature**: $R = 0.6~\Omega$, $L = 0.35$ mH

## State Feedback Design

The plant is augmented with the integral of the tracking error $\xi$, so that a constant disturbance or reference still yields $y \to r$ at steady state:

$$
\dot{\xi} = r - y, \qquad u = -K\begin{bmatrix}x \\ \xi\end{bmatrix}
$$

The gain $K$ is computed with `place` on the augmented pair $(A_a, B_a)$.

### Controller Parameters
- **Sample time**: 0.001 s (discrete integrator and zero-order hold on voltage)
- **Closed-loop poles**: $-15$, $-16$, $-17$, $-18$
- **Voltage limits**: $\pm v_{max}$ (`inf` in the default `init.m` run)
- **Anti-windup gain**: $K_{aw} = 0$ disables back-calculation (see Part 2)

## Simulation Setup
1. Run `init.m`
2. Simulate `DC_motor_state_feedback_control.slx`
3. Run `plot_results.m`

The default reference is a step of amplitude `stp` at $t = 1$ s. A load-torque disturbance of $0.1$ N·m is applied at $t = 2.5$ s. Logged signals include $\theta$, $\theta_{ref}$, an ideal response $\theta_{id}$, voltage, and current.

## Files
- **`init.m`**: plant parameters, augmented model, pole-placement gain $K$, and default `stp`, $v_{max}$, $K_{aw}$.
- **`DC_motor_state_feedback_control.slx`**: plant, state feedback with integral action, saturation, and anti-windup path.
- **`plot_results.m`**: plots angle, voltage, and current from the last simulation.

---

# Part 2 – Back-Calculation Anti-Windup

## Summary
This part adds back-calculation anti-windup on the integral state so the controller remains consistent when the voltage saturates. Setting $K_{aw} = 0$ recovers the original implementation from Part 1.

## Project Overview
The integral of the tracking error is the only dynamic state of the controller. From the error $e = r - y$ to the unsaturated command $u$, the controller is strictly proper, so high-frequency-gain (Hanus) conditioning does not apply. Back-calculation is the matching anti-windup law for this architecture: the saturation residual is fed into the integrator.

## Anti-Windup Design
With $e = r - y$ and $u_{sat} = \mathrm{sat}(u)$:

$$
\dot{\xi} = e + K_{aw}(u_{sat} - u)
$$

Where:
- $K_{aw} = 0$ disables anti-windup
- $K_{aw} > 0$ drives $\xi$ so that $u$ is pulled back toward the voltage limits during saturation

The path is implemented in the Control System area of `DC_motor_state_feedback_control.slx` (`SatDiff`, `Kaw`, `AddAW`).

## Simulation Scenario
`compare_aw_vs_non_aw.m` uses a saturating step that is more demanding than the default `init.m` run:

- **Reference**: $15\pi$ rad at $t = 1$ s
- **Voltage limits**: $\pm 3.5$ V
- **Runs**: $K_{aw} = 0$ and $K_{aw} = 40$

## Results and Performance

### Key Observations
- Without anti-windup the integrator winds up on the voltage rails and the angle overshoots by about 26%.
- With $K_{aw} = 40$ overshoot drops to almost absent, closer to the unconstrained response, and time spent on the rails is shorter.
- After the load-torque disturbance, the anti-windup run leaves saturation cleaner and with less current ringing.

## Key Takeaways
- Integral state feedback needs anti-windup as soon as the actuator saturates.
- Back-calculation on $\xi$ is the natural scheme when the error-to-command map has no direct feedthrough.
- $K_{aw} = 0$ keeps the original offset-free controller for unsaturated experiments.

---

## Comparing Anti-Windup and No Anti-Windup

The script **`compare_aw_vs_non_aw.m`** runs both settings on the same model and overlays the logged signals.

### What the script does

1. **Initialise** — Runs `init`, then sets `stp = 15*pi` and `v_max = 3.5`.
2. **No-AW run** — Simulates with `Kaw = 0`.
3. **AW run** — Simulates with `Kaw = 40`.
4. **Comparison figure** — Angle (plus $\theta_{ref}$ and $\theta_{id}$), voltage, and current for both runs.

---

## Author
This project is developed by Simone Bertoni. Learn more about my work on my personal website - [Simone Bertoni - Control Lab](https://simonebertonilab.com/).

## Contact
For further communication, connect with me on [LinkedIn](https://www.linkedin.com/in/simone-bertoni-control-eng/).
