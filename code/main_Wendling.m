% This code repricates the structure of the Voss / Schiff FN simulation /
% estimation
clc
close all
clear

N = 1000;             	% number of samples
dT = 0.001;          	% sampling time step (global)
dt = 1*dT;            	% integration time step
nn = fix(dT/dt);      	% (used in for loop for forward modelling) the integration time step can be small that the sampling (fix round towards zero)

t = 0:dt:(N-1)*dt;

% Intial true parameter values
mode = 'background';
mode = 'alpha';       % this is more like alpha!!!
% mode = 'spikes';
parameters = SetParametersWendling(mode)
parameters.dt = dt;
A = parameters.A;
a = parameters.a;
sigma = parameters.sigma;

% Initialise random number generator for repeatability
rng(0);

% Transition model
NStates = 10;                           
f = @(x)model_Wendling(x,'transition',parameters);

% Initialise trajectory state
x0 = zeros(NStates,1);                   % initial state
x = zeros(NStates,N); 
x(:,1) = x0;


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate trajectory
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Define input
Q = zeros(NStates);
Q(4,4) = (sqrt(dt)*A*a*sigma)^2;
v = mvnrnd(zeros(NStates,1),Q,N)';

% Euler-Maruyama integration

for n=1:N-1
    x(:,n+1) = f(x(:,n))  + v(:,n);
end

H = [0 0 1 0 -1 0 -1 0 0 0];           % observation function
R = 1^2*eye(1);
w = mvnrnd(zeros(size(H,1),1),R,N)';
y = H*x + w;

figure
plot(t,-H*x)
