function [AD1,AD2,AD3, AOA, ADA] = modified_pinger_loc_test(f,x,z,y)
%Pinger_Loc: Takes in frequency and the x,y,z coordinates of Pinger Location
%and converts them into phase lead/lag wrt the center hydrophone 0
%Dimensions in meters
%      2 H2
% H3   |                  +
% 3 -- 0 H0     x ---+  z |  y (out of page +, in page -)
%      |                  -
%      1 H1 (below)
%Constants
c = 1482;                %Speed of Sound
spacing = .17;%0.0254;   %Distance between each Hydrophone (in meters)
AOA = abs(acos((x/(sqrt(x^2+z^2)))));
if    (z < 0)
    AOA = 2*pi - AOA;
end
ADA = abs(asin((y/(sqrt(y^2+x^2+z^2)))));
if(y < 0)
    ADA = -ADA;
end
%now we find the x, y, z coords with respect to each hydrophone
H3x = x+spacing; %*cos(AOA)*cos(ADA);
H1z = z+spacing; %*cos(AOA)*cos(ADA);
H2z = z-spacing; %*cos(AOA)*cos(ADA);
H1y = y+spacing; %*cos(AOA)*cos(ADA);
%Establish Distance Vectors
h0 = [x,y,z];
h1 = [x,H1y,H1z];
h2 = [x,y,H2z];
h3 = [H3x,y,z];
%Calculate Vector Magnitudes
mag_h0 = sqrt(h0(1)^2+h0(2)^2+h0(3)^2);
mag_h1 = sqrt(h1(1)^2+h1(2)^2+h1(3)^2);
mag_h2 = sqrt(h2(1)^2+h2(2)^2+h2(3)^2);
mag_h3 = sqrt(h3(1)^2+h3(2)^2+h3(3)^2);
%Distance to Hydrophone 1
h01_d = mag_h0 - mag_h1;
%Distance to Hydrophone 2
h02_d = mag_h0 - mag_h2;
%Distance to Hydrophone 3
h03_d = mag_h0 - mag_h3;
%calculate index offset
AD1 = round(360/14.4*f*h01_d/c);
AD2 = round(360/14.4*f*h02_d/c);
AD3 = round(360/14.4*f*h03_d/c);
AOA = round(180*AOA/pi);
ADA = round(180*ADA/pi);
if ((AD1 >= 25 || AD1 <= -25) || (AD2 >= 25 || AD2 <= -25) || (AD3 >= 25 || AD3 <= -25))
    fprintf('Error: AD1 = %d\n\n\n',AD1);
    fprintf('Error: AD2 = %d\n\n\n',AD1);
    fprintf('Error: AD3 = %d\n\n\n',AD1);
end
if ((AOA >= 360 || AOA < 0) || (ADA > 90 || ADA < -90))
    fprintf('Error: AOA = %d\n\n\n',AOA);
    fprintf('Error: ADA = %d\n\n\n',ADA);
end
end