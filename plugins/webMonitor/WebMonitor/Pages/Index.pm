package WebMonitor::Pages::Index;

use strict;

use WebMonitor::BasePage;
use base qw(WebMonitor::BasePage);
use Utils qw(formatNumber);
use Globals qw($char);

sub getURL {
	return "/index";
}

sub getName {
	return "Status";
}

sub getIcon {
	return "icon-user";
}

sub getContent {
    my ($self) = @_;

    return sprintf(
    "
	<script type=\"application/javascript\" defer=\"defer\">
		function stAdd(s) {
			window.location.href = '../handler?csrf=%s&command=st+add+' + s + '&page=index';
			return false;
		}
	</script>

    <div class=\"span9\">
    <div class=\"row-fluid\">
    <div class=\"span9\">
		<div class=\"span3\">
			<div align=\"center\">
				<div class=\"thumbnail job\" id=\"job%d%d\"></div>
			</div>
			
			<strong>HP</strong>
			<h6 align=\"right\">
				<span class=\"value_char_hp\">%d</span>
				/
				<span class=\"value_char_hp_max\">%d</span>
			</h6>
			<div class=\"progress progress_char_hp\" rel=\"tooltip\" title=\"%.2f%%\">
				<div class=\"bar bar-success\" style=\"width: %.2f%%;\"></div>
			</div>

			<strong>SP</strong>
			<h6 align=\"right\">
				<span class=\"value_char_sp\">%d</span>
				/
				<span class=\"value_char_sp_max\">%d</span>
			</h6>
			<div class=\"progress progress_char_sp\" rel=\"tooltip\" title=\"%.2f%%\">
				<div class=\"bar\" style=\"width: %.2f%%;\"></div>
			</div>
		</div>

		<div class=\"span3\">
			<table class=\"table-condensed\">
			<tbody>
				<tr>
					<td class=\"left\">Str</td>
					<td class=\"pull-right\">
						<span class=\"value_char_str\">%d</span>
						+
						<span class=\"value_char_str_bonus\">%d</span>
						<a href=\"javascript:stAdd('str')\" rel=\"tooltip\" title=\"You need %d points for add 1 STR point!\">
							<i class=\"icon-plus-sign\"></i>
						</a>
					</td>
				</tr>
				
				<tr>
					<td class=\"left\">Agi</td>
					<td class=\"pull-right\">
						<span class=\"value_char_agi\">%d</span>
						+
						<span class=\"value_char_agi_bonus\">%d</span>
						<a href=\"javascript:stAdd('agi')\" rel=\"tooltip\" title=\"You need %d points for add 1 AGI point!\">
							<i class=\"icon-plus-sign\"></i>
						</a>
					</td>
				</tr>
				
				<tr>
					<td class=\"left\">Vit</td>
					<td class=\"pull-right\">
						<span class=\"value_char_vit\">%d</span>
						+
						<span class=\"value_char_vit_bonus\">%d</span>
						<a href=\"javascript:stAdd('vit')\" rel=\"tooltip\" title=\"You need %d points for add 1 VIT point!\">
							<i class=\"icon-plus-sign\"></i>
						</a>
					</td>
				</tr>
				
				<tr>
					<td class=\"left\">Int</td>
					<td class=\"pull-right\">
						<span class=\"value_char_int\">%d</span>
						+
						<span class=\"value_char_int_bonus\">%d</span>
						<a href=\"javascript:stAdd('int')\" rel=\"tooltip\" title=\"You need %d points for add 1 INT point!\">
							<i class=\"icon-plus-sign\"></i>
						</a>
					</td>
				</tr>
				
				<tr>
					<td class=\"left\">Dex</td>
					<td class=\"pull-right\">
						<span class=\"value_char_dex\">%d</span>
						+
						<span class=\"value_char_dex_bonus\">%d</span>
						<a href=\"javascript:stAdd('dex')\" rel=\"tooltip\" title=\"You need %d points for add 1 DEX point!\">
							<i class=\"icon-plus-sign\"></i>
						</a>
					</td>
				</tr>
				
				<tr>
					<td class=\"left\">Luk</td>
					<td class=\"pull-right\">
						<span class=\"value_char_luk\">%d</span>
						+
						<span class=\"value_char_luk_bonus\">%d</span>
						<a href=\"javascript:stAdd('luk')\" rel=\"tooltip\" title=\"You need %d points for add 1 LUK point!\">
							<i class=\"icon-plus-sign\"></i>
						</a>
					</td>
				</tr>
				
				<tr>
					<td></td>
				</tr>
				
				<tr>
					<td class=\"left\">Status Points</td>
					<td class=\"pull-right\">
						<span class=\"value_char_points_free\">%d</span>
					</td>
				</tr>
			</tbody>
			</table>
		</div>
		
		<div class=\"span3\">
			<table class=\"table-condensed\">
			<tbody>
				<tr>
					<td class=\"left\">Atk</td>
					<td class=\"pull-right\">
						<span class=\"value_char_attack\">%d</span>
						+
						<span class=\"value_char_attack_bonus\">%d</span>
					</td>
				</tr>

				<tr>
					<td class=\"left\">Matk</td>
					<td class=\"pull-right\">
						<span class=\"value_char_attack_magic_max\">%d</span>
						~
						<span class=\"value_char_attack_magic_min\">%d</span>
					</td>
				</tr>
				
				<tr>
					<td class=\"left\">Hit</td>
					<td class=\"pull-right\">
						<span class=\"value_char_hit\">%d</span>
					</td>
				</tr>
				
				<tr>
					<td class=\"left\">Critical</td>
					<td class=\"pull-right\">
						<span class=\"value_char_critical\">%d</span>
					</td>
				</tr>
				
				<tr>
					<td class=\"left\">Def</td>
					<td class=\"pull-right\">
						<span class=\"value_char_def\">%d</span>
						+
						<span class=\"value_char_def_bonus\">%d</span>
					</td>
				</tr>
				
				<tr>
					<td class=\"left\">Mdef</td>
					<td class=\"pull-right\">
						<span class=\"value_char_def_magic\">%d</span>
						+
						<span class=\"value_char_def_magic_bonus\">%d</span>
					</td>
				</tr>
				
				<tr>
					<td class=\"left\">Flee</td>
					<td class=\"pull-right\">
						<span class=\"value_char_flee\">%d</span>
						+
						<span class=\"value_char_flee_bonus\">%d</span>
					</td>
				</tr>
				
				<tr>
					<td class=\"left\">Aspd</td>
					<td class=\"pull-right\">
						<span class=\"value_char_attack_speed\">%d</span>
					</td>
				</tr>
			</tbody>
			</table>
		</div>
		
		<div class=\"span3\">
			<table class=\"table-condensed\">
			<tbody>
				<tr>Base Level
					<h6 align=\"right\">
						<span class=\"value_char_exp\">%d</span>
						/
						<span class=\"value_char_exp_max\">%d</span>
					</h6>
					<div class=\"progress progress_char_exp\" rel=\"tooltip\" title=\"%.2f%%\">
						<div class=\"bar\" style=\"width: %.2f%%;\"></div>
					</div>
				</tr>
				
				<tr>Job Level<br/>
					<h6 align=\"right\">
						<span class=\"value_char_exp_job\">%d</span>
						/
						<span class=\"value_char_exp_job_max\">%d</span>
					</h6>
					<div class=\"progress progress_char_exp_job\" rel=\"tooltip\" title=\"%.2f%%\">
						<div class=\"bar\" style=\"width: %.2f%%;\"></div>
					</div>
				</tr>
				
				<tr>Weight<br/>
					<h6 align=\"right\">
						<span class=\"value_char_weight\">%d</span>
						/
						<span class=\"value_char_weight_max\">%d</span>
					</h6>
					<div class=\"progress progress_char_weight\" rel=\"tooltip\" title=\"%.2f%%\">
						<div class=\"bar bar-danger\" style=\"width: %.2f%%;\"></div>
					</div>
				</tr>
				
				<tr>Zeny<br/>
					<div class=\"pull-right\">
						<span class=\"label label-success\">
							<span class=\"value_char_zeny\">%s</span>
						</span>
					</div>
				</tr>
				
			</tbody>
			</table>
		</div>
		
		<div class=\"span4\">
			<table class=\"table-condensed\">
			<tbody>
				<tr>
					<b>Status:</b> %s
				</tr>
			</tbody>
			</table>
		</div>
    </div>
	%s
	</div>
	</div>
    ",
    $self->{csrf}, $char->{sex}, $char->{jobID}, $char->{hp}, $char->{hp_max}, $char->hp_percent, $char->hp_percent,
	$char->{sp}, $char->{sp_max}, $char->sp_percent, $char->sp_percent, $char->{str}, $char->{str_bonus}, 
	$char->{points_str}, $char->{agi}, $char->{agi_bonus}, $char->{points_agi}, $char->{vit}, $char->{vit_bonus},
	$char->{points_vit}, $char->{int}, $char->{int_bonus}, $char->{points_int}, $char->{dex}, $char->{dex_bonus},
	$char->{points_dex}, $char->{luk}, $char->{luk_bonus}, $char->{points_luk}, $char->{points_free}, $char->{attack},
	$char->{attack_bonus}, $char->{attack_magic_max}, $char->{attack_magic_min}, $char->{hit}, $char->{critical},
	$char->{def}, $char->{def_bonus}, $char->{def_magic}, $char->{def_magic_bonus}, $char->{flee}, $char->{flee_bonus},
	$char->{attack_speed}, $char->{exp}, $char->{exp_max}, $char->exp_base_percent, $char->exp_base_percent,
	$char->{exp_job}, $char->{exp_job_max}, $char->exp_job_percent, $char->exp_job_percent, $char->{weight},
	$char->{weight_max}, $char->weight_percent,	$char->weight_percent, formatNumber($char->{zeny}), 
	$char->statusesString, $self->getSidebar);
}

1;