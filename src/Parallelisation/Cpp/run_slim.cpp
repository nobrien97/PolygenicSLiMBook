#include "includes/csv.h" // https://github.com/awdeorio/csvstream
#include "stdlib.h"
#include <iostream>
#include <utility>
#include <vector>
#include <string>
#include "omp.h"
#include <map>

using std::vector; using std::string;

#define THREAD_NUM 4 //omp_get_thread_num(); // Max CPUs on machine


// Escaped " and ' are so the command line doesn't freak out with quotations in the middle of the line for string input
void runSLiM(std::pair<float, string> combo, string seed) {
    float param1 = combo.first;
    string param2 = combo.second;
    string callLine = "slim -s " + seed + " -d param1=" + std::to_string(param1) + " -d \"param2=\'" + param2 + "\'\" ~/Desktop/example_script.slim";
    std::system(callLine.c_str());
}



int main() {
    // Read the seeds and combos
    io::CSVReader<1> seeds("./seeds.csv");
    seeds.read_header(io::ignore_extra_column, "Seed");
    vector<string> vSeeds;
    int64_t curSeed;

    while (seeds.read_row(curSeed)) {
        vSeeds.emplace_back(std::to_string(curSeed));
    }
    io::CSVReader<2> combos("./combos.csv");
    combos.read_header(io::ignore_extra_column, "param1", "param2");
    vector<std::pair<float, string>> vCombos;
    float curP1;
    string curP2;
    while (combos.read_row(curP1, curP2)) {
        vCombos.emplace_back(curP1, curP2);
        }
    
    
    // Start of parallel processing code
    omp_set_num_threads(THREAD_NUM);
    #pragma omp parallel for collapse(2)
    { 
        for (int i=0; i < vSeeds.size(); ++i) {
            for (int j=0; j < vCombos.size(); ++j) {
                runSLiM(vCombos[j], vSeeds[i]);
            }
        }
    }
    

    return 0;
}