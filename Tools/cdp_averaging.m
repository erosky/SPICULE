function out = cdp_averaging(ncfile, starttime, endtime)
    %Plot the DSD and droplet size PDF from a cloud segment averaged over a
    %given period of time. From CDP.
    
    %Get data from the netCDF file
    time = ncread(ncfile,'Time');
    conc = ncread(ncfile, 'CCDP_LWOO');
    binsizes = ncreadatt(ncfile, 'CCDP_LWOO', 'CellSizes');
    cdplwc = ncread(ncfile,'PLWCD_LWOO');
    meandiam = ncread(ncfile,'DBARD_LWOO');
    flightnumber = upper(ncreadatt(ncfile, '/', 'FlightNumber'));
    flightdate = ncreadatt(ncfile, '/', 'FlightDate');
    
    %Reshape the concentration array into two dimensions
    s = size(conc);
    conc2 = reshape(conc, [s(1), s(3)]);
    s2 = size(conc2);
    
   % select the flight segmennt of interest
   i_start = find(time==starttime);
   i_end = find(time==endtime);
   
   time_segment = time(i_start:i_end);
   conc_segment = conc2(:, i_start:i_end);
   
    conc_avg = mean(conc_segment, 2, 'omitnan')
    
    
    %Plot droplet size distribution in #/cc/um
    figure
    semilogy(binsizes,conc_avg), 
    xlabel('Diameter (microns)'), ylabel('Concentration (#/cc/micron)')
    title('DSD from SPICULE CDP')
    
    
%     %Make figure
%     figure(1);
%     tiledlayout(4,1);
%     ax1 = nexttile([2 1]);
%     
%     %Concentration contour
%     levels = 10.^(linspace(0,2,20));  %Log10 levels
%     contourf(time, binsizes, conc2, levels, 'LineStyle', 'none');
%     set(gca,'ColorScale','log');
%     grid on
% 
%     xlabel('Time (s)')
%     ylabel('Diameter (microns)');
%     c=colorbar;
%     set(gca,'ColorScale','log');
%     c.Label.String = 'Concentration (#/cc/um)';
%     title([flightnumber ' ' date]);
%     
%     %Mean Diameter
%     ax2 = nexttile;
%     plot(time, meandiam)
%     ylim([0 50])
%     xlabel('Time (s)')
%     ylabel('Dbar (microns)')
%     grid on
%     
%     %LWC
%     ax3 = nexttile;
%     plot(time, cdplwc)
%     ylim([0 2])
%     xlabel('Time (s)')
%     ylabel('LWC (g/m3)')
%     grid on
%     
%     %Link axes for panning and zooming
%     linkaxes([ax1, ax2, ax3],'x');
%     zoom xon;  %Zoom x-axis only
%     pan;  %Toggling pan twice seems to trigger desired behavior, not sure why
%     pan;
    
end