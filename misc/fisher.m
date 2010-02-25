function [Z]=fisher(R)
%FISHER    Converts correlation coefficients to the Z statistic
%
%    Usage:    z=fisher(r)
%
%    Description: Z=FISHER(R) uses the Fisher transform to convert
%     correlation coefficients R to the z statistic Z.  Correlation
%     coefficients should be bounded by -1 and 1.  Any correlation
%     coefficient outside the range is set to NaN.
%
%    Notes:
%
%    Examples:
%     Convert correlations to z statistic get the mean and std dev and
%      convert them back to correlation values
%       z=fisher(r)
%       z_mean=mean(z)
%       z_std=var(z)
%       [r_lower,r_mean,r_upper]=ifisher(z_mean-z_std,z_mean,z_mean+z_std)
%
%    See also: IFISHER

%     Version History:
%        Sep.  9, 2009 - minor doc update
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated Sep.  9, 2009 at 01:55 GMT

% todo:

% CONVERT CORRELATIONS OUT OF RANGE TO NaN
R(abs(R)>1)=nan;

% FISHER TRANSFORM -> CORRELATION SPACE TO Z STATISTIC SPACE
Z=0.5*log((1+R)./(1-R));

end