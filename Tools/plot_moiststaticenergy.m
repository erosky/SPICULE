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
    
    for f = 1:length(Files)
        % Open up the cloudpass file
        pass = readtable(fullfile(Files(f).folder, Files(f).name));
        time = pass.Time;
        temp = mean(pass.Temperature);
        vwind = pass.VerticalWind;
        mixingratio = pass.MixingRatio./1000; % g/kg converted to kg/kg
        altitude = pass.Altitude; %m
        
        specific_heat = 1005.7 + 1820.0.*mixingratio; %J/kg*K
        latent_heat = 2.501e6; % J/kg
        g = 9.8; %m/s
        
        MSE = specific_heat.*pass.Temperature + g.*altitude + latent_heat.*mixingratio %J/kg
        
        fig = figure(1);     
        
%         plot(MSE);
%         ylabel('Moist static energy (J/kg)')
%         xlabel('Cloud pass duration')
%         hold on
%         grid on
        
        fig = figure(1);
        tiledlayout(6,1);
        ax1 = nexttile;       
        
        plot(time, MSE);
        ylabel('Moist static energy (J/kg)')
        datetick('x')
        xlabel('Time')
        title(Files(f).name)
        grid on
        
        ax2 = nexttile;
        plot(time, mixingratio);
        datetick('x')
        xlabel('Time')
        ylabel('mixing ratio')
        grid on
        
        ax3 = nexttile;
        plot(time, altitude);
        datetick('x')
        xlabel('Time')
        ylabel('altitude')
        grid on
        
        ax4 = nexttile;
        plot(time, pass.Temperature);
        datetick('x')
        xlabel('Time')
        ylabel('temperature')
        grid on
        
        ax5 = nexttile;
        plot(time, specific_heat);
        datetick('x')
        xlabel('Time')
        ylabel('specific heat')
        grid on
        
        ax6 = nexttile;
        plot(time, vwind);
        ylabel('Vertical wind (m/s)')
        datetick('x')
        xlabel('Time')
        grid on
        
         %Save figure
         figname = int2str(f) + ".png";
         figfile = fullfile(Folder+"/test", figname);
         if ~isfile(figfile)
             saveas(fig, figfile);
         end

     
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