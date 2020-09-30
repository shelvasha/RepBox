#!/usr/bin/perl
#
# concatenates and translates GFF/GTF and sends output to stdout
# as it goes
#
# WARNING: UNTESTED
#
# Useage: ls *.gtf | xargs ./this-script.pl > concatenated.gtf
#

use strict;

my $offset = 0;
my $max_pos = 0;
my @arl;
my $fname;

#
# get first offset
#

$fname = shift @ARGV;
open FIN, '<', $fname or die($!);
while(<FIN>) {
	# print out
	print STDOUT $_;

	# process offset
	chomp;
	@arl = split(/\t/);
	if($arl[4] > $max_pos) {
		$max_pos = $5;
	}
}

close FIN;

# shift offset forward a base
$offset = $max_pos+1;

while(scalar @ARGV) {

	$fname = shift @ARGV;
	$max_pos = 0;
	open FIN, '<', $fname or die($!);

	while(<FIN>) {
		chomp;
		@arl = split(/\t/);

		# translate this line's coordinates
		$arl[3] += $offset;
		$arl[4] += $offset;

		# update max position from translated file
		if($arl[4] > $max_pos) {
			$max_pos = $arl[4];
		}

		# print translated line out
		print STDOUT join("\t", @arl) . "\n";

	}

	close FIN;

	# update offset for next file
	$offset = $max_pos + 1;

}
