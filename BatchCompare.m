% Author: Warren Chan
% Date: 2022-04-06
% Source for step_load_forces: code written by Gabriel Chen
% Comment: based on livescript "GetAveragesLive.mlx", modified to run
% through the files expected to be found in the SyncOutputFiles folder

clear;


mkdir ComparisonOutputFiles;



%     calibration_factor = 6993.456; % this is the calculated average of the three load cells  
%     calibration_factor = 7003.039;  % this is using only load cells 1 and 3   
%     calibration_factor = 7001.392; % this is using only load cell 1 data
%     calibration_factor = 6974.29; % this is using only load cell 2 data
%     calibration_factor = 7004.68; % this is using only load cell 2 data
calibration_factor = 7050; % this is just playing with the aribitraty values
disp("Calibration Factor = " + calibration_factor);

for load_cell_number_index = 1:3
    for test_number_index = 1:3
        conversion = Get_Average_Gradients(load_cell_number_index, test_number_index, calibration_factor);
        disp(conversion);
    end
end
disp("All conversions completed");

function status = Get_Average_Gradients(load_cell_number, test_number, calibration_factor)
    %tab here

    clearvars -except load_cell_number test_number gradient_average calibration_factor

    kg_to_N = 9.80665;

    %read the data from the synchronized output files
    sync_MCU_filename = "SyncOutputFiles\MCUSteppedLoading_LC"+load_cell_number+"_T"+test_number+".csv";
    sync_Instron_filename = "SyncOutputFiles\InstronSteppedLoading_LC"+load_cell_number+"_T"+test_number+".csv";

    MCU_data = readtable(sync_MCU_filename);
    Instron_data = readtable(sync_Instron_filename);

    %get the data into vectors
    MCU_time = MCU_data{:,1};
    MCU_raw = MCU_data{:,2};
    Instron_time = Instron_data{:,1};
    Instron_N = Instron_data{:,2};

    %scale the result from the MCU loads according to the calibration
    %factor
    MCU_load = MCU_raw./ calibration_factor;
    Instron_kg = Instron_N ./kg_to_N;

    % at this point we have all the data that we need, try to plot it

    plot(MCU_time, MCU_load);
    hold on
    plot (Instron_time, Instron_kg);
    title("Synchronized and calibrated data");
    xlabel("Time (seconds)");
    ylabel("Calibrated readings and Instron values");
    legend("Calibrated prototype","Instron"); 
    hold off

    filenameplot = "ComparisonOutputFiles\Comparison_LC"+ load_cell_number + "_T"+test_number+".png";
    plotholder = gcf;
    exportgraphics(plotholder, filenameplot, 'Resolution', 300);
    close;
    
    maximum_MCU = max(MCU_load);
    maximum_Instron = max(Instron_kg);

    max_error = abs(maximum_Instron-maximum_MCU);


    status = "Max error:"+ max_error + ", for LC" + load_cell_number + ", T"+test_number;

    

end


