function [map,time,lat,lon]=ww3mat(ww3)
%WW3MAT    Converts WaveWatch III data from struct to matrix form
%
%    Usage:    [values,time,lat,lon]=ww3mat(ww3)
%
%    Description:
%     [VALUES,TIME,LAT,LON]=WW3MAT(WW3) converts WaveWatch III data in the
%     struct WW3 (created by READ_GRIB) to a matrix VALUES, the time in
%     TIME as well as the latitudes and longitudes of the data in LAT/LON.
%     TIME is in the format [YR MONTH DAY HOUR MINUTE SECOND] and LAT/LON
%     are vectors in units of degrees.  The matrix is output as size
%     NLATxNLON.
%
%    Notes:
%
%    Examples:
%     % Read the first record of a NOAA WW3 grib file and plot it up:
%     ww3=read_grib('nww3.hs.200607.grb',1);
%     [map,time,lat,lon]=ww3mat(ww3);
%     figure;
%     imagesc(lon,lat,map);
%     set(gca,'ydir','normal');
%     title([datestr(time) ' Significant Wave Heights']);
%
%    See also: READ_GRIB, PLOTWW3, WW3MOV, WW3TS

%     Version History:
%        June 30, 2010 - initial version
%        July  2, 2010 - added WW3TS to see also
%        Dec.  5, 2011 - doc update
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated Dec.  5, 2011 at 00:40 GMT

% todo:

% check nargin
error(nargchk(1,1,nargin));

% check grib
% need fields fltarray, description, units, stime
%             gds (La1, La2, Dj, Nj, Lo1, Lo2, Di, Ni)
top={'fltarray' 'description' 'units' 'stime' 'gds' 'pds'};
gds={'La1' 'La2' 'Dj' 'Nj' 'Lo1' 'Lo2' 'Di' 'Ni'};
pds={'year' 'month' 'day' 'hour' 'min'};
if(~isstruct(ww3) || ~isscalar(ww3) ...
        || any(~ismember(top,fieldnames(ww3))) ...
        || any(~ismember(gds,fieldnames(ww3.gds))) ...
        || any(~ismember(pds,fieldnames(ww3.pds))))
    error('seizmo:ww3mat:badWW3',...
        'WW3 must be a struct generated by READ_GRIB!');
end

% get lat/lons
% - location corresponds to Center-Left of the pixel
lat=fliplr(ww3.gds.La2:ww3.gds.Dj:ww3.gds.La1);
lon=(ww3.gds.Lo1:ww3.gds.Di:ww3.gds.Lo2)+ww3.gds.Di/2;

% get time
time=[ww3.pds.year ww3.pds.month ww3.pds.day ww3.pds.hour ww3.pds.min 0];

% get array
map=reshape(ww3.fltarray,ww3.gds.Ni,ww3.gds.Nj).';

end
