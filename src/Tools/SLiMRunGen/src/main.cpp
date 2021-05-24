///////////////////////////////////////////////////////////////////////////////////////
// This program autogenerates R and PBS scripts for running SLiM on a super computer //
///////////////////////////////////////////////////////////////////////////////////////

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <random>
#include "getopt.h"
#include "generators.cpp"
#include "main.hpp"

#define no_arg 0
#define arg_required 1
#define arg_optional 2

using std::vector;
using std::string;


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


void doHelp(char* appname) {
    std::fprintf(stdout,
    "SLiM HPC Script Generator\n"
    "\n"
    "This program generates .PBS and .R files to run SLiM in parallel on UQ's Tinaroo HPC.\n"
    "Usage: %s [OPTION]...\n"
    "Example: %s -h\n"
    "\n"
    "-h             Print this help manual.\n"
    "\n"
    "-N NAME        Provide a job name for your HPC job.\n"
    "\n"
    "-v             Turn on verbose mode.\n"    
    "\n"
    "-J '1-N'       Sets the job to a job array using 1-N nodes\n"
    "               Example: -J='1-3' OR -J'1-3'\n"
    "\n"
    "-d FILEPATH    Specify a filepath and name for the generated scripts. Defaults to ./slim_job.\n"
    "               Example: -d ~/Desktop/slim_job.csv\n"
    "\n"
    "-w HH:MM:SS    Specify a walltime for your job in hours, minutes seconds.\n"
    "               -w '10:00:00'\n"
    "\n"
    "-c N           Specify the number of cores to use per node.\n"
    "\n"
    "-m N           Specify the amount of memory to use per node.\n"
    "               Example: -m '50G\n"
    "\n"
    "-p LIST        Provide a list of SLiM parameters to vary, delimited by commas.\n"
    "               Example: -p \"nloci,Ne,param1,param2\"\n"
    "\n"
    "-n             Specify if you would like to generate a Nimrod script.\n"
    "\n"
    "-R             Specify if you would like to only generate a .R file.\n"
    "\n"
    "-P             Specify if you would like to only generate a .PBS file.\n"
    "\n",
    appname,
    appname
    );

}

int main(int argc, char* argv[]) {

   const struct option voptions[] = 
    {
        { "jobname",        required_argument,  0,  'N' },
        { "filename",       required_argument,  0,  'd' },
        { "jobarray",       required_argument,  0,  'J' },
        { "help",           no_argument,        0,  'h' },
        { "verbose",        no_argument,        0,  'v' },
        { "walltime",       required_argument,  0,  'w' },
        { "nimrod",         no_argument,        0,  'n' },
        { "cores",          required_argument,  0,  'c' },
        { "memory",         required_argument,  0,  'm' },
        { "parameters",     required_argument,  0,  'p' },
        { "R-Only",         no_argument,        0,  'R' },
        { "PBS-only",       no_argument,        0,  'P' },
        {0,0,0,0}
    };

    int optionindex = 0;
    int options;
    FileGenerator fileinit; // Initialiser for PBSGen and RGen


    while (options != -1) {


        options = getopt_long(argc, argv, "N:d:hvJ:w:nc:m:p:RP", voptions, &optionindex);

        switch (options) {
            case 'N':
                fileinit._jobname = optarg; // job name in PBS script, -N
                continue;

            case 'd':
                fileinit._filename = optarg; // filepath for output
                continue;

            case 'h':
                doHelp(argv[0]);
                return 1;

            case 'v':
                fileinit._verbose = true; // verbose mode
                continue;

            case 'J':
                fileinit._jobarray = optarg; // job array range
                continue;

            case 'w':
                fileinit._walltime = optarg; // job walltime in hh:mm:ss
                continue;

            case 'n':
                fileinit._nimrod = true; // nimrod yes or no
                continue;

            case 'c':
                fileinit._cores = std::stoi(optarg); // how many cores to use
                continue;

            case 'm':
                fileinit._mem = std::stoi(optarg); // how much memory to use
                continue;

            case 'p':
                fileinit._parameters = optarg; // list of parameters, delimited by commas and encapsulated in ""

            case 'R':
                fileinit._r_only = true; // 

            case 'P':
                fileinit._pbs_only = true;

            case -1:
                break;
            }
        }

    if ( fileinit._pbs_only == true ) {
        PBSGenerator PBS(fileinit);
        PBS.FileGenerate();
        return 0;
    }

    else if ( fileinit._r_only == true ) {
        RGenerator RScript(fileinit);
        RScript.FileGenerate();
        return 0;
    }

    else {
        PBSGenerator PBS(fileinit);
        RGenerator RScript(fileinit);
        PBS.FileGenerate();
        RScript.FileGenerate();
    }


    return 0;
}