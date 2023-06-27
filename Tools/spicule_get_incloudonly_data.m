 function out = spicule_get_incloud_data(directory, ncfile)
    % Prepare all the data for below cloudbase
    
    
    folder = fullfile(directory, '/InCloud');
    timestamps = readtable(fullfile(folder, 'timestamps.csv'));
    regionproperties = readtable(fullfile(directory, 'region_properties.csv'));
    
    % Get cloudbase properties
    cb_height = regionproperties.CloudBase_m;

    %Get data from the netCDF file
    time = ncread(ncfile,'Time');
    meandiam = ncread(ncfile,'DBARD_LWOO');
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
    lwc_cdp = ncread(ncfile,'PLWCD_LWOO');
    lwc_king = ncread(ncfile,'PLWCC');
    lwc_2dc = ncread(ncfile,'PLWC2DCR_RWOO'); % Fast 2DC Liquid Water Content, Round Particles (g m-3)
    effrad_cdp = ncread(ncfile,'REFFD_LWOO'); % CDP Effective Radius (um)
    effrac_2dc = ncread(ncfile,'REFF2DCR_RWOO'); % Fast 2DC Effective Radius, Round Particles (um)
    totalconc_2dc = ncread(ncfile,'CONC2DCR_RWOO'); % Total Fast 2DC Concentration, Round Particles' (#/L)
    totalconc_cdp = ncread(ncfile,'CONCD_LWOO'); % CDP Concentration (all cells) (#/cm3)
    icing = ncread(ncfile,'RICE'); % Raw Icing-Rate Indicator
    
    
    
    % Reformat time to human readable format
    % Given in netcdf file as seconds since 00:00:00 +0000 of flight date
    time2 = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(time(:,1));
    
    % {startcore, endcore, duration, avg_lwc_cdp, avg_lwc_king, avg_lwc_2dc, 
    %  avg_totalconc_cdp, avg_totalconc_2dc, avg_effrad_cdp, avg_effrad_2dc, 
    %  avg_alt, avg_temp, max_updraft, avg_updraft, height_abv_cb_core,
    %  temp_change_core, avg_hum, calc_hum_king_core, avg_MR, avg_vap_pres, 
    %  avg_p_sat, avg_satmr, avg_pres, air_density_core, mr_change_core, lwc_over_density_core, avg_mse}
    
    summary = table('Size',[0 25],...
                        'VariableTypes',{'datetime','datetime','double','double','double', 'double', 'double','double','double','double', 'double', 'double', 'double', 'double', 'double', 'double','double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double'},...
                        'VariableNames', ["StartTime", "EndTime", "Duration_s", "LWC_cdp", "LWC_king", "LWC_2dc",... 
                                          "TotalConc_cdp_cm3", "TotalConc_2dc_L", "EffRad_cdp", "EffRad_2dc",...
                                          "AverageAlt", "AverageTemp", "MaxUpdraft", "MeanUpdraft", "HeightAboveCB",... 
                                          "AbsoluteHumidity", "MixingRatio", "VaporPressure",... 
                                          "SaturationPessure", "SaturationMixingRatio", "StaticPres_hPa", "DryAirDensity", "LWC_over_density", "SpecificHeatCapacity", "MoistStaticEnergy"]);
    size(timestamps)
       
    for p = 1 : size(timestamps)
        
        disp(p)
   
        starttime = timestamps.StartTime(p) - seconds(2);
        endtime = timestamps.EndTime(p) + seconds(2);
        startcore = timestamps.StartTime(p);
        endcore = timestamps.EndTime(p);
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
         output_data.LWC_cdp = lwc_cdp(timeIndexes);
         output_data.LWC_king = lwc_king(timeIndexes);
         output_data.LWC_2dc = lwc_2dc(timeIndexes);
         output_data.EffRadius_cdp = effrad_cdp(timeIndexes);
         output_data.EffRadius_2dc = effrac_2dc(timeIndexes);
         output_data.TotalConc_2dc_L = totalconc_2dc(timeIndexes);
         output_data.TotalConc_cdp_cm3 = totalconc_cdp(timeIndexes);
         output_data.Icing = icing(timeIndexes);
             
         
         % Compute below cloud values:
         % specific heat capacity
         % moist static energy 
         % saturation vapor pressure

         latent_heat = 2.501e6; % J/kg
         g = 9.8; %m/s
         avg_MR = mean(mr(coreIndexes));
         sat_pres = [];
         
         for t = 1 : length(output_data.Temperature)
             T = output_data.Temperature(t);
             p_s = e_saturation(T, 'liquid');
             sat_pres = [sat_pres; p_s];
         end
         
         sat_mr = 622.0.*sat_pres./(output_data.StaticPres-sat_pres) %g/kg
         
         
        
         height_abv_cb = output_data.Altitude - cb_height;
         air_density = 100*output_data.StaticPres./(287*(output_data.Temperature + 273.15)); % kg/m3
         lwc_over_density = output_data.LWC_king./air_density; %g/kg
         
         heatcapacity = 1005.7 + 1820.0*(sat_mr+lwc_over_density)./1000 %J/kg*K
         mse = heatcapacity.*output_data.Temperature + g.*output_data.Altitude + latent_heat.*sat_mr./1000; %J/kg
        
         
         output_data.SatVapPres = sat_pres;
         output_data.SatMixingRatio = sat_mr;
         output_data.HeightAbvCloudBase = height_abv_cb;
         output_data.DryAirDensity = air_density;
         output_data.LWC_over_Density = lwc_over_density;
         output_data.SpecificHeatCapacity = heatcapacity;
         output_data.MoistStaticEnergy = mse;

         
        
         
         

         output_filename = fullfile(folder, sprintf('thermodynamics_%s.csv', passname));
         writetable(output_data, output_filename, 'WriteMode','overwrite');

         % Compute averages for the summary
         avg_alt = mean(alt(coreIndexes));
         avg_temp = mean(temp(coreIndexes));
         max_updraft = max(vwind(coreIndexes));
         avg_updraft = mean(vwind(coreIndexes));
         avg_hum = mean(abs_hum(coreIndexes));
         avg_vap_pres = mean(ewx(coreIndexes));
         avg_pres = mean(psxc(coreIndexes));
         avg_MR = mean(mr(coreIndexes));
         
         avg_lwc_cdp = mean(lwc_cdp(coreIndexes));
         avg_lwc_king = mean(lwc_king(coreIndexes));
         avg_lwc_2dc = mean(lwc_2dc(coreIndexes));
         avg_effrad_cdp = mean(effrad_cdp(coreIndexes));
         avg_effrad_2dc = mean(effrac_2dc(coreIndexes));
         avg_totalconc_2dc = mean(totalconc_2dc(coreIndexes));
         avg_totalconc_cdp = mean(totalconc_cdp(coreIndexes));
         
         
         sat_pres_core = [];
         t_core = temp(coreIndexes);
         p_core = psxc(coreIndexes);
         
         for t = 1 : length(t_core)
             T = t_core(t);
             p_s = e_saturation(T, 'liquid');
             sat_pres_core = [sat_pres_core; p_s];
         end
         
         sat_mr_core = 622.0.*sat_pres_core./(p_core-sat_pres_core); %g/kg 
  
         
         height_abv_cb_core = avg_alt - cb_height;
         air_density_core = mean(100*(p_core)./(287*(t_core+273.15))); % kg/m3
         lwc_over_density_core = mean(lwc_king(coreIndexes)./air_density_core); %g/kg
         
         heatcapacity_core = 1005.7 + 1820.0*(sat_mr_core+lwc_over_density_core)./1000 %J/kg*K
         mse_core = heatcapacity_core.*t_core + g.*alt(coreIndexes) + latent_heat.*sat_mr_core./1000; %J/kg
         
         avg_p_sat = max(sat_pres_core);
         avg_satmr = mean(sat_mr_core);
         avg_mse = mean(mse_core);
         avg_cp = mean(heatcapacity_core);
        
         
         pass = {startcore, endcore, duration, avg_lwc_cdp, avg_lwc_king, avg_lwc_2dc, avg_totalconc_cdp, avg_totalconc_2dc, avg_effrad_cdp, avg_effrad_2dc, avg_alt, avg_temp, max_updraft, avg_updraft, height_abv_cb_core,... 
                 avg_hum, avg_MR, avg_vap_pres, avg_p_sat, avg_satmr, avg_pres, air_density_core, lwc_over_density_core, avg_cp, avg_mse};
         summary = [summary;pass];
 
         
    end
    summary_filename = fullfile(folder, 'incloud_summary.csv');
    writetable(summary, summary_filename,'WriteMode','overwrite');
    
end