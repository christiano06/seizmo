function [fh,lh]=p2(data,xlimits,ylimits,legend_ok,norm,fh,sfh) 
%P2    Overlay plot of SAClab data records
%
%    Description: Plots timeseries and xy records over one another in a
%     plot.  Other record types are ignored.  Optional inputs are the x/y
%     limits for the plot ([low high]), a legend logical (default is 0), a
%     normalization flag (default is 0), and the figure and subplot handles
%     (to put p2 in a particular figure and subplot).  The legend box can 
%     be moved by left-clicking on its box and dragging.  The legend labels
%     can be graphically edited by double-clicking on them.  Outputs are 
%     the figure and legend handles.
%
%    Usage:  [fh,lh]=p2(data,xlim,ylim,legend_ok,norm,fh,sfh)
%
%    Examples:
%     To overlay the first 4 records
%      p2(data(1:4)) 
%
%     To overlay the 5th and 8th records from 0 to 300 seconds
%      p2(data([5 8]),[0 300]) 
%
%     To plot all traces with a legend, without limiting the x/y axis
%      p2(data,[],[],1)
%
%    See also:  p1, p3, recsec

% check number of inputs
error(nargchk(1,7,nargin))

% check data structure
if(~isstruct(data))
    error('input data is not a structure')
elseif(~isvector(data))
    error('data structure not a vector')
elseif(~isfield(data,'version') || ~isfield(data,'head') || ...
        ~isfield(data,'x'))
    error('data structure does not have proper fields')
end

% default basic plotting parameters
bgc='k';    % background color
fgc='w';    % axis color
ts=4;       % text size
tn='times'; % text name
tw='light'; % text weight
lw=1;       % line width of record

% initialize plot
if(nargin<6 || isempty(fh) || fh<1); fh=figure;
else figure(fh); if(nargin==7 && ~isempty(sfh)); subplot(sfh); end; end
whitebg(bgc);
set(gcf,'Name','P2 -- SAC Seismogram Plotting Utility', ...
    'NumberTitle','off','color',bgc,'Pointer','crosshair');
set(gca,'FontName',tn,'FontWeight',tw,'FontSize',ts,'box','on',...
    'xcolor',fgc,'ycolor',fgc,'TickDir','out','ticklength',[0 0]);
xlabel('Time (sec)');
ylabel('Amplitude');
grid on;

% number of records
nrecs=length(data);

% record coloring
colors=hsv(nrecs);

% header info
iftype=genumdesc(data,'iftype');
leven=glgc(data,'leven');
[b,npts,delta]=gh(data,'b','npts','delta');

% normalization
scaling=ones(nrecs,1);
if(nargin>4 && ~isempty(norm) && norm); scaling=gnrm(data); end

% loop through each file
hold on
plotted=false(nrecs,1);
for i=1:nrecs
    % check if timeseries or xy (if not skip)
    if(~any(strcmp(iftype(i),{'Time Series File' 'General X vs Y file'}))); continue; end
    
    % get record timing
    if(strcmp(leven(i),'true')); time=b(i)+(0:npts(i)-1).'*delta(i);
    elseif(strcmp(leven(i),'false')); time=data(i).t;
    else error('sample spacing logical must be set');
    end
    
    % plot series
    plot(time,data(i).x/scaling(i),'color',colors(i,:),'linewidth',lw);
    plotted(i)=1;
end
hold off

% zooming
axis tight;
if(nargin>1 && ~isempty(xlimits)); axis auto; xlim(xlimits); end
if(nargin>2 && ~isempty(ylimits)); ylim(ylimits); end

% legend
if(nargin>3 && ~isempty(legend_ok) && legend_ok)
    if(isfield(data,'name')); lh=legend(data(plotted).name,'location','best');
    else i=1:nrecs; lh=legend(strcat({'Record '},cellstr(num2str(i(plotted).')))); end
    set(lh,'interpreter','none')
    set(lh,'fontsize',4)
end

% title (total plotted / total records)
title([num2str(nnz(plotted)) '/' num2str(nrecs) ' Records']);

end