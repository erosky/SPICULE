%% Code for reading ncdf files from aircraft data %%
% Written by Susanne Glienke

% This code reads in various ncdf files from aircraft data. It has been
% used for CSET (2015), where CDP, 3V-CPI (2DS) and 2DC were deployed
% alongside HOLODEC. HOLODEC is not included here - this code was used
% together with raw HOLODEC data not yet in archivable format. All
% instruments listed below are saved in one ncdf file - if they are in
% different files, the filenames have to change between instruments. 

% For CSET, NCAR used a naming convention for the variables indicating the
% wing position. If the position is different, the variable names will be
% most likely, too. 

% To get an overview of the content of a NCDF file, explore the matlab
% commands "ncdisp" and "ncinfo" (not included below). 

% This code is copied from a more extensive code, so it may not be
% stand-alone - I did not test it by itself. 


time(1,:)=begintime;
time(2,:)=endtime;

%% CDP and other aircraft data

% getting data from CDP for comparison
cdp.dbard=ncread(filename_GV,'DBARD_LWOI');
cdp.concd=ncread(filename_GV,'CONCD_LWOI');
cdp.time_read=ncread(filename_GV,'Time');
cdp.time=datestr(double(cdp.time_read)/86400,'HH:MM:SS.FFF');
cdp.time_dn=datenum(cdp.time,'HH:MM:SS.FFF'); %datenum of cdp.time
cdp.plwcd=ncread(filename_GV,'PLWCD_LWOI');
cdp.sizedist=ncread(filename_GV,'CCDP_LWOI');
cdp.sizedist_a=ncread(filename_GV,'ACDP_LWOI');
cdp.disp=ncread(filename_GV,'DISPD_LWOI');

if exist('time','var')
    [~,i_time1]=ismember(time(1,:),cdp.time,'rows');
    [~,i_time2]=ismember(time(2,:),cdp.time,'rows');
    cdp.tperiod=i_time1:i_time2;
end

% aircraft measurements
gv.alt=ncread(filename_GV,'GGALT');
gv.atx=ncread(filename_GV,'ATX');
gv.dpxc=ncread(filename_GV,'DPXC');
gv.king.plwcc=ncread(filename_GV,'PLWCC');% liquid water content from King Probe
gv.wind_u=ncread(filename_GV,'UIC');% east wind
gv.wind_v=ncread(filename_GV,'VIC');% north wind
gv.wind_w=ncread(filename_GV,'WIC');% up wind


%2DC
twodc.sizedist=ncread(filename_GV,'C2DCR_LWOO')/1000; % in cm3
twodc.sizedist_a=ncread(filename_GV,'A2DCR_LWOO')/1000;
twodc.disp=ncread(filename_GV,'DISP2DCR_LWOO');
twodc.dbard=ncread(filename_GV,'DBAR2DCR_LWOO');
twodc.concd=ncread(filename_GV,'CONC2DCR_LWOO');
%2DC-ALL
twodc.a_sizedist=ncread(filename_GV,'C2DCA_LWOO')/1000; % in cm3


ncid = netcdf.open(filename_GV,'NC_NOWRITE');% Open netCDF file.
cdp.varid = netcdf.inqVarID(ncid,'CCDP_LWOI');% Get ID of variable.
cdp.bin = netcdf.getAtt(ncid,cdp.varid,'CellSizes');% Get value of attribute.
for i=1:length(cdp.bin)-1;
    cdp.bins(i)=(cdp.bin(i)+cdp.bin(i+1))/2;
end
twodc.varid = netcdf.inqVarID(ncid,'C2DCR_LWOO');
twodc.bin = netcdf.getAtt(ncid,twodc.varid,'CellSizes');
for i=1:length(twodc.bin)-1;
    twodc.bins(i)=(twodc.bin(i)+twodc.bin(i+1))/2;
end

%2D-S Horizontal
twods_h.str=[];
try
    ID = netcdf.inqVarID(ncid,'C2D3R_3H');
catch exception
    if strcmp(exception.identifier,'MATLAB:imagesci:netcdf:libraryFailure')
        twods_h.str = 'no 2DS';
        disp(twods_h.str);
    end
end


if ~strcmp('no 2DS',twods_h.str) %for RF10-11 no 2DS variable is found!
    twods_h.sizedist=ncread(filename_GV,'C2D3R_3H')/1000; % in cm3
    twods_h.varid = netcdf.inqVarID(ncid,'C2D3R_3H');
    twods_h.bin = netcdf.getAtt(ncid,twods_h.varid,'CellSizes');
    for i=1:length(twods_h.bin)-1;
        twods_h.bins(i)=(twods_h.bin(i)+twods_h.bin(i+1))/2;
    end
    twods_h.dbard=ncread(filename_GV,'DBAR2D3R_3H');
    twods_h.concd=ncread(filename_GV,'CONC2D3R_3H');
    
