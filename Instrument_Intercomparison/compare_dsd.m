function out = compare_dsd(quicklookfile, numberofbins, ncfile, starttime, endtime);
    % plot dsd for both holodec and cdp on same plot


    % Holodec Data
    quicklook = load(quicklookfile); % loaded structure
    diameters = quicklook.ans.eqDiam;
    totalN = length(diameters);

    numbins = numberofbins;
    Dcenters = [];
    N = [];

    % Find total sample volume of all holograms combined
    samples = length(quicklook.ans.counts)
    sample_volume = 20; %cubic cm
    volume = samples*sample_volume

    Dedges = zeros(numbins+1,1); Dedges(1) = min(diameters); Dedges(end) = max(diameters);
    dD = Dedges(end) - Dedges(1);
    increment = dD/numbins;
    for i = 1:numbins
        Dedges(i+1) = Dedges(i) + increment;
        Dcenters(i) = Dedges(i) + increment/2;
    end

    %now go through and find particles
    particlesinbin = zeros(numbins,1);
    for i = 1:numbins
        Dsinbin = find(diameters>=Dedges(i) & diameters<Dedges(i+1)); %Dedges(i) is the lower diameter
        particlesinbin(i) = length(Dsinbin); %this is the number of particle diameters that fell between the bin edges    
    end

    N = particlesinbin./totalN;
    C = particlesinbin./volume;

    % figure
    % semilogx(Dcenters.*1000000,N), 
    % xlabel('Diameter (microns)'), ylabel('Probability (Nbin/Ntotal)')
    % title('PDF from SPICULE Holodec')


    %Plot droplet size distribution in #/cc/um
    % figure
    % semilogy(Dcenters.*1000000,C), 
    % xlabel('Diameter (microns)'), ylabel('Concentration (#/cc/micron)')
    % title('DSD from SPICULE Holodec')


    % CDP
    
    %Get data from the netCDF file
    time = ncread(ncfile,'Time');
    conc = ncread(ncfile, 'CCDP_LWOO');
    binsizes = ncreadatt(ncfile, 'CCDP_LWOO', 'CellSizes')
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
   semilogy(binsizes, conc_avg, 'g', Dcenters.*1000000, C, 'b'), legend('CDP', 'Holodec')  
   xlabel('Diameter (microns)'), ylabel('Concentration (#/cc/micron)')
   title('DSD from SPICULE, CDP & Holodec')
   grid on
    
    
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
