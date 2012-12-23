#include "pseudoknot_opts.hh"
#include "rna.hh"
#include <stdio.h>
#include <ctype.h>

gapc::Opts::Opts()
:
#ifdef WINDOW_MODE
				window_mode(true),
#else
				window_mode(false),
#endif
				energydeviation_relative(10.0),
				energydeviation_absolute(std::numeric_limits<float>::quiet_NaN()),
//				maximalPseudoknotSize(std::numeric_limits<int>::max()),
				minimalHelixLength(2),
				energyPenaltyHtype(900.0),
				energyPenaltyKtype(1200.0),
				window_size(0),
				window_increment(0),
				delta(0),
				repeats(1),
				k(3),
				strategy('A')

{
}

gapc::Opts::~Opts()
{
	for (inputs_t::iterator i = inputs.begin(); i != inputs.end(); ++i)
		delete[] (*i).first;
}

void gapc::Opts::help(char **argv)
		{
	std::cout << argv[0] << " ("
			#ifdef WINDOW_MODE
			<< "-w <int-value> Specify the window size." << std::endl
			<< "" << std::endl
			<< "-i <int-value> Specify the window increment." << std::endl
			<< "   Default is 1. Use with -w." << std::endl
			<< "" << std::endl
#endif
			<< "-T <float-value>" << std::endl
			<< "   Rescale energy parameters to a temperature of <float-value> C." << std::endl
			<< "   Default is 37C." << std::endl
			<< "" << std::endl
			<< "-P <paramfile>"
			<< "   Read energy parameters from paramfile, instead of using the default parameter" << std::endl
			<< "   set. A sample parameter file should accompany your distribution." << std::endl
			<< "   See the RNAlib (Vienna-Package) documentation for details on the file format." << std::endl
			<< "" << std::endl
			<< std::endl
			<< "-c <float-value> Set energy range (%)." << std::endl
			<< "   This sets the energy range as percentage value of the minimum free energy. " << std::endl
			<< "   For example, when -c 5.0 is specified, and the minimum free energy is -10.0 " << std::endl
			<< "   kcal/mol, the energy range is set to -9.5 to -10.0 kcal/mol." << std::endl
			<< "   Default is 10.0." << std::endl
			<< "   (If -e is set, -c will be ignored.)" << std::endl
			<< "" << std::endl
			<< "-e <float-value> Set energy range (kcal/mol)." << std::endl
			<< "   This sets the energy range as an absolute value of the minimum free energy. " << std::endl
			<< "   For example, when -e 10.0 is specified, and the minimum free energy is -10.0 " << std::endl
			<< "   kcal/mol, the energy range is set to 0.0 to -10.0 kcal/mol." << std::endl
			<< "   By default, -c is set to 10.0." << std::endl
			<< "   (If -e is set, -c will be ignored.)" << std::endl
			<< "" << std::endl
			<< "-z <int-value> Set minimal hairpin length for K-type pseudoknots" << std::endl
			<< "   The first heuristic step in computung kissing hairpins, is to find stable, non-" << std::endl
			<< "   interrupted helices. These helices must have a minimal length, i.e. number " << std::endl
			<< "   of stacked base-pairs, of <int-value>. The higher the value, the faster the " << std::endl
			<< "   program, but also the less accurate." << std::endl
			<< "   This affects only the stems of both hairpins, not their kissing helix!" << std::endl
			<< "   Default is 2. Only positive numbers are allowed." << std::endl
			<< "" << std::endl
			<< "-s <char> select pseudoknot strategy." << std::endl
			<< "   To speed up computation, you can limit the number of bases involved in a " << std::endl
			<< "   pseudoknot (and all it's loop regions) by giving <int-value>. " << std::endl
			<< "   Default is 'A', without ticks." << std::endl
			<< "   Available strategies are 'A','B','C','D' and 'P'." << std::endl
			<< "" << std::endl
//			<< "-s <int-value> Set a maximal pseudoknot size." << std::endl
//			<< "   To speed up computation, you can limit the number of bases involved in a " << std::endl
//			<< "   pseudoknot (and all it's loop regions) by giving <int-value>. " << std::endl
//			<< "   By default, there is no limitation, i.e. -s is set to input length. " << std::endl
//			<< "   Only positive numbers are allowed." << std::endl
//			<< "" << std::endl
			<< "-x <float-value> Set init. energy penalty for an H-type pseudoknot [9.00]" << std::endl
			<< "   Thermodynamic energy parameters for pseudoknots have not been measured in a " << std::endl
			<< "   wet lab, yet. Thus, you might want to set the penalty for opening a H-type " << std::endl
			<< "   pseudoknot yourself. " << std::endl
			<< "   Default is +9.00 kcal/mol." << std::endl
			<< "" << std::endl
			<< "-y <float-value> Set init. energy penalty for an K-type pseudoknot [12.00]" << std::endl
			<< "   Thermodynamic energy parameters for pseudoknots have not been measured in a " << std::endl
			<< "   wet lab, yet. Thus, you might want to set the penalty for opening a K-type " << std::endl
			<< "   pseudoknot yourself. " << std::endl
			<< "   Default is +12.00 kcal/mol." << std::endl
			<< "" << std::endl
			<< "-f <file> Read input from a file" << std::endl
			<< "" << std::endl
			<< "-h Print this help." << std::endl
			<< "" << std::endl
			<< " (-[drk] [0-9]+)*\n";
}

