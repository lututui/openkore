package WebMonitor::Pages::Homunculus;

use strict;

use WebMonitor::BasePage;
use base qw(WebMonitor::BasePage);
use Globals qw($char);
use Skill;

sub getURL {
	return "/homunculus";
}

sub getName {
	return "Homunculus";
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
	<div class=\"tabbable\">
		<ul class=\"nav nav-tabs\">
			<li class=\"active\"><a href=\"#status\" data-toggle=\"tab\">Status</a></li>
			<li><a href=\"#skills\" data-toggle=\"tab\">Skills</a></li>
			<li><a href=\"#commands\" data-toggle=\"tab\">Commands</a></li>
		</ul>
		
        <div class=\"tab-content\">
            <div class=\"tab-pane active\" id=\"status\">
            <div class=\"span9\">
                <div class=\"span3\">
                    <div align=\"center\">
                        <div class=\"thumbnail job\" id=\"homunculus%d\"></div>
                    </div>
                    
                    <strong>Name</strong>
                    <h6 align=\"left\">
                        <span class=\"value_homunculos_name\">%s</span>
                    </h6>

                    <strong>Level</strong>
                    <h6 align=\"left\">
                        <span class=\"value_homunculos_level\">%d</span>
                    </h6>

                    <strong>HP</strong>
                    <h6 align=\"right\">
                        <span class=\"value_homunculos_hp\">%d</span>
                        /
                        <span class=\"value_homunculos_hp_max\">%d</span>
                    </h6>
                    <div class=\"progress progress_homunculos_hp\" rel=\"tooltip\" title=\"%.2f%%\">
                        <div class=\"bar bar-success\" style=\"width: %.2f%%;\"></div>
                    </div>
                    
                    <strong>SP</strong>
                    <h6 align=\"right\">
                        <span class=\"value_homunculos_sp\">%d</span>
                        /
                        <span class=\"value_homunculos_sp_max\">%d</span>
                    </h6>
                    <div class=\"progress progress_homunculos_sp\" rel=\"tooltip\" title=\"%.2f%%\">
                        <div class=\"bar\" style=\"width: %.2f%%;\"></div>
                    </div>
                    
                    <strong>EXP</strong>
                    <h6 align=\"right\">
                        <span class=\"value_homunculos_exp\">%d</span>
                        /
                        <span class=\"value_homunculus_exp_max\">%d</span>
                    </h6>
                    <div class=\"progress progress_homunculos_exp\" rel=\"tooltip\" title=\"%.2f%%\">
                        <div class=\"bar\" style=\"width: %.2f%%;\"></div>
                    </div>
                    
                    <strong>Hunger</strong>
                    <h6 align=\"right\">
                        <span class=\"value_homunculos_hunger\">%d</span>
                        /
                        <span class=\"value_homunculus_hunger_max\">100</span>
                    </h6>
                    <div class=\"progress progress_homunculos_hunger\" rel=\"tooltip\" title=\"%d%%\">
                        <div class=\"bar\" style=\"width: %d%%;\"></div>
                    </div>
                </div>
                
                <div class=\"span3\">
                    <table class=\"table-condensed\">
                    <tbody>
                        <tr>
                            <td class=\"left\">Atk</td>
                            <td class=\"pull-right\">
                                <span class=\"value_homunculos_atk\">%d</span>
                            </td>
                        </tr>
                        
                        <tr>
                            <td class=\"left\">Matk</td>
                            <td class=\"pull-right\">
                                <span class=\"value_homunculos_atkmagic\">%d</span>
                            </td>
                        </tr>
                        
                        <tr>
                            <td class=\"left\">Aspd</td>
                            <td class=\"pull-right\">
                                <span class=\"value_homunculos_atckspeed\">%d</span>
                            </td>
                        </tr>
                        
                        <tr>
                            <td class=\"left\">Hit</td>
                            <td class=\"pull-right\">
                                <span class=\"value_homunculos_hit\">%d</span>
                            </td>
                        </tr>
                        
                        <tr>
                            <td class=\"left\">Crit</td>
                            <td class=\"pull-right\">
                                <span class=\"value_homunculos_critical\">%d</span>
                            </td>
                        </tr>
                        
                        <tr>
                            <td class=\"left\">Def</td>
                            <td class=\"pull-right\">
                                <span class=\"value_homunculos_def\">%d</span>
                            </td>
                        </tr>
                        
                        <tr>
                            <td class=\"left\">Mdef</td>
                            <td class=\"pull-right\">
                                <span class=\"value_homunculos_mdef\">%d</span>
                            </td>
                        </tr>
                        
                        <tr>
                            <td class=\"left\">Flee</td>
                            <td class=\"pull-right\">
                                <span class=\"value_homunculos_flee\">%d</span>
                            </td>
                        </tr>
                    </tbody>
                    </table>
                </div>
                
                <div class=\"span3\">
                    <table class=\"table-condensed\">
                    <tbody>
                        <tr>
                            <td class=\"left\">Intimacy</td>
                            <td class=\"pull-right\">
                                <span class=\"value_homunculos_intimacy\">%d</span>
                            </td>
                        </tr>
                        
                        <tr>
                            <td class=\"left\">Acessory</td>
                            <td class=\"pull-right\">
                                <span class=\"value_homunculos_attack_magic_min\">%s</span>
                            </td>
                        </tr>

                        <tr>
                            <td class=\"left\">Faith</td>
                            <td class=\"pull-right\">
                                <span class=\"value_homunculos_hit\">%s</span>
                            </td>
                        </tr>
                    </tbody>
                    </table>
                </div>
            </div>
            </div>

			<div class=\"tab-pane\" id=\"skills\">
				<table class=\"table table-hover\">
					<thead>
					<tr>
						<th></th>
						<th><div>Level</div></th>
						<th><div>Name</div></th>
						<th><div>SP</div></th>
						<th><div>Use</div></th>
					</tr>
					</thead>
					
                    <tbody id=\"listarItens\">
                        %s
						<tr>Skill Points: <span class=\"badge badge-success\"><span class=\"value_homunculus_points_skill\">%d</span></span></tr>
					</tbody>
				</table>
			</div>
			
			<div class=\"tab-pane\" id=\"commands\">
				<pre class=\"log console\" style=\"width:900px\">%s</pre>

				<div class=\"input-append\" rel=\"tooltip\">
					<select class=\"span2\" id=\"selection_command\" onChange=\"write_input(this.value)\">
						<option selected value=\"\">Console</option>
						<option value=\"homun s\">Homunculus status</option>
						<option value=\"homun feed\">Feed homunculus</option>
						<option value=\"homun move\">Moves your homunculus</option>
						<option value=\"homun rename\">Rename your homunculus</option>
						<option value=\"homun standby\">Makes your homunculus standby</option>
						<option value=\"homun aiv\">Display current homunculus AI</option>
						<option value=\"homun ai auto\">Turns homunculus AI on</option>
						<option value=\"homun ai manual\">Toggles AI manual</option>
						<option value=\"homun ai off\">Toggles AI off</option>
						<option value=\"homun delete\">Deletes your homunculus</option>
					</select>

					<input class=\"span9\" id=\"input_command\" type=\"text\" onKeyPress=\"submit(this.event)\">
					<input type=\"button\" class=\"btn span1\" id=\"button_send\" value=\"Send\" disabled onClick=\"sendConsoleCommand()\"/>
				</div>
			</div>
        </div>  
    </div>
    </div>
    </div>
    ",
    $self->submitConsoleCommandJS, $char->{homunculus}{jobId}, $char->{homunculus}{name}, $char->{homunculus}{level},
    $char->{homunculus}{hp}, $char->{homunculus}{hp_max}, $char->{homunculus}{hpPercent},
    $char->{homunculus}{hpPercent}, $char->{homunculus}{sp}, $char->{homunculus}{sp_max}, 
    $char->{homunculus}{spPercent}, $char->{homunculus}{spPercent}, $char->{homunculus}{exp},
    $char->{homunculus}{exp_max}, $char->{homunculus}{expPercent}, $char->{homunculus}{expPercent},
    $char->{homunculus}{hunger}, $char->{homunculus}{hunger}, $char->{homunculus}{hunger}, $char->{homunculus}{atk},
    $char->{homunculus}{matk}, $char->{homunculus}{attack_speed}, $char->{homunculus}{hit},
    $char->{homunculus}{critical}, $char->{homunculus}{def}, $char->{homunculus}{mdef}, $char->{homunculus}{flee},
    $char->{homunculus}{intimacy}, $char->{homunculus}{accessory}, $char->{homunculus}{faith},
    $self->getHomunSkillList, $char->{homunculus}{points_skill}, &webMonitorServer::consoleLogHTML);
}

