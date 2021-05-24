#include "stdlib.h"
#include "stdio.h"
#include <utility>
#include <vector>
#include <fstream>
#include <string>
#include <sstream>
#include <stdexcept>
#include <thread>

typedef std::vector<std::pair<std::string, std::vector<std::string>>> dframe;

// read_csv function from: https://www.gormanalysis.com/blog/reading-and-writing-csv-files-with-cpp/

dframe read_csv(std::string filename, bool header) {
    dframe file;
    std::ifstream fileStream(filename);

    if (!fileStream.is_open()) throw std::runtime_error("Failed to open file.");

    std::string line, colname;
    std::string val;

    // Read column names
    if (fileStream.good()) {
        std::getline(fileStream, line);
        std::stringstream lineStream(line);
        int nameIdx = 0;

        // Get the header: if there is none, create one using parameter names X0, X1, etc.
        while(std::getline(lineStream, colname, ',')) {
            if (header == true)
                file.push_back({colname, std::vector<std::string> {}});
            else {
                file.push_back({"X"+std::to_string(nameIdx), std::vector<std::string> {}});
                nameIdx++;
            }
        }      
    }

    // For each column, get the values within
    while(std::getline(fileStream, line)) {
        std::stringstream lineStream(line);

        int colIdx = 0;

        while(fileStream >> val) {
            file.at(colIdx).second.push_back(val);

            if (lineStream.peek() == ',') 
                lineStream.ignore();
            
            colIdx++;
        }
    }
    fileStream.close();
    return file;
}

void runSLiM(dframe combo, dframe seed) {
    std::string param1 = combo[0].first.at(0);
    std::string param2 = combo[1].second.at(0);
    std::system(fprintf(stdout, "/home/$USER/SLiM/slim -s %s -d param1=%s -d param2=%s ~/Desktop/example_script.slim", seed.at(0), seed, param1, param2));

}



int main() {
    // Read the seeds and combos
    std::vector<std::pair<std::string, std::vector<std::string>>> seeds = read_csv("./seeds.csv", true);
    std::vector<std::pair<std::string, std::vector<std::string>>> combos = read_csv("./combos.csv", true);
    std::system(fprintf(stdout, "/home/$USER/SLiM/slim -s %s -d param1=%f -d param2=%s  ~/Desktop/example_script.slim", seeds.at(i), seeds, df.p[i,]$param2, intern=T)));

    return 0;
}