void gapc::Opts::parse(int argc, char **argv)
		{
	int o = 0;
	char *input = 0;
	char *par_filename = 0;
	while ((o = getopt(argc, argv, ":f:"
#ifdef WINDOW_MODE
			"w:i:"
#endif
					"t:T:P:"
					"c:e:x:y:z:"
					"s:"
					"hd:r:k:")) != -1) {
		switch (o) {
		case 'f':
			{
			std::ifstream file(optarg);
			file.exceptions(std::ios_base::badbit |
					std::ios_base::failbit |
					std::ios_base::eofbit);
			std::filebuf *buffer = file.rdbuf();
			size_t size = buffer->pubseekoff(0, std::ios::end, std::ios::in);
			buffer->pubseekpos(0, std::ios::in);
			input = new char[size + 1];
			assert(input);
			buffer->sgetn(input, size);
			input[size] = 0;

			char *end = input + size;
			for (char *i = input; i != end;) {
				char *s = std::strchr(i, '\n');
				if (s)
					*s = 0;
				size_t x = std::strlen(i) + 1;
				char *j = new char[x];
				std::strncpy(j, i, x);
				inputs.push_back(std::make_pair(j, x - 1));
				if (s)
					i = s + 1;
				else
					break;
			}
			delete[] input;
		}
			break;
		case 'w':
			window_size = std::atoi(optarg);
			break;
		case 'i':
			window_increment = std::atoi(optarg);
			break;
		case 'T':
			case 't':
			temperature = std::atof(optarg);
			break;
		case 'P':
			par_filename = optarg;
			break;
		case 'c':
			energydeviation_relative = std::atof(optarg);
			energydeviation_absolute = std::numeric_limits<float>::quiet_NaN();
			break;
		case 'e':
			energydeviation_relative = std::numeric_limits<float>::quiet_NaN();
			energydeviation_absolute = std::atof(optarg);
			break;
		case 'z':
			minimalHelixLength = std::atoi(optarg);
			break;
//		case 's':
//			maximalPseudoknotSize = std::atoi(optarg);
//			break;
		case 's':
			strategy = toupper(*optarg);
			break;
		case 'x':
			energyPenaltyHtype = std::atof(optarg)*100;
			break;
		case 'y':
			energyPenaltyKtype = std::atof(optarg)*100;
			break;
		case 'k':
			k = std::atoi(optarg);
			break;
		case 'h':
			help(argv);
			std::exit(0);
			break;
		case 'd':
			delta = std::atoi(optarg);
			break;
		case 'r':
			repeats = std::atoi(optarg);
			break;
		case '?':
			case ':':
			{
			std::ostringstream os;
			os << "Missing argument of " << char(optopt);
			throw OptException(os.str());
		}
		default:
			{
			std::ostringstream os;
			os << "Unknown Option: " << char(o);
			throw OptException(os.str());
		}
		}
	}
	if (!input) {
		if (optind == argc)
			throw OptException("Missing input sequence or no -f.");
		for (; optind < argc; ++optind) {
			input = new char[std::strlen(argv[optind]) + 1];
			std::strcpy(input, argv[optind]);
			unsigned n = std::strlen(input);
			inputs.push_back(std::make_pair(input, n));
		}
	}
	if (window_mode) {
		if (!window_size)
			throw OptException("window size (-w) is zero");
		if (!window_increment)
			throw OptException("window increment (-i) is zero");
		if (window_increment >= window_size)
			throw OptException("window_increment >= window_size");
	}
	librna_read_param_file(par_filename);
//	if (maximalPseudoknotSize < 1) {
//		throw OptException("maximal pseudoknot size (-s) cannot be less then 1!");
//	}
	if ((strategy != 'A') && (strategy != 'B') && (strategy != 'C') && (strategy != 'D') && (strategy != 'P')) {
		throw OptException("Invalid strategy. Please select one out of 'A', 'B', 'C', 'D' or 'P'!");
	}
	if (minimalHelixLength < 1) {
		throw OptException("minimal length of pseudoknot helices (-z) cannot be less then 1!");
	}

}
