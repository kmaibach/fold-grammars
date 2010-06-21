import rna

import stacklen

import pkenergy

input rna

type shape_t = shape
// type base_t = extern // XXX
type Rope = extern
type mfeanswer = (int energy, int betaLeftOuter, int alphaRightOuter)
type string_t = Rope


signature Algebra(alphabet, comp) {
  comp stackss(Subsequence);
  comp stackhl(Subsequence, Subsequence, Subsequence, Subsequence, Subsequence);
  comp stacksr(Subsequence, comp, Subsequence);
  comp sadd(Subsequence, comp);
  comp cadd(comp, comp);
  comp nil(void);
  comp is(Subsequence, comp, Subsequence);
  comp edl(Subsequence, comp, Subsequence);
  comp edr(Subsequence, comp, Subsequence);
  comp edlr(Subsequence, comp, Subsequence);
  comp pk(comp);
  comp pknot(Subsequence, comp, Subsequence, comp, Subsequence, comp, Subsequence, comp, comp, comp, comp);
  comp kndl(Subsequence, comp);
  comp kndr(comp, Subsequence);
  comp kndlr(Subsequence, comp, Subsequence);
  comp sr(Subsequence, comp, Subsequence);
  comp hl(Subsequence, Subsequence, Subsequence, Subsequence, Subsequence);
  comp bl(Subsequence, Subsequence, Subsequence, comp, Subsequence, Subsequence);
  comp br(Subsequence, Subsequence, comp, Subsequence, Subsequence, Subsequence);
  comp il(Subsequence, Subsequence, Subsequence, comp, Subsequence, Subsequence, Subsequence);
  comp ml(Subsequence, Subsequence, comp, Subsequence, Subsequence);
  comp mldl(Subsequence, Subsequence, Subsequence, comp, Subsequence, Subsequence);
  comp mldr(Subsequence, Subsequence, comp, Subsequence, Subsequence, Subsequence);
  comp mldlr(Subsequence, Subsequence, Subsequence, comp, Subsequence, Subsequence, Subsequence);
  comp addss(comp, Subsequence);
  comp mlstem(comp);
  comp pkml(comp);
  comp frd(comp, Subsequence; int); //frd j
  comp ul(comp);
  comp emptymid(Subsequence ; int, int);
  comp midbase(Subsequence ; int, int);
  comp middlro(Subsequence ; int, int);
  comp midregion(comp);
  comp middl(Subsequence, comp; int); //middl k
  comp middr(comp, Subsequence; int); //middr   l
  comp middlr(Subsequence, comp, Subsequence; int, int); //middlr k l
  comp bkd(Subsequence, comp; int); //bkd i
  comp pss(Subsequence);
  choice [comp] h([comp]);
}


