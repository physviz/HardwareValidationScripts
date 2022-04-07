% Author: Warren Chan
% Date: 2022-03-20
% Source for step_load_forces: code written by Gabriel Chen
% Comment: based on livescript "GetAveragesLive.mlx", modified to run
% through the files expected to be found in the SyncOutputFiles folder

clear;

mkdir Average_GradientOutputFiles;

for load_cell_number_index = 1:3
    for test_number_index = 1:3
        conversion = Get_Average_Gradients(load_cell_number_index, test_number_index);
        disp(conversion);
    end
end
disp("All conversions completed");

function status = Get_Average_Gradients(load_cell_number, test_number)
    %tab here

    clearvars -except load_cell_number test_number gradient_average

    

    %read the data from the synchronized output files
    sync_MCU_filename = "SyncOutputFiles\MCUSteppedLoading_LC"+load_cell_number+"_T"+test_number+".csv";
    sync_Instron_filename = "SyncOutputFiles\InstronSteppedLoading_LC"+load_cell_number+"_T"+test_number+".csv";

    MCU_data = readtable(sync_MCU_filename);
    Instron_data = readtable(sync_Instron_filename);

    %get the data into vectors
    MCU_time = MCU_data{:,1};
    MCU_load = MCU_data{:,2};
    Instron_time = Instron_data{:,1};
    Instron_load = Instron_data{:,2};

    %scaling factor for visualization of the instron data
    scaling_factor = (1000/1.3831);

%     %plot the information obtained just for visualization purposes:
%     plot(MCU_time, MCU_load);
%     hold on
%     plot(Instron_time, Instron_load.*scaling_factor);
%     title ("Data from the synchronized output files");
%     xlabel("Time (seconds)");
%     ylabel("Raw readings and scaled Instron values");

    interval_duration = 5; %seconds

    %defined in the protocol
    %source: Gabriel Chen
    step_loads_force = [10.00... 
                        20.00... 
                        40.00... 
                        70.00... 
                        100.00... 
                        200.00... 
                        400.00... 
                        700.00... 
                        1000.00... 
                        1236.00... 
                        1500.00].';

    %find out the time ranges to be averaged:
    force_tolerance = 2; % in N, subject to be changed

    %finding the step start times:
    step_start_times = zeros(11,1);
    step_end_times= zeros(11,1);

    for step_index = 1:length(step_loads_force) 
        for item = 1:length(Instron_load)
            if(Instron_load(item) > (step_loads_force(step_index) - force_tolerance))
                step_start_times(step_index) = Instron_time(item);
                step_end_times(step_index) = step_start_times(step_index) + interval_duration;

%                 xlstart = xline(step_start_times(step_index), '--r', "Start");
%                 xlstart.LabelVerticalAlignment = 'middle';
%                 xlstart.LabelHorizontalAlignment = 'center';
%                 xlend = xline(step_end_times(step_index), '-.b', "End");
%                 xlend.LabelVerticalAlignment = 'middle';
%                 xlend.LabelHorizontalAlignment = 'center';
                break;
            end
        end
    end
    set(gcf,'position',[10,10,900,600]);
