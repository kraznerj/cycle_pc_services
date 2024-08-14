#!/usr/bin/perl
####################################################
#This script will cycle windows services via cygwin#
####################################################

############################################
#####Check to make sure User is Oracle######
############################################
my $login = (getpwuid $>);
die "must run as oracle" if $login ne 'oracle';

###################
###HELP Function###
###################
sub usage {
    print <<HELP

  \e[1m$0\e[0m

  This script will cycle windows services via cygwin

  \e[1mUSAGE:\e[0m

    $0; <pc_name>
    $0; <pc_name> <pc_name>

HELP
}
if( $ARGV[0] eq '-h' || $ARGV[0] eq '-help')
{
  usage();
  die;
}

#Accept CLI args into array
