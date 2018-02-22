package WebMonitor::Pages::Skill;

use strict;

use WebMonitor::BasePage;
use base qw(WebMonitor::BasePage);
use Globals qw(@skillsID $char);
use Skill;

sub getURL {
	return "/skill";
}

sub getName {
	return "Skill List";
}

sub getIcon {
	return "icon-th-list";
}

sub getContent {
    my ($self) = @_;

    return sprintf(
    "
    <div class=\"span9\">
    <div class=\"row-fluid\">
    <div class=\"span9\">
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
			<tr>Skill Points: <span class=\"badge badge-success\"><span class=\"value_char_points_skill\">%d</span></span></tr>
		</tbody>
	</table>
    </div>
    </div>	  
    </div>
    ", $self->getSkillList, $char->{points_skill});
}

sub getSkillList {
    my ($self) = @_;
    my $returnString;

    foreach my $skillHandle (@skillsID) {
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
            <td>%d</td>
            <td>
                <div align=\"center\">
                    %s
                </div>
            </td>
        </tr>
        ",
        $skill->getIDN, $self->getSkillLevelUpButton($skill), $char->getSkillLevel($skill), $skillHandle,
        $skill->getName, $char->{skills}{$skillHandle}{sp}, $self->getSkillUseButton($skill));
    }

    return $returnString;
}

sub getSkillLevelUpButton {
    my ($self, $skill) = @_;
    
    return undef unless $char->{points_skill} && $char->{skills}{$skill->getHandle}{up};

    return sprintf(
    "
    <div class=\"iconSkill left\">
        <div class=\"iconUp right\">
            <a href=\"/handler?csrf=%s&command=skills+add+%d\" title=\"Level Up\" rel=\"tooltip\">
                <i class=\"icon-plus-sign\"></i>
            </a>
        </div>
    </div>
    ", $self->{csrf}, $skill->getIDN);
}

1;