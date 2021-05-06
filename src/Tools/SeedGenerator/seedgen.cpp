#include <iostream>
#include <fstream>
#include <random>
#include <string>
#include <vector>
#include <getopt.h>

using std::endl;
using std::cout;

#define no_argument 0
#define required_argument 1
#define optional_argument 2


// Function to write the csv file using ofstream
void write_csv(std::string filename, std::vector<int32_t> values, std::string header) {
    std::ofstream outfile(filename);

    // Check if a header is supplied and if the first character is = to write the header properly
    if (header.size() && header != "") {
        if (header[0] == '=') 
            header.erase(header.begin());
        outfile << header << "\n";
    }
    
    // For each generated seed, put it in an output file with a newline character, 
    // unless it's the last value, in which case just the value itself
    for (int i = 0; i < values.size(); ++i) {
    if (i < values.size() - 1) {
        outfile << values[i] << "\n";
        }
    else
        outfile << values[i];
    }

    outfile.close();
}

// Help function for displaying options
void doHelp(char* appname) {
    std::fprintf(stdout,
    "Uniformly Distributed Seed Generator\n"
    "\n"
    "This program generates a .csv of uniformly distributed 32-bit integers for use as RNG seeds.\n"
    "Usage: %s [OPTION]...\n"
    "Example: %s -h\n"
    "\n"
    "-h             Print this help manual.\n"
    "\n"
    "-n N           Generate N random samples. Defaults to 10.\n"
    "\n"
    "-v             Turn on verbose mode.\n"    
    "\n"
    "-t NAME        Choose a header name. Defaults to 'Seed'. Enter nothing to have no header.\n"
    "               Example: -t=Number OR -tNumber\n"
    "\n"
    "-d FILEPATH    Specify a filepath and name for the generated seeds to be saved. Defaults to ./seeds.csv.\n"
    "               Example: -d ~/Desktop/seeds.csv\n"
    "\n",
    appname,
    appname
    );

}

int main(int argc, char* argv[]) {
    
    // struct of long names for options

    const struct option longopts[] =
    {
        { "destination",    no_argument,        0,  'd' },
        { "nsamples",       required_argument,  0,  'n' },
        { "help",           no_argument,        0,  'h' },
        { "verbose",        no_argument,        0,  'v' },
        { "top",            optional_argument,  0,  't' },
        {0,0,0,0}
    };

// Initialise variables with defaults if values are not supplied
    std::string filename = "./seeds.csv";
    int n_samples = 10;
    bool debug = false;
    std::string headername = "Seed";
    int optionindex = 0;
    int options; 

    // Get commandline options and set variables to their associated entries
    while (options != -1) {

        options = getopt_long(argc, argv, "n:d:hvt::", longopts, &optionindex);

        switch (options) {
            case 'n':
                n_samples = std::stoi(optarg);
                continue;

            case 'd':
                filename = optarg;
                continue;

            case 'h':
                doHelp(argv[0]);
                return 0;

            case 'v':
                debug = true;
                continue;

            case 't':
                if (optarg)
                    headername = optarg;
                else
                    headername = "";
                continue;

            case -1:
                break;
            }
        }

    // Use /dev/random to generate a seed for the Mersenne Twister
    std::random_device mersseed;

    // Test output if we're using the verbose command
    if(debug) {
        cout << "/dev/random seed for Mersenne Twister: " << mersseed() << "\n"
             << "Number of seeds =  " << n_samples << "\n"
             << "File written to: " << filename << endl;
    }

    // Initialise MT generator and the distribution to pull from
    std::mt19937 generator(mersseed());
    std::uniform_int_distribution<int32_t> distribution(1, INT32_MAX - 1);

    // Initialise vector for generated numbers
    std::vector<int32_t> seeds;

    // Generate seeds and fill vector
    for (int i = 0; i < n_samples; ++i) {
        int32_t gen = distribution(generator);
        seeds.emplace_back(gen);
    }

    write_csv(filename, seeds, headername);

    return 0;
}