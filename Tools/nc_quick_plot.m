function out = nc_quick_plot(cloudpassfile, ncfile)
    % Plot a snapshot of cloudpasses of interest, select variable of
    % interest from aircraft netcdf file
    

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
    psxc = ncread(ncfile,'PSXC'); % mixing ratio dependency (corrected static pressure)
    ewx = ncread(ncfile,'EWX'); % mixing ratio dependency (ambient water vapor pressure)
    
    
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
         plot(datenum(time2(logicalIndexes)), ewx(logicalIndexes))
         datetick('x')
         xlabel('Time')
         ylabel('Ambient Water Vapor Pressure')
         legend()
         grid on
         
         %LWC
         ax4 = nexttile;
         plot(datenum(time2(logicalIndexes)), psxc(logicalIndexes))
         datetick('x')
         xlabel('Time')
         ylabel('Corrected Static Pressure')
         grid on
 
         %Link axes
         linkaxes([ax1, ax2, ax3, ax4],'x');
         
         % Ask user if we should keep the cloudpass
         prompt = "Next? Y/N: ";
         txt = input(prompt,"s");
    end
    
end