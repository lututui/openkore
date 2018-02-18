package WebMonitor::Pages::Guild;

use strict;

use WebMonitor::BasePage;
use base qw(WebMonitor::BasePage);
use Globals qw($char %guild %jobs_lut);

sub getURL {
	return "/guild";
}

sub getName {
	return "Guild";
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
					<th>Guild: %s</th>
                    <th>Master: %s</th>
					<th>Level: %d</th>
                    <th>Connect: <span class=\"badge badge-success\">%d</span>/<span class=\"badge badge-inverse\">%d</span></th>
					<th>Exp: %d/%d</th>
				</tr>
				<tr>
					<th><div align=\"center\">Name</div></th>
					<th><div align=\"center\">Class</div></th>
					<th><div align=\"center\">Level</div></th>
					<th><div align=\"center\">Title</div></th>
					<th><div align=\"center\">Online</div></th>
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
    $char->{guild}{name}, $guild{master}, $guild{lv}, $guild{conMember}, $guild{maxMember}, $guild{exp},
    $guild{exp_next}, $self->getGuildMemberList);
}

sub getGuildMemberList {
    my ($self) = @_;
    my $returnString;

    return unless $guild{member} && @{$guild{member}};

    foreach my $member (@{$guild{member}}) {
        $returnString .= sprintf(
        "
        <tr>
            <td><div align=\"center\">%s</div></td>
            <td><div align=\"center\">%s</div></td>
            <td><div align=\"center\">%d</div></td>
            <td><div align=\"center\">%s</div></td>
            <td><div align=\"center\">
        ", $member->{name}, $jobs_lut{$member->{jobID}}, $member->{lv}, $member->{title});

        if ($member->{online}) {
            $returnString .= "<span class='label label-success'>Online</span>";
        } else {
            $returnString .= "<span class='label label-important'>Offline</span>";
        }

        $returnString .= "</div></td></tr>";
    }

    return $returnString;
}

1;