end
% calculating volume mean diameter for the cloud probes
% CDP
cdp.sizedist_t=permute(cdp.sizedist(2:end,1,cdp.tperiod),[1 3 2]);
cdp.sizedist_t_a=permute(cdp.sizedist_a(2:end,1,cdp.tperiod),[1 3 2]);
v_bins=(pi/6)*((cdp.bins).^3); %volume of each bin
v_g=1:length(cdp.tperiod); %preallocating
cdp.lwc=1:length(cdp.tperiod); %preallocating
for i_i = 1 : length(cdp.tperiod)
    
    v_g(i_i)=sum(cdp.sizedist_t(:,i_i)'.*v_bins); %total volume per second
    cdp.dbar(i_i)=((v_g(i_i)/cdp.concd(cdp.tperiod(i_i)))*6/pi)^(1/3); % mean diameter
    
    %     %LWC from CDP - curently wrong!
    cdp.lwc(i_i)=sum(cdp.sizedist_t(cdp.bins>10,i_i)'.*v_bins(cdp.bins>10))/(0.25*0.025*14000)/1e4; %total g/cm3 LWC per s
    %      cm3
    
    % if no drops, mean diameter = 0
    if cdp.concd(cdp.tperiod(i_i))==0
        cdp.dbar(i_i)=0;
    end
    
end
cdp.dbard(cdp.tperiod)=cdp.dbar;
clear v_bins; clear v_g;

% same for 2DC (and some for 2DC all)
twodc.sizedist_t=permute(twodc.sizedist(2:end,1,cdp.tperiod),[1 3 2]);
twodc.a_sizedist_t=permute(twodc.a_sizedist(2:end,1,cdp.tperiod),[1 3 2]);
twodc.sizedist_t_a=permute(twodc.sizedist_a(2:end,1,cdp.tperiod),[1 3 2]);

v_bins=(pi/6)*((twodc.bins).^3); %volume of each bin
v_g=1:length(cdp.tperiod);
for i_i = 1 : length(cdp.tperiod)
    
    v_g(i_i)=sum(twodc.sizedist_t(:,i_i)'.*v_bins); %total volume per second
    twodc.dbar(i_i)=((v_g(i_i)/twodc.concd(cdp.tperiod(i_i)))*6/pi)^(1/3); % mean diameter
    
    % if no drops, mean diameter = 0
    if twodc.concd(cdp.tperiod(i_i))==0
        twodc.dbar(i_i)=0;
    end
    
end
twodc.dbard(cdp.tperiod)=twodc.dbar*10;
clear v_bins; clear v_g;

% same for 2DS-H
if ~strcmp('no 2DS',twods_h.str)
    twods_h.sizedist_t=permute(twods_h.sizedist(2:end,1,cdp.tperiod),[1 3 2]);
    v_bins=(pi/6)*((twods_h.bins).^3); %volume of each bin
    v_g=1:length(cdp.tperiod);
    for i_i = 1 : length(cdp.tperiod)
        
        v_g(i_i)=sum(twods_h.sizedist_t(:,i_i)'.*v_bins); %total volume per second
        twods_h.dbar(i_i)=((v_g(i_i)/twods_h.concd(cdp.tperiod(i_i)))*6/pi)^(1/3); % mean diameter
        
        % if no drops, mean diameter = 0
        if twods_h.concd(cdp.tperiod(i_i))==0
            twods_h.dbar(i_i)=0;
        end
        
    end
    twods_h.dbard(cdp.tperiod)=twods_h.dbar;
    clear v_g;
    
end

%size dists
cdp.sizedist_tmean=nanmean(cdp.sizedist_t,2);% CDP
cdp.sizedist_tmean_a=nanmean(cdp.sizedist_t_a,2);% CDP
twodc.sizedist_tmean=nanmean(twodc.sizedist_t,2);% 2DC
twodc.sizedist_tmean_a=nanmean(twodc.sizedist_t_a,2);% 2 DC
twodc.a_sizedist_tmean=nanmean(twodc.a_sizedist_t,2);% 2DC ALL
if ~strcmp('no 2DS',twods_h.str)
    twods_h.sizedist_tmean=nanmean(twods_h.sizedist_t,2);% 2DS H
end
