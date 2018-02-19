package WebMonitor::Pages::Shop;

use strict;

use WebMonitor::BasePage;
use base qw(WebMonitor::BasePage);
use Globals qw($shopstarted $char %shop @venderListsID %venderLists $venderItemList @articles);
use Settings;

sub getURL {
	return "/shop";
}

sub getName {
	return "Shop";
}

sub getIcon {
	return "icon-shopping-cart";
}

sub getContent {
    my ($self) = @_;

    return sprintf(
    "
    %s

    <script type=\"application/javascript\" defer=\"defer\">
        function exibir() {
            window.location.href = '../handler?csrf=%s&shop=' + lista_loja.options[lista_loja.selectedIndex].value;
            return false;
		}
    </script>

    <div class=\"span9\">
    <div class=\"row-fluid\">
    <div class=\"span9\">
	<div class=\"tabbable\">
		<ul class=\"nav nav-tabs\">
			<li class=\"active\"><a href=\"#shoplist\" data-toggle=\"tab\">Shop list</a></li>
			<li><a href=\"#myshop\" data-toggle=\"tab\">My shop</a></li>
			<li><a href=\"#log\" data-toggle=\"tab\">Log</a></li>
			%s
		</ul>
		<div class=\"tab-content\">
            <div class=\"tab-pane active\" id=\"shoplist\">
                <pre class=\"log console\">%s</pre>
                <select class=\"span4\" id=\"lista_loja\" onChange=\"exibir()\">
                    <option selected value=\"\">Choose a shop to view</option>
                    %s
                </select>
                <input class=\"span7\" id=\"text_command\" size=\"16\" type=\"text\" onKeyPress=\"submit()\">&nbsp;<button class=\"btn btn-small\" type=\"button\" value=\"Send command\" onClick=\"sendConsoleCommand()\">Send</button><br>
                <table class=\"table table-hover\">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Item</th>
                        <th>Price</th>
                        <th>Amount</th>
                        <th>Buy</th>
                    </tr>
                    </thead>
                    <tbody id=\"listarItens\">
                        %s
                    </tbody>
                </table>	
            </div>
            <div class=\"tab-pane\" id=\"myshop\">
                <table class=\"table table-hover\">
                    <div align=\"center\"><b>%s</b></div>
                    <thead>
                    <tr>
                        <th></th>
                        <th>Item</th>
                        <th>Amount</th>
                        <th>Price</th>
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
    $self->submitConsoleCommandJS, $self->{csrf}, $self->getSelfShopButton, &webMonitorServer::consoleLogHTML,
    $self->getShopListComboBox, $self->getShopContent, $shop{title}, $self->getSelfShopContent,
    &webMonitorServer::loadTextToHTML($Settings::shop_log_file));
}

sub getSelfShopButton {
    my ($self) = @_;
    my $baseString = "<a href=\"/handler?csrf=%s&command=%s\" class=\"btn %s btn-mini pull-right\"><i class=\"icon-shopping-cart icon-white\"></i>%s</a>";

    if ($char->{skills}{MC_VENDING}{lv} && $shop{title_line}) {
        if ($shopstarted && $char->cartActive) {
            return sprintf($baseString, $self->{csrf}, "closeshop", "btn-danger", "closeshop");
        } elsif (!$shopstarted && $char->cart->isReady) {
            return sprintf($baseString, $self->{csrf}, "openshop", "btn-success", "openshop");
        }
    }

    return undef;
}

sub getShopListComboBox {
    my ($self) = @_;
    my $returnString;

    for (my $i = 0; $i < scalar @venderListsID; ++$i) {
        $returnString .= sprintf("<option value=\"%d\">%s</option>", $i, $venderLists{$venderListsID[$i]}{title});
    }

    return $returnString;
}

sub getShopContent {
    my ($self) = @_;
    my $returnString;

    for (my $i = 0; $i < scalar @{$venderItemList->getItems}; ++$i) {
        $returnString .= sprintf(
        "
        <tr>
            <td><div align=\"center\">%d</div></td>
            <td>%s</td>
            <td>%s</td>
            <td><div align=\"center\">%d</div></td>
            <td><div align=\"center\">%s</div></td>
        </tr>
        ",
        $i, $venderItemList->[$i]->{name}, formatNumber($venderItemList->[$i]->{price}),
        $venderItemList->[$i]->{amount}, $self->getBuyButton($i));
    }

    return $returnString;
}

sub getBuyButton {
    my ($self, $i) = @_;

    if ($venderItemList->[$i]->{price} <= $char->{zeny}) {
        return sprintf("<a class=\"btn btn-mini btn-success\" href=\"/handler?csrf=%s&command=buy+%d+,+%d)\">Buy</a>",
            $self->{csrf}, $webMonitorServer::shopNumber, $i);
    }

    return "<a class=\"btn btn-mini btn-danger\" rel=\"tooltip\" title=\"Not enough zeny\">Buy</button>";
}

sub getSelfShopContent {
    return undef unless ($shopstarted && $char->{skills}{MC_VENDING}{lv} && $char->cartActive && $shop{title_line});
    
    my ($self) = @_;
    my $returnString;

    foreach my $item (@articles) {
        $returnString .= sprintf(
        "
        <tr>
            <td><img src=\"https://www.ragnaplace.com/bro/item/%d.png\"/></td>
            <td>%s</td>
            <td>%d</td>
            <td>%s</td>
        </tr>
        ",
        $item->{nameID}, $item->{name}, $item->{quantity}, formatNumber($item->{price}));
    }

    return $returnString;
}

1;