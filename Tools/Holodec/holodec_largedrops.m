function [holo_SIZE, cdp_SIZE] = holodec_largedrops(quicklookfile, flightnum, outputdir)

% output list per cloudpass
% holodec 90th percentile
% cdp 90th percentile


% return bin centers and number of particles in the bin
% separate plots:
% limit cdp to size bins larger than 13.5 um
% bin holodec with same size bins as cdp
%
% difference plot
% turn holodec to 1 hz
% match up time stamps with cdp data
% subtract values
% plot difference

% cdp netcdf location
nc_path = '/home/simulations/Field_Projects/SPICULE/Data/LRT_Aircraft_2.1';
flight_nc = dir(fullfile(nc_path, sprintf('%s.*.nc', flightnum)));
ncfile = fullfile(nc_path, flight_nc.name);
flightdate = ncreadatt(ncfile, '/', 'FlightDate');
time_ref = split(flightdate, "/");

vwind = ncread(ncfile,'WIC'); %Vertical windspeed derived from Rosemount 858 airdata probe located on the starboard pylon, in units of metres per second


quicklook = load(quicklookfile); % loaded structure
diameters = quicklook.ans.majsiz;
totalN = length(diameters);


% numbins = numberofbins;
% Dcenters = [];
% N = [];


% Find total sample volume of all holograms combined
N_holograms = length(quicklook.ans.counts);
holotimes = datetime(quicklook.ans.time,'ConvertFrom','datenum', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
holotimes = sortrows(holotimes);
dy = 0.28; %cm
dx = 1.44; %cm
dz = 13; %cm
sample_volume = dy*dx*dz; %cubic cm


% Get CDP data and bin sizes
starttime = holotimes(1);
endtime = holotimes(end);

cdptime = ncread(ncfile,'Time');
cdp_conc = ncread(ncfile, 'CCDP_LWOO');
all_edges = ncreadatt(ncfile, 'CCDP_LWOO', 'CellSizes');


% Reshape the concentration array into two dimensions
s = size(cdp_conc);
conc2 = reshape(cdp_conc, [s(1), s(3)]);
s2 = size(conc2);

cdptime = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(cdptime(:,1));
timeIndexes = (cdptime <= endtime) & (cdptime >= starttime);
%conc2(:,logicalIndexes))

% Limit the CDP to sizes larger than 10 um
% Define large droplet concentration threshold
% 9 = 10 um
% 13 = 15 um
% 15 = 19 um
bin_edges = all_edges(9:end);
bins = [];
for b = 1 : length(bin_edges)-1
    center = (bin_edges(b) + bin_edges(b+1))/2;
    bins = [bins; center];
end

cdp_contours = conc2(9:end,timeIndexes);


% divide holodec data into time series - rows are time, columns are
% concentration bins
% bin holodec data the same as CDP bins

holo_contours = zeros(length(bins),N_holograms);
N_time_table = [quicklook.ans.time, transpose(1:N_holograms)];
N_time_table = sortrows(N_time_table);
index_search = N_time_table(:,2);

for n=1 : N_holograms
    h = index_search(n);
    totalN = quicklook.ans.counts(h);
    indexes = (quicklook.ans.holonum == h);
    h_diameters = diameters(indexes);
    particlesinbin = zeros(length(bins),1);
    for i = 1:length(bin_edges)-1
          b1 = bin_edges(i)*10^-6; %convert from um to m
          b2 = bin_edges(i+1)*10^-6;
          Dsinbin = find(h_diameters>=b1 & h_diameters<b2); % b1 is the lower diameter
          particlesinbin(i) = length(Dsinbin); %this is the number of particle diameters that fell between the bin edges    
    end
    if totalN > 0 
        N = particlesinbin./totalN;
    else N = 0;
    end
    C = particlesinbin./sample_volume;
    holo_contours(:,n) = C;
        
end


% % Liquid Water content of Holodec and CDP
% Using density of water, and diameter, calculate LWZ in g/m^3
% Density of water
rho_liquid = 997 * 1e3 ; %gm/m^3

% Find the 90th percentile
% plot cdf and find index where cdf reaches 90%
holo_sum = sum(holo_contours, 2);
totalholo_sum = sum(holo_sum);
holo_CDF = [];
for p = 1:length(bins)
    c = sum(holo_sum(1:p));
    holo_CDF = [holo_CDF; c]; 
end
holo_P = find( holo_CDF./totalholo_sum > 0.90, 1 );
holo_SIZE = bins(holo_P);

cdp_sum = nansum(cdp_contours, 2);
totalcdp_sum = sum(cdp_sum);
cdp_CDF = [];
for p = 1:length(bins)
    c = nansum(cdp_sum(1:p));
    cdp_CDF = [cdp_CDF; c]; 
end
cdp_P = find( cdp_CDF./totalcdp_sum > 0.90, 1 );
cdp_SIZE = bins(cdp_P);

if ~isempty(cdp_SIZE) & ~isempty(holo_SIZE)

    fig = figure(1)
    semilogx(bins, cdp_CDF./totalcdp_sum, '-b', 'LineWidth',2.0, 'DisplayName', 'CDP')
    xline(cdp_SIZE,'--b','DisplayName','CDP 90 percentile');
    hold on
    semilogx(bins, holo_CDF./totalholo_sum,'-r', 'LineWidth',2.0, 'DisplayName', 'Holodec')
    xline(holo_SIZE,'--r','DisplayName','HOLODEC 90 percentile');
    ylabel('Cumulative Distribution Function');
    xlabel('Droplet size (\mu m)');
    grid on
    hold off
    legend
    
     date_txt = string(starttime, 'yyyy-MM-dd-HH-mm-ss') + '_' + string(endtime, 'yyyy-MM-dd-HH-mm-ss');
     passname = flightnum + "_" + date_txt;
     saveas(fig, sprintf('%s/HOLOvCDP_%s.png', outputdir, passname))
else
    disp(flightnum)

end


       

end



