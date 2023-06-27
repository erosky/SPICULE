function out = spicule_get_incloud_microphysics()
    % store microphysics data for in cloud passes
    % CDP
    % Future: hvps, 2dc, holodec
    
    Directory = "/home/simulations/Field_Projects/Updraft_Analysis/SPICULE";
    Regions = dir(fullfile(Directory, 'RF*_Region*'));
    
    % For each Region, enter InCloud folder
    % find timstamps and write cdp netcdf file into same folder
    
    for f = 1:length(Regions)
    % Open up the cloudpass file
        region_folder = fullfile(Regions(f).folder, Regions(f).name,'/InCloud');
        timestamps = readtable(fullfile(region_folder, 'timestamps.csv'));
        flight = split(Regions(f).name,"_");
        flight = flight{1};
        flight_nc = dir(fullfile('/home/simulations/Field_Projects/SPICULE/Data/LRT_Aircraft_2.1',sprintf('%s.*.nc',flight)));
        ncfile = fullfile(flight_nc.folder, flight_nc.name);
    
        time = ncread(ncfile,'Time');
        conc = ncread(ncfile, 'CCDP_LWOO');
        bin_edges = ncreadatt(ncfile, 'CCDP_LWOO', 'CellSizes');
        cdplwc = ncread(ncfile,'PLWCD_LWOO');
        effrad = ncread(ncfile,'REFFD_LWOO');
        totalconc = ncread(ncfile,'CONCD_LWOO');
        meandiam = ncread(ncfile,'DBARD_LWOO');
        flightnumber = upper(ncreadatt(ncfile, '/', 'FlightNumber'));
        flightdate = ncreadatt(ncfile, '/', 'FlightDate');
        time_ref = split(flightdate, "/");

        %Reshape the concentration array into two dimensions
        s = size(conc);
        conc2 = reshape(conc, [s(1), s(3)]);
        s2 = size(conc2);

        bins = [];
        for b = 1 : length(bin_edges)-1
            center = (bin_edges(b) + bin_edges(b+1))/2;
            bins = [bins; center];
        end
        bins;

        % Reformat time to human readable format
        % Given in netcdf file as seconds since 00:00:00 +0000 of flight date
        time2 = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(time(:,1));
        
        coincidence_data = table('Size',[0 4],...
                        'VariableTypes',{'datetime', 'datetime', 'double','double'},...
                        'VariableNames', ["StartTime", "EndTime", "SmallConc", "LargeConc"]);
        
        % for each cloudpass, create the cdp nc file
        for row = 1:height(timestamps)
            
            pass = timestamps(row,:);
            starttime = pass.StartTime - seconds(2);
            endtime = pass.EndTime + seconds(2);
            logicalIndexes = (time2 <= endtime) & (time2 >= starttime);

             % Save data
             % CDP data
             % timestamps, LWC, meandiam, effdiam, totalconc, binedges, bincenters, concentration
             date_txt = string(starttime, 'yyyy-MM-dd-HH-mm-ss') + '_' + string(endtime, 'yyyy-MM-dd-HH-mm-ss');
             passname = flightnumber + "_" + date_txt;
             cdpname = "cdp_" + passname + ".nc";
             cdpfile = fullfile(region_folder, cdpname);
%              if exist(cdpfile, 'file')==2
%                   delete(cdpfile);
%              end
%              if ~isfile(cdpfile)
%                  nccreate(cdpfile, 'time', "Dimensions", {"time", length(time2(logicalIndexes))}, "Format","classic" );
%                  ncwrite(cdpfile, 'time', datenum(time2(logicalIndexes)));
%                  nccreate(cdpfile, 'LWC', "Dimensions", {"time", length(time2(logicalIndexes))});
%                  ncwrite(cdpfile, 'LWC', cdplwc(logicalIndexes));
%                  nccreate(cdpfile, 'EffectiveDiameter', "Dimensions", {"time", length(time2(logicalIndexes))});
%                  ncwrite(cdpfile, 'EffectiveDiameter', effrad(logicalIndexes));
%                  nccreate(cdpfile, 'MeanDiameter', "Dimensions", {"time", length(time2(logicalIndexes))});
%                  ncwrite(cdpfile, 'MeanDiameter', meandiam(logicalIndexes));
%                  nccreate(cdpfile, 'TotalConc', "Dimensions", {"time", length(time2(logicalIndexes))});
%                  ncwrite(cdpfile, 'TotalConc', totalconc(logicalIndexes));
%                  nccreate(cdpfile, 'bins', "Dimensions", {"bins", 30});
%                  ncwrite(cdpfile, 'bins', bins);
%                  nccreate(cdpfile, 'bin_edges', "Dimensions", {"bin_edges", 31});
%                  ncwrite(cdpfile, 'bin_edges', bin_edges);
%                  nccreate(cdpfile, 'PSD', "Dimensions", {"time", length(time2(logicalIndexes)), "bins", 30});
%                  ncwrite(cdpfile, 'PSD', transpose(conc2(:,logicalIndexes)));
%              end
             
             conc_array = conc2(:, logicalIndexes);
             large_conc_array = conc2(13:end, logicalIndexes);
             small_conc_array = conc2(1:13-1, logicalIndexes);
             % create vector that is the integral of laerge and small for each timestep
             large_conc = sum(large_conc_array);
             small_conc =sum(small_conc_array);
             coincidence = {starttime, endtime, mean(small_conc), mean(large_conc)};
             coincidence_data = [coincidence_data; coincidence];
             
        end
       
       writetable(coincidence_data, fullfile(region_folder, 'coincidence_conc.csv'), 'WriteMode','overwrite'); 
    end
end