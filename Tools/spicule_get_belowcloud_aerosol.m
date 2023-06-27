function out = spicule_get_belowcloud_aerosol(cloudpassfile, ncfile)
    % Plot a snapshot of cloudpasses of interest
    % manually accept or reject them
    % store data for the accepted passes
    

    %Get data from the netCDF file
    time = ncread(ncfile,'Time');
    conc = ncread(ncfile, 'CCDP_LWOO');
    bin_edges = ncreadatt(ncfile, 'CCDP_LWOO', 'CellSizes');
    cdplwc = ncread(ncfile,'PLWCD_LWOO');
    meandiam = ncread(ncfile,'DBARD_LWOO');
    flightnumber = upper(ncreadatt(ncfile, '/', 'FlightNumber'));
    flightdate = ncreadatt(ncfile, '/', 'FlightDate');
    time_ref = split(flightdate, "/");
    
    %Reshape the concentration array into two dimensions
    s = size(conc);
    conc2 = reshape(conc, [s(1), s(3)]);
    s2 = size(conc2);
    
    bins = [];
    for b = 1 : length(bin_edges)-1
        center = (bin_edges(b) + bin_edges(b+1))/2;
        bins = [bins; center];
    end
    bins;
    
    
    temp = ncread(ncfile,'ATX'); % 'Ambient Temperature, Reference', in units of degrees Celsius
    vwind = ncread(ncfile,'WIC'); %Vertical windspeed derived from Rosemount 858 airdata probe located on the starboard pylon, in units of metres per second
    icing = ncread(ncfile,'RICE'); % 'Raw Icing-Rate Indicator'
    alt = ncread(ncfile,'GGALT'); %'Reference GPS Altitude (MSL) (m)' 
    lat = ncread(ncfile,'LAT');
    lon = ncread(ncfile,'LON');
    dpt = ncread(ncfile,'DPXC'); % dewpoint temp
    mr = ncread(ncfile,'MR'); % mixing ratio
    
    
    % Reformat time to human readable format
    % Given in netcdf file as seconds since 00:00:00 +0000 of flight date
    time2 = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(time(:,1));
    
   
    % Open up the cloudpass file
    passes = readtable(cloudpassfile);
    
    % Check each cloudpass
    % Plot snapshot of cdp dsd, lwc, and vertical wind
    % ask user if they want to keep or reject the cloudpass
    % If the user keeps cloudpass, create a new directory, save snapshots
    % to the directory, write aircraft data to a csv file
    
    % Read cloudpasses
    parentFolder = "/home/simulations/Field_Projects/CloudPass_Analysis/SPICULE";
    
    n=1;
    tempTypes = [];
    summary = table('Size',[0 9],...
                        'VariableTypes',{'datetime','datetime','int8','double','double','double','double','double','double'},...
                        'VariableNames', ["StartTime", "EndTime", "Duration_s", "StartTime_datenum", "EndTime_datenum", "LargeConc_cc", "SmallConc_cc", "MeanDiameter_um", "AverageLWC_g_m3"]);
    
    for row = 1:height(passes)
        pass = passes(row,:)
        largeconc = pass.LargeConc_cc;   
        starttime = pass.StartTime - seconds(2);
        endtime = pass.EndTime + seconds(2);
        logicalIndexes = (time2 <= endtime) & (time2 >= starttime);
        
         % Plot properties
         
         fig = figure(1);
         tiledlayout(5,1);
         ax1 = nexttile([2 1]);
