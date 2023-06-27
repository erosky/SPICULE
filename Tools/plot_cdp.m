function out = plot_cdp(ncfile)
    %Plot a time series of CDP DSDs from SPICULE
    
    %Get data from the netCDF file
    time = ncread(ncfile,'Time');
    conc = ncread(ncfile, 'CCDP_LWOO');
    binsizes = ncreadatt(ncfile, 'CCDP_LWOO', 'CellSizes');
    cdplwc = ncread(ncfile,'PLWCD_LWOO');
    meandiam = ncread(ncfile,'DBARD_LWOO');
    flightnumber = upper(ncreadatt(ncfile, '/', 'FlightNumber'));
    flightdate = ncreadatt(ncfile, '/', 'FlightDate');
    time_ref = split(flightdate, "/");
    
    time = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(time(:,1));

    
    %Reshape the concentration array into two dimensions
    s = size(conc)
    conc2 = reshape(conc, [s(1), s(3)]);
    s2 = size(conc2)
    
    function mypostcallback(obj,evd,AX)
        datetick('x', 'keeplimits'); % update dateticks on the 1st axis
    end
    
    %Make figure
    figure(1);
    tiledlayout(4,1);
    ax1 = nexttile([2 1]);
    
    %Concentration contour
    levels = 10.^(linspace(0,2,20));  %Log10 levels
    contourf(datenum(time), binsizes(1:end-1), conc2, levels, 'LineStyle', 'none');
    datetick('x');
    set(gca,'ColorScale','log');
    test = gca(); 
    test.XTick = linspace(test.XTick(1),test.XTick(end),1000); 
    grid on

    xlabel('Time (s)')
    ylabel('Diameter (microns)');
    c=colorbar;
    set(gca,'ColorScale','log');
    c.Label.String = 'Concentration (#/cc/um)';
    title([flightnumber ' ' date]);
    
    %Mean Diameter
%     ax2 = nexttile;
%     plot(datenum(time), meandiam)
%     datetick('x')
%     ylim([0 50])
%     xlabel('Time (s)')
%     ylabel('Dbar (microns)')
%     grid on
%     
%     %LWC
%     ax3 = nexttile;
%     plot(datenum(time), cdplwc)
%     datetick('x')
%     ylim([0 2])
%     xlabel('Time (s)')
%     ylabel('LWC (g/m3)')
%     grid on
    
    %Link axes for panning and zooming
    linkaxes([ax1, ax2, ax3],'x');
    zoom xon;  %Zoom x-axis only
    pan;  %Toggling pan twice seems to trigger desired behavior, not sure why
    pan;
    
end