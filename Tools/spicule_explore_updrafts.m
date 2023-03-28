function out = spicule_explore_updrafts(ncfile)
    % Plot a snapshot of cloudpasses of interest, select variable of
    % interest from aircraft netcdf file
    
   [i, t, utc] = spicule_updraft_search(ncfile,3,3);

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
    
   
    
    % Check each cloudpass
    % Plot snapshot of cdp dsd, lwc, and vertical wind
    % ask user if they want to keep or reject the cloudpass
    % If the user keeps cloudpass, create a new directory, save snapshots
    % to the directory, write aircraft data to a csv file
       
    for p = 1 : length(i)
   
        conc_array = conc2(:, i{p}(1):i{p}(end));
        % average total LWC
        lwc = cdplwc(i{p}(1):i{p}(end));
        starttime = utc{p}(1) - seconds(2);
        endtime = utc{p}(end) + seconds(2);
        logicalIndexes = (time2 <= endtime) & (time2 >= starttime);
        
         % Plot properties
         
         fig = figure(1);
         plot(lon(logicalIndexes), lat(logicalIndexes))
         xlabel('Lon')
         ylabel('Lat')
         legend()
         grid on
         hold on
         
         
         fig = figure(2);
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
         plot(datenum(time2(logicalIndexes)), alt(logicalIndexes))
         datetick('x')
         xlabel('Time')
         ylabel('Altitude')
         legend()
         grid on
         
         %LWC
         ax4 = nexttile;
         plot(datenum(time2(logicalIndexes)), cdplwc(logicalIndexes))
         datetick('x')
         xlabel('Time')
         ylabel('LWC')
         grid on
 
         %Link axes
         linkaxes([ax1, ax2, ax3, ax4],'x');
         
         % Ask user if we should keep the cloudpass
         prompt = "Next? Y/N: ";
         txt = input(prompt,"s");
    end
    
end