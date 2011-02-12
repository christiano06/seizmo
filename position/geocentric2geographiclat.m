function [lat]=geocentric2geographiclat(lat,ecc)
%GEOCENTRIC2GEOGRAPHICLAT    Convert latitude from geocentric to geographic
%
%    Usage:    latitudes=geocentric2geographiclat(latitudes)
%              latitudes=geocentric2geographiclat(latitudes,ecc)
%
%    Description: GEOCENTRIC2GEOGRAPHICLAT(LATITUDES) converts LATITUDES
%     that are geocentric latitudes to geographic latitudes.  LATITUDES
%     units are in degrees.  Assumes the WGS-84 reference ellipsoid.
%
%     GEOCENTRIC2GEOGRAPHICLAT(LATITUDES,ECC) specifies the eccentricity
%     for the ellipsoid to use in the conversion.
%
%    Notes:
%     - If the location is not on the surface use GEOCENTRIC2GEOGRAPHIC.
%
%    Examples:
%     Show the difference in latitudes:
%      plot(geocentric2geographiclat(-90:90)-(-90:90))
%
%    See also: GEOGRAPHIC2GEOCENTRICLAT, GEOGRAPHICLAT2RADIUS

%     Version History:
%        Oct. 14, 2008 - initial version
%        Nov. 10, 2008 - minor doc update
%        Apr. 23, 2009 - fix nargchk for octave, move usage up
%        Nov. 13, 2009 - name change: geodetic to geographic
%        Feb. 11, 2011 - mass nargchk fix
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated Feb. 11, 2011 at 15:05 GMT

% todo:

% require 1 or 2 inputs
error(nargchk(1,2,nargin));

% assume WGS-84 ellipsoid if no eccentricity given
if(nargin==1); ecc=8.181919084262149e-02; end

% check inputs
if(~isnumeric(lat) || isempty(lat))
    error('seizmo:geocentric2geographiclat:badInput',...
        'LAT must be nonempty numeric array!');
elseif(~isnumeric(ecc) || ~isscalar(ecc) || ecc>=1 || ecc<0)
    error('seizmo:geocentric2geographiclat:badInput',...
        'ECC must be numeric scalar with 0<=ECC<1 !');
end

% convert to geographic
lat=atan2(sind(lat),(1-ecc^2).*cosd(lat)).*(180/pi);

end
