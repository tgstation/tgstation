///All colors available to pipes and atmos components
GLOBAL_LIST_INIT(pipe_paint_colors, sortList(list(
	"amethyst" = COLOR_AMETHYST, //supplymain
	"blue" = COLOR_BLUE,
	"brown" = COLOR_BROWN,
	"cyan" = COLOR_CYAN,
	"dark" = COLOR_DARK,
	"green" = COLOR_VIBRANT_LIME,
	"grey" = COLOR_VERY_LIGHT_GRAY,
	"orange" = COLOR_TAN_ORANGE,
	"purple" = COLOR_PURPLE,
	"red" = COLOR_RED,
	"violet" = COLOR_STRONG_VIOLET,
	"yellow" = COLOR_YELLOW
)))

///List that sorts the colors and is used for setting up the pipes layer so that they overlap correctly
GLOBAL_LIST_INIT(pipe_colors_ordered, sortList(list(
	COLOR_AMETHYST = -6,
	COLOR_BLUE = -5,
	COLOR_BROWN = -4,
	COLOR_CYAN = -3,
	COLOR_DARK = -2,
	COLOR_VIBRANT_LIME = -1,
	COLOR_VERY_LIGHT_GRAY = 0,
	COLOR_TAN_ORANGE = 1,
	COLOR_PURPLE = 2,
	COLOR_RED = 3,
	COLOR_STRONG_VIOLET = 4,
	COLOR_YELLOW = 5
)))