sub getHomunSkillList {
    my ($self) = @_;
    my $returnString;

    foreach my $skillHandle (@{$char->{homunculus}{slave_skillsID}}) {
        my $skill = Skill->new(handle => $skillHandle);

        $returnString .= sprintf(
        "
        <tr>
            <td>
                <img src=\"https://pt.ragnaplace.com/bro/skill/%d.png\"></img>
                %s
            </td>
            <td>
                <div align=\"center\">%d</div>
            </td>
            <td class=\"left\">
                <abbr title=\"%s\">%s</abbr>
            </td>
            <td>
                %d
            </td>
            <td>
                <div align=\"center\">
                    %s
                </div>
            </td>
        </tr>
        ",
        $skill->getIDN, $self->getHomunSkillLevelUpButton($skill), $char->getSkillLevel($skill), $skillHandle,
        $skill->getName, $char->{skills}{$skillHandle}{sp}, $self->getSkillUseButton($skill));
    }
    
    return $returnString;
}

sub getHomunSkillLevelUpButton {
    my ($self, $skill) = @_;

    return undef unless $char->{homunculus}{points_skill} && $char->{homunculus}{skills}{$skill->getIDN}{up};

    return sprintf(
    "
    <div class=\"iconSkill left\">
        <div class=\"iconUp right\">
            <a href=\"/handler?csrf=%s&command=homun+skills+add+%d\" title=\"Level Up\" rel=\"tooltip\">
                <i class=\"icon-plus-sign\"></i>
            </a>
        </div>
    </div>
    ", $self->{csrf}, $skill->getIDN);
}

1;