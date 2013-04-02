#ifndef OUTSIDE_HH
#define OUTSIDE_HH

template<typename alphabet, typename pos_type, typename T>
inline bool containsBase(const Basic_Sequence<alphabet, pos_type> &seq, T i, T j, base_t x)
{
  if (j<i)
    return false;

  for (T k = i; k < j; k++) {
    if (seq[k] == x)
      return true;
  }
  return false;
}

template<typename alphabet, typename pos_type, typename T>
inline bool collfilter2(const Basic_Sequence<alphabet, pos_type> &seq, T i, T j)
{
	unsigned int n = (seq.size()-1)/2;
	return j-i <= n+1; //once orig sequence + separator character
}

inline Subsequence shiftIndex(Subsequence s) {
	Subsequence res;
	res.seq = s.seq;
	int bias = ((seq_size(s)-1)/2) + 1;
	res.i = s.i - bias;
	res.j = s.j - bias;
	return res;
}
inline Subsequence shiftLeftIndex(Subsequence s) {
	Subsequence res = s;
	if (s.i == 0) {
		res.i = (seq_size(s)-1)/2;
		res.j = res.i;
	}
	return res;
}



//following is everything do draw Vienna dot plots:
#include <iostream>
#include <fstream>
#include <string>
inline const std::string getPSheader(Basic_Sequence<char> rna) {
	std::ostringstream result;

	result << "%!PS-Adobe-3.0 EPSF-3.0\n";
	result << "%%Title: RNA Dot Plot\n";
	result << "%%Creator: fold-grammars (Stefan Janssen)%s\n";
    time_t ltime; /* calendar time */
    ltime=time(NULL); /* get current cal time */
    const char* timestamp = asctime(localtime(&ltime));
	result << "%%CreationDate: " << timestamp;
	if (getWindowSize() > 0) {
		result << "%%BoundingBox: 58 530 520 650\n";
	} else {
		result << "%%BoundingBox: 58 201 518 662\n";
	}
	result << "%%DocumentFonts: Helvetica\n";
	result << "%%Pages: 1\n";
	result << "%%EndComments\n\n";

	result << "%Options: UNKNOWN PARAMETERS\n";
	result << "% \n";
	result << "%This file contains the square roots of the base pair probabilities in the form\n";
	result << "% i  j  sqrt(p(i,j)) ubox\n\n";
	result << "%%BeginProlog\n";
	result << "/DPdict 100 dict def\n";
	result << "DPdict begin\n";
	result << "/logscale false def\n";
	result << "/lpmin 1e-05 log def\n\n";
	result << "/box { %size x y box - draws box centered on x,y\n";
	result << "   2 index 0.5 mul sub            % x -= 0.5\n";
	result << "   exch 2 index 0.5 mul sub exch  % y -= 0.5\n";
	result << "   3 -1 roll dup rectfill\n";
	result << "} bind def\n\n";
	result << "/ubox {\n";
	result << "   logscale {\n";
	result << "      log dup add lpmin div 1 exch sub dup 0 lt { pop 0 } if\n";
	result << "   } if\n";
	result << "   3 1 roll\n";
	result << "   exch len exch sub 1 add box\n";
	result << "} bind def\n\n";
	result << "/lbox {\n";
	result << "   3 1 roll\n";
	result << "   len exch sub 1 add box\n";
	result << "} bind def\n\n";
	result << "/drawseq {\n";
	result << "% print sequence along all 4 sides\n";
	result << "[ [0.7 -0.3 0 ]\n";
	result << "  [0.7 0.7 len add 0]\n";
	result << "  [-0.3 len sub -0.4 -90]\n";
	result << "  [-0.3 len sub 0.7 len add -90]\n";
	result << "] {\n";
	result << "   gsave\n";
	result << "    aload pop rotate translate\n";
	result << "    0 1 len 1 sub {\n";
	result << "     dup 0 moveto\n";
	result << "     sequence exch 1 getinterval\n";
	result << "     show\n";
	result << "    } for\n";
	result << "   grestore\n";
	result << "  } forall\n";
	result << "} bind def\n\n";
	result << "/drawgrid{\n";
	result << "  0.01 setlinewidth\n";
	result << "  len log 0.9 sub cvi 10 exch exp  % grid spacing\n";
	result << "  dup 1 gt {\n";
	result << "     dup dup 20 div dup 2 array astore exch 40 div setdash\n";
	result << "  } { [0.3 0.7] 0.1 setdash } ifelse\n";
	result << "  0 exch len {\n";
	result << "     dup dup\n";
	result << "     0 moveto\n";
	result << "     len lineto \n";
	result << "     dup\n";
	result << "     len exch sub 0 exch moveto\n";
	result << "     len exch len exch sub lineto\n";
	result << "     stroke\n";
	result << "  } for\n";
	result << "  [] 0 setdash\n";
	result << "  0.04 setlinewidth \n";
	result << "  currentdict /cutpoint known {\n";
	result << "    cutpoint 1 sub\n";
	result << "    dup dup -1 moveto len 1 add lineto\n";
	result << "    len exch sub dup\n";
	result << "    -1 exch moveto len 1 add exch lineto\n";
	result << "    stroke\n";
	result << "  } if\n";
	result << "  0.5 neg dup translate\n";
	result << "} bind def\n\n";
	result << "end\n";
	result << "%%EndProlog\n";

	result << "DPdict begin\n";
	result << "%delete next line to get rid of title\n";
	result << "270 665 moveto /Helvetica findfont 14 scalefont setfont ";
	result << "("<< getDotplotFilename() << ") show\n\n";
	result << "/sequence { (\\\n";

	Basic_Sequence<char>::iterator it = rna.begin();
	for (it = rna.begin(); it != rna.end(); it++) {
		if (*it == N_BASE) break;
		result << base_to_char(*it);
	}
	result << "\\\n";

	result << ") } def\n";
	if (getWindowSize() > 0) {
		result << "/winSize %d def\n",getWindowSize();
	}
	result << "/len { sequence length } bind def\n\n";
	if (getWindowSize() > 0) {
		result << "292 416 translate\n";
		result << "72 6 mul len 1 add winSize add 2 sqrt mul div dup scale\n";
	} else {
		result << "72 216 translate\n";
		result << "72 6 mul len 1 add div dup scale\n";
	}
	result << "/Helvetica findfont 0.95 scalefont setfont\n\n";
	result << "drawseq\n";
	result << "0.5 dup translate\n";
	result << "% draw diagonal\n";
	result << "0.04 setlinewidth\n";
	result << "0 len moveto len 0 lineto stroke \n\n";
	result << "%draw the grid\n";
	result << "drawgrid\n\n";

	return result.str();
}

