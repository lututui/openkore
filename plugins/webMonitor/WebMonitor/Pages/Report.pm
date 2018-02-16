package WebMonitor::Pages::Report;

use strict;

use WebMonitor::BasePage;
use base qw(WebMonitor::BasePage);
use Globals qw($char $startTime_EXP $totalBaseExp $totalJobExp $startingzeny @monsters_Killed %itemChange %items_lut);
use Utils qw(timeConvert formatNumber);

sub getURL {
	return "/report";
}

sub getName {
	return "Report";
}

sub getIcon {
	return "icon-tasks";
}

sub getContent {
    my ($self) = @_;

    return sprintf(
    "
    <script type=\"application/javascript\" defer=\"defer\">
		function send_command_reset() {
			window.location.href = '../handler?csrf=%s&command=exp+reset&page=report';
            return false;
		}
    </script>
    <div class=\"span10\">
    <div class=\"row-fluid\">
    <div class=\"span10\">
        <div class=\"span3\">
            <div align=\"center\">
                <div class=\"thumbnail job\" id=\"job%d%d\"></div>
            </div>
            
            <strong>HP</strong>
            <h6 align=\"right\">%d/%d</h6>
            <div class=\"progress\" rel=\"tooltip\" title=\"%.2f%%\">
                <div class=\"bar bar-success\" style=\"width: %.2f%%;\"></div>
            </div>
            
            <strong>SP</strong>
            <h6 align=\"right\">%d/%d</h6>
            <div class=\"progress\" rel=\"tooltip\" title=\"%.2f%%\">
                <div class=\"bar\" style=\"width: %.2f%%;\"></div>
            </div>
        </div>
			
		<div class=\"span8\">
		<div class=\"tabbable\">
			<ul class=\"nav nav-tabs\">
				<li class=\"active\"><a href=\"#exp\" data-toggle=\"tab\" rel=\"tooltip\" title=\"Geral Overview\">Experience</a></li>
				<li><a href=\"#monsters\" data-toggle=\"tab\" rel=\"tooltip\" title=\"Monster Killed Until Now\">Monsters</a></li>
				<li><a href=\"#itens\" data-toggle=\"tab\" rel=\"tooltip\" title=\"Report items of earned and spent\">Itens</a></li>
				<li class=\"pull-right\"><a onClick=\"send_command_reset()\" rel=\"tooltip\" title=\"Reset statistics!\"><i class=\"icon-repeat\"></i><i> Reset</a></i></li>
			</ul>
			
            <div class=\"tab-content\">
                <div class=\"tab-pane active\" id=\"exp\">
                    <i class=\"icon-time\"></i>  Bot Time: %d<br/>
                    <i class=\"icon-exclamation-sign\"></i>  Died: %d<br/>
                    <br/>
                    <i class=\"icon-ok-circle\"></i>  Base Exp Gained: %d (%d per hour)<br/>
                    <i class=\"icon-ok-circle\"></i>  Job Exp Gained: %d (%d per hour)<br/>
                    <br/>
                    <i class=\"icon-circle-arrow-up\"></i>  Time for Base UP: %s<br/>
                    <i class=\"icon-circle-arrow-up\"></i>  Time for Job UP: %s<br/>
                    <br>
                    <i class=\"icon-briefcase\"></i>  zeny made: %d\z
                </div>
				
                <div class=\"tab-pane\" id=\"monsters\">
					<table class=\"table table-hover\">
					<tbody>
						%s
					</tbody>
					</table>
				</div>
				
                <div class=\"tab-pane\" id=\"itens\">
					<table class=\"table table-hover\">
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
    </div>
    ", 
    $self->{csrf}, $char->{sex}, $char->{jobID}, $char->{hp}, $char->{hp_max}, $char->hp_percent, $char->hp_percent,
    $char->{sp}, $char->{sp_max}, $char->sp_percent, $char->sp_percent, timeConvert(&getBottingTime), 
    $char->{deathCount}, $totalBaseExp, &getBaseEXPPerHour, $totalJobExp, &getJobEXPPerHour, 
    timeConvert(&getExpectedBaseLevelUpTime), timeConvert(&getExpectedJobLevelUpTime), formatNumber(&getZenyMade),
    &getMonstersReport, &getItemsReport);
}

sub getBottingTime {
    return time - $startTime_EXP;
}

sub getBaseEXPPerHour {
    my $bottingTime = getBottingTime;
    
    return $totalBaseExp / $bottingTime * 3600 if ($bottingTime);
    return 0;
}

sub getJobEXPPerHour {
    my $bottingTime = getBottingTime;
    
    return $totalJobExp / $bottingTime * 3600 if ($bottingTime);
    return 0;
}

sub getExpectedBaseLevelUpTime {
    my $baseEXPPerHour = getBaseEXPPerHour;

    return ($char->{exp_max} - $char->{exp}) * 3600/ $baseEXPPerHour if ($baseEXPPerHour && $char->{exp_max});
    return 0;
}


sub getExpectedJobLevelUpTime {
    my $jobEXPPerHour = getJobEXPPerHour;

    return ($char->{exp_job_max} - $char->{exp_job}) * 3600 / $jobEXPPerHour if ($jobEXPPerHour && $char->{exp_job_max});
    return 0;
}

sub getZenyMade {
    return $char->{zeny} - $startingzeny;
}

sub getMonstersReport {
    my $returnString;

    foreach my $monster (@monsters_Killed) {
        $returnString .= sprintf (
        "
        <tr>
            <td><img src=\"https://www.ragnaplace.com/bro/mob/%d.gif\"></td>
            <td>%d</td>
            <td><a href=\"http://ratemyserver.net/index.php?page=mob_db&mob_id=%d\">%s</a></td>
        </tr>
        ", 
        $monster->{nameID}, $monster->{count}, $monster->{nameID}, $monster->{name});
    }

    return $returnString;
}

sub getItemsReport {
    my $returnString;
    my %reverseItemsLut = reverse %items_lut;

    foreach my $item (keys %itemChange) {
        $returnString .= sprintf(
        "
        <tr>
            <td><img src=\"https://www.ragnaplace.com/bro/item/%s.png\"/></td>
            <td>%d</td>
            <td><a href=\"http://ratemyserver.net/index.php?page=item_db&item_id=%s\">%s</a></td>
        </tr>
        ", 
        $reverseItemsLut{$item}, $itemChange{$item}, $reverseItemsLut{$item}, $item);
    }

    return $returnString;
}

1;