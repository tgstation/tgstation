//returns a component spanclass from a component id
/proc/get_component_span(id)
	switch(id)
		if(BELLIGERENT_EYE)
			return "neovgre"
		if(VANGUARD_COGWHEEL)
			return "inathneq"
		if(GEIS_CAPACITOR)
			return "sevtug"
		if(REPLICANT_ALLOY)
			return "nezbere"
		if(HIEROPHANT_ANSIBLE)
			return "nzcrentr"
		else
			return "brass"

//returns a component color from a component id, but with brighter colors for the darkest
/proc/get_component_color_bright(id)
	switch(id)
		if(BELLIGERENT_EYE)
			return "#880020"
		if(REPLICANT_ALLOY)
			return "#5A6068"
		else
			return get_component_color(id)

//returns a component color from a component id
/proc/get_component_color(id)
	switch(id)
		if(BELLIGERENT_EYE)
			return "#6E001A"
		if(VANGUARD_COGWHEEL)
			return "#1E8CE1"
		if(GEIS_CAPACITOR)
			return "#AF0AAF"
		if(REPLICANT_ALLOY)
			return "#42474D"
		if(HIEROPHANT_ANSIBLE)
			return "#DAAA18"
		else
			return "#BE8700"
