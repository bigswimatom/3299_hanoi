#!/usr/local/bin/perl -w
# ****************************************************
#  * file  : not_hanoi.pl
#  * author: nakai<nakai@chem.s.u-tokyo.ac.jp>
#  * create day  : Thu Jun  1 12:21:41 2017
#  * last updated: Thu Jun  1 12:31:08 2017
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

my %found;
chomp(my $input = <>);

printf "%d\n",is_OK($input);

sub move{
  my ($input, $count) = @_;
  my @stiks = split ",", $input;
  
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

