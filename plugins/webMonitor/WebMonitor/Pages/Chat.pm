package WebMonitor::Pages::Chat;

use strict;

use WebMonitor::BasePage;
use base qw(WebMonitor::BasePage);
use Settings;

sub getURL {
	return "/chat";
}

sub getName {
	return "Chat Log";
}

sub getIcon {
	return "icon-comment";
}

sub getContent {
    my ($self) = @_;

    return sprintf(
    "
    %s

    <div class=\"span9\">
	<div class=\"row-fluid\">
		<div class=\"span9\">
			<h3>Chat Log</h3>

			<pre class=\"log chat\" data-domains=\"web selfchat publicchat partychat guildchat pm pm/sent schat\">%s</pre>

			%s

			</br>
		</div>
        %s
	</div>
    </div>
    ",
    $self->submitConsoleCommandJS, &webMonitorServer::loadTextToHTML($Settings::chat_log_file), $self->getInputAppend, $self->getSidebar);
}

1;