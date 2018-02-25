package WebMonitor::Pages::Storage;

use strict;

use WebMonitor::BasePage;
use base qw(WebMonitor::BasePage);
use Globals qw($char);

sub getURL {
	return "/storage";
}

sub getName {
	return "Storage";
}

sub getIcon {
	return "icon-briefcase";
}

sub getContent {
    my ($self) = @_;

    return sprintf(
    "
    <script type=\"application/javascript\" defer=\"defer\">
		function storageGetCommand(args) {
			window.location.href = '../handler?csrf=%s&command=storage+get+' + args + '&page=storage';
			return false;
		}
	</script>

    <div class=\"span9\">
    <div class=\"row-fluid\">
    <div class=\"span9\">
	<div class=\"tabbable\">
		<ul class=\"nav nav-tabs\">
			<li class=\"active\"><a href=\"#usable\" data-toggle=\"tab\">Usable</a></li>
     		<li><a href=\"#unusable\" data-toggle=\"tab\">Unusable</a></li>
			<li><a href=\"#equipment\" data-toggle=\"tab\">Equipment</a></li>
			<li><a href=\"#log\" data-toggle=\"tab\">Log</a></li>
		</ul>
		
        <div class=\"tab-content\">
            <div class=\"tab-pane active\" id=\"usable\">
            <table class=\"table table-hover\">
                <thead>
                <tr>
                    <th></th>
                    <th>Amount</th>
                    <th>Item</th>
                    <th>Get</th>
                </tr>
                </thead>
                <tbody>
                    %s
                </tbody>
            </table>
            </div>
			
            <div class=\"tab-pane\" id=\"unusable\">
			<table class=\"table table-hover\">
				<thead>
				<tr>
                    <th></th>
                    <th>Amount</th>
                    <th>Item</th>
                    <th>Get</th>
				</tr>
				</thead>
			    
                <tbody>
                    %s
				</tbody>
			</table>
			</div>
			
            <div class=\"tab-pane\" id=\"equipment\">
			<table class=\"table table-hover\">
				<thead>
				<tr>
					<th></th>
					<th>Amount</th>
					<th>Item</th>
					<th>Get</th>
				</tr>
				</thead>
			
            	<tbody>
                    %s
				</tbody>
			</table>
			</div>
			
            <div class=\"tab-pane\" id=\"log\">
			<table class=\"table table-hover\">
			<tbody>
				<pre>%s</pre>
			</tbody>
			</table>
			</div>
		</div>
	</div>			
    </div>
    </div>
	</div>
    ",
    $self->{csrf}, $self->getInventory(0), $self->getInventory(1), $self->getInventory(4),
    &webMonitorServer::loadTextToHTML($Settings::storage_log_file));
}

sub inventoryList {
    return $char->storage->getItems;
}

sub getItemCommandButton {
    my ($self, $item) = @_;
    my $returnString;
    my $baseString =
    "<td>
        <a class=\"btn btn-mini btn-inverse\" href=\"javascript:storageGetCommand('%d%s')\">%s</a>
    </td>";

    $returnString .= sprintf($baseString, $item->{binID}, "+1", "Get 1");
    $returnString .= sprintf($baseString, $item->{binID}, undef, "Get Stack");

    return $returnString;
}

1;