%module "Language::Prolog::SWI"

%{
#include "SWIProlog.cpp"
%}

#include <SWI-Prolog.h>
#include <string.h>
#include <malloc.h>

#ifdef __BORLANDC__
#define __inline inline 
#else
#define __inline
#endif


class PlTerm;
class PlTermv;

		 /*******************************
		 *	 PROLOG CONSTANTS	*
		 *******************************/

class PlFunctor
{
public:
  functor_t functor;

  PlFunctor(const char *name, int arity)
  { functor = PL_new_functor(PL_new_atom(name), arity);
  }
};


class PlAtom
{
public:
  atom_t handle;

  PlAtom(atom_t h)
  { handle = h;
  }
  PlAtom(const char *text)
  { handle = PL_new_atom(text);
  }
  PlAtom(const PlTerm &t);

  %name(toString) operator const char *(void);
  %name(eq)       int operator ==(const char *s);
  %name(eq)       int operator ==(const PlAtom &a);

};

		 /*******************************
		 *     GENERIC PROLOG TERM	*
		 *******************************/


class PlTerm
{
public:
  term_t ref;

  PlTerm()
  { ref = PL_new_term_ref();
  }
  PlTerm(term_t t)
  { ref = t;
  }
  
					/* C --> PlTerm */
  PlTerm(const char *text)
  { ref = PL_new_term_ref();

    PL_put_atom_chars(ref, text);
  }
  PlTerm(long val)
  { ref = PL_new_term_ref();

    PL_put_integer(ref, val);
  }
  PlTerm(double val)
  { ref = PL_new_term_ref();

    PL_put_float(ref, val);
  }
  PlTerm(const PlAtom &a)
  { ref = PL_new_term_ref();

    PL_put_atom(ref, a.handle);
  }
  PlTerm(void *ptr)
  { ref = PL_new_term_ref();

    PL_put_pointer(ref, ptr);
  }

					/* PlTerm --> C */
  %name(toString)  operator char *(void);
#  %name(tolong)    operator long(void);
#  %name(toint)     operator int(void);
#  %name(todouble)  operator double(void);
  %name(toPlAtom)  operator PlAtom(void);

  int type()
  { return PL_term_type(ref);
  }

  int arity();
  const char *name();
};


		 /*******************************
		 *	   TERM VECTOR		*
		 *******************************/

class PlTermv
{
public:
  term_t a0;
  int    size;

  PlTermv(int n)
  { a0   = PL_new_term_refs(n);
    size = n;
  }
  PlTermv(int n, term_t t0)
  { a0   = t0;
    size = n;
  }

					/* create from args */
  PlTermv(PlTerm m0);
  PlTermv(PlTerm m0, PlTerm m1);
  PlTermv(PlTerm m0, PlTerm m1, PlTerm m2);
  PlTermv(PlTerm m0, PlTerm m1, PlTerm m2, PlTerm m3);
  PlTermv(PlTerm m0, PlTerm m1, PlTerm m2, PlTerm m3, PlTerm m4);

};

		 /*******************************
		 *	 SPECIALISED TERMS	*
		 *******************************/

class PlCompound : public PlTerm
{
public:
  
  PlCompound(const char *text);
  PlCompound(const char *functor, const PlTermv &args);
};


class PlString : public PlTerm
{
public:

  PlString(const char *text) : PlTerm()
  { PL_put_string_chars(ref, text);
  }
  PlString(const char *text, int len) : PlTerm()
  { PL_put_string_nchars(ref, len, text);
  }
};


class PlCodeList : public PlTerm
{ 
public:

  PlCodeList(const char *text) : PlTerm()
  { PL_put_list_codes(ref, text);
  }
};


class PlCharList : public PlTerm
{
public:

  PlCharList(const char *text) : PlTerm()
  { PL_put_list_chars(ref, text);
  }
};


		 /*******************************
		 *	      EXCEPTIONS	*
		 *******************************/

class PlException : public PlTerm
{
public:

  PlException(const PlTerm &t)
  { ref = t.ref;
  }

  int plThrow()
  { return PL_raise_exception(ref);
  }

  void cppThrow();
};


class PlTypeError : public PlException
{
public:

  PlTypeError(const PlTerm &t) : PlException(t) {}

  PlTypeError(const char *expected, PlTerm actual) :
    PlException(PlCompound("error",
			   PlTermv(PlCompound("type_error",
					      PlTermv(expected, actual)),
				   PlTerm())))
  {
  }
};


class PlDomainError : public PlException
{
public:

  PlDomainError(const PlTerm &t) : PlException(t) {}

  PlDomainError(const char *expected, PlTerm actual) :
    PlException(PlCompound("error",
			   PlTermv(PlCompound("domain_error",
					      PlTermv(expected, actual)),
				   PlTerm())))
  {
  }
};


class PlTermvDomainError : public PlException
{
public:

