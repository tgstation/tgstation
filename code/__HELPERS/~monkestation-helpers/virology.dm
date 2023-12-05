GLOBAL_LIST_INIT(all_antigens, list(
	ANTIGEN_O,
	ANTIGEN_A,
	ANTIGEN_B,
	ANTIGEN_RH,
	ANTIGEN_Q,
	ANTIGEN_U,
	ANTIGEN_V,
	ANTIGEN_M,
	ANTIGEN_N,
	ANTIGEN_P,
	ANTIGEN_X,
	ANTIGEN_Y,
	ANTIGEN_Z,
	))

GLOBAL_LIST_INIT(blood_antigens, list(
	ANTIGEN_O,
	ANTIGEN_A,
	ANTIGEN_B,
	ANTIGEN_RH,
))

GLOBAL_LIST_INIT(common_antigens, list(
	ANTIGEN_Q,
	ANTIGEN_U,
	ANTIGEN_V,
))

GLOBAL_LIST_INIT(rare_antigens, list(
	ANTIGEN_M,
	ANTIGEN_N,
	ANTIGEN_P,
))

GLOBAL_LIST_INIT(alien_antigens, list(
	ANTIGEN_X,
	ANTIGEN_Y,
	ANTIGEN_Z,
))

/proc/antigen_family(id)
	switch(id)
		if (ANTIGEN_BLOOD)
			return GLOB.blood_antigens
		if (ANTIGEN_COMMON)
			return GLOB.common_antigens
		if (ANTIGEN_RARE)
			return GLOB.rare_antigens
		if (ANTIGEN_ALIEN)
			return GLOB.alien_antigens