algebra mfe implements Algebra(alphabet = char, comp = mfeanswer) {
  mfeanswer sadd(Subsequence b, mfeanswer x) {
    return x;
  }

  mfeanswer cadd(mfeanswer x, mfeanswer y) {
    mfeanswer res = x;
    res.energy = x.energy + y.energy;
    return res;
  }

  mfeanswer nil(void) {
    mfeanswer res;
    res.energy = 0;
    res.betaLeftOuter = 0;
    res.alphaRightOuter = 0;
    return res;
  }

  mfeanswer is(Subsequence ld, mfeanswer x, Subsequence rd) {
    Subsequence stem;
    stem.seq = ld.seq;
    stem.i = ld.i;
    stem.j = rd.j;
    
    mfeanswer res = x;
    res.energy = res.energy + termaupenalty(stem, stem);
    
    return res;
  }

  mfeanswer edl(Subsequence ld, mfeanswer x, Subsequence rd) {
    Subsequence stem;
    stem.seq = ld.seq;
    stem.i = ld.i+1;
    stem.j = rd.j;
      
    mfeanswer res = x;
    res.energy = res.energy + termaupenalty(stem, stem) + dl_energy(stem, stem);
    
    return res;
  }
 
  mfeanswer edr(Subsequence ld, mfeanswer x, Subsequence rd) {
    Subsequence stem;
    stem.seq = ld.seq;
    stem.i = ld.i;
    stem.j = rd.j-1;
      
    mfeanswer res = x;
    res.energy = res.energy + termaupenalty(stem, stem) + dr_energy(stem, stem);
    
    return res;
  }

  mfeanswer edlr(Subsequence ld, mfeanswer x, Subsequence rd) {
    Subsequence stem;
    stem.seq = ld.seq;
    stem.i = ld.i+1;
    stem.j = rd.j-1;
      
    mfeanswer res = x;
    res.energy = res.energy + termaupenalty(stem, stem) + dl_energy(stem, stem) + dr_energy(stem, stem);
    
    return res;
  }

  mfeanswer pk(mfeanswer x) {
    return x;
  }

  mfeanswer pknot(Subsequence a, mfeanswer front, Subsequence b, mfeanswer middle, Subsequence aPrime, mfeanswer back, Subsequence bPrime, mfeanswer alphaMax, mfeanswer betaMax, mfeanswer alphaCorrect, mfeanswer betaCorrect) {
    mfeanswer res;
	
    Subsequence alphaOuter;
    alphaOuter.seq = a.seq;
    alphaOuter.i = a.i;
    alphaOuter.j = aPrime.j;
    
    Subsequence alphaInner;
    alphaInner.seq = a.seq;
    alphaInner.i = a.j-1;
    alphaInner.j = aPrime.i+1;
    
    Subsequence betaOuter;
    betaOuter.seq = b.seq;
    betaOuter.i = b.i;
    betaOuter.j = bPrime.j;
    
    Subsequence betaInner;
    betaInner.seq = b.seq;
    betaInner.i = b.j-1;
    betaInner.j = bPrime.i+1;
	  
    res.betaLeftOuter = b.i;
    res.alphaRightOuter = aPrime.j;
    
	//~ Subsequence h;
    //~ h.seq = b.seq;
    //~ h.i = b.j-1;
    //~ h.j = bPrime.i+1;
    
    res.energy =   alphaMax.energy - alphaCorrect.energy // alpha helix
                 + betaMax.energy - betaCorrect.energy   // beta helix
                 + pkmlinit                              // initiation energy for pk
                 + 3*npp                                 // penalty for 1+2 explicitly unpaired bases
                 + front.energy                          // energy from front substructure
                 + middle.energy                         // energy from middle substructure
                 + back.energy                           // energy from back substructure
                 + termaupenalty(alphaOuter, alphaOuter) // AU penalty for outmost BP in alpha helix
                 + termaupenalty(alphaInner, alphaInner) // AU penalty for innermost BP in alpha helix
                 + termaupenalty(betaOuter, betaOuter)   // AU penalty for outmost BP in beta helix
                 + termaupenalty(betaInner, betaInner)   // AU penalty for innermost BP in beta helix
                 + dli_energy(alphaInner, alphaInner)    // explicitly unpaired base, before front, dangles at the inside of helix alpha
		         + dri_energy(betaInner, betaInner);     // explicitly unpaired base, after back, dangles at the inside of helix beta
//~ ;
    return res;
  }

  mfeanswer kndl(Subsequence ld, mfeanswer x) {
    Subsequence alpha;
    alpha.seq = ld.seq;
    alpha.i = ld.i+1;
    alpha.j = x.alphaRightOuter;
    
    mfeanswer res = x;
    res.energy = res.energy + npp + dl_energy(alpha, alpha);
    
    return res;
  }

  mfeanswer kndr(mfeanswer x, Subsequence rd) {
    Subsequence beta;
    beta.seq = rd.seq;
    beta.i = x.betaLeftOuter;
    beta.j = rd.j-1;
    
    mfeanswer res = x;
    res.energy = res.energy + npp + dr_energy(beta, beta);
    
    return res;
  }

  mfeanswer kndlr(Subsequence ld, mfeanswer x, Subsequence rd) {
    Subsequence alpha;
    alpha.seq = ld.seq;
    alpha.i = ld.i+1;
    alpha.j = x.alphaRightOuter;
      
    Subsequence beta;
    beta.seq = ld.seq;
    beta.i = x.betaLeftOuter;
    beta.j = rd.j-1;
      
    mfeanswer res = x;
    res.energy = res.energy + 2*npp + dl_energy(alpha, alpha) + dr_energy(beta, beta);
    
    return res;
  }


  mfeanswer stackss(Subsequence r) {
	mfeanswer res;
	res.energy = 0;
	return res;
  }
  
  mfeanswer stackhl(Subsequence llb, Subsequence lb, Subsequence r, Subsequence rb, Subsequence rrb) {
    Subsequence outerStem;
    outerStem.seq = llb.seq;
    outerStem.i = llb.i;
    outerStem.j = rrb.j;
      
    Subsequence innerStem;
    innerStem.seq = lb.seq;
    innerStem.i = lb.i;
    innerStem.j = rb.j;
    
    mfeanswer res;
    res.energy = sr_energy(outerStem, outerStem); // + sr_energy(outerStem, outerStem);
    res.betaLeftOuter = 0;
    res.alphaRightOuter = 0;
    
    return res;
  }
  
  mfeanswer stacksr(Subsequence lb, mfeanswer x, Subsequence rb) {
    Subsequence stem;
    stem.seq = lb.seq;
    stem.i = lb.i;
    stem.j = rb.j;
      
    mfeanswer res = x;
    res.energy = res.energy + sr_energy(stem, stem);
    
    return res;
  }

  mfeanswer sr(Subsequence lb, mfeanswer x, Subsequence rb) {
    Subsequence stem;
    stem.seq = lb.seq;
    stem.i = lb.i;
    stem.j = rb.j;
      
    mfeanswer res = x;
    res.energy = res.energy + sr_energy(stem, stem);
    
    return res;
  }

  mfeanswer hl(Subsequence llb, Subsequence lb, Subsequence r, Subsequence rb, Subsequence rrb) {
    Subsequence outerStem;
    outerStem.seq = llb.seq;
    outerStem.i = llb.i;
    outerStem.j = rrb.j;
      
    Subsequence innerStem;
    innerStem.seq = lb.seq;
    innerStem.i = lb.i;
    innerStem.j = rb.j;
    
    mfeanswer res;
    res.energy = hl_energy(innerStem, innerStem) + sr_energy(outerStem, outerStem);
    res.betaLeftOuter = 0;
    res.alphaRightOuter = 0;
    
    return res;
  }

  mfeanswer bl(Subsequence llb, Subsequence lb, Subsequence lr, mfeanswer x, Subsequence rb, Subsequence rrb) {
    Subsequence outerStem;
    outerStem.seq = llb.seq;
    outerStem.i = llb.i;
    outerStem.j = rrb.j;
      
    Subsequence innerStem;
    innerStem.seq = lb.seq;
    innerStem.i = lb.i;
    innerStem.j = rb.j;
    
    mfeanswer res = x;
    res.energy = res.energy + sr_energy(outerStem, outerStem) + bl_energy(innerStem, lr, innerStem);
    
    return res;
  }

  mfeanswer br(Subsequence llb, Subsequence lb, mfeanswer x, Subsequence rr, Subsequence rb, Subsequence rrb) {
    Subsequence outerStem;
    outerStem.seq = llb.seq;
    outerStem.i = llb.i;
    outerStem.j = rrb.j;
      
    Subsequence innerStem;
    innerStem.seq = lb.seq;
    innerStem.i = lb.i;
    innerStem.j = rb.j;
    
    mfeanswer res = x;
    res.energy = res.energy + sr_energy(outerStem, outerStem) + br_energy(innerStem, rr, innerStem);
    
    return res;
  }

  mfeanswer il(Subsequence llb, Subsequence lb, Subsequence lr, mfeanswer x, Subsequence rr, Subsequence rb, Subsequence rrb) {
    Subsequence outerStem;
    outerStem.seq = llb.seq;
    outerStem.i = llb.i;
    outerStem.j = rrb.j;
      
    Subsequence innerStem;
    innerStem.seq = lb.seq;
    innerStem.i = lb.i;
    innerStem.j = rb.j;
    
    mfeanswer res = x;
    res.energy = res.energy + sr_energy(outerStem, outerStem) + il_energy(lr, rr);
    
    return res;
  }

  mfeanswer ml(Subsequence llb, Subsequence lb, mfeanswer x, Subsequence rb, Subsequence rrb) {
    Subsequence outerStem;
    outerStem.seq = llb.seq;
    outerStem.i = llb.i;
    outerStem.j = rrb.j;

    Subsequence innerStem;
    innerStem.seq = lb.seq;
    innerStem.i = lb.i;
    innerStem.j = rb.j;
      
    mfeanswer res = x;
    res.energy = res.energy + mlinit + sr_energy(outerStem, outerStem) + termaupenalty(innerStem, innerStem);

    return res;
  }

  mfeanswer mldl(Subsequence llb, Subsequence lb, Subsequence ld, mfeanswer x, Subsequence rb, Subsequence rrb) {
    Subsequence outerStem;
    outerStem.seq = llb.seq;
    outerStem.i = llb.i;
    outerStem.j = rrb.j;

    Subsequence innerStem;
    innerStem.seq = lb.seq;
    innerStem.i = lb.i;
    innerStem.j = rb.j;
      
    mfeanswer res = x;
    res.energy = res.energy + mlinit + sr_energy(outerStem, outerStem) + termaupenalty(innerStem, innerStem) + dli_energy(innerStem,innerStem);

    return res;
  }

  mfeanswer mldr(Subsequence llb, Subsequence lb, mfeanswer x, Subsequence rd, Subsequence rb, Subsequence rrb) {
    Subsequence outerStem;
    outerStem.seq = llb.seq;
    outerStem.i = llb.i;
    outerStem.j = rrb.j;

    Subsequence innerStem;
    innerStem.seq = lb.seq;
    innerStem.i = lb.i;
    innerStem.j = rb.j;
      
    mfeanswer res = x;
    res.energy = res.energy + mlinit + sr_energy(outerStem, outerStem) + termaupenalty(innerStem, innerStem) + dri_energy(innerStem,innerStem);

    return res;
  }

  mfeanswer mldlr(Subsequence llb, Subsequence lb, Subsequence ld, mfeanswer x, Subsequence rd, Subsequence rb, Subsequence rrb) {
    Subsequence outerStem;
    outerStem.seq = llb.seq;
    outerStem.i = llb.i;
    outerStem.j = rrb.j;

    Subsequence innerStem;
    innerStem.seq = lb.seq;
    innerStem.i = lb.i;
    innerStem.j = rb.j;
      
    mfeanswer res = x;
    res.energy = res.energy + mlinit + sr_energy(outerStem, outerStem) + termaupenalty(innerStem, innerStem) + dli_energy(innerStem,innerStem) + dri_energy(innerStem,innerStem);

    return res;
  }

  mfeanswer addss(mfeanswer x, Subsequence r) {
    mfeanswer res = x;
    res.energy = res.energy + ss_energy(r);
      
    return res;
  }

  mfeanswer mlstem(mfeanswer x) {
    x.energy = x.energy + 40;
    return x;
  }

  mfeanswer pkml(mfeanswer x) {
    x.energy = x.energy + pkmlinit;
    return x;
  }


  mfeanswer frd(mfeanswer x, Subsequence ld; int betaRightOuter) { //frd j
    Subsequence beta;
    beta.seq = ld.seq;
    beta.i = ld.i+1;
    beta.j = betaRightOuter;
      
    mfeanswer res = x;
    res.energy = x.energy + npp + dl_energy(beta, beta);

    return res;
  }

  mfeanswer ul(mfeanswer x) {
    return x;
  }

  mfeanswer emptymid(Subsequence m; int betaRightInner, int alphaLeftInner) {
    mfeanswer res;
    res.betaLeftOuter = 0;
    res.alphaRightOuter = 0;
    res.energy = sr_pk_energy(m[m.i-1], m[betaRightInner], m[m.i], m[alphaLeftInner-1]);
    return res;
  }

  mfeanswer midbase(Subsequence m; int betaRightInner, int alphaLeftInner) {
    mfeanswer res;
    res.betaLeftOuter = 0;
    res.alphaRightOuter = 0;
    res.energy = sr_pk_energy(m[m.i-1], m[betaRightInner], m[m.i+1], m[alphaLeftInner-1]);
    return res;
  }

  mfeanswer middlro(Subsequence m; int betaRightInner, int alphaLeftInner) {
    mfeanswer res;
    res.betaLeftOuter = 0;
    res.alphaRightOuter = 0;
    
    Subsequence beta;
    beta.seq = m.seq;
    beta.i = m.i-1;
    beta.j = betaRightInner+1;
      
    Subsequence alpha;
    alpha.seq = m.seq;
    alpha.i = alphaLeftInner-1;
    alpha.j = m.j+1;
      
    res.energy = 2*npp + dri_energy(alpha, alpha) + dli_energy(beta, beta);
    
    return res;
  }

  mfeanswer midregion(mfeanswer x) {
    return x;
  }

  mfeanswer middl(Subsequence ld, mfeanswer x; int betaRightInner) { //middl k
    Subsequence beta;
    beta.seq = ld.seq;
    beta.i = ld.i-1;
    beta.j = betaRightInner+1;

    mfeanswer res = x;
    res.energy = res.energy + npp + dli_energy(beta, beta);
    
    return res;
  }

  mfeanswer middr(mfeanswer x, Subsequence rd; int alphaLeftInner) { //middr   l
    Subsequence alpha;
    alpha.seq = rd.seq;
    alpha.i = alphaLeftInner-1;
    alpha.j = rd.j+1;

    mfeanswer res = x;
    res.energy = res.energy + npp + dri_energy(alpha, alpha);
    
    return res;
  }

  mfeanswer middlr(Subsequence ld, mfeanswer x, Subsequence rd; int betaRightInner, int alphaLeftInner) { //middlr k l
    Subsequence beta;
    beta.seq = ld.seq;
    beta.i = ld.i-1;
    beta.j = betaRightInner+1;
      
    Subsequence alpha;
    alpha.seq = rd.seq;
    alpha.i = alphaLeftInner-1;
    alpha.j = rd.j+1;

    mfeanswer res = x;
    res.energy = res.energy + 2*npp + dli_energy(beta, beta) + dri_energy(alpha, alpha);
    
    return res;
  }

  mfeanswer bkd(Subsequence rd, mfeanswer x; int alphaLeftOuter) { //bkd i
    Subsequence alpha;
    alpha.seq = rd.seq;
    alpha.i = alphaLeftOuter;
    alpha.j = rd.j-1;
    
    mfeanswer res = x;
    res.energy = res.energy + npp + dr_energy(alpha, alpha);

    return res;
  }
 
  mfeanswer pss(Subsequence r) {
    mfeanswer res;
    res.betaLeftOuter = 0;
    res.alphaRightOuter = 0;
    res.energy = npp * size(r);
    return res;
  }

  choice [mfeanswer] h([mfeanswer] i) {
    return list(minimum(i));
    //~ return i;
  }
}


