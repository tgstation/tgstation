/// X/Y bounds of the cell
#define CELL_SIZE 3
#define MAX_CELL_COUNT 255/CELL_SIZE
// Takes a position, transforms it into a cell key
#define CELL_TRANSFORM(pos) clamp(ROUND_UP((pos) / CELL_SIZE), 1, MAX_CELL_COUNT)
// Takes a cell, hands back the actual posiiton it represents
// A key of 1 becomes 1, a key of 2 becomes CELL_SIZE + 1, etc.
#define CELL_KEY_TO_POSITION(key) ((((key) - 1) * CELL_SIZE) + 1)

// /turf/list/visibility_info keys
// keep the most common case to the bottom so we can contract into it
/// Key that holds a list of info about the depths in sight
#define VIS_CELL_DEPTHS 1
/// Key that holds a list of info about the z stacks in sight (it's just a list of visible z levels from different stacks)
#define VIS_CELL_Z_STACKS 2
