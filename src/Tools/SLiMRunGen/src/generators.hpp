#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <random>
#include "getopt.h"

using std::string;
#pragma once

// Base class to generate files
class FileGenerator
{
public:
    // Constructor
    FileGenerator() = default;

    // Virtual for R and PBS classes
    virtual void FileGenerate();

    // Fix name by attaching PBS string
    string NameWrap(const char *input);

    // Append G to memory value to appease the PBS system
    string MemG(const char *input);


    // General Variables
    bool _verbose = false;
    bool _nimrod = false;
    bool _r_only = false;
    bool _pbs_only = false;

    // PBS Variables
    string _filename = "slim_job";
    string _bashreq = "#!/bin/bash -l\n#PBS -q workq\n#PBS -A qris-uq";
    string _jobname = "slim_job";
    string _jobarray;
    string _walltime = "3:00:00";
    int _cores = 24;
    string _mem = "120G";

    // R Variables
    bool _LHC = false;
    string _LHC_dir = "lscombos.csv";
    string _seeds_dir = "seeds.csv";
    string _parameters;

protected:
    // Basic function to save the file once it has been constructed
    void file_save(const std::vector<std::string> &file, const std::string filename);
};

class PBSGenerator : public FileGenerator
{
public:
    PBSGenerator();
    PBSGenerator(const FileGenerator &FG);

    void FileGenerate() override;

protected:
    void PBS_SetVars(const FileGenerator &FG);
};

class RGenerator : public FileGenerator
{
public:
    RGenerator();
    RGenerator(const FileGenerator &FG);

    void FileGenerate() override;

protected:
    void R_SetVars(const FileGenerator &FG);
};