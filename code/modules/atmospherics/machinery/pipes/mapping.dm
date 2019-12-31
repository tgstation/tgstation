//Colored pipes, use these for mapping

#define HELPER_PARTIAL(Fulltype, Iconbase, Color) \
	##Fulltype {						\
		pipe_color = Color;				\
		color = Color;					\
	}									\
	##Fulltype/visible {				\
		level = PIPE_VISIBLE_LEVEL;		\
		layer = GAS_PIPE_VISIBLE_LAYER;	\
	}									\
	##Fulltype/visible/layer1 {			\
		piping_layer = 1;				\
		icon_state = Iconbase + "-1";	\
	}									\
	##Fulltype/visible/layer3 {			\
		piping_layer = 3;				\
		icon_state = Iconbase + "-3";	\
	}									\
	##Fulltype/hidden {					\
		level = PIPE_HIDDEN_LEVEL;		\
	}									\
	##Fulltype/hidden/layer1 {			\
		piping_layer = 1;				\
		icon_state = Iconbase + "-1";	\
	}									\
	##Fulltype/hidden/layer3 {			\
		piping_layer = 3;				\
		icon_state = Iconbase + "-3";	\
	}

#define HELPER_PARTIAL_NAMED(Fulltype, Iconbase, Name, Color) \
	HELPER_PARTIAL(Fulltype, Iconbase, Color)	\
	##Fulltype {								\
		name = Name;							\
	}

#define HELPER(Type, Color) \
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/simple/##Type, "pipe11", Color) 		\
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/manifold/##Type, "manifold", Color)		\
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/manifold4w/##Type, "manifold4w", Color)

#define HELPER_NAMED(Type, Name, Color) \
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/simple/##Type, "pipe11", Name, Color) 		\
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/manifold/##Type, "manifold", Name, Color)		\
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/manifold4w/##Type, "manifold4w", Name, Color)

HELPER(general, null)
HELPER(yellow, rgb(255, 198, ZERO))
HELPER(cyan, rgb(ZERO, 255, 249))
HELPER(green, rgb(30, 255, ZERO))
HELPER(orange, rgb(255, 129, 25))
HELPER(purple, rgb(128, ZERO, 182))
HELPER(dark, rgb(69, 69, 69))
HELPER(brown, rgb(178, 100, 56))
HELPER(violet, rgb(64, ZERO, 128))

HELPER_NAMED(scrubbers, "scrubbers pipe", rgb(255, ZERO, ZERO))
HELPER_NAMED(supply, "air supply pipe", rgb(ZERO, ZERO, 255))
HELPER_NAMED(supplymain, "main air supply pipe", rgb(130, 43, 255))

#undef HELPER_NAMED
#undef HELPER
#undef HELPER_PARTIAL_NAMED
#undef HELPER_PARTIAL
