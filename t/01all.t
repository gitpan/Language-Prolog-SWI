use Test::More tests => 11;

require_ok( 'Language::Prolog::SWI::base' );

# atoms

my $e = new Language::Prolog::SWI::PlEngine();

{
  my $a = new Language::Prolog::SWI::PlAtom ("robert");
  is ($a->toString, "robert", "Atom string");
  
  my $t = new Language::Prolog::SWI::PlTerm ("anitta");
  my $b = new Language::Prolog::SWI::PlAtom ($t);
  is ($b->toString, "anitta", "Atom string2");
  ok (! Language::Prolog::SWI::PlAtom::eq ($a, $b), 'Atom eq different');
  
  my $s = new Language::Prolog::SWI::PlTerm ("robert");
  my $c = new Language::Prolog::SWI::PlAtom ($s);
  ok (Language::Prolog::SWI::PlAtom::eq ($a, $c), 'Atom eq equal');
}

# terms
{
  my $t = new Language::Prolog::SWI::PlTerm ("robert");
  is ($t->toString, "robert", "Term string");

  my $a = new Language::Prolog::SWI::PlAtom ("anitta");
  my $s = new Language::Prolog::SWI::PlTerm ($a);
  is ($s->toString, "anitta", "Term string2");

}

# termvs

{
  my $ts = new Language::Prolog::SWI::PlTermv (3);
  ok (1, 'Termv with int');
  my $s = new Language::Prolog::SWI::PlTerm ("robert");
  my $ts = new Language::Prolog::SWI::PlTermv ($s);
  ok (1, 'Termv with term');
  my $t = new Language::Prolog::SWI::PlTerm ("anitta");
  $ts = new Language::Prolog::SWI::PlTermv ($s, $t);
  ok (1, 'Termv with terms');
}

# queries

{
  Language::Prolog::SWI::PlCall ("assert(islocatedin(bonduni,robina))");
  Language::Prolog::SWI::PlCall ("assert(islocatedin(robina,goldcoast))");
  Language::Prolog::SWI::PlCall ("assert(islocatedin(goldcoast,qld))");
  Language::Prolog::SWI::PlCall ("assert((islocatedin2(X,Z):-islocatedin(X,Z)))");
  Language::Prolog::SWI::PlCall ("assert((islocatedin2(X,Z):-islocatedin(X,Y),islocatedin2(Y,Z)))");

  
  my $t1 = new Language::Prolog::SWI::PlTerm ("bonduni");
  my $t2 = new Language::Prolog::SWI::PlTerm ();
  my $av = new Language::Prolog::SWI::PlTermv ($t1, $t2);
  my $q  = new Language::Prolog::SWI::PlQuery ("islocatedin2", $av);
  $q->DISOWN();
  
  my @results;
  while ($q->next_solution) {
##    warn "match ".$t1->toString." ".$t2->toString;
    push @results, $t2->toString;
  }
  my @expect = qw (robina goldcoast qld);
  ok (eq_set(\@expect, \@results), 'Query all found');
}





__END__

use Language::Prolog::SWI;


Language::Prolog::SWI::PlCall ("assert(islocatedin(bonduni,robina))");
Language::Prolog::SWI::PlCall ("assert(islocatedin(robina,goldcoast))");
Language::Prolog::SWI::PlCall ("assert(islocatedin(goldcoast,qld))");
Language::Prolog::SWI::PlCall ("assert((islocatedin2(X,Z):-islocatedin(X,Z)))");
Language::Prolog::SWI::PlCall ("assert((islocatedin2(X,Z):-islocatedin(X,Y),islocatedin2(Y,Z)))");


my $t1 = new Language::Prolog::SWI::PlTerm ();
my $t2 = new Language::Prolog::SWI::PlTerm ();
my $av = new Language::Prolog::SWI::PlTermv ($t1, $t2);
my $q  = new Language::Prolog::SWI::PlQuery ("islocatedin2", $av);
$q->DISOWN();

while ($q->next_solution) {
  warn "match ".$t1->toString." ".$t2->toString;
}



__END__


my $a = Language::Prolog::SWIc::new_PlAtom ("robert");