%     hold off;

    %time tolerance defined here
    start_time_tolerance = 0.6; %seconds
    end_time_tolerance = 0.4; %seconds

    MCU_step_start_index = zeros(11,1);
    MCU_step_end_index = zeros(11,1);

    %now to average the values over in MCU;
    for step_index = 1: length(step_loads_force)
        for item = 1: length(MCU_load)
            if (MCU_time(item) >= (step_start_times(step_index)+start_time_tolerance)) %notice the PLUS tolerance
                MCU_step_start_index(step_index) = item; %grab the index
                break;
            end
        end
    end
    for step_index = 1: length(step_loads_force)
        for item = 1: length(MCU_load)
            if (MCU_time(item) >= (step_end_times(step_index)-end_time_tolerance)) %notice the MINUS tolerance
                MCU_step_end_index(step_index) = item; %grab the index
                break;
            end
        end
    end
    plot(MCU_time, MCU_load);
    hold on
    for step_index= 1:length(step_loads_force)
        xlstart = xline(MCU_time(MCU_step_start_index(step_index)), '--r', "Start");
        xlstart.LabelVerticalAlignment = 'middle';
        xlstart.LabelHorizontalAlignment = 'center';
        xlend = xline(MCU_time(MCU_step_end_index(step_index)), '-.b', "End");
        xlend.LabelVerticalAlignment = 'middle';
        xlend.LabelHorizontalAlignment = 'center';
    end


    % visual check completed
    % obtain averages:
    MCU_raw_averages  = zeros(11,1);

    for step_index = 1:length(step_loads_force)
        MCU_raw_averages(step_index) = mean(MCU_load(MCU_step_start_index(step_index):MCU_step_end_index(step_index),1));
        ylaverage = yline(MCU_raw_averages(step_index), '--g');
        set(gcf,'position',[10,10,900,600]);
    end


    hold off
    
    filenameplot = "Average_GradientOutputFiles\RawReadings_Average_plot_LC"+ load_cell_number + "_T"+test_number+".png";
    plotholder = gcf;
    exportgraphics(plotholder, filenameplot, 'Resolution', 300);
    close;

    %plot the curve of the gradients:

    %obtain the zero offset from the first 5 seconds of the MCU data:
    zero_offset_start_index = 1; %start from the beginning

    for item = 1:length(MCU_time)
        if(MCU_time(item) >= 5)
            zero_offset_end_index = item;
            break;
        end
    end

    zero_offset = mean(MCU_load(zero_offset_start_index:zero_offset_end_index, 1));

    gradient_sum = 0;
    gradient_vector = zeros(11,1);

    % One kilogram-force is equal to 9.80665 N\

    onekilogram_to_N = 9.80665;
    N_to_kg = 1/onekilogram_to_N;

    for gradient_index = 1:length(gradient_vector)
        
        if (gradient_index == 1)
            gradient_vector(gradient_index) = (MCU_raw_averages(gradient_index)-zero_offset)/((step_loads_force(gradient_index)-0)*N_to_kg);
        else 
            gradient_vector(gradient_index) = (MCU_raw_averages(gradient_index)-MCU_raw_averages(gradient_index-1))/((step_loads_force(gradient_index)-step_loads_force(gradient_index-1))*N_to_kg);
            gradient_sum = gradient_sum + gradient_vector(gradient_index);
        end
    end

    gradient_average = gradient_sum/(gradient_index-1); % displayed and excludes the first one
    fprintf("Load cell: " + load_cell_number +"\n Test number: " + test_number + "\n gradient average = "+ gradient_average + "\n");

    stem(step_loads_force.*N_to_kg, gradient_vector);
    hold on
    xlabel("Instron measured force (kg)");
    ylabel("Calculated gradient");
    titlestring = ["Calculated gradients vs. Instron measured force", "(raw readings/instron readings)"];
    title(titlestring);
    hold off

    filenameplot = "Average_GradientOutputFiles\Gradients_stemplot_LC"+ load_cell_number + "_T"+test_number+".png";
    plotholder = gcf;
    exportgraphics(plotholder, filenameplot, 'Resolution', 300);
    close;



    %output to a csv
    %column1: average raw readings at the steps
    %column2: gradients at the intervals


    Compiled_Average_Gradient_matrix = zeros(length(gradient_vector),2);
    Compiled_Average_Gradient_matrix(:,1) = MCU_raw_averages;
    Compiled_Average_Gradient_matrix(:,2) = gradient_vector;

    filenameOutputCSV = "Average_GradientOutputFiles\Average_Gradient_LC"+ load_cell_number + "_T"+test_number+".csv";
    writematrix(Compiled_Average_Gradient_matrix, filenameOutputCSV);

    status = "Averages and Gradients obtained for LC" + load_cell_number + ", T"+test_number;


    %tab here
end


