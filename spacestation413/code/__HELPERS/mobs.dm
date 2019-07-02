/proc/random_unique_troll_name(attempts_to_find_unique_name=10)
	for(var/i=1, i<=attempts_to_find_unique_name, i++)
		. = troll_name()

		if(i != attempts_to_find_unique_name && !findname(.))
			break

/proc/random_troll_caste()
	return pick(GLOB.troll_castes)

/proc/random_troll_horns()
	return pick(GLOB.troll_horns_list)

/proc/get_color_from_caste(troll_caste)
	switch(troll_caste)
		if("burgundy")
			return "#a10000"
		if("brown")
			return "#a25203"
		if("yellow")
			return "#a1a100"
		if("lime")
			return "#658200"
		if("olive")
			return "#416600"
		if("jade")
			return "#078446"
		if("teal")
			return "#008282"
		if("cerulean")
			return "#004182"
		if("indigo")
			return "#0021cb"
		if("purple")
			return "#631db4"
		if("violet")
			return "#6a006a"
		if("fuschia")
			return "#99004d"

/proc/get_hue_from_caste(troll_caste)
	switch(troll_caste)
		if("burgundy")
			return 0
		if("brown")
			return 30
		if("yellow")
			return 60
		if("lime")
			return 90
		if("olive")
			return 120
		if("jade")
			return 150
		if("teal")
			return 180
		if("cerulean")
			return 210
		if("indigo")
			return 240
		if("purple")
			return 270
		if("violet")
			return 300
		if("fuschia")
			return 330

GLOBAL_LIST_INIT(troll_castes, list(
	"burgundy",
	"brown",
	"yellow",
	"lime",
	"olive",
	"jade",
	"teal",
	"cerulean",
	"indigo",
	"purple",
	"violet",
	"fuschia"
	))