use Data::Dumper;
warn Dumper $a;

warn $a->toString;
__END__


my $self = Language::Prolog::SWIc::new_PlTermv(@args);

__END__
my $av = new Language::Prolog::SWI::PlTermv ();

use Data::Dumper;
warn $t1;
__END__

use Language::Prolog::SWI;

my $e = new Language::Prolog::SWI::PlEngine();

Language::Prolog::SWI::PlCall ("assert(likes(robert,anitta))");
Language::Prolog::SWI::PlCall ("assert(likes(robert,anitta2))");
Language::Prolog::SWI::PlCall ("assert(likes(prolog,anitta2))");
Language::Prolog::SWI::PlCall ("assert(likes(robert,M) :- likes(M,anitta))");
Language::Prolog::SWI::PlCall ("assert(islocatedin(bonduni,robina))");
Language::Prolog::SWI::PlCall ("assert(islocatedin(robina,goldcoast))");
Language::Prolog::SWI::PlCall ("assert(islocatedin(goldcoast,qld))");
Language::Prolog::SWI::PlCall ("assert((islocatedin2(X,Z):-islocatedin(X,Z)))");
Language::Prolog::SWI::PlCall ("assert((islocatedin2(X,Z):-islocatedin(X,Y),islocatedin2(Y,Z)))");


my $t1 = new Language::Prolog::SWI::PlTerm ();
my $t2 = new Language::Prolog::SWI::PlTerm ("qld");
my $av = new Language::Prolog::SWI::PlTermv ($t1, $t2);
my $q  = new Language::Prolog::SWI::PlQuery ("islocatedin2", $av);

while ($q->next_solution) {
  warn "match ".$t1->toString." ".$t2->toString;
}

$q->DISOWN();

__END__

use SWIProlog;

my $e = new SWIProlog::PlEngine ("xyz");

SWIProlog::PlCall ("assert(likes(robert,anitta))");
SWIProlog::PlCall ("assert(likes(robert,anitta2))");
SWIProlog::PlCall ("assert(likes(prolog,anitta2))");

my $t1 = new SWIProlog::PlTerm ();
my $t2 = new SWIProlog::PlTerm ();

{
  my $av = new SWIProlog::PlTermv ($t1, $t2);
  my $q  = new SWIProlog::PlQuery ("likes", $av);

  while ($q->next_solution) {
    warn "match ".$t1->toString." ".$t2->toString;
  }
}

#warn "the end";


__END__



my $r = new SWIProlog::PlAtom("robert");
my $a = new SWIProlog::PlAtom("anitta");


use Data::Dumper;
warn Dumper $a, $r;

warn $a->sprintf;


__END__

use SWIProlog;
if (SWIProlog::PlAtom_eq ($a, $r)) {
  warn "EQUAL!!";
} elsif (SWIProlog::PlAtom_eq ($a, "anitta")) {
  warn "EQUAL2!!";
}


my $e = SWIProlog::new_PlEngine("xyz");

SWIProlog::PlCall ("assert(likes(robert,anitta))");
SWIProlog::PlCall ("assert(likes(robert,anitta2))");
SWIProlog::PlCall ("assert(likes(prolog,anitta2))");

my $t1 = SWIProlog::new_PlTerm ();
my $t2 = SWIProlog::new_PlTerm ();

warn $t1->SWIProlog::PlTerm_tostring;
warn $t2->SWIProlog::PlTerm_tostring;



my $av = SWIProlog::new_PlTermv ($t1, $t2);
my $q  = SWIProlog::new_PlQuery ("likes", $av);

while ($q->SWIProlog::PlQuery_next_solution) {
  warn "match ".$t1->SWIProlog::PlTerm_tostring." ".$t2->SWIProlog::PlTerm_tostring;
}

__END__

my $f = SWIProlog::new_PlFunctor(300, "robert");

eval {
  $f->SWIProlog::PlFunctor_rxumsti ("xxx");
}; if ($@) {
  print "Hey there was an exception: $@\n";
}

#print $f->{atomx};
#       SWIProlog::new_PlFunctor
#my $f = SWIProlog::_wrap_new_PlFunctor ("xxx", 3);
