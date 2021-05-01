#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <random>
#include "main.hpp"

class PBSGenerator : public FileGenerator {
 public:
    PBSGenerator() = default;

    void file_save(int argc, char* argv[]);

    void file_generate();

};