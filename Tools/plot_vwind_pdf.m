function out = plot_vwind_pdf(cloudpassfolder)
    % find each aircraft data file in folder
    % plot a PDF of vertical wind speed, title the plot with timestamps
    
    % get list of filenames to read
    Folder = cloudpassfolder;
    Files = dir(fullfile(Folder, 'aircraft*.csv'));
    Names = {Files.name};

    low_v = -10;
    high_v = 20;
    edges = low_v:1:high_v;
    
    for f = 1:length(Files)
        % Open up the cloudpass file
        pass = readtable(fullfile(Files(f).folder, Files(f).name));
        time = pass.Time;
        temp = mean(pass.Temperature);
        vwind = pass.VerticalWind;
 
        PDF = histcounts(vwind, edges, 'Normalization', 'pdf');
        CDF = [];
        centers = [];
        for p = 2:length(edges)-1
            c = sum(PDF(1:p));
            CDF = [CDF; c]; 
            v = (edges(p-1) + edges(p))/2;
            centers = [centers, v];
        end
        
        if ~ sum(isnan(vwind)) > 0
            fig = figure(1);
            histogram(vwind, edges, 'Normalization', 'pdf')
            %plot(centers, CDF)
            hold on
            xlabel('Vertical windspeed (m/s)')
            grid on
            

            
        end
    end
%     
end