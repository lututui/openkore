package WebMonitor::Pages::Inventory;

use strict;

use WebMonitor::BasePage;
use base qw(WebMonitor::BasePage);
use Globals qw($char);

sub getURL {
	return "/inventory";
}

sub getName {
	return "Inventory";
}

sub getIcon {
	return "icon-briefcase";
}

sub getContent {
    my ($self) = @_;

    return sprintf (
    "
    <script type=\"application/javascript\" defer=\"defer\">
		function useInventoryCommand(command, args) {
			window.location.href = '../handler?csrf=%s&command='+ command + '+' + args + '&page=inventory';
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
			<li><a href=\"#equipped\" data-toggle=\"tab\">Equipped</a></li>
			<li><a href=\"#unequipped\" data-toggle=\"tab\">Unequipped</a></li>
			<li class=\"%s\"><a href=\"#cart\" data-toggle=\"tab\">Cart</a></li> 
		</ul>
		<div class=\"tab-content\">
            <div class=\"tab-pane active\" id=\"usable\">
                <table class=\"table table-hover\">
                    <thead>
                    <tr>
                        <th></th>
                        <th>Amount</th>
                        <th>Item</th>
                        <th>Action</th>
                        <th>Drop 1</th>
                        <th>Drop all</th>
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
						<th>Drop 1</th>
						<th>Drop all</th>
                        <th></th>
					</tr>
					</thead>
					<tbody>
						%s
					</tbody>
				</table>
			</div>
			<div class=\"tab-pane\" id=\"equipped\">
				<table class=\"table table-hover\">
					<thead>
					<tr>
						<th></th>
						<th>Amount</th>
						<th>Item</th>
						<th>Action</th>
						<th></th>
                        <th></th>
					</tr>
					</thead>
					<tbody>
						%s
					</tbody>
				</table>
			</div>
			<div class=\"tab-pane\" id=\"unequipped\">
				<table class=\"table table-hover\">
					<thead>
					<tr>
						<th></th>
						<th>Amount</th>
						<th>Item</th>
						<th>Action</th>
						<th>Drop</th>
					</tr>
				    </thead>
					<tbody>
						%s
					</tbody>
				</table>
			</div>
			<div class=\"tab-pane\" id=\"cart\">
				<table class=\"table table-hover\">
				    <thead>
					<tr>
						<th></th>
						<th>Amount</th>
						<th>Item</th>
						<th>Get 1</th>
                        <th>Get Stack</th>
					</tr>
					</thead>
					<tbody>
						%s
					</tbody>
				</table>
			</div>	
		</div>
	</div>			
    </div>
    </div>
    </div>
    ", 
    $self->{csrf}, &cartActive, $self->getInventory(0), $self->getInventory(1), $self->getInventory(2), $self->getInventory(3),
    $self->getCart);
}

sub getCart {
    my ($self) = @_;
    my $returnString;

    if ($char->cart->isReady) {
        foreach my $item (@{$char->cart->getItems}) {
            $returnString .= sprintf(
            "
            <tr>
                <td><img src=\"https://www.ragnaplace.com/bro/item/%s.png\"/></td>
                <td>%d</td>
                <td class=\"left\">%s</td>
                <td><a class=\"btn btn-mini btn-inverse\" href=\"javascript:useInventoryCommand('cart+get', '%d+1')\">Get 1</a></td>
                <td><a class=\"btn btn-mini btn-inverse\" href=\"javascript:useInventoryCommand('cart+get', '%d')\">Get Stack</a></td>
            </tr>
            ", $item->{nameID}, $item->{amount}, $item->name, $item->{binID}, $item->{binID});
        }
    }

    return $returnString;
}

sub getInventory {
    my ($self, $subType) = @_;
    my ($condition, $returnString);

    if ($subType == 0) {
        $condition = sub { $_[0]->{type} <= 2 };
    } elsif ($subType == 1) {
        $condition = sub { !$_[0]->{equipped} && ($_[0]->{type} == 3 || $_[0]->{type} == 6 || $_[0]->{type} == 10) };
    } elsif ($subType == 2) {
        $condition = sub { $_[0]->{equipped} };
    } elsif ($subType == 3) {
        $condition = sub { !$_[0]->{equipped} && $_[0]->{type} > 2 && $_[0]->{type} != 3 && $_[0]->{type} != 6 
            && $_[0]->{type} != 10 };
    } else {
        $condition = sub { 1 };
    }

    foreach my $item (@{$char->inventory->getItems}) {
        if ($condition->($item)) {
            $returnString .= sprintf(
            "
            <tr>
                <td><img src=\"https://www.ragnaplace.com/bro/item/%s.png\"/></td>
                <td>%d</td>
                <td><a href=\"http://ratemyserver.net/index.php?page=item_db&item_id=%s\">%s</a></td>
            ", $item->{nameID}, $item->{amount}, $item->{nameID}, $item->name);

            my $baseString = 
            "<td>
                <a class=\"btn btn-mini %s\" href=\"javascript:useInventoryCommand('%s', '%d%s')\">%s</a>
            </td>";
            
            if ($subType != 1) {
                if ($subType == 0) {
                    $returnString .= sprintf($baseString, "btn-success", "is", $item->{binID}, undef, "Use on Self");
                } elsif ($subType == 2) {
                    $returnString .= sprintf($baseString, "btn-inverse", "eq", $item->{binID}, undef, "Equip");
                } elsif ($subType == 3) {
                    $returnString .= sprintf($baseString, "btn-inverse", "uneq", $item->{binID}, undef, "Unequip");
                }
            }

            if ($subType != 2) {
                $returnString .= sprintf($baseString, "btn-danger", "drop", $item->{binID}, "+1", "Drop 1");
                if ($subType != 3) {
                    $returnString .= sprintf($baseString, "btn-danger", "drop", $item->{binID}, undef, "Drop Stack");
                }
            }
            
            $returnString .= "</tr>";
        }
    }

    return $returnString;
}

sub cartActive {
    return 'disabled' unless $char->cart->isReady;
}

1;