package Language::Prolog::SWI::base;

use 5.006;
use strict;
use warnings;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

#our %EXPORT_TAGS = ( 'all' => [ qw() ] );
#our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw(  );
our $VERSION = '0.01';

# set this to where your SWI Prolog keeps the boot32.prc, pl.rc, ... files
$ENV{SWI_HOME_DIR} = '/usr/lib/swi-prolog/'; # for Debian

use Language::Prolog::SWI;

#use vars qw($AUTOLOAD);

#sub AUTOLOAD {
#  warn $AUTOLOAD;
#}

#*main::SWI::AUTOLOAD = \&AUTOLOAD;

#*main::SWI = *main::Language::Prolog::SWIProlog;
#*main::SWI::PlAtom = *main::Language::Prolog::SWIProlog::PlAtom;

=pod

=head1 NAME

Language::Prolog::SWI - Perl extension for SWI-Prolog (OO Interface)

=head1 SYNOPSIS

  use Language::Prolog::SWI::base;

  # create an engine (actually for initialisation)
  my $e = new Language::Prolog::SWI::PlEngine();
  # add some knowledge
  Language::Prolog::SWI::PlCall ("assert(islocatedin(bonduni,robina))");
  Language::Prolog::SWI::PlCall ("assert(islocatedin(robina,goldcoast))");
  Language::Prolog::SWI::PlCall ("assert(islocatedin(goldcoast,qld))");
  Language::Prolog::SWI::PlCall ("assert((islocatedin2(X,Z):-islocatedin(X,Z)))");
  Language::Prolog::SWI::PlCall ("assert((islocatedin2(X,Z):-islocatedin(X,Y),islocatedin2(Y,Z)))");
  # bind one term, but not the other one
  my $t1 = new Language::Prolog::SWI::PlTerm ("bonduni");
  my $t2 = new Language::Prolog::SWI::PlTerm ();
  # create a Term vector
  my $av = new Language::Prolog::SWI::PlTermv ($t1, $t2);
  my $q  = new Language::Prolog::SWI::PlQuery ("islocatedin2", $av);
  $q->DISOWN(); # read CAVEATS below

  # iterate over all solutions
  while ($q->next_solution) {
    warn "match ".$t1->toString." ".$t2->toString;
  }

=head1 DESCRIPTION

This package is a wrapper for the SWI-Prolog CPP API described
at

  http://www.swi-prolog.org/packages/pl2cpp.html

and implements the classes there with the following exceptions:

=over

=item

the operator PlAtom::const char *(void) has been renamed to C<toString>

=item

the operators PlAtom::== have been renamed to C<eq>

=item

the operator PlTerm::const char *(void) has been renamed to C<toString>

=item

operators PlTerm::(long|int|double) have been omitted

=back

=head1 CAVEATS

As usual with C-based Perl packages there are some issues concerning the
memory allocation. There a good description of the problem at

  http://www.swig.org/Doc1.3/Perl5.html#n41

For the user of this packages this means that for some constructors the
user has to call the DISOWN method to let the wrapper class know that it
should NOT try to DESTROY the object itself. When this really happens
can only be determined by looking at the implementation, sorry.

If you are haunted by segfaults then obviously there is a allocation bug.

=head1 INSTALLATION

See the README file.

=head1 AUTHOR

Robert Barta, rho@bond.edu.au

=head1 SEE ALSO

L<perl>.

=cut

__END__
