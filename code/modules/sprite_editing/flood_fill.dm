//a macro for the stringized key for coordinates to check later
#define CANVAS_COORD(x, y) "[x]:[y]"
#define IS_IN_BOUNDS(x, y) (x > 0 && x <= width && y > 0 && y <= height)
#define COLORS_ARE_EQUAL(a, b) ((a == b) || (endswith(a, "00") && endswith(b, "00")))

#define SHOULD_ADD_POINT(x, y) (!coord_cache[CANVAS_COORD(x, y)] && IS_IN_BOUNDS(x, y) && COLORS_ARE_EQUAL(grid[y][x], target_color))

#define ADD_POINT(x, y) \
	points += list(list((x) - 1, (y) - 1, target_color));\
	coord_cache[CANVAS_COORD(x, y)] = TRUE

/proc/flood_fill(list/grid, x, y, width, height)
	var/target_color = grid[y][x]
	var/list/coord_cache = list()
	var/list/points = list()
	var/list/coord_queue = list(x, x, y, 1, x, x, y-1, -1)
	var/span_start
	var/column
	var/span_end
	var/row
	var/row_shift
	while(length(coord_queue))
		span_start = coord_queue[1]
		column = span_start
		span_end = coord_queue[2]
		row = coord_queue[3]
		row_shift = coord_queue[4]
		coord_queue.Cut(1, 5)
		if(SHOULD_ADD_POINT(column, row))
			while(SHOULD_ADD_POINT(column - 1, row))
				ADD_POINT(column - 1, row)
				column--
			if(column < span_start)
				coord_queue += list(column, span_start - 1, row - row_shift, -row_shift)
		while(span_start <= span_end)
			while(SHOULD_ADD_POINT(span_start, row))
				ADD_POINT(span_start, row)
				span_start++
			if(span_start > column)
				coord_queue += list(column, span_start - 1, row + row_shift, row_shift)
			if(span_start - 1 > span_end)
				coord_queue += list(span_end + 1, span_start - 1, row - row_shift, -row_shift)
			span_start++
			while(span_start < span_end && !SHOULD_ADD_POINT(span_start, row))
				span_start++
			column = span_start
	return points

#undef ADD_POINT
#undef SHOULD_ADD_POINT
#undef COLORS_ARE_EQUAL
#undef IS_IN_BOUNDS
#undef CANVAS_COORD
