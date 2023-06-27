function out = plot_moiststaticenergy(cloudpassfolder)
    % find each aircraft data file in folder
    % plot a PDF of vertical wind speed, title the plot with timestamps
    
    % get list of filenames to read
    Folder = cloudpassfolder;
    Files = dir(fullfile(Folder, 'aircraft*.csv'));
    Names = {Files.name};

    low_v = 5e4;
    high_v = 6.6e4;
    edges = low_v:1000:high_v;
    test_cloudbase = 2800; % (m) region 5
    test_T_cloudbase = 18; % guess based on 500 m below cloud base
    test_mr_cloudbase = 10.7/1000; % kg/kg
    test_hum_cb = 9.7; %g/m^3
    specific_heat = 1005.7 + 1820.0*test_mr_cloudbase %J/kg*K
    latent_heat = 2.501e6; % J/kg
    g = 9.8; %m/s
    
    test = table('Size',[0 11],...
                        'VariableTypes',{'datetime','datetime','double','double','double', 'double', 'double','double','double','double', 'double'},...
                        'VariableNames', ["StartTime", "EndTime", "AverageLWC_g_m3", "AverageAlt", "Height_above_CB", "AverageTemp", "Temp_over_CB", "MeanUpdraft", "dw_dz", "dw_dt", "Test_var"]);
    
    for f = 1:length(Files)
        % Open up the cloudpass file
        pass = readtable(fullfile(Files(f).folder, Files(f).name));
        time = pass.Time(3:end-2);
        temp = mean(pass.Temperature(3:end-2));
        vwind = pass.VerticalWind(3:end-2);
        mixingratio = pass.MixingRatio(3:end-2)./1000; % g/kg converted to kg/kg
        altitude = pass.Altitude(3:end-2); %m
        avg_lwc = mean(pass.kingLWC(3:end-2));
        avg_z = mean(altitude);
        height_abv_CB = avg_z - test_cloudbase;
        temp_abv_CB = temp - test_T_cloudbase;
        test_var = -(specific_heat/g)*temp_abv_CB-(latent_heat/g)*((avg_lwc/test_hum_cb)-1);
        dw_dz = avg_lwc/height_abv_CB;
        dw_dt = (avg_lwc/height_abv_CB) * mean(vwind);

        
        MSE = specific_heat.*pass.Temperature(3:end-2) + g.*altitude + latent_heat.*mixingratio; %J/kg

        
        test_pass = {time(1), time(end), avg_lwc, avg_z, height_abv_CB, temp, temp_abv_CB, mean(vwind), dw_dz, dw_dt, test_var};
        test = [test;test_pass];
        
%        fig = figure(1);     
        
%         plot(MSE);
%         ylabel('Moist static energy (J/kg)')
%         xlabel('Cloud pass duration')
%         hold on
%         grid on
        
%         fig = figure(1);
%         tiledlayout(5,1);
%         ax1 = nexttile;       
%         plot(time, vwind);
%         ylabel('Vertical wind (m/s)')
%         datetick('x')
%         xlabel('Time')
%         grid on
% 
%         ax2 = nexttile;
%         plot(time, pass.kingLWC);
%         ylabel('LWC')
%         datetick('x')
%         xlabel('Time')
%         title(Files(f).name)
%         grid on
%         
%         ax3 = nexttile;
%         plot(time, mixingratio);
%         datetick('x')
%         xlabel('Time')
%         ylabel('mixing ratio')
%         grid on
%         
%         ax4 = nexttile;
%         plot(time, altitude);
%         datetick('x')
%         xlabel('Time')
%         ylabel('altitude')
%         grid on
%         
%         ax5 = nexttile;
%         plot(time, pass.Temperature);
%         datetick('x')
%         xlabel('Time')
%         ylabel('temperature')
%         grid on
% 
%         
%          %Save figure
%          figname = int2str(f) + ".png";
%          figfile = fullfile(Folder+"/test", figname);
%          if ~isfile(figfile)
%              saveas(fig, figfile);
%          end
         
         test_filename = fullfile(Folder, '/test/test.csv');
         writetable(test, test_filename);
         
         fig = figure(1); 
         scatter(test.Height_above_CB(4:end), test.AverageLWC_g_m3(4:end));
         grid on
         xlabel("height above cloud base")
         ylabel("LWC")
         

     
%          if ~ sum(isnan(vwind)) > 0
%              PDF = histcounts(MSE, edges, 'Normalization', 'pdf');
%              CDF = [];
%              centers = [];
%              for p = 2:length(edges)-1
%                  c = sum(PDF(1:p));
%                  CDF = [CDF; c]; 
%                  v = (edges(p-1) + edges(p))/2;
%                  centers = [centers, v];
%              end
% 
%              fig = figure(2);
%              %histogram(MSE, edges, 'Normalization', 'pdf')
%             plot(centers, CDF)
%             hold on
%             xlabel('Moist static energy (m/s)')
%             grid on
%          end
            
    end
%     
end