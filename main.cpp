#include <iostream>
#include "export.h"
#include "import.h"
#include "lattice.h"
#include "solver.h"

#include "grid.h"

int main(int argc, char * argv[]) {
    Grid grid;
    Import importer = Import(grid);
    Export exporter = Export(grid);
    std::cout << "Before:" << std::endl;
    exporter.print();
    Solver solver = Solver(grid);
    std::cout << "After:" << std::endl;
    exporter.print();
    return 0;
}