  PlTermvDomainError(int size, int n) :
    PlException(PlCompound("error",
			   PlTermv(PlCompound("domain_error",
					      PlTermv(PlCompound("argv",
								 size),
						      n)),
				   PlTerm())))
  {
  }
};


		 /*******************************
		 *             LISTS		*
		 *******************************/

class PlTail : public PlTerm
{
public:
  
  PlTail(const PlTerm &l)
  { if ( PL_is_variable(l.ref) || PL_is_list(l.ref) )
      ref = PL_copy_term_ref(l.ref);
    else
      throw PlTypeError("list", l.ref);
  }

					/* building */
  int append(const PlTerm &e)
  { term_t tmp = PL_new_term_ref();

    if ( PL_unify_list(ref, tmp, ref) &&
	 PL_unify(tmp, e.ref) )
      return TRUE;

    return FALSE;
  }
  int close()
  { return PL_unify_nil(ref);
  }

					/* enumerating */
  int next(PlTerm &t)
  { if ( PL_get_list(ref, t, ref) )
      return TRUE;

    if ( PL_get_nil(ref) )
      return FALSE;

    throw PlTypeError("list", ref);
  }
};


		 /*******************************
		 *	 CALLING PROLOG		*
		 *******************************/

class PlFrame
{
public:
  fid_t fid;

  PlFrame()
  { fid = PL_open_foreign_frame();
  }

  ~PlFrame()
  { PL_close_foreign_frame(fid);
  }

  void rewind()
  { PL_rewind_foreign_frame(fid);
  }
};


class PlQuery
{
public:
  qid_t qid;

  PlQuery(const char *name, const PlTermv &av)
  { predicate_t p = PL_predicate(name, av.size, "user");
    
    qid = PL_open_query((module_t)0, PL_Q_CATCH_EXCEPTION, p, av.a0);
  }
  PlQuery(const char *module, const char *name, const PlTermv &av)
  { predicate_t p = PL_predicate(name, av.size, module);
    
    qid = PL_open_query((module_t)0, PL_Q_CATCH_EXCEPTION, p, av.a0);
  }

  ~PlQuery()
  { PL_cut_query(qid);
  }

  int next_solution();
};


__inline int
PlCall(const char *predicate, const PlTermv &args)
{ PlQuery q(predicate, args);
  return q.next_solution();
}

__inline int
PlCall(const char *module, const char *predicate, const PlTermv &args)
{ PlQuery q(module, predicate, args);
  return q.next_solution();
}

__inline int
PlCall(const char *goal)
{ PlQuery q("call", PlTermv(PlCompound(goal)));
  return q.next_solution();
}



		 /*******************************
		 *	    ATOM (BODY)		*
		 *******************************/

__inline
PlAtom::PlAtom(const PlTerm &t)
{ atom_t a;

  if ( PL_get_atom(t.ref, &a) )
    handle = a;
  else
    throw PlTypeError("atom", t);
}



__inline int
PlTerm::arity()
{ atom_t name;
  int arity;
  
  if ( PL_get_name_arity(ref, &name, &arity) )
    return arity;

  throw PlTypeError("compound", ref);
}


__inline const char *
PlTerm::name()
{ atom_t name;
  int arity;
  
  if ( PL_get_name_arity(ref, &name, &arity) )
    return PL_atom_chars(name);

  throw PlTypeError("compound", ref);
}

					/* comparison */


__inline int PlTerm::operator ==(long v)
{ long v0;

  if ( PL_get_long(ref, &v0) )
    return v0 == v;

  throw PlTypeError("integer", ref);
}

__inline int PlTerm::operator !=(long v)
{ long v0;

  if ( PL_get_long(ref, &v0) )
    return v0 != v;

  throw PlTypeError("integer", ref);
}

__inline int PlTerm::operator <(long v)
{ long v0;

  if ( PL_get_long(ref, &v0) )
    return v0 < v;

  throw PlTypeError("integer", ref);
}

__inline int PlTerm::operator >(long v)
{ long v0;

  if ( PL_get_long(ref, &v0) )
    return v0 > v;

  throw PlTypeError("integer", ref);
}

__inline int PlTerm::operator <=(long v)
{ long v0;

  if ( PL_get_long(ref, &v0) )
    return v0 <= v;

  throw PlTypeError("integer", ref);
}

__inline int PlTerm::operator >=(long v)
{ long v0;

  if ( PL_get_long(ref, &v0) )
    return v0 >= v;

  throw PlTypeError("integer", ref);
}

				      /* comparison (string) */

__inline int PlTerm::operator ==(const char *s)
{ char *s0;

  if ( PL_get_chars(ref, &s0, CVT_ALL) )
    return strcmp(s0, s) == 0;
  
  throw PlTypeError("text", ref);
}


