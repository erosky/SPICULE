function out = spicule_group_updrafts(ncfile)
    % Find regions with large updraft velocities
    % Group them together based on lat and lon
    % For updrafts that share the same lat and lon, put the data together
    % in one directory.
    % lat same to within ~1km (0.3 degrees)
    % lon same to within 0.3 degrees
    
   [i, t, utc] = spicule_updraft_search(ncfile,3,3);

    %Get data from the netCDF file
    time = ncread(ncfile,'Time');
    conc = ncread(ncfile, 'CCDP_LWOO');
    bin_edges = ncreadatt(ncfile, 'CCDP_LWOO', 'CellSizes');
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
    kinglwc = ncread(ncfile,'PLWCC'); % Corrected PMS-King Liquid Water Content
    abs_hum = ncread(ncfile,'RHODT'); %Absolute humidity g/m3
    cdplwc = ncread(ncfile,'PLWCD_LWOO');
    
    
    % Reformat time to human readable format
    % Given in netcdf file as seconds since 00:00:00 +0000 of flight date
    time2 = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(time(:,1));
    
    parentFolder = "/home/simulations/Field_Projects/Updraft_Analysis/SPICULE";  
    passFolder = "/home/simulations/Field_Projects/Updraft_Analysis/SPICULE/"+flightnumber; 
    
    % Check each cloudpass
    % Plot snapshot of cdp dsd, lwc, and vertical wind
    % ask user if they want to keep or reject the cloudpass
    % If the user keeps cloudpass, create a new directory, save snapshots
    % to the directory, write aircraft data to a csv file
    
    Bin = 13; % lower limit bin index
    Conc_threshold = 50.0; % #/cc/um
    
    summary = table('Size',[0 16],...
                        'VariableTypes',{'datetime','datetime','int8','double','double','double', 'double', 'double','double','double','double', 'double', 'double', 'double', 'string', 'string'},...
                        'VariableNames', ["StartTime", "EndTime", "Duration_s", "AverageLWC_g_m3", "Average_meanDiam","AverageLat", "AverageLon", "AverageAlt", "AverageTemp", "MaxUpdraft", "MeanUpdraft", "AbsoluteHumidity", "MixingRatio", "StaticPres_hPa", "InCloud_Flag", "HoloData_Flag"]);
    
       
    for p = 1 : length(i)
   
        starttime = utc{p}(1) - seconds(2);
        endtime = utc{p}(end) + seconds(2);
        logicalIndexes = (time2 <= endtime) & (time2 >= starttime);
        conc_array = conc2(:, logicalIndexes);
        % Identify how many large droplets exist that would be in Holodec
        % measurement range
        large_conc_array = conc2(Bin:end, logicalIndexes);
        small_conc_array = conc2(1:Bin-1, logicalIndexes);
        % create vector that is the integral of laerge and small for each timestep
        large_conc = sum(large_conc_array);
        small_conc =sum(small_conc_array);

         % Save cloudpass
         date_txt = string(starttime, 'yyyy-MM-dd-HH-mm-ss') + '_' + string(endtime, 'yyyy-MM-dd-HH-mm-ss');
         passname = flightnumber + "_" + date_txt;
         if mean(large_conc) >= Conc_threshold;
             holodec = "Yes";
         else
             holodec = "No";
         end
         
         if mean(kinglwc(logicalIndexes)) >= 0.1;
             in_cloud = "Yes";
         else
             in_cloud = "No";
         end


         % average mean diameter
         avg_diam = mean(meandiam(i{p}(1):i{p}(end)));
         % average total LWC
         avg_lwc = mean(kinglwc(i{p}(1):i{p}(end)));
         avg_lat = mean(lat(i{p}(1):i{p}(end)));
         avg_lon = mean(lon(i{p}(1):i{p}(end)));
         avg_alt = mean(alt(i{p}(1):i{p}(end)));
         avg_temp = mean(temp(i{p}(1):i{p}(end)));
         max_updraft = max(vwind(i{p}(1):i{p}(end)));
         avg_updraft = mean(vwind(i{p}(1):i{p}(end)));
         avg_hum = mean(abs_hum(i{p}(1):i{p}(end)));
         avg_mr = mean(mr(i{p}(1):i{p}(end)));
         avg_pres = mean(psxc(i{p}(1):i{p}(end)));
         
         
         pass = {utc{p}(1), utc{p}(2), length(i{p}), avg_lwc, avg_diam, avg_lat, avg_lon, avg_alt, avg_temp, max_updraft, avg_updraft, avg_hum, avg_mr, avg_pres, in_cloud, holodec};
         summary = [summary;pass];
 
         
    end
    summary_filename = fullfile(parentFolder, sprintf('%s_summary.csv', flightnumber));
    writetable(summary, summary_filename);
    
end