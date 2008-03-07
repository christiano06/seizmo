function [A]=strnlen(A,n)
%STRNLEN    Pad/truncate char/cellstr array to n character columns
%
%    Description: Pads or truncates character and cellstr elements to have
%     n columns.  Padding is done with spaces.  Works recursively, so will
%     accept nested cellstr arrays.  Does not modify array type.
%
%    Usage: A=strnlen(A,len)
%
%    Examples:
%
%    See also: strtrim, deblank, strjust

error(nargchk(2,2,nargin))
if(ischar(A))
    d=size(A);
    if(d(2)>=n)
        A=A(:,1:n); % truncate
    else
        A=[A ones(d(1),n-d(2))*32]; % pad with spaces
    end
elseif(iscellstr(A) || iscell(A))
    A=cellfun(@strnlen,A,num2cell(n(ones(size(A)))),'UniformOutput',false); 
else
    error('array not type char, cellstr, or cell')
end

end