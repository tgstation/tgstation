/obj/item/food/egg/raptor_egg
	icon = 'icons/mob/simple/lavaland/raptor_baby.dmi'
	icon_state = "raptor_egg"
	///inheritance datum to pass on to the child
	var/datum/raptor_inheritance/inherited_stats

/obj/item/food/egg/raptor_egg/Initialize(mapload)
	. = ..()
	if(SSmapping.is_planetary())
		icon = 'icons/mob/simple/lavaland/raptor_icebox.dmi'

/obj/item/food/egg/raptor_egg/proc/determine_growth_path(mob/living/basic/raptor/dad, mob/living/basic/raptor/mom)
	if(dad.type == mom.type)
		add_growth_component(dad.child_path)
		return
	var/dad_color = dad.raptor_color
	var/mom_color = mom.raptor_color
	var/list/my_colors = list(dad_color, mom_color)
	sortTim(my_colors, GLOBAL_PROC_REF(cmp_text_asc))
	for(var/path in GLOB.raptor_growth_paths) //guaranteed spawns
		var/list/required_colors = GLOB.raptor_growth_paths[path]
		if(!compare_list(my_colors, required_colors))
			continue
		add_growth_component(path)
		return
	var/list/valid_subtypes = list()
	var/static/list/all_subtypes = subtypesof(/mob/living/basic/raptor/baby_raptor)
	for(var/path in all_subtypes)
		var/mob/living/basic/raptor/baby_raptor/raptor_path = path
		if(!prob(initial(raptor_path.roll_rate)))
			continue
		valid_subtypes += raptor_path
	add_growth_component(pick(valid_subtypes))

/obj/item/food/egg/raptor_egg/proc/add_growth_component(growth_path)
	if(length(GLOB.raptor_population) >= MAX_RAPTOR_POP)
		return
	AddComponent(\
		/datum/component/fertile_egg,\
		embryo_type = growth_path,\
		minimum_growth_rate = 0.5,\
		maximum_growth_rate = 1,\
		total_growth_required = 100,\
		current_growth = 0,\
		location_allowlist = typecacheof(list(/turf)),\
		post_hatch = CALLBACK(src, PROC_REF(post_hatch)),\
	)

/obj/item/food/egg/raptor_egg/proc/post_hatch(mob/living/basic/raptor/baby)
	if(!istype(baby))
		return
	QDEL_NULL(baby.inherited_stats)
	baby.inherited_stats = inherited_stats
	inherited_stats = null

/obj/item/food/egg/raptor_egg/Destroy()
	QDEL_NULL(inherited_stats)
	return ..()
