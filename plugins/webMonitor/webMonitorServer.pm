package webMonitorServer;

# webMonitor - an HTTP interface to monitor bots
# Copyright (C) 2006 kaliwanagan
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#############################################

# webMonitorV2 - Web interface to monitor yor bots
# Copyright (C) 2012 BonScott
# thanks to iMikeLance
#
# ------------------------------
# How use:
# Add in your config.txt
#
# webPort XXXX
# 
# Where XXXX is a number of your choice. Ex:
# webPort 1020
#
# If webPort not defined in config, the default port is 1025
# ------------------------------
# Set only one port for each bot. For more details, visit:
# [OpenKoreBR]
#	http://openkore.com.br/index.php?/topic/3189-webmonitor-v2-by-bonscott/
# [OpenKore International]
#	http://forums.openkore.com/viewtopic.php?f=34&t=18264
#############################################

use strict;

use Base::WebServer;
use base qw(Base::WebServer);
use Utils qw(getFormattedDateShort);
use Globals qw(%consoleColors $field $messageSender @venderListsID);
use Log qw(message debug warning error);
use Field;
use List::MoreUtils;

use WebMonitor::Pages::Index;
use WebMonitor::Pages::Inventory;
use WebMonitor::Pages::Report;
use WebMonitor::Pages::Config;
use WebMonitor::Pages::Console;
use WebMonitor::Pages::Chat;
use WebMonitor::Pages::Guild;
use WebMonitor::Pages::Shop;

BEGIN {
	eval {
		require Math::Random::Secure;
		Math::Random::Secure->import('rand');
	};

	eval {
		require HTML::Entities;
		HTML::Entities->import('encode_entities');
	};
	if ($@) {
		*encode_entities = sub { '' };
	}

	eval {
		require File::ReadBackwards;
	};
}

my $time = getFormattedDateShort(time, 1);
our @pageList = qw(WebMonitor::Pages::Index WebMonitor::Pages::Inventory WebMonitor::Pages::Report
	WebMonitor::Pages::Config WebMonitor::Pages::Console WebMonitor::Pages::Chat WebMonitor::Pages::Guild
	WebMonitor::Pages::Shop);
my %fileRequests = 
	(
		'/css/bootstrap.min.css'				=>	1,
		'/css/webMonitor.css'					=>	1,
		'/img/glyphicons-halflings.png'			=>	1,
		'/img/favicon.png'						=>	1,
		'/img/glyphicons-halflings-white.png'	=>	1,
		'/js/bootstrap.min.js'					=>	1,
		'/js/bootstrap-2.0.2.js'				=>	1,
		'/js/jquery.min.js'						=>	1,
		'/js/webMonitor.js'						=>	1,
		'default'								=>	0,
	);
my @consoleCommandsBlacklist =
	qw(
		eval
	);
###
# cHook
#
# This sub hooks into the Log module of OpenKore in order to store console
# messages into a FIFO array @messages. Many thanks to PlayingSafe, from whom
# most of the code was derived from.
our @messages;
my $cHook = Log::addHook(\&cHook, "Console Log");
my $hookShopList = Plugins::addHook('packet_vender_store', \&hookShopList);
our $shopNumber;

# CSRF prevention token
my $csrf = int rand 2**32;

sub new {
	my $class = shift;
	my $self = $class->SUPER::new(@_);
	
	message sprintf("webMonitor started at http://%s:%s/\n", $self->getHost, $self->getPort), 'connection';
	return $self;
}

sub checkCSRF {
	my ($self, $process) = @_;
	my $ret = $process->{GET}{csrf} eq $csrf;
	
	unless ($ret) {
		$process->status(403 => 'Forbidden');
		$process->header('Content-Type' => 'text/html');
		$process->shortResponse('<h1>Forbidden</h1>');
	}
	
	return $ret;
}

sub cHook {
	my ($type, $domain, $level, $currentVerbosity, $message, $data) = @_;

	if ($level <= $currentVerbosity) {
		push @messages, {type => $type, domain => $domain, level => $level, message => $message};

		# Make sure we don't let @messages grow too large
		# TODO: make the message size configurable
		while (@messages > 40) {
			splice @messages, 0, -20
		}
	}
}

sub getConsoleColors {
	my $css;

	foreach my $type (keys %consoleColors) {
		foreach my $domain (keys %{$consoleColors{$type}}) {
			next unless $type =~ /^\w+$/ && $domain =~ /^\w+$/;
			$css .= ".msg_" . $type . "_" . $domain . " { color: " . $consoleColors{$type}{$domain} . "; }\n";
		}
	}

	return $css;
}

