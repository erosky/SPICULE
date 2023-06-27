function out = particlesize()

tstart = datenum(2021,06,21,00,07,29)	
tstop = datenum(2021,06,21,00,07,36)
datenum(

time = ncread("06202021_190100_2DS_H.pbp.nc","time");
diam = ncread("06202021_190100_2DS_H.pbp.nc","diam");
rejectionflag = ncread("06202021_190100_2DS_H.pbp.nc","rejectionflag");
arearatiofilled = ncread("06202021_190100_2DS_H.pbp.nc","arearatiofilled");

largeparticles = find((time > tstart) & (time < tstop))
time(1)

end

