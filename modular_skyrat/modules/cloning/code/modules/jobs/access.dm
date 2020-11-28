/get_all_accesses()
	. = ..()
	. += ACCESS_CLONING

/get_region_accesses(code)
	. = ..()
	if(code == 3)
		. += ACCESS_CLONING
	if(.)
		return .

/get_access_desc(A)
	. = ..()
	if(.)
		return .
	switch(A)
		if(ACCESS_CLONING)
			return "Cloning Room"

