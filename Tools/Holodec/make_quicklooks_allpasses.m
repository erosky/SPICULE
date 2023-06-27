function out = make_quicklooks_allpasses();

% for every region in histmat folder, make a quicklook and store somewhere
% then perform cdp holodec intercomparison, save figures

histmat_path = '/media/simulations/My Passport/SPICULE/HPC_files/SPICULE_histmat';
quicklook_path = '/home/simulations/Field_Projects/Updraft_Analysis/SPICULE';

recons = dir(fullfile(histmat_path, 'RF*_Region*'));

for q=1:length(recons)
    
    region = recons(q).name
    flightnumber = split(region, "_");
    flightnumber = flightnumber{1};
    passes = dir(fullfile(histmat_path, region));
    passes = passes([passes.isdir]);
    passes = passes(~ismember({passes(:).name},{'.','..'}));
    
    for p=1:length(passes)
        
        % Make quicklook file
        pathtohistmat = fullfile(histmat_path, region, passes(p).name);
        ans = makeQuicklookFromHistFolder_spicule(pathtohistmat)
        
        if ~isempty(ans.time)
            holotimes = datetime(ans.time,'ConvertFrom','datenum', 'Format', 'yyyy-MM-dd HH:mm:ss');
            holotimes = sortrows(holotimes);
            starttime = holotimes(1);
            endtime = holotimes(end);

            % Save quicklook file
            date_txt = string(starttime, 'yyyy-MM-dd-HH-mm-ss') + '_' + string(endtime, 'yyyy-MM-dd-HH-mm-ss');
            passname = flightnumber + "_" + date_txt;
            outputfile = fullfile(quicklook_path, region, sprintf('holoquicklook_%s.mat', passname))
            save(outputfile, "ans"); 
        end
        
        
    end


end