#define MAKEPLOT(rnaSeq) \
	std::ofstream psfile; \
	psfile.open(getDotplotFilename()); \
	psfile << getPSheader(rnaSeq); \
	psfile << "%start of base pair probability data\n"; \
	unsigned int i,j,n=(rnaSeq.size()-1)/2; \
	for (i = 0; i <= n; i++) { \
		for (j = i+1; j <= n; j++) { \
			/*std::cout << (i+1) << ", " << j << " = weak: " << nt_weak(i,j) << ", strong: "  << nt_strong(i,j) << ", outer_weak: " << nt_outer_weak(j,n+i+1) << ", outer_strong: " << nt_outer_strong(j,n+i+1) << "\n"; */\
			double prob = 0.0;\
			if (gapc::Opts::getOpts()->allowLonelyBasepairs) {\
				if (nt_weak(i,j) != std::numeric_limits<double>::infinity() && nt_outer_dangle(j,n+i+1) != std::numeric_limits<double>::infinity()) { \
					prob += nt_weak(i,j) * nt_outer_dangle(j,n+i+1); \
				} \
			} else {\
				if (nt_weak(i,j) != std::numeric_limits<double>::infinity() && nt_outer_strong(j,n+i+1) != std::numeric_limits<double>::infinity()) { \
					prob += nt_weak(i,j) * nt_outer_strong(j,n+i+1); \
				} \
				if (nt_strong(i,j) != std::numeric_limits<double>::infinity() && nt_outer_weak(j,n+i+1) != std::numeric_limits<double>::infinity()) {\
					prob += nt_strong(i,j) * nt_outer_weak(j,n+i+1); \
				} \
			}\
			/*std::cout << "prob(" << i << "," << j << ") = " << prob / nt_struct(0,n) << "\n"; */\
			prob = sqrt(prob / nt_struct(0,n)); \
			/* for debugging: I think that due to rounding problems, sometimes pair probs are > 1?!: */ if (prob*prob > 1.0) std::cerr << "(" << i+1 << " , " << j << "): prob: " << prob << ", inside: " << nt_weak(i,j) << ", outside: " << nt_outer_dangle(j,n+i+1) << ", pfAll: " << nt_struct(0,n) << "\n";  \
			if (prob >= sqrt(lowProbabilityFilter())) { \
				psfile << (i+1) << " " << j << " " << prob << " ubox\n"; \
			} \
		} \
	} \
	psfile << "showpage\n"; \
	psfile << "end\n"; \
	psfile << "%%EOF\n"; \
	psfile.close(); \
	std::cout << "wrote Post-Script dot-plot to '" << getDotplotFilename() << "'\n";

