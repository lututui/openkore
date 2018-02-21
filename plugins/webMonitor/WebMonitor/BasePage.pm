package WebMonitor::BasePage;

use strict;

use Globals qw(%config $char $field);
use Settings qw(%sys);

sub new {
	my ($class) = shift;
	my $self = {
		csrf => shift,
		time => shift,
	};

	bless $self, $class;
	
	return $self;
}

sub getURL {}
sub getName {}
sub getIcon {
	return "icon-chevron-right";
}

sub build {
	my ($self) = @_;
	
	return sprintf(
	"
	<!DOCTYPE html>
	<html lang=\"%s\">
	<head>
	%s
	</head>
	<body>
	%s
	</body>
	</html>
	",
	$sys{locale}, $self->buildHeader, $self->buildBody);
}

sub buildHeader {
	my ($self) = @_;

	return sprintf(
	"
	<meta charset=\"utf-8\">
	<title>%s - %d/%d - %s</title>
	<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" />
	<link rel=\"icon\" type=\"image/png\" href=\"img/favicon.png\" />
	<link rel=\"stylesheet\" type=\"text/css\" href=\"css/bootstrap.min.css\" />
	<link rel=\"stylesheet\" type=\"text/css\" href=\"css/webMonitor.css\">
	<style type=\"text/css\">
		/*<![CDATA[*/
			%s
		/*]]>*/
	</style>
	<script type=\"application/javascript\" src=\"js/jquery.min.js\"></script>
	<script type=\"application/javascript\" src=\"js/bootstrap.min.js\"></script>
	<script type=\"application/javascript\" src=\"js/webMonitor.js\"></script>
	<script type=\"application/javascript\">
		//<![CDATA[
			window.CONFIG = {
				socketHost: window.location.host.replace(/:.*/, ''),
				socketPort: %d,
			};
		//]]>
	</script>

	<!--[if lt IE 9]>
		<script src=\"http://html5shim.googlecode.com/svn/trunk/html5.js\"></script>
	<![endif]-->
	",
	$char->name, $char->{lv}, $char->{lv_job}, $Settings::NAME, &webMonitorServer::getConsoleColors, $self->getSocketPort);
}

sub buildBody {
	my ($self) = @_;

	return sprintf(
	"
	<div class=\"navbar\">
	<div class=\"navbar-inner\">
		<a class=\"brand\">%s</a>

		<ul class=\"nav\">
			<li class=\"active\"><a>%s</a></li>
			<li><a>Base Level: <span class=\"value_char_lv\">%d</span></a></li>
			<li><a>Job Level: <span class=\"value_char_lv_job\">%d</span></a></li>
			<li><a>Username: %s</a></li>
			<li><a>Time: %s</a></li>
		</ul>

		<a href=\"/handler?csrf=%s&command=quit\" class=\"btn btn-danger btn-mini pull-right\"><i class=\"icon-off icon-white\"></i> OFF</a>
	</div>
	</div>

	<div class=\"container-fluid\">
	<div class=\"row-fluid\">
		<div class=\"span2\">
		<div class=\"well sidebar-nav\">
			<ul class=\"nav nav-list\">
				%s
			</ul>
		</div>
		</div>
		%s
	</div>
	%s
	</div>
	",
	$Settings::NAME, $char->name, $char->{lv}, $char->{lv_job}, $config{username}, $self->{time}, $self->{csrf},
	$self->getMenu, $self->getContent, $self->getFooter);
}

sub getSocketPort {
	my ($self) = @_;

	return int($webMonitorPlugin::socketServer && $webMonitorPlugin::socketServer->getPort);
}

sub getMenu {
	my ($self) = @_;
	my $returnString = "<li class=\"nav-header\">Menu</li>";
	
	foreach my $pagePackage (@webMonitorServer::pageList) {
		$returnString .= sprintf("<li class=\"%s\"><a href=\"%s\"><i class=\"%s\"></i>%s</a></li>\n", 
			($pagePackage->getURL eq $self->getURL && 'active'), $pagePackage->getURL, $pagePackage->getIcon,
			$pagePackage->getName);
	}

	return $returnString;
}

