#!usr/bin/perl
use strict;
use File::Basename;

open in,$ARGV[0] or die "$!\n";
my $path=dirname($ARGV[0]);
my $sinefile=$ARGV[1];
my %sines=();
my %order=();
my %pos=();
if(-e $sinefile){
	system "rm $sinefile";
}
while(<in>){
	chomp $_;
	my $u=$_;
	if(-e "$path/$u/$u.sine.fa"){
		open IN,"$path/$u/$u.sine.fa" or die "$!\n";
		my $line;
		my $flag=0;
		my $Number=$u;
		while(defined($line=<IN>)){
			chomp $line;
			if($line=~/>/){
				my @a=split(/\|/,$line);
				$u=$line;
				my @b=split(/-/,$a[1]);
				my $w="$a[0],$a[1]";
				if(!exists $pos{$w}){
					$order{$b[0]}{$u}=$Number;
					$sines{$u}="";
					$flag=1;
					$pos{$w}=1;
				}else{
					$flag=0;
				}
			}else{
				if($flag == 1){
					$sines{$u}.=$line;
				}
			}
		}
		close IN;
	}
}
close in;
undef%pos;

my @A=();
foreach my $first(sort {$a<=>$b} keys %order){
	foreach my $second(sort {$order{$first}{$a}<=>$order{$first}{$b}} keys%{$order{$first}}){ 
		push @A,$second;
	}
}
open out,'>',$sinefile or die "$!\n";
my @b=split(/\|/,$A[0]);
my @c=split(/-/,$b[1]);
my $s=$c[0];
my $e=$c[1];
my $num=@A;
for(my $i=1;$i<$num;$i++){
	@b=split(/\|/,$A[$i]);
	@c=split(/-/,$b[1]);
	if(($s-$c[1])*($e-$c[0]) < 0){
		next;
	}else{
		$s=$c[0];
		$e=$c[1];
		print out"$A[$i]\n$sines{$A[$i]}\n";
	}
}
close out;
