package WebMonitor::Pages::Config;

use strict;

use WebMonitor::BasePage;
use base qw(WebMonitor::BasePage);
use Globals qw(%config %timeout);
use Settings;

sub getURL {
	return "/config";
}

sub getName {
	return "Config";
}

sub getIcon {
	return "icon-cog";
}

sub getContent {
    my ($self) = @_;

    return sprintf(
    "
    <script type=\"application/javascript\" defer=\"defer\">
			function sendConfigCommand() {
				var key = document.getElementById(\"configKey\");
				var value = document.getElementById(\"configValue\");
                sendCommand('conf', key.value, value.value);
                return false;
			}

            function sendTimeoutCommand() {
                var key = document.getElementById(\"timeoutKey\");
				var value = document.getElementById(\"timeoutValue\");
                sendCommand('timeout', key.value, value.value);
                return false;
            }

            function sendReload() {
                var file = document.getElementById(\"reloadFile\");
                sendCommand('reload', file.value);
            }

            function sendReloadAll() {
                sendCommand('reload', 'all');
            }

            function sendCommand(cmd, key, value) {
                var combinedKey;

                if (typeof value !== 'undefined') {
                    combinedKey = key + '+' + value;
                } else {
                    combinedKey = key;
                }

                window.location.href = '../handler?csrf=%s&command=' + cmd + '+' + combinedKey;
                return false;
            }

			function submitConfig(e) {
				if (window.event)
				    if (window.event.keyCode == 13)
                        sendTimeoutCommand();
			}

            function submitTimeout(e) {
				if (window.event)
				    if (window.event.keyCode == 13)
                        sendConfigCommand();
			}
    </script>

    <div class=\"span9\">
    <div class=\"row-fluid\">
    <div class=\"span9\">
	<div class=\"tabbable\">
		<ul class=\"nav nav-tabs\">
			<li class=\"active\"><a href=\"#config\" data-toggle=\"tab\">Config</a></li>
			<li><a href=\"#timeouts\" data-toggle=\"tab\">Timeouts</a></li>
            <li><a href=\"#reloads\" data-toggle=\"tab\">Reload Control Files</a></li>
		</ul>
		<div class=\"tab-content\">
            <div class=\"tab-pane active\" id=\"config\">
            <div class=\"span8 well\">
                %s
                <input class=\"span7\" id=\"configValue\" type=\"text\" placeholder=\"value\" onKeyPress=\"submitConfig(this.event)\">
                <button class=\"btn\" type=\"button\" onClick=\"sendConfigCommand()\">Change</button>
            </div>
            </div>
            
            <div class=\"tab-pane\" id=\"timeouts\">
            <div class=\"span8 well\">
                %s
                <input class=\"span7\" id=\"timeoutValue\" type=\"text\" placeholder=\"value\" onKeyPress=\"submitTimeout(this.event)\">
                <button class=\"btn\" type=\"button\" onClick=\"sendTimeoutCommand()\">Change</button>
            </div>
            </div>

            <div class=\"tab-pane\" id=\"reloads\">
            <div class=\"span8 well\">
                %s
                <button class=\"btn\" type=\"button\" onClick=\"sendReload()\">Reload</button>
                <button class=\"btn\" type=\"button\" onClick=\"sendReloadAll()\">Reload All</button>
            </div>
            </div>
        </div>
	</div>
    </div>
    </div>
    </div>
    ",
    $self->{csrf}, &getConfigSelect, &getTimeoutSelect, &getReloadSelect);
}

sub getConfigSelect {
    my $returnString = "<select id=\"configKey\">\n";

    foreach my $key (sort { lc($a) cmp lc($b) } keys %config) {
        $returnString .= sprintf("<option value=\"%s\">%s</option>\n", $key, $key);
    }

    $returnString .= "</select>";

    return $returnString;
}

sub getTimeoutSelect {
    my $returnString = "<select id=\"timeoutKey\">\n";

    foreach my $key (sort { lc($a) cmp lc($b) } keys %timeout) {
        $returnString .= sprintf("<option value=\"%s\">%s</option>\n", $key, $key);
    }

    $returnString .= "</select>";

    return $returnString;
}

sub getReloadSelect {
    my $returnString = "<select id=\"reloadFile\">\n";

    foreach my $file (sort { lc($a->{name}) cmp lc($b->{name}) } @{$Settings::files->getItems}) {
        $returnString .= sprintf("<option value=\"%s\">%s</option>\n", $file->{name}, $file->{name});
    }

    $returnString .= "</select>";

    return $returnString;
}

1;