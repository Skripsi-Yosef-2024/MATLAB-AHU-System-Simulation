close all
clear all
clc

tspan = [0 5000];
init = [28;28;28];

[t,x] = ode45(@(t,x) orig(t,x),tspan,init);
figure(1);
plot(t,x(:,1),'k','LineWidth',1.5)
hold on;
plot(t,x(:,2),'r','LineWidth',1.5)
plot(t,x(:,3),'g','LineWidth',1.5)
hold off;
legend('Tm','Tz','Ts');
xlabel('Time (s)');
title('Without Controller / Constant Fanspeed')

function dxdt=orig(t,x)
    dxdt = zeros(3,1);

    To = 28;
    a1 = 0.0097 * To;
    b1 = 0.062;
    b2 = 0.052;
    b3 = 0.00001;
    b4 = 0.0025;
    b5 = 0.0025;
    b6 = 0.05;

    dxdt(1) = -b1*x(1) + b2*x(2) + a1;
    dxdt(2) = b3*x(1) - b3*x(2) - b4*(x(2) - x(3))*0.129;
    dxdt(3) = b5*((1- 0.25)*x(2) - x(3) + 0.25*To)*0.129 - b6;
    if(x(3)) < 17
        x(3) = 17;
        dxdt(3) = 0;
    end

end