algebra pretty implements Algebra(alphabet = char, comp = string_t) {
  string_t sadd(Subsequence b, string_t x) {
    string_t res;
    append(res, '.');
    append(res, x);
    return res;
  }

  string_t cadd(string_t x, string_t y) {
    string_t res;
    append(res, x);
    append(res, y);
    return res;
  }

  string_t nil(void) {
    string_t res;
    return res;
  }

  string_t is(Subsequence ld, string_t x, Subsequence rd) {
    return x;
  }

  string_t edl(Subsequence ld, string_t x, Subsequence rd) {
    string_t res;
    append(res, '.');
    append(res, x);
    return res;
  }
 
  string_t edr(Subsequence ld, string_t x, Subsequence rd) {
    string_t res;
    append(res, x);
    append(res, '.');
    return res;
  }

  string_t edlr(Subsequence ld, string_t x, Subsequence rd) {
    string_t res;
    append(res, '.');
    append(res, x);
    append(res, '.');
    return res;
  }

  string_t pk(string_t x) {
    return x;
  }

  string_t pknot(Subsequence a, string_t frt, Subsequence b, string_t mid, Subsequence at, string_t bck, Subsequence bt, string_t alphaMax, string_t betaMax, string_t alphaCorrect, string_t betaCorrect) {
    string_t res;
    append(res, '[', size(a));
    append(res, '.');
    append(res, frt);
    append(res, '{', size(b));
    append(res, mid);
    append(res, ']', size(at));
    append(res, bck);
    append(res, '.', 2);
    append(res, '}', size(bt));
	  
	 //~ append(res, " a:", 3);
	 //~ append(res, a.i);
	 //~ append(res, '-');
	 //~ append(res, a.j);
	 //~ append(res, " a':", 4);
	 //~ append(res, at.i);
	 //~ append(res, '-');
	 //~ append(res, at.j);
	 //~ append(res, " b:", 3);
	 //~ append(res, b.i);
	 //~ append(res, '-');
	 //~ append(res, b.j);
	 //~ append(res, " b':", 4);
	 //~ append(res, bt.i);
	 //~ append(res, '-');
	 //~ append(res, bt.j);
	
	//~ append(res, " alpha:", 7);
	//~ append(res, alphaMax);
	//~ append(res, ' ');
	//~ append(res, " beta:", 6);
	//~ append(res, betaMax);
	//~ append(res, " alphaC:", 8);
	//~ append(res, alphaCorrect);
	//~ append(res, " betaC:", 7);
	//~ append(res, betaCorrect);
    return res;
  }

  string_t kndl(Subsequence ld, string_t x) {
    string_t res;
    append(res, '.');
    append(res, x);
    return res;
  }

  string_t kndr(string_t x, Subsequence rd) {
    string_t res;
    append(res, x);
    append(res, '.');
    return res;
  }

  string_t kndlr(Subsequence ld, string_t x, Subsequence rd) {
    string_t res;
    append(res, '.');
    append(res, x);
    append(res, '.');
    return res;
  }

  string_t stackss(Subsequence r) {
    string_t res;
    return res;
  }
  
  string_t stacksr(Subsequence lb, string_t x, Subsequence rb) {
    string_t res;
    append(res, x);
    return res;
  }

  string_t stackhl(Subsequence llb, Subsequence lb, Subsequence r, Subsequence rb, Subsequence rrb) {
    string_t res;
    return res;
  }

  string_t sr(Subsequence lb, string_t x, Subsequence rb) {
    string_t res;
    append(res, '(');
    append(res, x);
    append(res, ')');
    return res;
  }

  string_t hl(Subsequence llb, Subsequence lb, Subsequence r, Subsequence rb, Subsequence rrb) {
    string_t res;
    append(res, "((", 2);
    append(res, '.', size(r));
    append(res, "))", 2);
    return res;
  }

  string_t bl(Subsequence llb, Subsequence lb, Subsequence lr, string_t x, Subsequence rb, Subsequence rrb) {
    string_t res;
    append(res, "((", 2);
    append(res, '.', size(lr));
    append(res, x);
    append(res, "))", 2);
    return res;
  }

  string_t br(Subsequence llb, Subsequence lb, string_t x, Subsequence rr, Subsequence rb, Subsequence rrb) {
    string_t res;
    append(res, "((", 2);
    append(res, x);
    append(res, '.', size(rr));
    append(res, "))", 2);
    return res;
  }

  string_t il(Subsequence llb, Subsequence lb, Subsequence lr, string_t x, Subsequence rr, Subsequence rb, Subsequence rrb) {
    string_t res;
    append(res, "((", 2);
    append(res, '.', size(lr));
    append(res, x);
    append(res, '.', size(rr));
    append(res, "))", 2);
    return res;
  }

  string_t ml(Subsequence llb, Subsequence lb, string_t x, Subsequence rb, Subsequence rrb) {
    string_t res;
    append(res, "((", 2);
    append(res, x);
    append(res, "))", 2);
    return res;
  }

  string_t mldl(Subsequence llb, Subsequence lb, Subsequence ld, string_t x, Subsequence rb, Subsequence rrb) {
    string_t res;
    append(res, "((", 2);
    append(res, '.');
    append(res, x);
    append(res, "))", 2);
    return res;
  }

  string_t mldr(Subsequence llb, Subsequence lb, string_t x, Subsequence rd, Subsequence rb, Subsequence rrb) {
    string_t res;
    append(res, "((", 2);
    append(res, x);
    append(res, '.');
    append(res, "))", 2);
    return res;
  }

  string_t mldlr(Subsequence llb, Subsequence lb, Subsequence ld, string_t x, Subsequence rd, Subsequence rb, Subsequence rrb) {
    string_t res;
    append(res, "((", 2);
    append(res, '.');
    append(res, x);
    append(res, '.');
    append(res, "))", 2);
    return res;
  }

  string_t addss(string_t x, Subsequence r) {
    string_t res;
    append(res, x);
    append(res, '.', size(r));
    return res;
  }

  string_t mlstem(string_t x) {
    return x;
  }

  string_t pkml(string_t x) {
    return x;
  }


  string_t frd(string_t x, Subsequence ld; int betaRightOuter) { //frd j
    string_t res;
    append(res, x);
    append(res, '.');
    return res;
  }

  string_t ul(string_t x) {
    return x;
  }

  string_t emptymid(Subsequence m; int betaRightInner, int alphaLeftInner) {
    string_t res;
	  //~ append(res, "emptymid", 8);
	//~ append(res, " bi: ", 5);
	//~ append(res, betaRightInner);
	//~ append(res, " ai: ", 5);
	//~ append(res, alphaLeftInner);
	//~ append(res, " m.i: ", 6);
	//~ append(res, m.i);
	//~ append(res, " m.j: ", 6);
	//~ append(res, m.j);
	  
    return res;
  }

  string_t midbase(Subsequence m; int betaRightInner, int alphaLeftInner) {
    string_t res;
    append(res, '.');
    return res;
  }

  string_t middlro(Subsequence m; int betaRightInner, int alphaLeftInner) {
    string_t res;
    append(res, "..", 2);
	  
	  //~ append(res, " m.i: ", 6);
	  //~ append(res, m.i);
	  //~ append(res, " m.j: ", 6);
	  //~ append(res, m.j);
	  //~ append(res, " bri: ", 6);
	  //~ append(res, betaRightInner);
	  //~ append(res, " ali: ", 6);
	  //~ append(res, alphaLeftInner);
	  
    return res;
  }

  string_t midregion(string_t x) {
    return x;
  }

  string_t middl(Subsequence ld, string_t x;  int betaRightInner) { //middl k
    string_t res;
    append(res, '.');
    append(res, x);
	  //~ append(res, " ld.i: ", 7);
	  //~ append(res, ld.i);
	  //~ append(res, " ld.j: ", 7);
	  //~ append(res, ld.j);
	  //~ append(res, " bri: ", 6);
	  //~ append(res, betaRightInner);
	  
    return res;
  }

  string_t middr(string_t x, Subsequence rd;  int alphaLeftInner) { //middr   l
    string_t res;
    append(res, x);
    append(res, '.');
    return res;
  }

  string_t middlr(Subsequence ld, string_t x, Subsequence rd; int betaRightInner, int alphaLeftInner) { //middlr k l
    string_t res;
    append(res, '.');
    append(res, x);
    append(res, '.');
    return res;
  }

  string_t bkd(Subsequence rd, string_t x; int alphaLeftOuter) { //bkd i
    string_t res;
    append(res, '.');
    append(res, x);
    return res;
  }
 
  string_t pss(Subsequence r) {
    string_t res;
    append(res, '.', size(r));
    return res;
  }

  choice [string_t] h([string_t] i) {
    return unique(i);
  }
}


