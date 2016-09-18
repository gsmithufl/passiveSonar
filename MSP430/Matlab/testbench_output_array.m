function testbench_output_array(freq, num_values)
half_num_values = num_values/2;
fprintf('\n');
fprintf('Concatinated Angle of Declination, H3 offset, H2 offset, H1 offset (2 bytes each):\n');
fprintf('\n');
fprintf('{ ');
for i = -half_num_values:half_num_values;
    if i == 0
        continue;
    end
    if i == -half_num_values
        fprintf('{ ');
    else
        fprintf('  { ');
    end
    for j = -half_num_values:half_num_values;
        if j == 0
            continue;
        end
        fprintf('{');
        for k = -half_num_values:half_num_values;
            if k == 0
                continue;
            end
            [d1, d2, d3, aoa, ada] = modified_pinger_loc_test(freq,i,j,k);
            ada = myhex(ada,2);
            c1  = myhex( d1,2);
            c2  = myhex( d2,2);
            c3  = myhex( d3,2);
            fprintf('0x%s%s%s%s', ada, c3, c2, c1);
            if k ~= half_num_values;
                fprintf(', ');
            end
        end %k for
        if j ~= half_num_values;
            fprintf('}, ');
        else
            fprintf('} ');
        end
    end %j for
    if i ~= half_num_values;
        fprintf('},\n');
    else
        fprintf('} ');
    end
end %i for
fprintf('};\n');
fprintf('\n');
fprintf('Angle of Attack array:\n');
fprintf('\n');
fprintf('{ ');
for i = -half_num_values:half_num_values;
    if i == 0
        continue;
    end
    if i == -half_num_values
        fprintf('{ ');
    else
        fprintf('  { ');
    end
    for j = -half_num_values:half_num_values;
        if j == 0
            continue;
        end
        fprintf('{');
        for k = -half_num_values:half_num_values;
            if k == 0
                continue;
            end
            [d1, d2, d3, aoa, ada] = modified_pinger_loc_test(freq,i,j,k);
            aoa = myhex(aoa,4);
            fprintf('0x%s', aoa);
            if k ~= half_num_values;
                fprintf(', ');
            end
        end %k for
        if j ~= half_num_values;
            fprintf('}, ');
        else
            fprintf('} ');
        end
    end %j for
    if i ~= half_num_values;
        fprintf('},\n');
    else
        fprintf('} ');
    end
end %i for
fprintf('};\n');
end %fn