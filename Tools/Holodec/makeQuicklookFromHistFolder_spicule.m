function pd_out = makeQuicklookFromHistFolder_spicule(pathtohistmat)
% Function to make quicklooks from a series of reconstructed holograms
% We apply some rules to get a reasonable quicklook

t = dir(fullfile(pathtohistmat,'*hist.mat'))

% Rules
art = 1.5; % Aspect ratio less than - For liquid droplets
utt = 0.1; % Underthresh greater than
dsqth = 2; % Threshold for dsqoverlz less than
phflip = 2; %Phase flip greater than
zmin = 0.015;
zmax = 0.145;
ythresh = 2e-3; %y position greater than

xpos = [];
ypos = [];
zpos = [];
majsiz = [];
minsiz = [];
area = [];
holonum = [];
hn2 = [];
%pIm = cell(0);
time = zeros(size(t));

% This date format is correct for ACE-ENA. For other data it needs to be
% adapted
for cnt = 1:length(t)
   tmp = t(cnt).name;
   %tmp = tmp(13:end);
   D = split(tmp, {'-','_'});
   D(7) = pad(D(7),6,'right','0');
   S = sprintf('%s*', D{1:7});
   Num = sscanf(S, '%g*');
   yr = Num(1);
   mt = Num(2);
   dy = Num(3);
   hr = Num(4);
   mn = Num(5);
   sc = Num(6) + (1e-6)*Num(7)
   time(cnt) = datenum(yr,mt,dy,hr,mn,sc);
end


uS = etd(clock,1,length(t),60);
for cnt = 1:length(t)
    try
    test = fullfile(pathtohistmat,t(cnt).name);
    s1 = load(test);
    if isfield(s1,'pd') && ~isempty(s1.pd.getmetric('xpos'))
         if ~exist('dz','var')
             dz = diff(s1.pd.zs(1:2));
         end
        %read in variables
        xpos_in=s1.pd.getmetric('xpos');
        ypos_in=s1.pd.getmetric('ypos');
        zpos_in=s1.pd.getmetric('zpos');
        asprat_in=s1.pd.getmetric('asprat');
        underthresh_in=s1.pd.getmetric('underthresh');
        minsiz_in=s1.pd.getmetric('minsiz');
        majsiz_in=s1.pd.getmetric('majsiz');
        area_in=s1.pd.getmetric('area');
        numzs_in=s1.pd.getmetric('numzs');
        dsqoverlz_in=s1.pd.getmetric('dsqoverlz');
        %dsqoverlz_in = (minsiz_in.*majsiz_in)./(numzs_in*355e-9*dz);
        phfl_in=s1.pd.getmetric('phfl');

        ind=(asprat_in<art & underthresh_in>utt & zpos_in>zmin & zpos_in<zmax & dsqoverlz_in<dsqth & phfl_in>phflip & ypos_in>ythresh);

       if ~isempty(ind)
            xpos = [xpos;xpos_in(ind)];
            ypos = [ypos;ypos_in(ind)];
            zpos = [zpos;zpos_in(ind)];
            majsiz = [majsiz;majsiz_in(ind)];
            minsiz = [minsiz;minsiz_in(ind)];
            area = [area;area_in(ind)];
            holonum = [holonum;ones(size(xpos_in(ind)))*cnt];
%              if ~isempty(ind3)
%                  hn2 = [hn2;cnt*ones(size(xpos_in(ind3)))];
%                  pIm(end+1:end+length(ind3)) = s1.pStats.prtclIm(ind3);
%              end
       end
    end
    uS = etd(uS,cnt);
    catch
       warning(['Could not open ',t(cnt).name]);
    end
end

eqDiam = sqrt(4/pi.*area);
counts = zeros(size(t));
meanDiam = nan(size(counts));
meanVolDiam = nan(size(counts));

for cnt = 1:length(t)
    idx = find(holonum == cnt);
    counts(cnt) = nnz(idx);
    if ~isempty(idx)
    meanDiam(cnt) = mean(eqDiam(idx));
    meanVolDiam(cnt) = nthroot(mean(eqDiam(idx).^3),3);
    end
end


pd_out.xpos = xpos;
pd_out.ypos = ypos;
pd_out.zpos = zpos;
pd_out.majsiz = majsiz;
pd_out.minsiz = minsiz;
pd_out.area = area;
pd_out.eqDiam = eqDiam;
pd_out.holonum = holonum;
pd_out.counts = counts;
pd_out.meanDiam = meanDiam;
pd_out.meanVolDiam = meanVolDiam;
pd_out.time = time;
% pd_out.hn2 = hn2;
% pd_out.prtclIm = pIm;
% 
%  zs = [6:1:160]*1e-3;
%  xs = [-s1.b.Nx/2:40:s1.b.Nx/2-1]*2.95e-6;
%  ys = [-s1.b.Ny/2:40:s1.b.Ny/2-1]*2.95e-6;
% 
%  h1 = histc(zpos,zs);
%  h2 = histc(xpos,xs);
%  h3 = histc(ypos,ys);
% 
%  figure(1); clf;
%  plot(zs*1e3,h1); grid on;
%  xlabel('Z position [mm]');
%  title('Histogram of Particle Z Position');
% 
%  figure(2); clf;
%  plot(xs*1e3,h2); grid on;
%  xlabel('X position [mm]');
%  title('Histogram of Particle X Position');
% 
%  figure(3); clf;
%  plot(ys*1e3,h3); grid on;
%  xlabel('Y position [mm]');
%  title('Histogram of Particle Y Position');

end
