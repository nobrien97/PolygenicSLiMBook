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

// Function to generate random number from noise - mangles bits, overflows
static uint64_t randNoise(int position, unsigned int seed)
{
    uint64_t PRIME1 = 0xD56AC08568010DB9;
    uint64_t PRIME2 = 0x3EE9CACE50B4F641;
    uint64_t PRIME3 = 0xFB7D9F3F3DCAA0CD;

    uint64_t mangled = position;
    mangled *= PRIME1;
    mangled += seed;
    mangled ^= (mangled >> 8);
    mangled *= PRIME2;
    mangled ^= (mangled << 6);
    mangled *= PRIME3;
    mangled *= mangled;
    mangled ^= (mangled >> 5);
    return mangled;
}

// Function to generate random number from noise - mangles bits, overflows
// Primes from: https://github.com/sublee/squirrel3-python/blob/master/squirrel3.py
static uint32_t randNoise32(int position, unsigned int seed)
{
    uint32_t PRIME1 = 0xb5297a4d;
    uint32_t PRIME2 = 0x68e31da4;
    uint32_t PRIME3 = 0x1b56c4e9;

    uint32_t mangled = position;
    mangled *= PRIME1;
    mangled += seed;
    mangled ^= (mangled >> 8);
    mangled *= PRIME2;
    mangled ^= (mangled << 6);
    mangled *= PRIME3;
    mangled *= mangled;
    mangled ^= (mangled >> 5);
    return mangled;
}



// Function to write the csv file using ofstream
template<typename T>
void write_csv(std::string filename, std::vector<T> values, std::string header) 
{
    std::ofstream outfile(filename);

    // Check if a header is supplied and if the first character is = to write the header properly
    if (header.size() && header != "") 
    {
        if (header[0] == '=') 
            header.erase(header.begin());
        outfile << header << "\n";
    }
    
    // For each generated seed, put it in an output file with a newline character, 
    // unless it's the last value, in which case just the value itself
    for (int i = 0; i < values.size(); ++i) 
    {
        if (i < values.size() - 1) 
        {
            outfile << values[i] << "\n";
        }
        else
            outfile << values[i];
    }

    outfile.close();
}

// Help function for displaying options
void doHelp(char* appname) 
{
    std::fprintf(stdout,
    "Uniformly Distributed Noise-Based Seed Generator\n"
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
    "-l             Generate 64-bit numbers instead of 32-bit.\n"            
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

int main(int argc, char* argv[]) 
{
    
    // struct of long names for options

    const struct option longopts[] =
    {
        { "destination",    no_argument,        0,  'd' },
        { "nsamples",       required_argument,  0,  'n' },
        { "help",           no_argument,        0,  'h' },
        { "long",           no_argument,        0,  'l' },
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
    bool bit64 = false; 

    // Get commandline options and set variables to their associated entries
    while (options != -1) 
    {

        options = getopt_long(argc, argv, "n:d:hlvt::", longopts, &optionindex);

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

            case 'l':
                bit64 = true;
                continue;

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

    // Use /dev/random to generate a seed for the noise function
    std::random_device mersseed;

    // Test output if we're using the verbose command
    if(debug) 
    {
        cout << "/dev/random seed for Mersenne Twister: " << mersseed() << "\n"
             << "Number of seeds =  " << n_samples << "\n"
             << "File written to: " << filename << endl;
    }
    // Initialise vector for generated numbers
    std::vector<uint64_t> seeds;
    int initSeed = mersseed();

    // Generate seeds and fill vector
    if (bit64)
    {

        for (int i = 0; i < n_samples; ++i)
        {
            // Multiply input position by large prime for some more unpredictability
            uint64_t gen = randNoise(i * 0x982C28C631FE28B3, initSeed);
            seeds.emplace_back(gen);
        }
    }
    else
    {

        for (int i = 0; i < n_samples; ++i)
        {
            uint32_t gen = randNoise32(i * 0x982C28C631FE28B3, initSeed);
            seeds.emplace_back(gen);
        }
    }
    write_csv(filename, seeds, headername);

    return 0;
}