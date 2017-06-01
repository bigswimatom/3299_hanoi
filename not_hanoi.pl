#!/usr/local/bin/perl -w
# ****************************************************
#  * file  : not_hanoi.pl
#  * author: nakai<nakai@chem.s.u-tokyo.ac.jp>
#  * create day  : Thu Jun  1 12:21:41 2017
#  * last updated: Thu Jun  1 14:52:05 2017
#
# ****************************************************

use strict;
use Getopt::Long;

my %ctl;
my ($name) = ($0 =~ m|([^/]+)$|);
$name =~ s/\.pl$//;

GetOptions( \%ctl, "help|h", "c|conf=s",)
  or die "invalid options.  Try --help for brief usage.\n";
if ( $ctl{'help'} ) { &help; exit; }

#----------------------------------------------------------------------
# main
#----------------------------------------------------------------------
&startup();

my %queue;
chomp(my $input = <>);
$input .= ",,";
$queue{$input} = 1;
my $count = 1;
while(1){
  foreach my $input (sort{$queue{$a} <=> $queue{$b}} keys %queue){
    move($input, $count);
  }
  $count++;
}

sub move{
  my ($input, $count) = @_;
  delete $queue{$input};
  my @stack = split ",", $input;
  push @stack, "" if($#stack < 1);
  push @stack, "" if($#stack < 2);
  for(my $i = 0; $i < 3; $i++){
    my ($disk, $remaining) = pop_disk($stack[$i]);
    next if($disk < 0);
    #put disk
    for(my $j = 0; $j < 2; $j++){
      if(is_OK($disk . $stack[($i+1+$j)%3])){
        my @new;
        $new[$i] = $remaining;
        $new[($i+1+$j)%3] = $disk . $stack[($i+1+$j)%3];
        $new[($i+2-$j)%3] = $stack[($i+2-$j)%3];
        ($new[1], $new[2]) = ($new[2], $new[1]) if($new[1] gt $new[2]);
        my $key = join ",", @new;
        if($key =~ m/^,,\d+$/){
          printf "%d\n", $count;
          exit;
        }
        unless (exists $queue{$key}){
          $queue{$key} = 1;
        }
      }
    }
  }
}

sub is_OK{
  my $input = shift @_;
  my @disks = split //, $input;
  for(my $i = 0; $i < $#disks+1; $i++){
    my $flag = 0;
    for(my $j = 0; $j < $i; $j++){
      $flag++ if($disks[$i] < $disks[$j])
    }
    return 0 if ($flag > 1);
  }
  return 1;
}

sub pop_disk{
  my $input = shift @_;
  return -1 if $input eq "";
  $input =~ m#^(\d)#;
  return ($1, $');
}


#----------------------------------------------------------------------
sub help {

  print STDERR <<HELP_TEXT;
Usage: $name [Option] text...

Option:
-h, --help
    print this help.
-c, --conf FILE_NAME
    read this configure file
    default conf is ./$name.conf or \$HOME/etc/$name.conf

HELP_TEXT
}

sub startup {
  my $CONF_FILE = "$name.conf";
  if(! -e $CONF_FILE && -e $ENV{"HOME"} . "/etc/" . $CONF_FILE){
    $CONF_FILE = $ENV{"HOME"} . "/etc/" . $CONF_FILE;
  }
  my $confname = $name;
  $confname =~ tr/a-z/A-Z/;
  $CONF_FILE = $ENV{"${confname}_CONF"}
    if (defined $ENV{"${confname}_CONF"});
  $CONF_FILE = $ctl{"c"} if (defined $ctl{"c"});
  if ( -e "$CONF_FILE" ){
    local $/;
    open (File, "< $CONF_FILE") or die "can't open $CONF_FILE: $!";
    flock(File, 1);
    eval <File>; die "Recreate Failure! : $@" if $@;
    close File;
  }
}

