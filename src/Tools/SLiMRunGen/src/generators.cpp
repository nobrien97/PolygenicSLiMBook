// Generate PBS script based on SLiM input and parameters
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <random>
#include <sstream>
#include "getopt.h"
#include "generators.hpp"

using std::string;
using std::vector;

// Base class to generate files
class FileGenerator
{
public:
  FileGenerator() = default;

 
  // General Variables
  bool _verbose = false;
  bool _nimrod = false;
  bool _r_only = false;
  bool _pbs_only = false;

 // PBS Variables
  string _filename = "slim_script";
  string _bashreq = "#!/bin/bash -l\n#PBS -q workq\n#PBS -A qris-uq\n";
  string _jobname = "#PBS -N slim_job";
  string _jobarray;
  string _walltime = "3:00:00";
  int _cores = 24;
  int _mem = 120;


  // R Variables
  bool _LHC = false;
  string _LHC_dir = "lscombos.csv";
  string _seeds_dir = "seeds.csv";
  string _parameters;

 protected:
    // Basic function to save the file once it has been constructed
  void file_save(const vector<string> &file, const std::string &filename)
  {
    std::ofstream outfile(filename);

    for (int i = 0; i < file.size(); ++i)
    {
      outfile << file[i];
    }
  }

};


class PBSGenerator : public FileGenerator
{
public:
  PBSGenerator() = default;
  PBSGenerator(const FileGenerator &FG) {
    PBS_SetVars(FG);
  }
  
  void FileGenerate()
  {

    if (_nimrod == false) {
      // Add \n to options
      _jobname += "\n";
      _walltime = "#PBS -l walltime=" + _walltime + "\n";

      // Set up the script with the first few necessary parts of the script
      vector<string> scriptLines = {_bashreq, _jobname, _walltime};
      // Add the cores and memory
      string coresMem = "#PBS -l nodes=1:ncpus=" + std::to_string(_cores) + ":mem=" + std::to_string(_mem);
      scriptLines.push_back(coresMem);

      if (_jobarray.size()) {
        string jobArrString = "#PBS -J " + _jobarray;
        scriptLines.push_back(jobArrString);
      }

      string scriptSetup = "cd $TMPDIR\nmodule load R/3.5.0\nSECONDS=0";
      scriptLines.push_back(scriptSetup);

      string sublaunchR = "R --file=" + _filename + ".R";
      scriptLines.push_back(sublaunchR);

      vector<string> outputStrings = {"out_stabsel_means.csv",
                                           "out_stabsel_muts.csv",
                                           "out_stabsel_burnin.csv",
                                           "out_stabsel_opt.csv",
                                           "out_stabsel_dict.csv",
                                           "out_stabsel_pos.csv"};

      for (const string &str : outputStrings) {
        scriptLines.push_back("cat /$TMPDIR/" + str + ">> /30days/$USER/" + str);
      }

      string timer = "DURATION=$SECONDS";
      scriptLines.push_back(timer);
      string timeLine = "echo \"$(($DURATION / 3600)) hours, $((($DURATION / 60) % 60)) minutes, and $(($DURATION % 60)) seconds elapsed.\"";
      scriptLines.push_back(timeLine);

      file_save(scriptLines, _filename + ".pbs");

    }


  }
  private:
    void PBS_SetVars(const FileGenerator &FG) {
     this->_filename = FG._filename;
     this->_bashreq = FG._bashreq;
     this->_jobname = FG._jobname;
     this->_jobarray = FG._jobarray;
     this->_walltime = FG._walltime;
     this->_cores = FG._cores;
     this->_mem = FG._mem;
     this->_verbose = FG._verbose;
     this->_nimrod = FG._nimrod;
     this->_r_only = FG._r_only;
     this->_pbs_only = FG._pbs_only;
   }

  // Get commandline options and set variables to their associated entries

  // Set up various strings that may be combined later depending on arguments
};

class RGenerator : public FileGenerator {
public:
  RGenerator() = default;
  RGenerator(const FileGenerator &FG) {
    R_SetVars(FG);
  }

  void FileGenerate() {
    if(_nimrod == false) {
      vector<string> RScriptLines = {"USER <- Sys.getenv('USER')\n", 
                                     "library(foreach)\nlibrary(doParallel)\nlibrary(future)\n", 
                                     "cl <- makeCluster(future::availableCores())\n",
                                     "registerDoParallel(cl)"};

      RScriptLines.push_back("seeds <- read.csv(" + _seeds_dir + "), header = T)");

      std::stringstream ss(_parameters);
      vector<string> params;

      while (ss.good()) {
        string substr;
        std::getline(ss, substr, ',');
        params.push_back(substr);
      }

      RScriptLines.push_back("foreach(i=1:nrow(combos)) %:%\n"
                             " foreach(j=seeds$Seed) %dopar% {\n"
                             "    slim_out <- system(sprintf(/home/$USER/SLiM/slim -s %s "
     );      

    /* Add SLiM parameter list into a single command line string: 
    treating all variables as strings for feeding into sprintf, should be fine */
      string slimParamList;

      for (string param : params) {
        slimParamList += "-d " + param + "=%s ";
      }
      // Attach the parameter list to the end
      *(RScriptLines.end()-1) += slimParamList + "\n";
      RScriptLines.push_back("  }"
                             "stopCluster(cl)");

    }
  }


protected:
  void R_SetVars(const FileGenerator &FG) {
    this->_LHC = FG._LHC;
    this->_LHC_dir = FG._LHC_dir;
    this->_seeds_dir = FG._seeds_dir;
    this->_parameters = FG._parameters;
    this->_verbose = FG._verbose;
    this->_nimrod = FG._nimrod;
    this->_r_only = FG._r_only;
    this->_pbs_only = FG._pbs_only;

  }



};