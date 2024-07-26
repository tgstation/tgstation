///All colors available to pipes and atmos components
GLOBAL_LIST_INIT(pipe_paint_colors, list(
	"omni" = COLOR_VERY_LIGHT_GRAY,
	"green" = COLOR_VIBRANT_LIME,
	"blue" = COLOR_BLUE,
	"red" = COLOR_RED,
	"orange" = COLOR_ENGINEERING_ORANGE,
	"cyan" = COLOR_CYAN,
	"dark" = COLOR_DARK,
	"yellow" = COLOR_YELLOW,
	"brown" = COLOR_BROWN,
	"pink" = COLOR_LIGHT_PINK,
	"purple" = COLOR_PURPLE,
	"violet" = COLOR_STRONG_VIOLET,
))

///List that sorts the colors and is used for setting up the pipes layer so that they overlap correctly
GLOBAL_LIST_INIT(pipe_colors_ordered, sort_list(list(
	COLOR_AMETHYST = -6,
	COLOR_BLUE = -5,
	COLOR_BROWN = -4,
	COLOR_CYAN = -3,
	COLOR_DARK = -2,
	COLOR_VIBRANT_LIME = -1,
	COLOR_VERY_LIGHT_GRAY = 0,
	COLOR_ENGINEERING_ORANGE = 1,
	COLOR_PURPLE = 2,
	COLOR_RED = 3,
	COLOR_STRONG_VIOLET = 4,
	COLOR_YELLOW = 5
)))

///Names shown in the examine for every colored atmos component
GLOBAL_LIST_INIT(pipe_color_name, sort_list(list(
	COLOR_VERY_LIGHT_GRAY = "omni",
	COLOR_BLUE = "blue",
	COLOR_RED = "red",
	COLOR_VIBRANT_LIME = "green",
	COLOR_ENGINEERING_ORANGE = "orange",
	COLOR_CYAN = "cyan",
	COLOR_DARK = "dark",
	COLOR_YELLOW = "yellow",
	COLOR_BROWN = "brown",
	COLOR_LIGHT_PINK = "pink",
	COLOR_PURPLE = "purple",
	COLOR_STRONG_VIOLET = "violet"
)))
