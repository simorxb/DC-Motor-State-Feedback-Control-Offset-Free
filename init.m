%% Init params
m = 0.1;
r = 0.05;
J = 0.5*m*r^2;
b = 0.0000095;
kt = 0.0187;
R = 0.6;
L = 0.35/1000;
ke = 0.0191;

%% Controller params

% Compute A, B, C, D matrices
A = [0 1 0; 0 -b/J kt/J; 0 -ke/L -R/L];
B = [0; 0; 1/L];
C = [1 0 0];
D = 0;

% Compute A, B, C, D matrices for augmented system
Aa = [A, zeros(3,1); -C, 0];
Ba = [B; -D];

% Compute state feedback gains using pole placement for augmented system
K = place(Aa, Ba, [-15 -16 -17 -18]);

tSamp = 0.001;