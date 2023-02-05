function [Dcenters, N] = pdf_test(quicklookfile, numberofbins);
% return bin centers and number of particles in the bin

quicklook = load(quicklookfile); % loaded structure
diameters = quicklook.pd_out.eqDiam;
totalN = length(diameters);


numbins = numberofbins;
Dcenters = [];
N = [];


% Find total sample volume of all holograms combined
samples = length(quicklook.pd_out.counts)
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

figure
semilogx(Dcenters.*1000000,N), 
xlabel('Diameter (microns)'), ylabel('Probability (Nbin/Ntotal)')
title('PDF from SPICULE Holodec')


%Plot droplet size distribution in #/cc/um
figure
semilogy(Dcenters.*1000000,C), 
xlabel('Diameter (microns)'), ylabel('Concentration (#/cc/micron)')
title('DSD from SPICULE Holodec')







