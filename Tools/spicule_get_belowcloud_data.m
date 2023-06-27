function out = spicule_get_belowcloud_data(region, flightnumber)
    % Prepare all the data for below cloudbase
    
    directory = fullfile('/home/simulations/Field_Projects/Updraft_Analysis/SPICULE/',region);
    nc_path = '/home/simulations/Field_Projects/SPICULE/Data/LRT_Aircraft_2.1';
    flight_nc = dir(fullfile(nc_path, sprintf('%s.*.nc', flightnumber)));
    ncfile = fullfile(nc_path, flight_nc.name);
    
    folder = fullfile(directory, '/BelowCloud');
    timestamps = readtable(fullfile(folder, 'timestamps.csv'));

    %Get data from the netCDF file
    time = ncread(ncfile,'Time');
    flightnumber = upper(ncreadatt(ncfile, '/', 'FlightNumber'));
    flightdate = ncreadatt(ncfile, '/', 'FlightDate');
    time_ref = split(flightdate, "/");
   
    % variables
    temp = ncread(ncfile,'ATX'); % 'Ambient Temperature, Reference', in units of degrees Celsius
    vwind = ncread(ncfile,'WIC'); %Vertical windspeed derived from Rosemount 858 airdata probe located on the starboard pylon, in units of metres per second
    alt = ncread(ncfile,'GGALT'); %'Reference GPS Altitude (MSL) (m)' 
    lat = ncread(ncfile,'LAT');
    lon = ncread(ncfile,'LON');
    dpt = ncread(ncfile,'DPXC'); % dewpoint temp
    mr = ncread(ncfile,'MR'); % mixing ratio
    psxc = ncread(ncfile,'PSXC'); % mixing ratio dependency (corrected static pressure)
    ewx = ncread(ncfile,'EWX'); % mixing ratio dependency (ambient water vapor pressure)
    abs_hum = ncread(ncfile,'RHODT'); %Absolute humidity g/m3
    concn = ncread(ncfile,'CONCN'); % Condensation Nuclei (CN) Concentration (#/cm3)
    
    
    % Reformat time to human readable format
    % Given in netcdf file as seconds since 00:00:00 +0000 of flight date
    time2 = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(time(:,1));
    
    summary = table('Size',[0 16],...
                        'VariableTypes',{'datetime','datetime','double','double','double', 'double','double', 'double', 'double','double','double','double', 'double', 'double', 'double', 'double'},...
                        'VariableNames', ["StartTime", "EndTime", "Duration_s", "Average_CN", "AverageAlt", "AverageTemp", "MaxUpdraft", "MeanUpdraft", "AbsoluteHumidity", "MixingRatio", "VaporPressure", "SaturationPessure", "SaturationMixingRatio", "StaticPres_hPa", "SpecificHeatCapacity", "MoistStaticEnergy"]);
    size(timestamps)
       
    for p = 1 : size(timestamps)
        
        disp(p)
   
        starttime = timestamps.StartTime(p) - seconds(2);
        endtime = timestamps.EndTime(p) + seconds(2);
        startcore = timestamps.StartTime(p)
        endcore = timestamps.EndTime(p)
        timeIndexes = (time2 <= endtime) & (time2 >= starttime);
        coreIndexes = (time2 <= endcore) & (time2 >= startcore);
        duration = seconds(endcore-startcore);

         % Save cloudpass
         date_txt = string(startcore, 'yyyy-MM-dd-HH-mm-ss') + '_' + string(endcore, 'yyyy-MM-dd-HH-mm-ss');
         passname = flightnumber + "_" + date_txt;


         
         % Save data

         % Thermodynamic data csv 
         % timestamp, CN, alt, temp, vwind, lat, lon, humidity,
         % mixingratio, vaporpressure, saturationpressure, staticpressure,
         % specificheat, moiststaticenergy
         output_data = table('Size', [length(time2(timeIndexes)) 0]);
         output_data.Time = time2(timeIndexes);
         output_data.Altitude = alt(timeIndexes);
         output_data.Latitude = lat(timeIndexes);
         output_data.Longitude = lon(timeIndexes);
         output_data.VerticalWind = vwind(timeIndexes);
         output_data.Temperature = temp(timeIndexes); 
         output_data.StaticPres = psxc(timeIndexes);
         output_data.DewPoint = dpt(timeIndexes);
         output_data.MixingRatio = mr(timeIndexes);
         output_data.absHumidity = abs_hum(timeIndexes);
         output_data.vapPres = ewx(timeIndexes);
         output_data.ConcCN = concn(timeIndexes);
             
         
         % Compute below cloud values:
         % specific heat capacity
         % moist static energy 
         % saturation vapor pressure

         latent_heat = 2.501e6; % J/kg
         g = 9.8; %m/s
         avg_MR = mean(mr(coreIndexes));
         c_p = 1005.7 + 1820.0*avg_MR./1000; %J/kg*K
         sat_pres = [];
         
         for t = 1 : length(output_data.Temperature)
             T = output_data.Temperature(t);
             p_s = e_saturation(T, 'liquid');
             sat_pres = [sat_pres; p_s];
         end
         
         sat_mr = 622.0.*output_data.vapPres./(output_data.StaticPres-output_data.vapPres) %g/kg
         
         mse = c_p.*output_data.Temperature + g.*output_data.Altitude + latent_heat.*output_data.MixingRatio./1000; %J/kg
         
         output_data.SatVapPres = sat_pres;
         output_data.MoistStaticEnergy = mse;
         output_data.SatMixingRatio = sat_mr;
         
         

         output_filename = fullfile(folder, sprintf('thermodynamics_%s.csv', passname));
         writetable(output_data, output_filename,'WriteMode','overwrite');

         % Compute averages for the summary
         avg_cn = nanmean(concn(coreIndexes));
         avg_alt = mean(alt(coreIndexes));
         avg_temp = mean(temp(coreIndexes));
         max_updraft = max(vwind(coreIndexes));
         avg_updraft = mean(vwind(coreIndexes));
         avg_hum = mean(abs_hum(coreIndexes));
         avg_vap_pres = mean(ewx(coreIndexes));
         avg_pres = mean(psxc(coreIndexes));
         
         sat_pres_core = [];
         t_core = temp(coreIndexes);
         p_core = psxc(coreIndexes);
         
         for t = 1 : length(t_core)
             T = t_core(t);
             p_s = e_saturation(T, 'liquid');
             sat_pres_core = [sat_pres_core; p_s];
         end
         
         sat_mr_core = 622.0.*sat_pres_core./(p_core-sat_pres_core); %g/kg
         
         mse_core = c_p.*t_core + g.*alt(coreIndexes) + latent_heat.*mr(coreIndexes)./1000; %J/kg    
         
         avg_p_sat = max(sat_pres_core);
         avg_satmr = mean(sat_mr_core);
         avg_mse = mean(mse_core);
         
         pass = {startcore, endcore, duration, avg_cn, avg_alt, avg_temp, max_updraft, avg_updraft, avg_hum, avg_MR, avg_vap_pres, avg_p_sat, avg_satmr, avg_pres, c_p, avg_mse};
         summary = [summary;pass];
 
         
    end
    summary_filename = fullfile(folder, 'belowcloud_summary.csv');
    writetable(summary, summary_filename,'WriteMode','overwrite');
    
end