function out = holodec_largedrops_allpasses()

% then perform cdp holodec intercomparison, save figures

nc_path = '/home/simulations/Field_Projects/SPICULE/Data/LRT_Aircraft_2.1';
quicklook_path = '/home/simulations/Field_Projects/Updraft_Analysis/SPICULE';
output_path = '/home/simulations/Field_Projects/Updraft_Analysis/SPICULE/Microphysics_Analysis/AllPasses';

regions = dir(fullfile(quicklook_path, 'RF*_Region*'));

                    
for r=1:length(regions)
    
    region = regions(r).name;
    flightnumber = split(region, "_");
    flightnumber = flightnumber{1};
    passes = dir(fullfile(quicklook_path, region, 'holoquicklook_*.mat'));
    
    datafile = fullfile('/home/simulations/Field_Projects/Updraft_Analysis/SPICULE/', region, 'droplets_90percentile.csv');
    output_data = table('Size',[0 3],...
                        'VariableTypes',{'string','double','double'},...
                        'VariableNames', ["Region", "HoloSize", "CDPSize"]);
    
    for p=1:length(passes)
        
        % compare cdp and holodec!
        quicklookfile = fullfile(quicklook_path, region, passes(p).name);
        [holo_SIZE, cdp_SIZE] = holodec_largedrops(quicklookfile, flightnumber, output_path);
        if ~isempty(cdp_SIZE) & ~isempty(holo_SIZE)
            data = {region, holo_SIZE, cdp_SIZE};
            output_data = [output_data; data];
        end
    end
    
    writetable(output_data, datafile, 'WriteMode','overwrite');


end

end