grammar pknotsRG uses Algebra(axiom = struct) {
    struct       = sadd(BASE,      struct) |
                   cadd(dangle_Pr, struct) |
                   nil (EMPTY) 
                   # h;

    dangle_Pr    = dangle | 
                   dangleknot
                   # h;
    
    dangle       = is   (LOC,  closed, LOC ) |
                   edl  (BASE, closed, LOC ) |
                   edr  (LOC,  closed, BASE) |
                   edlr (BASE, closed, BASE) 
                   # h;
    
    dangleknot   = pk   (      knot        ) |
                   kndl (BASE, knot        ) |
                   kndr (      knot,   BASE) |
                   kndlr(BASE, knot,   BASE) 
                   # h;

    closed       ={stack   | 
                   hairpin |
                   leftB   | 
                   rightB  | 
                   iloop   | 
                   multiloop} with stackpairing 
                   # h;

    stack        = sr   (      BASE,                          closed,                                            BASE      ) # h;
    hairpin      = hl   (BASE, BASE,                          {REGION with minsize(3)},                          BASE, BASE) # h;
    leftB        = bl   (BASE, BASE, REGION with maxsize(30), closed,                                            BASE, BASE) # h;
    rightB       = br   (BASE, BASE,                          closed,                   REGION with maxsize(30), BASE, BASE) # h;
    iloop        = il   (BASE, BASE, REGION with maxsize(30), closed,                   REGION with maxsize(30), BASE, BASE) # h;
    
    multiloop    ={ml   (BASE, BASE,                          ml_comps1,                                         BASE, BASE) |
                   mldl (BASE, BASE, BASE,                    ml_comps1,                                         BASE, BASE) |
                   mldr (BASE, BASE,                          ml_comps1,                BASE,                    BASE, BASE) |
                   mldlr(BASE, BASE, BASE,                    ml_comps1,                BASE,                    BASE, BASE) } with stackpairing
                   # h;

    ml_comps1    = sadd (BASE,             ml_comps1) |
                   cadd (mldangle,         ml_comps)  |
                   addss(pkml(dangleknot), REGION0)
                   # h ;

                     
    ml_comps     = sadd (BASE,             ml_comps) |
                   cadd (mldangle,         ml_comps) |
                   addss(mldangle,         REGION0)
                   # h ;

    mldangle     = mlstem(dangle)     |
                   pkml  (dangleknot)
                   # h;
                     
    knot         = 
      .[
         int i = t_0_i;
         int j = t_0_j;
         int k = t_0_k_0;
         int l = t_0_k_1;
         if (j-i<11)
           continue;
         if (k-i < 3 || j-l < 4)
           continue;
         if (l-k < 4)
           continue;
         int alphamaxlen = stacklen(t_0_seq, i, l);
         if (alphamaxlen < 2)
           continue;
         int alphareallen = min(alphamaxlen, k-i-1);
         if (alphareallen < 2)
           continue;
         int betamaxlen = stacklen(t_0_seq, k, j);
         if (betamaxlen < 2)
           continue;
         int betatemplen = min(betamaxlen, j-l-2);
         int betareallen = min(betatemplen, l-k-alphareallen);
         if (betareallen < 2)
           continue;
       ].
      {
         pknot(REGION, REGION, REGION) .{
           pknot(REGION[i, i+alphareallen],
              front[i+alphareallen+1, k] .(j).,
              REGION[k, k+betareallen],
              middle[k+betareallen, l-alphareallen] .(j-betareallen, i+alphareallen).,
              REGION[l-alphareallen, l],
              back[l, j-betareallen-2] .(i).,
              REGION[j-betareallen, j],
              stacknrg[i, l],
              stacknrg[k, j],
              stacknrg[i+alphareallen-1, l-alphareallen+1],
              stacknrg[k+betareallen-1, j-betareallen+1] ) 
         }.
      } # h;    
                     
    front(int betaRightOuter) = front_Pr               |
                                frd  (front_Pr, BASE; betaRightOuter)
                                # h;
              
    front_Pr     = ul(emptystrand) |
                   pk_comps
                   # h;
               
    middle(int betaRightInner, int alphaLeftInner) = emptymid  (REGION0        ; betaRightInner, alphaLeftInner) with minsize(0) with maxsize(0) |
                                                     midbase   (REGION0        ; betaRightInner, alphaLeftInner) with minsize(1) with maxsize(1) |
                                                     middlro   (REGION0        ; betaRightInner, alphaLeftInner) with minsize(2) with maxsize(2) |
                                                     midregion (      mid                                      ) |
                                                     middl     (BASE, mid      ; betaRightInner                ) |
                                                     middr     (      mid, BASE;                 alphaLeftInner) |
                                                     middlr    (BASE, mid, BASE; betaRightInner, alphaLeftInner) 
                                                     # h;
    
    mid          = ul(singlestrand) |
                   pk_comps
                   # h;
          
    back(int alphaLeftOuter) = back_Pr               |
                               bkd  (BASE, back_Pr; alphaLeftOuter) 
                               # h;
             
    back_Pr      = ul(emptystrand) |
                   pk_comps
                   # h;
              
    pk_comps     = cadd(singlestrand, pk_comps)    |
                   cadd(mldangle, pk_comps)        |
                   cadd(mldangle, ul(emptystrand)) 
                   # h;
    
    singlestrand = pss(REGION) # h;
    
    emptystrand  = pss(REGION0) # h ;

    stacknrg     = stackss(REGION0) | 
                   stackcont 
		   # h;
	
    stackcont    = stacksr(BASE, stackcont, BASE) with stackpairing |
	           stackhl(BASE, BASE, REGION with minsize(3), BASE, BASE) with stackpairing  
		   # h;
}


instance pretty = pknotsRG(pretty) ;
instance mfe = pknotsRG(mfe) ;
instance mfepp = pknotsRG(mfe * pretty);
instance ppmfe = pknotsRG(pretty * mfe);


//GCUCGGGUGCAACCCG