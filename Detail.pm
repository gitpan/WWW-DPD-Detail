package WWW::DPD::Detail;
use strict;
#use warnings;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/dpdcheck/;
our $VERSION = '0.1';
use LWP::Simple;

sub dpdcheck {
	my $paketnummer = shift;
	my $language = shift || 'de';

	my @newdata;
	my $data = get("http://extranet.dpd.de/cgi-bin/delistrack?pknr=$paketnummer&typ=2&lang=$language");
	$data =~ s/[\n\r]//g;

	my($detail) = ($data =~ /<\/form><\/td><\/tr><\/table><\/td><\/tr><tr(.*?)<\/div><br><div id="codeDescription" >/);
	while($detail =~ /<tr(.*?)<\/tr>/ig){
		my $detailone = $1;

		my($datum) = ($detailone =~ /<td style="padding-left: 10px;">(.*?)\s*<\/td>/);
		$datum =~ s/<br>//;
		my($depot,$ort) = ($detailone =~ /style="text-decoration:none"><b>([^<]*)<\/b><\/a><br>&nbsp;([^<]*)<\/td>/);
		my($daten,$land,$plz,$route) = ($detailone =~ /<br>([^<\&]*)&nbsp;<\/td><td style="padding-left: 10px;">&nbsp;<br>(\w*) &bull; (\w*) &bull; (\w*)<\/td>/);
		my($tour,$code) = ($detailone =~ /style="text-align:right; padding-left: 10px;padding-right: 10px;">&nbsp;<br>(\d*) <\/td><td style="[^"]*"><br>(\d*) <\/td>/);
		my %details;
		$details{'datum'} = $datum;
		$details{'depot'} = $depot;
		$details{'ort'} = $ort;
		$details{'daten'} = $daten;
		$details{'tour'} = $tour;
		$details{'code'} = $code;
		$details{'route'} = $route;
		$details{'plz'} = $plz;
		$details{'land'} = $land;
		push(@newdata,\%details)
	}

	return(\@newdata,({
		'shipnumber' => $paketnummer
		})
	);
}


=pod

=head1 NAME

WWW::DPD::Detail - Perl module for the DPD online tracking service with details.

=head1 SYNOPSIS

	use WWW::DPD::Detail;
	my($newdata,$other) = dpdcheck('paketnumber','de');#de or en for text in german or english

	foreach my $key (keys %$other){# shipnumber
		print $key . ": " . ${$other}{$key} . "\n";
	}
	print "\nDetails:\n";

	foreach my $key (@{$newdata}){
		#foreach my $key2 (keys %{$key}){#datum, depot, ort, daten, land, plz, route, tour, code
		#	print ${$key}{$key2};
		#	print "\t";
		#}

		print ${$key}{datum};
		print "\t";
		print ${$key}{depot};
		print "\t";
		print ${$key}{ort};
		print "\t";
		print ${$key}{daten};
		print "\t";
		print ${$key}{land}."-".${$key}{plz}."-".${$key}{route};
		print "\t";
		print ${$key}{tour};
		print "\t";
		print ${$key}{code};
		print "\n";
	}


=head1 DESCRIPTION

WWW::DPD::Detail - Perl module for the DPD online tracking service with details.

=head1 AUTHOR

    Stefan Gipper <stefanos@cpan.org>, http://www.coder-world.de/

=head1 COPYRIGHT

	WWW::DPD::Detail is Copyright (c) 2010 Stefan Gipper
	All rights reserved.

	This program is free software; you can redistribute
	it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO



=cut