//just for debugging purposes:
#define PLOTCOUNT() \
	unsigned int i,j,n=(t_0_seq.size()-1)/2; \
	for (i = 0; i <= n; i++) { \
		for (j = i+1; j <= n; j++) { \
			std::cout << i << "\t" << j << "\t";\
			if (gapc::Opts::getOpts()->allowLonelyBasepairs) {\
				std::cout << nt_weak(i,j) * nt_outer_strong(j,n+i+1);\
			} else {\
				std::cout << nt_weak(i,j) * nt_outer_strong(j,n+i+1) + nt_strong(i,j) * nt_outer_weak(j,n+i+1);\
			}\
			std::cout << "\n";\
		}\
	}\

#define DEBUGPLOT() \
		std::cout << "weak(" << gapc::Opts::getOpts()->openBase << ", " << gapc::Opts::getOpts()->closeBase << "):\n";\
		gapc::return_type results = out::nt_weak(gapc::Opts::getOpts()->openBase, gapc::Opts::getOpts()->closeBase);\
		for (gapc::return_type::iterator it = results->begin(); it != results->end(); ++it) {\
			std::cout << "\t" << (*it) << "\n";\
		}\
		std::cout << "\n";\
		std::cout << "strong(" << gapc::Opts::getOpts()->openBase << ", " << gapc::Opts::getOpts()->closeBase << "):\n";\
		results = out::nt_strong(gapc::Opts::getOpts()->openBase, gapc::Opts::getOpts()->closeBase);\
		for (gapc::return_type::iterator it = results->begin(); it != results->end(); ++it) {\
			std::cout << "\t" << (*it) << "\n";\
		}\
		std::cout << "\n";\
		unsigned int n = (t_0_seq.size()-1)/2;\
		std::cout << "outer_weak(" << gapc::Opts::getOpts()->closeBase << ", " << (n+gapc::Opts::getOpts()->openBase+1) << "):\n";\
		results = out::nt_outer_weak(gapc::Opts::getOpts()->closeBase, (n+gapc::Opts::getOpts()->openBase+1));\
		for (gapc::return_type::iterator it = results->begin(); it != results->end(); ++it) {\
			std::cout << "\t" << (*it) << "\n";\
		}\
		std::cout << "\n";\
		std::cout << "outer_strong(" << gapc::Opts::getOpts()->closeBase << ", " << (n+gapc::Opts::getOpts()->openBase+1) << "):\n";\
		results = out::nt_outer_strong(gapc::Opts::getOpts()->closeBase, (n+gapc::Opts::getOpts()->openBase+1));\
		for (gapc::return_type::iterator it = results->begin(); it != results->end(); ++it) {\
			std::cout << "\t" << (*it) << "\n";\
		}\
		std::cout << "\n";\

#endif
