function [s] = myhex(number,numBytes)
if number < 0,
    s=dec2hex(16^numBytes+number,numBytes);
else
    s=dec2hex(number,numBytes);
end;