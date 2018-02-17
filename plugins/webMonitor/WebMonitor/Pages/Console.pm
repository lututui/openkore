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
    <script type=\"application/javascript\" defer=\"defer\">
		function sendConsoleCommand() {
			var ic = document.getElementById(\"input_command\");
			var sc = document.getElementById(\"selection_command\");
			window.location.href = '../handler?csrf=%s&command=' + sc.options[sc.selectedIndex].value + ic.value;
			ic.value = '';
            return false;
		}

		function submit() {
			if (window.event)
                if (window.event.keyCode == 13)
                    sendConsoleCommand();
		}
    </script>

    <div class=\"span9\">
	<div class=\"row-fluid\">
	    <div class=\"span9\">
			<h3>Console</h3>

			<div>
				<pre class=\"log console\">%s</pre>
			</div>

			<div class=\"input-append\" rel=\"tooltip\">
				<select class=\"span2\" id=\"selection_command\">
					<option selected value=\"\">Console</option>
					<option value=\"c \">Chat</option>
					<option value=\"p \">Party</option>
					<option value=\"g \">Guild</option>
				</select>

				<input class=\"span9\" id=\"input_command\" type=\"text\" onKeyPress=\"submit()\">
				<input type=\"button\" class=\"btn span2\" id=\"button_send\" value=\"Send\" disabled onClick=\"sendConsoleCommand()\"/>
			</div>

			</br>
		</div>
		%s
	</div>
    </div>
    ",
    $self->{csrf}, &webMonitorServer::consoleLogHTML, $self->getSidebar);
}


1;