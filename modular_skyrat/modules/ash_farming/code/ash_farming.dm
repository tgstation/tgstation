/turf/open/floor/plating/asteroid/basalt/lava_land_surface/attackby(obj/item/attacking_object, mob/user, params)
	if(istype(attacking_object, /obj/item/grown))
		var/obj/item/grown/attacking_grown = attacking_object
		if(attacking_grown.seed)
			try_seeding(attacking_grown.seed, attacking_grown, user)
			return
	else if(istype(attacking_object, /obj/item/food/grown))
		var/obj/item/food/grown/attacking_food = attacking_object
		if(attacking_food.seed)
			try_seeding(attacking_food.seed, attacking_food, user)
			return
	return ..()

/turf/open/floor/plating/asteroid/basalt/lava_land_surface/proc/try_seeding(obj/item/seeds/planting_seed, obj/targeted_delete, mob/user)
	var/obj/structure/flora/ash_farming/find_farm = locate() in contents
	if(find_farm)
		to_chat(user, span_warning("There can only be one farm in a hole at a time!"))
		return
	var/planting_chance = HAS_TRAIT(user, TRAIT_PRIMITIVE) ? 100 : 40
	if(!dug)
		to_chat(user, span_warning("You cannot grow plants on [src] without it being dug first!"))
		return
	if(!planting_seed)
		to_chat(user, span_warning("[targeted_delete] does not have a seed, it cannot be grown!"))
		return
	to_chat(user, span_notice("You begin planting..."))
	if(!do_after(user, 5 SECONDS, target = src))
		to_chat(user, span_warning("You interrupt your planting!"))
		return
	if(!prob(planting_chance))
		to_chat(user, span_warning("[targeted_delete] breaks in your hands!"))
		qdel(targeted_delete)
		return
	var/obj/structure/flora/ash_farming/new_farm = new /obj/structure/flora/ash_farming(src)
	new_farm.planted_seed = planting_seed
	new_farm.planted_type = planting_seed.type
	new_farm.appearance_naming()
	qdel(targeted_delete)

/obj/structure/flora/ash_farming
	name = "ash flora"
	desc = "A plant that has mutated to adapt to the environment."
	///the seed that is "within" the structure, vars are pulled from it
	var/obj/item/seeds/planted_seed
	///the stored type of the planted see, in case of emergency
	var/planted_type
	///the time set for the harvest_timer cooldown
	var/harvesting_cooldown = 1 MINUTES
	//when off of cooldown, is harvestable
	COOLDOWN_DECLARE(harvest_timer)
	//when off of cooldown, will process
	COOLDOWN_DECLARE(process_timer)

/obj/structure/flora/ash_farming/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	COOLDOWN_START(src, harvest_timer, harvesting_cooldown)

/obj/structure/flora/ash_farming/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(planted_seed)
		QDEL_NULL(planted_seed)
	if(planted_type)
		planted_type = null
	return ..()

/obj/structure/flora/ash_farming/process(delta_time)
	if(!COOLDOWN_FINISHED(src, process_timer))
		return
	COOLDOWN_START(src, process_timer, 5 SECONDS)
	appearance_naming()
	if(!planted_seed && planted_type)
		planted_seed = new planted_type(src)

/obj/structure/flora/ash_farming/attack_hand(mob/living/user, list/modifiers)
	if(COOLDOWN_FINISHED(src, harvest_timer))
		COOLDOWN_START(src, harvest_timer, harvesting_cooldown)
		create_harvest()
		appearance_naming()
		return
	visible_message("[src] shifts from being touched by [user].")
	return ..()

/obj/structure/flora/ash_farming/proc/appearance_naming()
	if(planted_seed)
		icon = planted_seed.growing_icon
		if(COOLDOWN_FINISHED(src, harvest_timer))
			if(planted_seed.icon_harvest)
				icon_state = planted_seed.icon_harvest
			else
				icon_state = "[planted_seed.icon_grow][planted_seed.growthstages]"
			name = lowertext(planted_seed.plantname)
		else
			icon_state = "[planted_seed.icon_grow]1"
			name = lowertext("harvested [planted_seed.plantname]")

/obj/structure/flora/ash_farming/proc/create_harvest()
	if(!planted_seed)
		qdel(src)
		return
	for(var/looped_spawn in 1 to rand(1, 4))
		var/obj/creating_obj
		if(length(planted_seed.mutatelist) && prob(10))
			var/obj/item/seeds/choose_seed = pick(planted_seed.mutatelist)
			creating_obj = initial(choose_seed.product)
			new creating_obj(get_turf(src))
			visible_message("[src] quivers from dropping something!")
			return
		creating_obj = planted_seed.product
		new creating_obj(get_turf(src))
	visible_message("[src] drops something...")

/obj/structure/flora/ash_farming/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_SHOVEL)
		visible_message("[src] gets destroyed...")
		qdel(src)
		return
	if(istype(I, /obj/item/organ/regenerative_core))
		var/obj/item/organ/regenerative_core/regen_item = I
		if(regen_item.inert)
			to_chat(user, span_warning("[regen_item] is inert and is unable to even try to instantly grow [src]!"))
			return
		if(prob(25))
			create_harvest()
		qdel(regen_item)
		return
	if(istype(I, /obj/item/stack/sheet/sinew))
		if(harvesting_cooldown <= 30 SECONDS)
			to_chat(user, span_warning("[src] has been fully fertilized and cannot be fertilized further!"))
			return
		var/obj/item/stack/sheet/sinew/sinew_item = I
		if(!sinew_item.use(1))
			to_chat(user, span_warning("[sinew_item] is unable to be used on [src]!"))
			return
		if(prob(50))
			visible_message("[src] visibly shakes, growing a little taller!")
			harvesting_cooldown -= 5 SECONDS
			return
		visible_message("[src] shudders before returning back to normal...")
		return
	return ..()
