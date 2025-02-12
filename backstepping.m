close all
clear all
clc

Tref = 24;
Tinit = 28;

tspan = [0 300];
initZ = [Tinit-Tref;Tinit-Tref;Tinit-2];

options = odeset('AbsTol',[1e-8 1e-8 1e-8],'RelTol',1e-4, 'MaxStep',1);
[t,z] = ode45(@(t,z) reftrack(t,z,Tref,Tinit),tspan,initZ,options);
figure(2);
plot(t,z(:,1)+Tref,'k','LineWidth',1.5)
hold on;
plot(t,z(:,2)+Tref,'r','LineWidth',1.5)
plot(t,z(:,3),'g','LineWidth',1.5)
hold off;
legend('Tm','Tz','Ts');
xlabel('Time (s)');
title('With Backstepping Controller / Error Tracking')

init = [Tinit;Tinit;Tinit];
[t,x] = ode45(@(t,x) orig(t,x,Tinit),tspan,init);
figure(1);
plot(t,x(:,1),'k','LineWidth',1.5)
hold on;
plot(t,x(:,2),'r','LineWidth',1.5)
plot(t,x(:,3),'g','LineWidth',1.5)
hold off;
legend('Tm','Tz','Ts');
xlabel('Time (s)');
title('Without Controller / Constant Fanspeed')

function dxdt=orig(t,x,Tinit)
    dxdt = zeros(3,1);

    kmz = 343;
    kom = 34.3;
    Cm = 2900;
    rho_a = 1.18;
    Vz = 2*2*1;
    Vc = 0.8*0.8*0.9;
    Qac_btu = 5000*0.55;
    Qac_joule = (Qac_btu/3600)*1055.06;
    Cpa = 1012;

    To = Tinit + 2;
    a1 = (kom/Cm) * To;
    b1 = (kmz + kom)/Cm;
    b2 = kmz/Cm;
    b3 = kmz/(rho_a * Cpa * Vz);
    b4 = 1/Vz;
    b5 = 1/Vc;
    b6 = Qac_joule/(rho_a * Cpa * Vc);

    dxdt(1) = -b1*x(1) + b2*x(2) + a1;
    dxdt(2) = b3*x(1) - b3*x(2) - b4*(x(2) - x(3))*0.129;
    dxdt(3) = b5*((1- 0.5)*x(2) - x(3) + 0.5*To)*0.129 - b6;
    if(x(3)) < 16
        x(3) = 16;
        dxdt(3) = 0;
    end
end

function dzdt = reftrack(t,z,Tref,Tinit)
    dzdt = zeros(3,1);

    kmz = 343;
    kom = 34.3;
    Cm = 2900;
    rho_a = 1.18;
    Vz = 2*2*1;
    Vc = 0.8*0.8*0.9;
    Qac_btu = 5000*0.55;
    Qac_joule = (Qac_btu/3600)*1055.06;
    Cpa = 1012;

    To = Tinit + 2;
    a1 = (kom/Cm) * To;
    b1 = (kmz + kom)/Cm;
    b2 = kmz/Cm;
    b3 = kmz/(rho_a * Cpa * Vz);
    b4 = 1/Vz;
    b5 = 1/Vc;
    b6 = Qac_joule/(rho_a * Cpa * Vc);

    k1 = 1;
    k2 = 1;

    c1 = b3 - ((k1 - b3)*(k1 - b1))/b2;
    c2 = k1 - b1 - b3;
    c3 = (k1 - b1)/b2;
    f1 = -(a1/b2) + b1*Tref/b2;
    f2 = (b3*a1)/b2 + (b3*(b2 - b1)/b2)*Tref;

    z2e = -(1/b2) * ((k1 - b1)*z(1) + a1 + (b2 - b1)*Tref);
    e = z(2) - z2e;
    if(t) == 0
        e = 0;
    end

    u = ((c1 + b2)*z(1)+(c2 + k2)*e + f2)/(b4 * (e - c3*z(1) - z(3) + f1));
    if u > 0.129
        u = 0.129;
    end

    dzdt(1) = -b1*z(1) + b2*z(2) + a1 + (b2 - b1)*Tref;
    dzdt(2) = b3*z(1) - b3*z(2) - b4*(z(2) - z(3) + Tref)*u;
    dzdt(3) = b5*((1 - 0.5)*z(2) - z(3) + (1-0.5)*Tref + 0.5*To)*u - b6;
    if(z(3)) < 18
        z(3) = 18;
        dzdt(3) = 0;
    end
end