package WebMonitor::Pages::Console;

use strict;

use WebMonitor::BasePage;
use base qw(WebMonitor::BasePage);

sub getURL {
	return "/console";
}

sub getName {
	return "Console";
}

sub getContent {
    my ($self) = @_;

    return sprintf(
    "
    %s

    <div class=\"span9\">
	<div class=\"row-fluid\">
	    <div class=\"span9\">
			<h3>Console</h3>

			<div>
				<pre class=\"log console\">%s</pre>
			</div>

			%s

			</br>
		</div>
		%s
	</div>
    </div>
    ",
    $self->submitConsoleCommandJS, &webMonitorServer::consoleLogHTML, $self->getInputAppend("Console"),
	$self->getSidebar);
}


1;