sub getSidebar {
	my ($self) = @_;

	return sprintf(
	"
	<div class=\"span3\">
		<h5 class=\"center\">
			<i class=\"icon-map-marker\"></i>
			<span class=\"value_field_description\">%s</span>
		</h5>
		
		<div class=\"center\">
			<canvas id=\"map\" width=\"512\" height=\"512\" style=\"background-image: url('%s'); width: 512px; height: 512px;\">
				<form action=\"/handler\" method=\"GET\">
					<input type=\"hidden\" name=\"csrf\" value=\"%s\"/>
					<input type=\"image\" alt=\"%s\" src=\"%s\"/>
				</form>
			</canvas>
		</div>
		
		<p>
			<div class=\"center\" id=\"coord\">
				<span class=\"value_char_pos_x\">%d</span>, 
				<span class=\"value_char_pos_y\">%d</span>
			</div>
		</p>
		
		<script type=\"text/javascript\">
			\$(function(){
				var \$map = \$(\"#map\");
				
				\$map.on(\"click\", function(){
					var newWH = {
						width: \"\",
						height: \"\",
					};
					
					if (\$map.css(\"width\") != \"512px\") {
						newWH = {
						width: \"512px\", 
						height: \"512px\", 
						};
					}
					
					\$map.css(newWH);
				});
				
				var canvas = \$map[0];
				var ctx = canvas.getContext(\"2d\");
				
				function clearMap() {
					ctx.clearRect(0, 0, canvas.width, canvas.height);
				}
				
				function draw() {
					clearMap();
					
					//drawPoints();
					drawPlayer();
				}
				
				setInterval(draw, 1000);
				draw();
				
				function drawPoint(x, y, color, text, textColor) {
					var ox = x, oy = y;
					var w = h = 3;
					var ratio = 512 / 400
					
					x = (x * ratio) - (w / 2);
					y = 512 - (y * ratio) - (h / 2);
					
					ctx.fillStyle = \"#FFFFFF\";
					ctx.fillRect(x - 4, y - 4, w + 8, h + 8);
					
					ctx.fillStyle = \"#000000\";
					ctx.fillRect(x - 2, y - 2, w + 4, h + 4);
					
					ctx.fillStyle = color;
					ctx.fillRect(x, y, w, h);
					
					if (typeof text !== \"undefined\") {
						// ctx.font = \"14px Georgia\";
						// ctx.fillStyle = textColor ? textColor : \"#FF0000\";
						// ctx.fillText(text, x + (w * 2 + 8), y + (h * 2) - (h / 2));
						
						var tx = x + (w * 2 + 8);
						var ty = y + (h * 2) - (h / 2);
						
						ctx.font = \"16px Georgia\"
						
						ctx.strokeStyle = \"#FFFFFF\";
						ctx.lineWidth = 4;
						ctx.strokeText(text, tx, ty);
						
						ctx.fillStyle = \"#000000\";
						ctx.fillText(text, tx, ty);
					}
				}
				
				function drawPlayer() {
					var x = parseInt(\$(\".value_char_pos_x\").text());
					var y = parseInt(\$(\".value_char_pos_y\").text());
					
					drawPoint(x, y, \"#FF0000\");
				}
				
				// function drawPoints() {
					// var data = [[178, 370], [222, 24], [26, 318], [362, 263], [362, 73], [77, 366]];
					// 
					// data.forEach(function(v, k){
						// drawPoint(v[0], v[1], \"#FFFF00\", v[0] + \", \" + v[1]);
					// });
				// }
			});
		</script>
	</div>
	",
	$field->descString, $self->getMapURL, $self->{csrf}, $field->name, $self->getMapURL, $char->position->{x},
	$char->position->{y});
}

sub getFooter {
	my ($self) = @_;

	return 
	"
	<hr>

	<footer>
		<p align=\"center\">BonScott &copy; webMonitor 2012</p>
	</footer>
	";
}

sub getMapURL {
	my ($self) = @_;
	my $pattern = $config{webMapURL} || '/map/%s';
	my $result = sprintf($pattern, $field->name);

	return $result;
}

sub submitConsoleCommandJS {
	my ($self) = @_;

	return sprintf(
	"
	<script type=\"application/javascript\" defer=\"defer\">
		function sendConsoleCommand() {
			var ic = document.getElementById(\"input_command\");
			var sc = document.getElementById(\"selection_command\");
			window.location.href = '../handler?csrf=%s&command=' + sc.options[sc.selectedIndex].value + ic.value;
			ic.value = '';
		}

		function submit(e) {
			if (window.event)
                if (window.event.keyCode == 13)
                    sendConsoleCommand();
		}
    </script>
	",
	$self->{csrf});
}

sub getInputAppend {
	my ($self, $selected) = @_;
	my $returnString =
	"
	<div class=\"input-append\" rel=\"tooltip\">
		<select class=\"span2\" id=\"selection_command\">
	";

	my @options = (
		{ name => 'Chat', 		command => "c", 		value => 0 },
		{ name => 'Party', 		command => "p", 		value => 1 },
		{ name => 'Guild', 		command => "g", 		value => 2 },
		{ name => 'Console', 	command => undef, 		value => 3 },
	);

	if ($selected) {
		my ($holdValue, $holdI);
		for (my $i = 0; $i < scalar @options; ++$i) {
			if ($selected eq $options[$i]->{name}) {
				$options[0]->{value} = $options[$i]->{value};
				$options[$i]->{value} = 0;
				last;
			}
		}

		@options = sort { $a->{value} cmp $b->{value} } @options;
	}

	for (my $i = 0; $i < scalar @options; ++$i) {
		if ($i == 0) {
			$returnString .= sprintf("<option selected value=\"%s \">%s</option>\n", $options[$i]->{command}, $options[$i]->{name});
		} else {
			$returnString .= sprintf(
			"
			<option value=\"%s \">%s</option>
			", $options[$i]->{command}, $options[$i]->{name});
		}
	}

	$returnString .= 
	"
	</select>

	<input class=\"span9\" id=\"input_command\" type=\"text\" onKeyPress=\"submit(this.event)\">
	<input type=\"button\" class=\"btn span2\" id=\"button_send\" value=\"Send\" disabled onClick=\"sendConsoleCommand()\"/>
	</div>
	";

	return $returnString;
}

1;