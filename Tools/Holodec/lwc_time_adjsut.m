function out = lwc_time_adjust(flightnum, quicklookfile)
    %Plot a time series of CDP DSDs from SPICULE
    
    nc_path = '/home/simulations/Field_Projects/SPICULE/Data/LRT_Aircraft_2.1';
    flight_nc = dir(fullfile(nc_path, sprintf('%s.*.nc', flightnum)));
    ncfile = fullfile(nc_path, flight_nc.name);
    flightdate = ncreadatt(ncfile, '/', 'FlightDate');
    time_ref = split(flightdate, "/");

    quicklook = load(quicklookfile); % loaded structure
    diameters = quicklook.ans.majsiz;
    totalN = length(diameters);
    
    
    
    %Get data from the netCDF file
    time = ncread(ncfile,'Time');
    cdplwc = ncread(ncfile,'PLWCD_LWOO');
    kinglwc = ncread(ncfile,'PLWCC');
    
    nctime = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(time(:,1));
    
    
    % Using density of water, and diameter, calculate LWZ in g/m^3
    % Density of water
    rho_liquid = 997 * 1e3 ; %gm/m^3
    

    %Make figure
    figure(1);
    
    plot(time, cdplwc)
    ylim([0 2])
    datetick('x')
    xlabel('Time (s)')
    ylabel('LWC (g/m3)')
    grid on
    
    zoom xon;  %Zoom x-axis only
    pan;  %Toggling pan twice seems to trigger desired behavior, not sure why
    pan;
    
end