__inline int PlTerm::operator ==(const PlAtom &a)
{ atom_t v;

  if ( PL_get_atom(ref, &v) )
    return v == a.handle;
  
  throw PlTypeError("atom", ref);
}


		 /*******************************
		 *	COMPPOUND (BODY)	*
		 *******************************/


__inline
PlCompound::PlCompound(const char *text) : PlTerm()
{ term_t t = PL_new_term_ref();

  if ( !PL_chars_to_term(text, t) )
    throw PlException(t);

  PL_put_term(ref, t);
}

__inline
PlCompound::PlCompound(const char *functor, const PlTermv &args) : PlTerm()
{ PL_cons_functor_v(ref,
		    PL_new_functor(PL_new_atom(functor), args.size),
		    args.a0);
}

		 /*******************************
		 *	   TERMV (BODY)		*
		 *******************************/


__inline PlTermv::PlTermv(PlTerm m0)
{ size = 1;
  a0 = m0.ref;
}

__inline PlTermv::PlTermv(PlTerm m0, PlTerm m1)
{ size = 2;
  a0 = PL_new_term_refs(2);
  PL_put_term(a0+0, m0);
  PL_put_term(a0+1, m1);
}

__inline PlTermv::PlTermv(PlTerm m0, PlTerm m1, PlTerm m2)
{ size = 3;
  a0 = PL_new_term_refs(3);
  PL_put_term(a0+0, m0);
  PL_put_term(a0+1, m1);
  PL_put_term(a0+2, m2);
}

__inline PlTermv::PlTermv(PlTerm m0, PlTerm m1, PlTerm m2, PlTerm m3)
{ size = 4;
  a0 = PL_new_term_refs(4);
  PL_put_term(a0+0, m0);
  PL_put_term(a0+1, m1);
  PL_put_term(a0+2, m2);

  PL_put_term(a0+3, m3);
}

__inline PlTermv::PlTermv(PlTerm m0, PlTerm m1, PlTerm m2,
			  PlTerm m3, PlTerm m4)
{ size = 5;
  a0 = PL_new_term_refs(5);
  PL_put_term(a0+0, m0);
  PL_put_term(a0+1, m1);
  PL_put_term(a0+2, m2);
  PL_put_term(a0+3, m3);
  PL_put_term(a0+4, m4);
}


__inline PlTerm
PlTermv::operator [](int n)
{ if ( n < 0 || n >= size )
    throw PlTermvDomainError(size, n);

  return PlTerm(a0+n);
}



		 /*******************************
		 *	    QUERY (BODY)	*
		 *******************************/

__inline int
PlQuery::next_solution()
{ int rval;

  if ( !(rval = PL_next_solution(qid)) )
  { term_t ex;

    if ( (ex = PL_exception(qid)) )
      PlException(ex).cppThrow();
  }
  return rval;
}


		 /*******************************
		 *	      ENGINE		*
		 *******************************/

class PlError
{
public:
  char *message;

  PlError(const char *msg)
  { message = new char[strlen(msg+1)];
    strcpy(message, msg);
  }
};


class PlEngine
{
public:

  PlEngine()
  { int ac = 0;
    char **av = (char **)malloc(sizeof(char *) * 2);

    av[ac++] = "xyz";
    if ( !PL_initialise(1, av) )
      throw PlError("failed to initialise");
  }

  PlEngine(int argc, char **argv)
  { if ( !PL_initialise(argc, argv) )
      throw PlError("failed to initialise");
  }

  PlEngine(char *av0)
  { int ac = 0;
    char **av = (char **)malloc(sizeof(char *) * 2);

    av[ac++] = av0;

    if ( !PL_initialise(1, av) )
      throw PlError("failed to initialise");
  }

  ~PlEngine()
  { PL_cleanup(0);
  }
};


		 /*******************************
		 *     REGISTER PREDICATES	*
		 *******************************/

#ifdef PROLOG_MODULE
#define PlPredName(name) PROLOG_MODULE ":" #name
#else
#define PlPredName(name) #name
#endif

#define PREDICATE(name, arity) \
	static foreign_t \
	pl_ ## name ## __ ## arity(PlTermv _av); \
	static foreign_t \
	_pl_ ## name ## __ ## arity(term_t t0, int a, control_t c) \
	{ try \
	  { \
	    return pl_ ## name ## __ ## arity(PlTermv(arity, t0)); \
	  } catch ( PlException &ex ) \
	  { return ex.plThrow(); \
	  } \
	} \
	static PlRegister _x ## name ## __ ## arity(PlPredName(name), \
						    arity, \
					    _pl_ ## name ## __ ## arity); \
	static foreign_t pl_ ## name ## __ ## arity(PlTermv _av)
#define A1  _av[0]        
#define A2  _av[1]        
#define A3  _av[2]        
#define A4  _av[3]        
#define A5  _av[4]        
#define A6  _av[5]        
#define A7  _av[6]        
#define A8  _av[7]        
#define A9  _av[8]        
#define A10 _av[9]        
