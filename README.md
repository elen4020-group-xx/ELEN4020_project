# ELEN4020 Project
#### This project compares the performance of MPI one-sided and two-sided communication with respect to a block-based matrix transposition implementation.

## Files
### The relevant files for the two core implementations are `MPI.cpp` and `MPI_one_sided.cpp`. Two additional collective I/O alternatives were also developed: `MPI_coll.cpp` and `MPI_one_sided_coll.cpp`.

There are some other auxiliary files and alternative implementations: `resViewer.cpp`, `inputCreator.cpp`, and `UPC.upc`.

ResViewer and InputCreator can be used to display and create row-major ordered binary matrix files. These scripts are useful for viewing the output files of the MPI jobs and for creating input files for the collective I/O approaches.

Once compiled, they can both be used with the following syntax, where N is the size of the matrix and fileName is the file to be written to or read from:

`./<executable> <N> <fileName>`


## Running the code:

If the environment has been set up with a job scheduler that it is unlikely that a hostfile would need to be specified.

Thus, after compiling with `mpiCC`, the two main executables can be run using:

 `mpiexec <MPI flags> <executableName> <N> <outputFile>`


 For the two collective I/O approaches, an input filename must be specified:

  `mpiexec <MPI flags> <executableName> <inputFile> <outputFile>`

  ##### Running The UPC code
  The provided UPC code is not intended for grading and is somewhat unstable. However, if required it can be run using:

`upcrun <flags> <executableName> <inputFile> <outputFile>`


#### Alternatively, the performance results can be obtained by running the included bash scripts.

These scripts print the results for all combinations of matrix size and processs count, also comparing the use of OpenMP to a serial approach.

`./runTests.sh` will print the results for the two main (non collective I/O) approaches.


`./runTestsColl.sh` will print the results for the two collective I/O approaches.


`./runTestsBig.sh` will print the results for larger matrix sizes than those originally prescribed.



## Docs

The documents can be found in the `/docs/`folder, specifically `Report.pdf`.
The report can also be compiled from the Latex source if required.