sub consoleLogHTML {
	my @parts;

	if (defined &HTML::Entities::encode) {
		foreach my $msg (@messages) {
			my $domain = $consoleColors{$msg->{type}}{$msg->{domain}} ? $msg->{domain} : 'default';
			my $class = messageClass($msg->{type}, $msg->{domain});
			$class = ' class="' . $class . '"' if $class;

			push @parts, '<span' . $class . '>' . encode_entities($msg->{message}) . '</span>';
		}

		push @parts, '<noscript><span class="msg_web">Reload to get new messages.</span></noscript>';

		return "@parts";
	}

	return '<span class="msg_web"><a href="http://search.cpan.org/perldoc?HTML::Entities">HTML::Entities</a> is required to display console log.' . "\n" . '</span>';
}

sub messageClass {
	my ($type, $domain) = @_;
	return unless $type =~ /^\w+$/ && $domain =~ /^\w+$/;
	$domain = 'default' unless $consoleColors{$type}{$domain};
	'msg_' . $type . '_' . $domain
}

# TODO merge with chist command somehow, new API?
# TODO chat_log_file's contents are formatted and look different
sub loadTextToHTML {
	my ($file) = @_;
	my @parts;
	
	my $bw = eval { File::ReadBackwards->new($file) };
	
	if ($@ or not defined $bw) {
		if ($@ =~ 'perhaps you forgot to load "File::ReadBackwards"' || $@ =~ 'Can\'t locate object method "new" via package "File::ReadBackwards"') {
			return '<span class="msg_web"><a href="http://search.cpan.org/perldoc?File::ReadBackwards">File::ReadBackwards</a> is required to retrieve chat log.' . "\n" . '</span>'
		}
		return '<span class="msg_error_default">Error while retrieving file \'' . $file . "\n" . encode_entities($@) . '</span>'
	}

	if (defined &HTML::Entities::encode) {
		push @parts, '<noscript><span class="msg_web">Load $file:</span></noscript>';
			
		while (defined(my $line = $bw->readline)) {
			push @parts, encode_entities($line);
			# TODO: make the message size configurable
			last if @parts > 20;
		}
			
		@parts = reverse @parts;
		push @parts, '<noscript><span class="msg_web">Reload to get new messages.</span></noscript>';

		return "@parts";
	}
		
	return '<span class="msg_web"><a href="http://search.cpan.org/perldoc?HTML::Entities">HTML::Entities</a> is required to display chat log.' . "\n" . '</span>';
}

###
# $webMonitorServer->request
#
# This virtual method will be called every time a web browser requests a page
# from this web server. We override this method so we can respond to requests.
sub request {
	my ($self, $process) = @_;
	my $content = '';
	
	# We then inspect the headers the client sent us to see if there are any
	# resources that was sent
	my %resources = %{$process->{GET}};
	
	my $filename = $process->file;

	# map / to /index
	$filename .= 'index' if ($filename =~ /\/$/);
	# alias the newbie maps to new_zone01
	$filename =~ s/new_.../new_zone01/;

	my $csrf_pass = $resources{csrf} eq $csrf;

	debug "[webMonitorServer] received request for " . $filename . "\n";
	
	# Deal with action requests
	if ($filename eq '/handler') {
		$self->checkCSRF($process) or return;
		handle(\%resources, $process);

	# Deal with map image requests
	} elsif ($filename =~ /^\/map\/(\w+)$/) {
		my $field = Field->new(name => "$1");
		my $image = $field->image('png, jpg');
		$process->header('Content-Type', contentType($image));
		if (sendFile($process, $image)) {
			debug "[webMonitorServer] Requested image " . $image . " sent successfully\n";
		} else {
			debug "[webMonitorServer] Requested image " . $image . " could not be sent\n";
			$process->status(500, 'Internal Server Error');
		}
	# Deal with allowed file requests
	} elsif ($fileRequests{$filename} || $fileRequests{default}) {
		$process->header("Content-Type", contentType($filename));

		# See if the file being requested exists in the file system. This is
		# useful for static stuff like style sheets and graphics.
		my $fullFilename = $webMonitorPlugin::path . '/WWW/' . $filename;
		if (sendFile($process, $fullFilename)) {
			debug "[webMonitorServer] Requested file " . $fullFilename . " sent successfully\n";
		} else {
			debug "[webMonitorServer] Requested file " . $fullFilename . " could not be sent\n";
			$process->status(500, 'Internal Server Error');
		}
	} else {
		my $packageIndex = List::MoreUtils::first_index { $_->getURL eq $filename } @pageList;

		# Deal with page requests
		if ($packageIndex != -1) {
			$process->header("Content-Type", "text/html");
			$process->print($pageList[$packageIndex]->new($csrf, $time)->build);
		} else {
			$process->header('Content-Type', 'text/html');

			# Deal with forbidden file requests
			if (-e $filename) {
				$process->status(403, 'Forbidden');
				$process->shortResponse("<h1>Forbidden</h1>");

			# Deal with unknown requests
			} else {
				$process->status(404, 'Not Found');
				$process->shortResponse("<h1>Not Found</h1>");
			}
		}
	}
}

