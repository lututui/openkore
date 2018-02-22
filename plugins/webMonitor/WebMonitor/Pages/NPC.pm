package WebMonitor::Pages::NPC;

use strict;

use WebMonitor::BasePage;
use base qw(WebMonitor::BasePage);
use Globals qw($npcsList);

sub getURL {
	return "/npc";
}

sub getName {
	return "NPC List";
}

sub getIcon {
	return "icon-th-list";
}

sub getContent {
    my ($self) = @_;

    return sprintf(
    "
    %s

    <script type=\"application/javascript\" defer=\"defer\">
        function write_input(command) {
            var ic = document.getElementById(\"input_command\");
            var sc = document.getElementById(\"selection_command\");
            ic.value = command;
            sc.value = '';
            ic.focus();
        }
    </script>

    <div class=\"span9\">
    <div class=\"row-fluid\">
    <div class=\"span9\">
		<pre class=\"log console\">%s</pre>
		
        <select class=\"span4\" id=\"selection_command\" onChange=\"write_input(this.value)\">
			<option selected value=\"\">Console</option>
			<option value=\"talk cont\">Continue talking</option>
			<option value=\"talk resp\">Display the list of available responses</option>
			<option value=\"talk resp \">Send a response to an NPC</option>
			<option value=\"talk num \">Send a number to NPC</option>
			<option value=\"talk text \">Send text</option>
			<option value=\"talk no\">End or cancel conversation</option>
		</select>
			
		<input class=\"span7\" id=\"input_command\" size=\"16\" type=\"text\" onKeyPress=\"submit(this.event)\">&nbsp;<button class=\"btn btn-small\" type=\"button\" value=\"Send command\" onClick=\"sendConsoleCommand()\">Send</button><br>
			
		<table class=\"table table-hover\">
			<thead>
			<tr>
				<th>ID</th>
				<th>Name</th>
				<th>Location</th>
				<th>Action</th>
			</tr>
			</thead>
			<tbody id=\"listarItens\">
                %s
			</tbody>
		</table>
    </div>
    </div>
    </div>
    ",
    $self->submitConsoleCommandJS, &webMonitorServer::consoleLogHTML, $self->getNPCList);
}

sub getNPCList {
    my ($self) = @_;
    my $returnString;

    foreach my $npc (@{$npcsList->getItems}) {
        $returnString .= sprintf(
        "
        <tr>
            <td>%d</td>
            <td>%s</td>
            <td>%d %d</td>
            <td><a class=\"btn btn-mini\" href=\"javascript:write_input(\'talk %d\')\">Talk</a></td>
        </tr>
        ",
        $npc->{binID}, $npc->name, $npc->{pos}{x}, $npc->{pos}{y}, $npc->{binID});
    }

    return $returnString;
}

1;