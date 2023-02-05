function pd_out = makeQuicklookFromHistFolder_new_aceena(pathtohistmat)
% Function to make quicklooks from a series of reconstructed holograms
% We apply some rules to get a reasonable quicklook

t = dir(fullfile(pathtohistmat,'*hist.mat'));

% Thresholds
art = 1.5; % Aspect ratio less than
utt = 0.04; % Underthresh greater than
dsqth = 6; % Threshold for dsqoverlz less than

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
   yr = str2double(tmp(end-34:end-31));
   mt = str2double(tmp(end-29:end-28));
   dy = str2double(tmp(end-26:end-25));
   hr = str2double(tmp(end-23:end-22));
   mn = str2double(tmp(end-20:end-19));
   sc = str2double(tmp(end-17:end-16)) + 1e-6*str2double(tmp(end-14:end-9));
   time(cnt) = datenum(yr,mt,dy,hr,mn,sc);
end


uS = etd(clock,1,length(t),60);
for cnt = 1:length(t)
    try
   s1 = load(fullfile(pathtohistmat,t(cnt).name));
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


%
       ind1 = find(and(asprat_in < art,underthresh_in>utt));
       ind2 = find(and(zpos_in > 20e-3, zpos_in < 150e-3));
       %ind = intersect(ind1,ind2);
       ind=(asprat_in < art&underthresh_in>utt&zpos_in > 20e-3& zpos_in < 150e-3);

    %   dsqoverlz = (minsiz_in(ind).*majsiz_in(ind))./(numzs_in(ind)*355e-9*dz);
       dsqoverlz = (minsiz_in.*majsiz_in)./(numzs_in*355e-9*dz);
    %   ind = intersect(ind,find(dsqoverlz < dsqth));
        ind=ind&dsqoverlz < dsqth;
       
    %   ind3 = intersect(ind,find(majsiz_in > 1e-4));
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