#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <random>
#include "getopt.h"

using std::string;

// Base class to generate files
class FileGenerator
{
public:
    // Constructor
    FileGenerator();

    // Virtual for R and PBS classes
    virtual void FileGenerate() = 0;

    // General Variables
    bool verbose;

    // PBS Variables
    bool nimrod;
    bool r_only;
    bool pbs_only;
    string filename;
    string bashreq;
    string jobname;
    string jobarray;
    string walltime;
    int cores;
    int mem;

    // R Variables
    bool LHC;
    string LHC_dir;
    string seeds_dir;
    string parameters;

protected:
    // Basic function to save the file once it has been constructed
    void file_save(const std::vector<std::string> &file, const std::string filename);

};

class PBSGenerator : public FileGenerator
{
public:
    PBSGenerator();
    PBSGenerator(const FileGenerator &FG);

    void FileGenerate();

protected:
    void PBS_SetVars(const FileGenerator &FG);
};

class RGenerator : public FileGenerator
{
public:
    RGenerator();
    RGenerator(const FileGenerator &FG);

    void FileGenerate();


protected:
    void R_SetVars(const FileGenerator &FG);
};