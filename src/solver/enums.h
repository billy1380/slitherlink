#ifndef ENUMS_H
#define ENUMS_H

enum Edge { EMPTY, LINE, NLINE };
enum Number { NONE, ZERO, ONE, TWO, THREE };
enum Orientation { UP, DOWN, LEFT, RIGHT, UPFLIP, DOWNFLIP, LEFTFLIP, RIGHTFLIP };
                /* , available, already, cannotexpandfrom, ?? */
enum LoopCell { UNKNOWN, EXP, NOEXP, OUT };

#endif