sub sendFile {
	my ($process, $filename) = @_;

	if (open my $f, '<', $filename) {
		binmode $f;
		while (read $f, my $buffer, 1024) {
			$process->print($buffer);
		}
		close $f;
		return 1;
	}
}

sub handle {
	my $resources = shift;
	my $process = shift;
	my $retval;

	if ($resources->{command}) {
		# Sanitize command received from web
		if (index($resources->{command}, ";;") != -1) {
			error "Sublines are not allowed in web context: $resources->{command}\n";
		} else {
			unless (List::MoreUtils::any { $resources->{command} =~ /^$_/ } @consoleCommandsBlacklist) {
				message "New command received via web: $resources->{command}\n";
				if ($resources->{command} =~ /^reload/) {
					# Deal with windows files using \ as a path separator, 
					# which is the escape character and affects Settings::loadByRegex
					$resources->{command} =~ s/\\/\\\\/;
				}
				Commands::run($resources->{command});
			} else {
				error "Received blacklisted command via web: $resources->{command}\n";
			}
		}
	}

	if ($resources->{x} && $resources->{y}) {
		my ($x, $y) = map int, @{$resources}{qw(x y)};
		$y = $field->{height} - $y;
		Commands::run("move $x $y");
	}

	# Used Shop tab
	if ($resources->{shop}) {
		# Tell send\ServerType0.pm to send packets to Ragnarok, in order to list the itens from the shop
		$shopNumber = $resources->{shop};
		$messageSender->sendEnteringVender($venderListsID[$shopNumber]);
		# Look "sub hookShopList" to learn how the data reading was made
	}

	# make sure this is the last resource to be checked
	if ($resources->{page}) {
		my $filename = $resources->{page};
		$filename .= 'index' if ($filename =~ /\/$/);

		# hooray for standards-compliance
 		$process->header('Location', $filename);
		$process->status(303, "See Other");
		$process->print("\n");
		return;
	}

	$process->status(204 => 'No Content');
}

sub contentType {
	# TODO: make it so we don't depend on the filename extension for the content
	# type. Instead, look in the file to determine the content-type.
	my $filename = shift;
	
	my @parts = split /\./, $filename;
	my $extension = lc($parts[-1]);
	
	return "text/html"						if ($extension eq "htm" or $extension eq "html");
	return "text/plain"						if ($extension eq "txt");
	return "text/css"						if ($extension eq "css");
	
	return "image/gif"						if ($extension eq "gif");
	return "image/png"						if ($extension eq "png");
	return "image/jpeg"						if ($extension eq "jpg" or $extension eq "jpeg");
	
	return "video/x-ms-asf" 				if ($extension eq "asf");
	return "video/avi" 						if ($extension eq "avi");
	return "video/mpeg"						if ($extension eq "mpg" or $extension eq "mpeg");
	
	return "audio/wav"						if ($extension eq "wav");
	return "audio/mpeg3"					if ($extension eq "mp3");
	
	return "application/msword" 			if ($extension eq "doc");
	return "application/zip"				if ($extension eq "zip");
	return "application/vnd.ms-excel"		if ($extension eq "xls");
	return "application/rtf"				if ($extension eq "rtf");
	return "application/pdf"				if ($extension eq "pdf");
	
	return "application/x-unknown";
}

1;

	# the webserver shouldn't differentiate between actual characters and url
	# encoded characters. see http://www.blooberry.com/indexdot/html/topics/urlencoding.htm
#	$filename =~ s/\%24/\$/sg;
#	$filename =~ s/\%26/\&/sg;
#	$filename =~ s/\%2B/\+/sg;
#	$filename =~ s/\%2C/\,/sg;
#	$filename =~ s/\%2F/\//sg;
#	$filename =~ s/\%3A/\:/sg;
#	$filename =~ s/\%3B/\:/sg;
#	$filename =~ s/\%3D/\=/sg;
#	$filename =~ s/\%3F/\?/sg;
#	$filename =~ s/\%40/\@/sg;
#	$filename =~ s/\%20/\+/sg;
#	$filename =~ s/\%22/\"/sg;
#	$filename =~ s/\%3C/\</sg;
#	$filename =~ s/\%3E/\>/sg;
#	$filename =~ s/\%23/\#/sg;
#	$filename =~ s/\%25/\%/sg;
#	$filename =~ s/\%7B/\{/sg;
#	$filename =~ s/\%7D/\}/sg;
#	$filename =~ s/\%7C/\|/sg;
#	$filename =~ s/\%5C/\\/sg;
#	$filename =~ s/\%5E/\^/sg;
#	$filename =~ s/\%7E/\~/sg;
#	$filename =~ s/\%5B/\[/sg;
#	$filename =~ s/\%5D/\]/sg;
#	$filename =~ s/\%60/\`/sg;
