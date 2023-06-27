function out = holodec_vs_cdp_allpasses()

% then perform cdp holodec intercomparison, save figures

nc_path = '/home/simulations/Field_Projects/SPICULE/Data/LRT_Aircraft_2.1';
quicklook_path = '/home/simulations/Field_Projects/Updraft_Analysis/SPICULE';
output_path = '/home/simulations/Field_Projects/Updraft_Analysis/SPICULE/Microphysics_Analysis';


regions = dir(fullfile(quicklook_path, 'RF*_Region*'));

for r=1:length(regions)
    
    region = regions(r).name;
    flightnumber = split(region, "_");
    flightnumber = flightnumber{1};
    passes = dir(fullfile(quicklook_path, region, 'holoquicklook_*.mat'));
    
    for p=1:length(passes)
        
        % compare cdp and holodec!
        quicklookfile = fullfile(quicklook_path, region, passes(p).name);
        holodec_vs_cdp(quicklookfile, flightnumber, fullfile(output_path, region));
        
    end


end

