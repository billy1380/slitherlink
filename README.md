## build
Navigate to the base directory and run
```
$ make 
```

## run slitherlink solver
```
$ ./slsolver mypuzzle.slk anotherpuzzle.slk
```

## run slitherlink generator
```
$ ./slgenerator height width difficulty
```
where difficulty is either 'e' or 'h'

## proposed run-time
```
O((mn)^(2d+1))
```

where d is depth (the maximum nembe rof consecutive guesses needed to solve a specific puzzle), m is the puzzle's height (in terms of number of squares), and n is the puzzle's width.

```
Depth 0 (no guessing): 0.610963 seconds
```


## analytic run-time

####Run time on 9 puzzles (varying sizes and solvable up to depth 2) on our on lab computer:

```
Depth 0: 0.610963 seconds (solved 1 puzzle)

Depth 1: 174.177 seconds (solved 3 puzzles)

Depth 2: 405.207 seconds (solved 9 puzzles)
```


####Run time on puzzle 9 (30x25):

```
Depth 0: 0.183561 seconds (<50% completed)

Depth 1: 66.0678 seconds (>75% completed)

Depth 2: 138.411 seconds (100% completed)
```


####Run Time on empty 3x3 puzzle (has to make every possible combination of guesses):

```
Depth 0: 0.001111 seconds

Depth 1: 0.033743 seconds

Depth 2: 1.19998 seconds

Depth 3: 57.2004 seconds 

Depth 4: 2587.52 seconds
```

