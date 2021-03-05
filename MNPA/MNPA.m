clc
clear close
set(0, 'DefaultFigureWindowStyle', 'docked')

R1 = 1;
cap = 0.25;
R2 = 2;
L = 0.2;
R3 = 10;
alpha = 100;
R4 = 0.1;
R0 = 1000;

% 8 nodes -  5 from diagram, 1 From independent voltage source, 
% 1 from inductor, 1 from VCVS

G = [1/R1 -1/R1 0 0 0 1 0 0 ; 
    -1/R1 (1/R1+1/R2) 0 0 0 0 1 0; 
    0 0 1/R3 0 0 0 -1 0;
    0 0 0 1/R4 -1/R4 0 0 1;
    0 0 0 -1/R4 (1/R4+1/R0) 0 0 0;
    1 0 0 0 0 0 0 0;
    0 1 -1 0 0 0 0 0;
    0 0 (-alpha/R3) 1 0 0 0 0
    ];

C = [cap -cap 0 0 0 0 0 0;
    -cap cap 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 -L 0;
    0 0 0 0 0 0 0 0];

F = zeros(8,1);

% F = [0 0 0 0 0 Vin 0 0 ]

%%%%%%%%%%%%%%%%%%%%%%
% 2A DC Sweep

vin = linspace(-10,10,50);
vout = zeros(50,1);
v3 = zeros(50,1);
for i = 1:length(vin)
    F(6) = vin(i);
    V = G\F;
    v3(i) = V(3);
    vout(i) = V(5);
end


figure(1);
subplot(2,1,1);
plot(vin,vout)
xlabel('Vin (V)')
ylabel('Vout (V)')
title('DC Case for Vout node')
xlim([-10,10])
ylim([min(vout),max(vout)])

subplot(2,1,2)
plot(vin,v3)
xlabel('Vin (V)')
ylabel('V3 (V)')
title('DC Case for V3 node')
xlim([-10,10])
ylim([min(v3),max(v3)])


%%%%%%%%%%%%%%%%%%%%%%
% 2C AC Case

w = 2*pi* linspace(0,50,1000);
vout = zeros(1000,1);
gain = zeros(1000,1);

for n = 1:1000
    s = 1i*w(n);
    A = G + (s.*C) ;
    V = A\F;
    vout(n) = abs(V(5)); 
    gain(n) = 20*log10(abs(vout(n))/abs(V(1)));
end

figure(2);
subplot(2,1,1)
plot(w,vout,'b')
xlabel('Frequency (Hz)')
ylabel('Vout (V)')
title('AC Case for Vout')
grid on;

subplot(2,1,2)
plot(w,gain,'b')
xlabel('Frequency (Hz)')
ylabel('Gain (dB)')
title('AC Gain')
set(gca,'XScale','log');
grid on; 

%%%%%%%%%%%%%%%%%%%%%%%%
% 2D Gain as random Pertubations of C

figure(3);
vout = zeros(1000,1);
gain = zeros(1000,1);

for n=1:1000
    
    p = 0.05*randn();
    C(1, 1)= cap*p;
    C(2, 2)= cap*p;
    C(1, 2)= -cap*p;
    C(2, 1)= -cap*p;
    
    s = 2*pi;
    A = G + (s.*C) ;
    V = A\F;
    vout(n) = abs(V(5)); 
    gain(n) = 20*log10(abs(vout(n))/abs(V(1)));
end

histogram(gain,100);
title('Gain with random C');
xlabel('Gain (dB)');
ylabel('');