% 
%         %Concentration contour
         levels = 10.^(linspace(0,4,20));  %Log10 levels
         contourf(datenum(time2(logicalIndexes)), bins, conc2(:,logicalIndexes), levels, 'LineStyle', 'none');
         datetick('x')
         set(gca,'ColorScale','log');
         grid on
 
         xlabel('Time')
         ylabel('Diameter (microns)');
         c=colorbar;
         set(gca,'ColorScale','log');
         c.Label.String = 'Concentration (#/cc/um)';
         title([flightnumber ' ' date]);
 
         %Vertical Velocity
         ax2 = nexttile;
         plot(datenum(time2(logicalIndexes)), vwind(logicalIndexes))
         datetick('x')
         xlabel('Time')
         ylabel('Vertical windspeed (m/s)')
         grid on
 
         %LWC
         ax3 = nexttile;
         plot(datenum(time2(logicalIndexes)), cdplwc(logicalIndexes))
         datetick('x')
         xlabel('Time')
         ylabel('LWC (g/m3)')
         legend()
         grid on
         
         %LWC
         ax4 = nexttile;
         plot(datenum(time2(logicalIndexes)), temp(logicalIndexes))
         datetick('x')
         xlabel('Time')
         ylabel('Temperature (C)')
         legend(sprintf('Large droplets (>15um) = %f', largeconc))
         grid on
 
         %Link axes
         linkaxes([ax1, ax2, ax3, ax4],'x');
         
         % Ask user if we should keep the cloudpass
         prompt = "Save this cloudpass? Y/N: ";
         txt = input(prompt,"s");
         if txt=="Y";
             fprintf("keep\n");
             % Save cloudpass
             date_txt = string(starttime, 'yyyy-MM-dd-HH-mm-ss') + '_' + string(endtime, 'yyyy-MM-dd-HH-mm-ss');
             passname = flightnumber + "_" + date_txt;
             if all(temp(logicalIndexes) >= 0);
                 tempFile = "WarmClouds";
                 if largeconc > 100;
                    concFile = "HighConc";
                 else 
                    concFile = "LowConc";
                 end
                 passFolder = parentFolder + '/' + tempFile + '/' + concFile;
             else
                 tempFile = "ColdClouds";
                 passFolder = parentFolder + '/' + tempFile;
             end
                
             
             % Save figure
             figname = passname + ".png";
             figfile = fullfile(passFolder, figname);
             if ~isfile(figfile)
                 saveas(fig, figfile);
             end
             
             
             % Save data
             % CDP data
             % timestamps, LWC, meandiam, binedges, bincenters, concentration
             cdpname = "cdp_" + passname + ".nc";
             cdpfile = fullfile(passFolder, cdpname);
             if ~isfile(cdpfile)
                 nccreate(cdpfile, 'time', "Dimensions", {"time", length(time(logicalIndexes))}, "Format","classic" );
                 ncwrite(cdpfile, 'time', time(logicalIndexes));
                 nccreate(cdpfile, 'LWC', "Dimensions", {"time", length(time(logicalIndexes))});
                 ncwrite(cdpfile, 'LWC', cdplwc(logicalIndexes));
                 nccreate(cdpfile, 'bins', "Dimensions", {"bins", 30});
                 ncwrite(cdpfile, 'bins', bins);
                 nccreate(cdpfile, 'bin_edges', "Dimensions", {"bin_edges", 31});
                 ncwrite(cdpfile, 'bin_edges', bin_edges);
                 nccreate(cdpfile, 'PSD', "Dimensions", {"time", length(time(logicalIndexes)), "bins", 30});
                 ncwrite(cdpfile, 'PSD', transpose(conc2(:,logicalIndexes)));
             end
             
             
             % Aircraft data csv
             % timestamp, air_temp, vwind, icing, altitude, lat, lon
             output_data = table('Size', [length(time2(logicalIndexes)) 0]);
             output_data.Time = time2(logicalIndexes);
             output_data.Temperature = temp(logicalIndexes);
             output_data.VerticalWind = vwind(logicalIndexes);
             output_data.Icing = icing(logicalIndexes);
             output_data.Altitude = alt(logicalIndexes);
             output_data.Latitude = lat(logicalIndexes);
             output_data.Longitude = lon(logicalIndexes);
             output_data.DewPoint = dpt(logicalIndexes);
             output_data.MixingRatio = mr(logicalIndexes);
             
             output_filename = fullfile(passFolder, sprintf('aircraft_%s.csv', passname));
             if ~isfile(output_filename)
                writetable(output_data, output_filename);
             end
             
             summary = [summary;pass];
             tempTypes = [tempTypes;tempFile];
             n=n+1;
         end
         
    end
    summary.CloudTemp = tempTypes
    summary_filename = fullfile(parentFolder, sprintf('%s_summary.csv', flightnumber));
    writetable(summary, summary_filename);
    
end