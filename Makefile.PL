use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Language::Prolog::SWI',
    'VERSION_FROM'	=> 'SWI/base.pm', # finds $VERSION
    'PREREQ_PM'		=> { Test::More => 0.46 }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'SWI/base.pm', # retrieve abstract from module
       AUTHOR     => 'R. Barta <rho@bond.edu.au>') : ()),
);


package MY;

sub dynamic_lib {
    return <<MAKE

# this is the place for Debian (make sure the Makefile there is unzipped!)
TOP        = /usr/doc/swig1.3/examples
# this might be the place when using the sources
#TOP        = /usr/local/src/SWIG-1.3.14/Examples/
SWIG       = swig
CXXSRCS    = SWIProlog.cpp
TARGET     = SWI
INTERFACE  = SWI.i
LIBS       = -lpl -dl -lreadline -lcurses -lm
SWIGOPT    = -proxy

#wrapper2::
#	\$(MAKE) -f \$(TOP)/Makefile CXXSRCS='\$(CXXSRCS)' SWIG='\$(SWIG)' LIBS='\$(LIBS)' SWIGOPT='\$(SWIGOPT)' TARGET='\$(TARGET)' INTERFACE='\$(INTERFACE)' perl5_cpp

wrapper:: SWI.pm SWI.so

SWI.pm: SWIProlog.cpp SWI.i
	\$(SWIG) -perl5 -c++ -proxy SWI.i

SWI.so:
	\$(MAKE) -f \$(TOP)/Makefile CXXSRCS='\$(CXXSRCS)' SWIG='\$(SWIG)' LIBS='\$(LIBS)' SWIGOPT='\$(SWIGOPT)' TARGET='\$(TARGET)' INTERFACE='\$(INTERFACE)' perl5_cpp

\$(INST_DYNAMIC): wrapper \$(OBJECT) \$(MYEXTLIB) \$(BOOTSTRAP) \$(INST_ARCHAUTODIR)/.exists \$(EXPORT_LIST) \$(PERL_ARCHIVE) \$(PERL_ARCHIVE_AFTER) \$(INST_DYNAMIC_DEP)
	\$(RM_F) \$@
	-cp SWI.so \$@
	\$(CHMOD) \$(PERM_RWX) \$@

MAKE
}

sub clean {
    return <<MAKE

clean :: clean_swig
	-rm -rf ./blib \$(MAKE_APERL_FILE) \$(INST_ARCHAUTODIR)/extralibs.all perlmain.c mon.out core core.*perl.*.? *perl.core so_locations pm_to_blib *\$(OBJ_EXT) *\$(LIB_EXT) perl.exe \$(BOOTSTRAP) \$(BASEEXT).bso \$(BASEEXT).def \$(BASEEXT).exp

clean_swig ::
	-rm -rf *.so *.cxx *.lreg


MAKE
}
