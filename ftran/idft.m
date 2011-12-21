function [data]=idft(data)
%IDFT    Performs an inverse discrete fourier transform on SEIZMO records
%
%    Usage:    data=idft(data)
%
%    Description:
%     IDFT(DATA) converts SEIZMO records from the frequency domain to the
%     time domain using an inverse discrete fourier transform (Matlab's
%     ifft).  Output filetype is 'Time Series File'.
%
%    Notes:
%     - SAC (and thus SEIZMO's DFT for sanity) calculates spectral data 
%       according to Parseval's theorem.  This is not equivalent to how
%       Matlab's fft/ifft functions work so be careful when working with
%       amplitudes!
%
%    Header Changes: B, SB, E, DELTA, SDELTA, NPTS, NSPTS, IFTYPE
%                    DEPMEN, DEPMIN, DEPMAX
%     In the frequency domain B, DELTA, and NPTS are changed to the 
%     beginning frequency, sampling frequency, and number of data points in
%     the transform (includes negative frequencies).  The original values 
%     of B, DELTA, and NPTS are saved in the header as SB, SDELTA, and 
%     NSNPTS and are restored when this command is performed.
%
%    Examples:
%     % To take the derivative of a time-series in the frequency domain:
%     data=idft(multiplyomega(dft(data)))
%
%    See also: DFT, AMPH2RLIM, RLIM2AMPH, DIVIDEOMEGA, MULTIPLYOMEGA

%     Version History:
%        Jan. 28, 2008 - initial version
%        Feb. 28, 2008 - seischk support and code cleanup
%        Mar.  2, 2008 - readibility change
%        Mar.  3, 2008 - now compatible with SAC
%        Mar.  4, 2008 - cleaned up errors and warnings
%        May  12, 2008 - name changed to idft
%        June 11, 2008 - added example
%        July 19, 2008 - doc update, .dep rather than .x, dataless support,
%                        one ch call, updates DEP* fields
%        Oct.  7, 2008 - minor code cleaning
%        Nov. 22, 2008 - update for new name schema
%        Apr. 23, 2009 - fix nargchk for octave
%        June  3, 2009 - minor doc fix
%        Oct. 15, 2009 - force ifft down columns
%        Jan. 29, 2010 - seizmoverbose support, proper SEIZMO handling,
%                        improved messaging
%        Aug. 19, 2010 - removed ifft symmetric flag, real conversion
%        Feb. 11, 2011 - mass seizmocheck fix
%        Dec. 21, 2011 - doc update, better checkheader usage
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated Dec. 21, 2011 at 15:05 GMT

% todo:

% check nargin
error(nargchk(1,1,nargin));

% check data structure
error(seizmocheck(data,'dep'));

% turn off struct checking
oldseizmocheckstate=seizmocheck_state(false);

% attempt inverse fast fourier transform
try
    % check headers
    data=checkheader(data,...
        'NONSPECTRAL_IFTYPE','ERROR',...
        'FALSE_LEVEN','ERROR');

    % verbosity
    verbose=seizmoverbose;

    % number of records
    nrecs=numel(data);

    % retreive header info
    iftype=getenumid(data,'iftype');
    [b,delta,sb,sdelta,npts,nspts]=...
        getheader(data,'b','delta','sb','sdelta','npts','nspts');
    e=sb+(nspts-1).*sdelta;
    
    % detail message
    if(verbose)
        disp('Transforming Record(s) to the Time Domain');
        print_time_left(0,nrecs);
    end

    % loop through records
    depmen=nan(nrecs,1); depmin=depmen; depmax=depmen;
    for i=1:nrecs
        % skip dataless (reduce ncmp by 2)
        if(isempty(data(i).dep))
            data(i).dep=data(i).dep([],1:2:end);
            % detail message
            if(verbose); print_time_left(i,nrecs); end
            continue;
        end

        % save class and convert to double precision
        oclass=str2func(class(data(i).dep));
        data(i).dep=double(data(i).dep);

        % turn back into time domain
        if(strcmpi(iftype(i),'irlim'))
            data(i).dep=real(1/sdelta(i)*ifft(...
                complex(data(i).dep(:,1:2:end),data(i).dep(:,2:2:end)),...
                [],1));
        else % iamph
            data(i).dep=real(1/sdelta(i)*ifft(...
                data(i).dep(:,1:2:end).*exp(1j*data(i).dep(:,2:2:end)),...
                [],1));
        end

        % truncate to original length and change class back
        data(i).dep=oclass(data(i).dep(1:nspts(i),:));

        % dep*
        depmen(i)=mean(data(i).dep(:));
        depmin(i)=min(data(i).dep(:));
        depmax(i)=max(data(i).dep(:));
        
        % detail message
        if(verbose); print_time_left(i,nrecs); end
    end

    % update header (note there is no field 'se')
    data=changeheader(data,'b',sb,'e',e,'delta',sdelta,'sb',b,...
        'sdelta',delta,'nspts',npts,'npts',nspts,'iftype','itime',...
        'depmen',depmen,'depmin',depmin,'depmax',depmax);

    % toggle checking back
    seizmocheck_state(oldseizmocheckstate);
catch
    % toggle checking back
    seizmocheck_state(oldseizmocheckstate);
    
    % rethrow error
    error(lasterror);
end

end
