//Landmarks and other helpers which speed up the mapping process and reduce the number of unique instances/subtypes of items/turf/ect



/obj/effect/baseturf_helper //Set the baseturfs of every turf in the /area/ it is placed.
	name = "baseturf editor"
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = ""

	var/list/baseturf_to_replace
	var/baseturf

	plane = POINT_PLANE

/obj/effect/baseturf_helper/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/baseturf_helper/LateInitialize()
	if(!baseturf_to_replace)
		baseturf_to_replace = typecacheof(list(/turf/open/space,/turf/baseturf_bottom))
	else if(!length(baseturf_to_replace))
		baseturf_to_replace = list(baseturf_to_replace = TRUE)
	else if(baseturf_to_replace[baseturf_to_replace[1]] != TRUE) // It's not associative
		var/list/formatted = list()
		for(var/i in baseturf_to_replace)
			formatted[i] = TRUE
		baseturf_to_replace = formatted

	var/area/our_area = get_area(src)
	for(var/i in get_area_turfs(our_area, z))
		replace_baseturf(i)

	qdel(src)

/obj/effect/baseturf_helper/proc/replace_baseturf(turf/thing)
	thing.remove_baseturfs_from_typecache(baseturf_to_replace)
	thing.PlaceOnBottom(fake_turf_type = baseturf)

/obj/effect/baseturf_helper/space
	name = "space baseturf editor"
	baseturf = /turf/open/space

/obj/effect/baseturf_helper/asteroid
	name = "asteroid baseturf editor"
	baseturf = /turf/open/misc/asteroid

/obj/effect/baseturf_helper/asteroid/airless
	name = "asteroid airless baseturf editor"
	baseturf = /turf/open/misc/asteroid/airless

/obj/effect/baseturf_helper/asteroid/basalt
	name = "asteroid basalt baseturf editor"
	baseturf = /turf/open/misc/asteroid/basalt

/obj/effect/baseturf_helper/asteroid/snow
	name = "asteroid snow baseturf editor"
	baseturf = /turf/open/misc/asteroid/snow

/obj/effect/baseturf_helper/beach/sand
	name = "beach sand baseturf editor"
	baseturf = /turf/open/misc/beach/sand

/obj/effect/baseturf_helper/beach/water
	name = "water baseturf editor"
	baseturf = /turf/open/water/beach

/obj/effect/baseturf_helper/lava
	name = "lava baseturf editor"
	baseturf = /turf/open/lava/smooth

/obj/effect/baseturf_helper/lava_land/surface
	name = "lavaland baseturf editor"
	baseturf = /turf/open/lava/smooth/lava_land_surface

/obj/effect/baseturf_helper/reinforced_plating
	name = "reinforced plating baseturf editor"
	baseturf = /turf/open/floor/plating/reinforced
	baseturf_to_replace = list(/turf/open/floor/plating,/turf/open/space,/turf/baseturf_bottom)

//This applies the reinforced plating to the above Z level for every tile in the area where this is placed
/obj/effect/baseturf_helper/reinforced_plating/ceiling
	name = "reinforced ceiling plating baseturf editor"

/obj/effect/baseturf_helper/reinforced_plating/ceiling/replace_baseturf(turf/thing)
	var/turf/ceiling = get_step_multiz(thing, UP)
	if(isnull(ceiling))
		CRASH("baseturf helper is attempting to modify the Z level above but there is no Z level above above it.")
	if(isspaceturf(ceiling) || istype(ceiling, /turf/open/openspace))
		return
	return ..(ceiling)


/obj/effect/mapping_helpers
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = ""
	var/late = FALSE

/obj/effect/mapping_helpers/Initialize(mapload)
	..()
	return late ? INITIALIZE_HINT_LATELOAD : INITIALIZE_HINT_QDEL

//airlock helpers
/obj/effect/mapping_helpers/airlock
	layer = DOOR_HELPER_LAYER
	late = TRUE

/obj/effect/mapping_helpers/airlock/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_mapping("[src] spawned outside of mapload!")
		return

	var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in loc
	if(!airlock)
		log_mapping("[src] failed to find an airlock at [AREACOORD(src)]")
	else
		payload(airlock)

/obj/effect/mapping_helpers/airlock/LateInitialize()
	. = ..()
	var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in loc
	if(!airlock)
		qdel(src)
		return
	if(airlock.cyclelinkeddir)
		airlock.cyclelinkairlock()
	if(airlock.closeOtherId)
		airlock.update_other_id()
	if(airlock.abandoned)
		var/outcome = rand(1,100)
		switch(outcome)
			if(1 to 9)
				var/turf/here = get_turf(src)
				for(var/turf/closed/T in range(2, src))
					here.PlaceOnTop(T.type)
					qdel(src)
					return
				here.PlaceOnTop(/turf/closed/wall)
				qdel(airlock)
				return
			if(9 to 11)
				airlock.lights = FALSE
				airlock.locked = TRUE
			if(12 to 15)
				airlock.locked = TRUE
			if(16 to 23)
				airlock.welded = TRUE
			if(24 to 30)
				airlock.set_panel_open(TRUE)
	if(airlock.cutAiWire)
		airlock.wires.cut(WIRE_AI)
	if(airlock.autoname)
		airlock.name = get_area_name(src, TRUE)
	airlock.update_appearance()
	qdel(src)

/obj/effect/mapping_helpers/airlock/proc/payload(obj/machinery/door/airlock/payload)
	return

/obj/effect/mapping_helpers/airlock/cyclelink_helper
	name = "airlock cyclelink helper"
	icon_state = "airlock_cyclelink_helper"

/obj/effect/mapping_helpers/airlock/cyclelink_helper/payload(obj/machinery/door/airlock/airlock)
	if(airlock.cyclelinkeddir)
		log_mapping("[src] at [AREACOORD(src)] tried to set [airlock] cyclelinkeddir, but it's already set!")
	else
		airlock.cyclelinkeddir = dir

/obj/effect/mapping_helpers/airlock/cyclelink_helper_multi
	name = "airlock multi-cyclelink helper"
	icon_state = "airlock_multicyclelink_helper"
	var/cycle_id

/obj/effect/mapping_helpers/airlock/cyclelink_helper_multi/payload(obj/machinery/door/airlock/airlock)
	if(airlock.closeOtherId)
		log_mapping("[src] at [AREACOORD(src)] tried to set [airlock] closeOtherId, but it's already set!")
	else if(!cycle_id)
		log_mapping("[src] at [AREACOORD(src)] doesn't have a cycle_id to assign to [airlock]!")
	else
		airlock.closeOtherId = cycle_id

/obj/effect/mapping_helpers/airlock/locked
	name = "airlock lock helper"
	icon_state = "airlock_locked_helper"

/obj/effect/mapping_helpers/airlock/locked/payload(obj/machinery/door/airlock/airlock)
	if(airlock.locked)
		log_mapping("[src] at [AREACOORD(src)] tried to bolt [airlock] but it's already locked!")
	else
		airlock.locked = TRUE

/obj/effect/mapping_helpers/airlock/unres
	name = "airlock unrestricted side helper"
	icon_state = "airlock_unres_helper"

/obj/effect/mapping_helpers/airlock/unres/payload(obj/machinery/door/airlock/airlock)
	airlock.unres_sides ^= dir
	airlock.unres_sensor = TRUE

/obj/effect/mapping_helpers/airlock/abandoned
	name = "airlock abandoned helper"
	icon_state = "airlock_abandoned"

/obj/effect/mapping_helpers/airlock/abandoned/payload(obj/machinery/door/airlock/airlock)
	if(airlock.abandoned)
		log_mapping("[src] at [AREACOORD(src)] tried to make [airlock] abandoned but it's already abandoned!")
	else
		airlock.abandoned = TRUE

/obj/effect/mapping_helpers/airlock/cutaiwire
	name = "airlock cut ai wire helper"
	icon_state = "airlock_cutaiwire"

/obj/effect/mapping_helpers/airlock/cutaiwire/payload(obj/machinery/door/airlock/airlock)
	if(airlock.cutAiWire)
		log_mapping("[src] at [AREACOORD(src)] tried to cut the ai wire on [airlock] but it's already cut!")
	else
		airlock.cutAiWire = TRUE

/obj/effect/mapping_helpers/airlock/autoname
	name = "airlock autoname helper"
	icon_state = "airlock_autoname"

/obj/effect/mapping_helpers/airlock/autoname/payload(obj/machinery/door/airlock/airlock)
	if(airlock.autoname)
		log_mapping("[src] at [AREACOORD(src)] tried to autoname the [airlock] but it's already autonamed!")
	else
		airlock.autoname = TRUE

//needs to do its thing before spawn_rivers() is called
INITIALIZE_IMMEDIATE(/obj/effect/mapping_helpers/no_lava)

/obj/effect/mapping_helpers/no_lava
	icon_state = "no_lava"

/obj/effect/mapping_helpers/no_lava/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	T.turf_flags |= NO_LAVA_GEN

///Helpers used for injecting stuff into atoms on the map.
/obj/effect/mapping_helpers/atom_injector
	name = "Atom Injector"
	icon_state = "injector"
	late = TRUE
	///Will inject into all fitting the criteria if false, otherwise first found.
	var/first_match_only = TRUE
	///Will inject into atoms of this type.
	var/target_type
	///Will inject into atoms with this name.
	var/target_name

//Late init so everything is likely ready and loaded (no warranty)
/obj/effect/mapping_helpers/atom_injector/LateInitialize()
	if(!check_validity())
		return
	var/turf/target_turf = get_turf(src)
	var/matches_found = 0
	for(var/atom/atom_on_turf as anything in target_turf.get_all_contents())
		if(atom_on_turf == src)
			continue
		if(target_name && atom_on_turf.name != target_name)
			continue
		if(target_type && !istype(atom_on_turf, target_type))
			continue
		inject(atom_on_turf)
		matches_found++
		if(first_match_only)
			qdel(src)
			return
	if(!matches_found)
		stack_trace(generate_stack_trace())
	qdel(src)

///Checks if whatever we are trying to inject with is valid
/obj/effect/mapping_helpers/atom_injector/proc/check_validity()
	return TRUE

///Injects our stuff into the atom
/obj/effect/mapping_helpers/atom_injector/proc/inject(atom/target)
	return

///Generates text for our stack trace
/obj/effect/mapping_helpers/atom_injector/proc/generate_stack_trace()
	. = "[name] found no targets at ([x], [y], [z]). First Match Only: [first_match_only ? "true" : "false"] target type: [target_type] | target name: [target_name]"

/obj/effect/mapping_helpers/atom_injector/obj_flag
	name = "Obj Flag Injector"
	icon_state = "objflag_helper"
	var/inject_flags = NONE

/obj/effect/mapping_helpers/atom_injector/obj_flag/inject(atom/target)
	if(!isobj(target))
		return
	var/obj/obj_target = target
	obj_target.obj_flags |= inject_flags

///This helper applies components to things on the map directly.
/obj/effect/mapping_helpers/atom_injector/component_injector
	name = "Component Injector"
	icon_state = "component"
	///Typepath of the component.
	var/component_type
	///Arguments for the component.
	var/list/component_args = list()

/obj/effect/mapping_helpers/atom_injector/component_injector/check_validity()
	if(!ispath(component_type, /datum/component))
		CRASH("Wrong component type in [type] - [component_type] is not a component")
	return TRUE

/obj/effect/mapping_helpers/atom_injector/component_injector/inject(atom/target)
	var/arguments = list(component_type)
	arguments += component_args
	target._AddComponent(arguments)

/obj/effect/mapping_helpers/atom_injector/component_injector/generate_stack_trace()
	. = ..()
	. += " | component type: [component_type] | component arguments: [list2params(component_args)]"

///This helper applies elements to things on the map directly.
/obj/effect/mapping_helpers/atom_injector/element_injector
	name = "Element Injector"
	icon_state = "element"
	///Typepath of the element.
	var/element_type
	///Arguments for the element.
	var/list/element_args = list()

/obj/effect/mapping_helpers/atom_injector/element_injector/check_validity()
	if(!ispath(element_type, /datum/element))
		CRASH("Wrong element type in [type] - [element_type] is not a element")
	return TRUE

/obj/effect/mapping_helpers/atom_injector/element_injector/inject(atom/target)
	var/arguments = list(element_type)
	arguments += element_args
	target._AddElement(arguments)

/obj/effect/mapping_helpers/atom_injector/element_injector/generate_stack_trace()
	. = ..()
	. += " | element type: [element_type] | element arguments: [list2params(element_args)]"

///This helper applies traits to things on the map directly.
/obj/effect/mapping_helpers/atom_injector/trait_injector
	name = "Trait Injector"
	icon_state = "trait"
	///Name of the trait, in the lower-case text (NOT the upper-case define) form.
	var/trait_name

/obj/effect/mapping_helpers/atom_injector/trait_injector/check_validity()
	if(!istext(trait_name))
		CRASH("Wrong trait in [type] - [trait_name] is not a trait")
	if(!GLOB.trait_name_map)
		GLOB.trait_name_map = generate_trait_name_map()
	if(!GLOB.trait_name_map.Find(trait_name))
		stack_trace("Possibly wrong trait in [type] - [trait_name] is not a trait in the global trait list")
	return TRUE

/obj/effect/mapping_helpers/atom_injector/trait_injector/inject(atom/target)
	ADD_TRAIT(target, trait_name, MAPPING_HELPER_TRAIT)

/obj/effect/mapping_helpers/atom_injector/trait_injector/generate_stack_trace()
	. = ..()
	. += " | trait name: [trait_name]"

///This helper applies dynamic human icons to things on the map
/obj/effect/mapping_helpers/atom_injector/human_icon_injector
	name = "Human Icon Injector"
	icon_state = "icon"
	/// Path of the outfit we give the human.
	var/outfit_path
	/// Path of the species we give the human.
	var/species_path = /datum/species/human
	/// Path of the mob spawner we base the human off of.
	var/mob_spawn_path
	/// Path of the right hand item we give the human.
	var/r_hand = NO_REPLACE
	/// Path of the left hand item we give the human.
	var/l_hand = NO_REPLACE
	/// Which slots on the mob should be bloody?
	var/bloody_slots = NONE
	/// Directions we generate for the mob.
	var/generated_dirs = list(NORTH, SOUTH, EAST, WEST)
	/// Do we draw more than one frame for the mob?
	var/animated = TRUE

/obj/effect/mapping_helpers/atom_injector/human_icon_injector/check_validity()
	if(!ispath(species_path, /datum/species))
		CRASH("Wrong species path in [type] - [species_path] is not a species")
	if(outfit_path && !ispath(outfit_path, /datum/outfit))
		CRASH("Wrong outfit path in [type] - [species_path] is not an outfit")
	if(mob_spawn_path && !ispath(mob_spawn_path, /obj/effect/mob_spawn))
		CRASH("Wrong mob spawn path in [type] - [mob_spawn_path] is not a mob spawner")
	if(l_hand && !ispath(l_hand, /obj/item))
		CRASH("Wrong left hand item path in [type] - [l_hand] is not an item")
	if(r_hand && !ispath(r_hand, /obj/item))
		CRASH("Wrong left hand item path in [type] - [r_hand] is not an item")
	return TRUE

/obj/effect/mapping_helpers/atom_injector/human_icon_injector/inject(atom/target)
	apply_dynamic_human_icon(target, outfit_path, species_path, mob_spawn_path, r_hand, l_hand, bloody_slots, generated_dirs, animated)

/obj/effect/mapping_helpers/atom_injector/human_icon_injector/generate_stack_trace()
	. = ..()
	. += " | outfit path: [outfit_path] | species path: [species_path] | mob spawner path: [mob_spawn_path] | right/left hand path: [r_hand]/[l_hand]"

///Fetches an external dmi and applies to the target object
/obj/effect/mapping_helpers/atom_injector/custom_icon
	name = "Custom Icon Injector"
	icon_state = "icon"
	///This is the var that will be set with the fetched icon. In case you want to set some secondary icon sheets like inhands and such.
	var/target_variable = "icon"
	///This should return raw dmi in response to http get request. For example: "https://github.com/tgstation/SS13-sprites/raw/master/mob/medu.dmi?raw=true"
	var/icon_url
	///The icon file we fetched from the http get request.
	var/icon_file

/obj/effect/mapping_helpers/atom_injector/custom_icon/check_validity()
	var/static/icon_cache = list()
	var/static/query_in_progress = FALSE //We're using a single tmp file so keep it linear.
	if(query_in_progress)
		UNTIL(!query_in_progress)
	if(icon_cache[icon_url])
		icon_file = icon_cache[icon_url]
		return TRUE
	log_asset("Custom Icon Helper fetching dmi from: [icon_url]")
	var/datum/http_request/request = new()
	var/file_name = "tmp/custom_map_icon.dmi"
	request.prepare(RUSTG_HTTP_METHOD_GET, icon_url, "", "", file_name)
	query_in_progress = TRUE
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()
	if(response.errored || response.status_code != 200)
		query_in_progress = FALSE
		CRASH("Failed to fetch mapped custom icon from url [icon_url], code: [response.status_code], error: [response.error]")
	var/icon/new_icon = new(file_name)
	icon_cache[icon_url] = new_icon
	query_in_progress = FALSE
	icon_file = new_icon
	return TRUE

/obj/effect/mapping_helpers/atom_injector/custom_icon/inject(atom/target)
	if(IsAdminAdvancedProcCall())
		return
	target.vars[target_variable] = icon_file

/obj/effect/mapping_helpers/atom_injector/custom_icon/generate_stack_trace()
	. = ..()
	. += " | target variable: [target_variable] | icon url: [icon_url]"

///Fetches an external sound and applies to the target object
/obj/effect/mapping_helpers/atom_injector/custom_sound
	name = "Custom Sound Injector"
	icon_state = "sound"
	///This is the var that will be set with the fetched sound.
	var/target_variable = "hitsound"
	///This should return raw sound in response to http get request. For example: "https://github.com/tgstation/tgstation/blob/master/sound/misc/bang.ogg?raw=true"
	var/sound_url
	///The sound file we fetched from the http get request.
	var/sound_file

/obj/effect/mapping_helpers/atom_injector/custom_sound/check_validity()
	var/static/sound_cache = list()
	var/static/query_in_progress = FALSE //We're using a single tmp file so keep it linear.
	if(query_in_progress)
		UNTIL(!query_in_progress)
	if(sound_cache[sound_url])
		sound_file = sound_cache[sound_url]
		return TRUE
	log_asset("Custom Sound Helper fetching sound from: [sound_url]")
	var/datum/http_request/request = new()
	var/file_name = "tmp/custom_map_sound.ogg"
	request.prepare(RUSTG_HTTP_METHOD_GET, sound_url, "", "", file_name)
	query_in_progress = TRUE
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()
	if(response.errored || response.status_code != 200)
		query_in_progress = FALSE
		CRASH("Failed to fetch mapped custom sound from url [sound_url], code: [response.status_code], error: [response.error]")
	var/sound/new_sound = new(file_name)
	sound_cache[sound_url] = new_sound
	query_in_progress = FALSE
	sound_file = new_sound
	return TRUE

/obj/effect/mapping_helpers/atom_injector/custom_sound/inject(atom/target)
	if(IsAdminAdvancedProcCall())
		return
	target.vars[target_variable] = sound_file

/obj/effect/mapping_helpers/atom_injector/custom_sound/generate_stack_trace()
	. = ..()
	. += " | target variable: [target_variable] | sound url: [sound_url]"

/obj/effect/mapping_helpers/dead_body_placer
	name = "Dead Body placer"
	late = TRUE
	icon_state = "deadbodyplacer"
	var/admin_spawned
	var/bodycount = 2 //number of bodies to spawn

/obj/effect/mapping_helpers/dead_body_placer/Initialize(mapload)
	. = ..()
	if(mapload)
		return
	admin_spawned = TRUE

/obj/effect/mapping_helpers/dead_body_placer/LateInitialize()
	var/area/a = get_area(src)
	var/list/trays = list()
	for (var/i in a.contents)
		if (istype(i, /obj/structure/bodycontainer/morgue))
			if(admin_spawned)
				var/obj/structure/bodycontainer/morgue/early_morgue_tray = i
				if(early_morgue_tray.connected.loc != early_morgue_tray)
					continue
			trays += i
	if(!trays.len)
		if(admin_spawned)
			message_admins("[src] spawned at [ADMIN_VERBOSEJMP(src)] failed to find a closed morgue to spawn a body!")
		else
			log_mapping("[src] at [x],[y] could not find any morgues.")
		return

	var/reuse_trays = (trays.len < bodycount) //are we going to spawn more trays than bodies?

	var/use_species = !(CONFIG_GET(flag/morgue_cadaver_disable_nonhumans))
	var/species_probability = CONFIG_GET(number/morgue_cadaver_other_species_probability)
	var/override_species = CONFIG_GET(string/morgue_cadaver_override_species)
	var/list/usable_races
	if(use_species)
		var/list/temp_list = get_selectable_species()
		usable_races = temp_list.Copy()
		usable_races -= SPECIES_ETHEREAL //they revive on death which is bad juju
		LAZYREMOVE(usable_races, SPECIES_HUMAN)
		if(!usable_races)
			notice("morgue_cadaver_disable_nonhumans. There are no valid roundstart nonhuman races enabled. Defaulting to humans only!")
		if(override_species)
			warning("morgue_cadaver_override_species BEING OVERRIDEN since morgue_cadaver_disable_nonhumans is disabled.")
	else if(override_species)
		usable_races += override_species

	for (var/i = 1 to bodycount)
		var/obj/structure/bodycontainer/morgue/morgue_tray = reuse_trays ? pick(trays) : pick_n_take(trays)
		var/obj/structure/closet/body_bag/body_bag = new(morgue_tray.loc)
		var/mob/living/carbon/human/new_human = new /mob/living/carbon/human(morgue_tray.loc, 1)

		var/species_to_pick
		if(LAZYLEN(usable_races))
			if(!species_probability)
				species_probability = 50
				stack_trace("WARNING: morgue_cadaver_other_species_probability CONFIG SET TO 0% WHEN SPAWNING. DEFAULTING TO [species_probability]%.")
			if(prob(species_probability))
				species_to_pick = pick(usable_races)
				var/datum/species/new_human_species = GLOB.species_list[species_to_pick]
				if(new_human_species)
					new_human.set_species(new_human_species)
					new_human_species = new_human.dna.species
					new_human_species.randomize_features(new_human)
					new_human.fully_replace_character_name(new_human.real_name, new_human_species.random_name(new_human.gender, TRUE, TRUE))
				else
					stack_trace("failed to spawn cadaver with species ID [species_to_pick]") //if it's invalid they'll just be a human, so no need to worry too much aside from yelling at the server owner lol.

		body_bag.insert(new_human, TRUE)
		body_bag.close()
		body_bag.handle_tag("[new_human.real_name][species_to_pick ? " - [capitalize(species_to_pick)]" : " - Human"]")
		body_bag.forceMove(morgue_tray)

		new_human.death() //here lies the mans, rip in pepperoni.
		for (var/part in new_human.internal_organs) //randomly remove organs from each body, set those we keep to be in stasis
			if (prob(40))
				qdel(part)
			else
				var/obj/item/organ/O = part
				O.organ_flags |= ORGAN_FROZEN

		morgue_tray.update_appearance()

	qdel(src)


//On Ian's birthday, the hop's office is decorated.
/obj/effect/mapping_helpers/ianbirthday
	name = "Ian's Bday Helper"
	late = TRUE
	icon_state = "iansbdayhelper"
	var/balloon_clusters = 2

/obj/effect/mapping_helpers/ianbirthday/LateInitialize()
	if(check_holidays("Ian's Birthday"))
		birthday()
	qdel(src)

/obj/effect/mapping_helpers/ianbirthday/proc/birthday()
	var/area/a = get_area(src)
	var/list/table = list()//should only be one aka the front desk, but just in case...
	var/list/openturfs = list()

	//confetti and a corgi balloon! (and some list stuff for more decorations)
	for(var/thing in a.contents)
		if(istype(thing, /obj/structure/table/reinforced))
			table += thing
		if(isopenturf(thing))
			new /obj/effect/decal/cleanable/confetti(thing)
			if(locate(/obj/structure/bed/dogbed/ian) in thing)
				new /obj/item/toy/balloon/corgi(thing)
			else
				openturfs += thing

	//cake + knife to cut it!
	if(length(table))
		var/turf/food_turf = get_turf(pick(table))
		new /obj/item/knife/kitchen(food_turf)
		var/obj/item/food/cake/birthday/iancake = new(food_turf)
		iancake.desc = "Happy birthday, Ian!"

	//some balloons! this picks an open turf and pops a few balloons in and around that turf, yay.
	for(var/i in 1 to balloon_clusters)
		var/turf/clusterspot = pick_n_take(openturfs)
		new /obj/item/toy/balloon(clusterspot)
		var/balloons_left_to_give = 3 //the amount of balloons around the cluster
		var/list/dirs_to_balloon = GLOB.cardinals.Copy()
		while(balloons_left_to_give > 0)
			balloons_left_to_give--
			var/chosen_dir = pick_n_take(dirs_to_balloon)
			var/turf/balloonstep = get_step(clusterspot, chosen_dir)
			var/placed = FALSE
			if(isopenturf(balloonstep))
				var/obj/item/toy/balloon/B = new(balloonstep)//this clumps the cluster together
				placed = TRUE
				if(chosen_dir == NORTH)
					B.pixel_y -= 10
				if(chosen_dir == SOUTH)
					B.pixel_y += 10
				if(chosen_dir == EAST)
					B.pixel_x -= 10
				if(chosen_dir == WEST)
					B.pixel_x += 10
			if(!placed)
				new /obj/item/toy/balloon(clusterspot)
	//remind me to add wall decor!

/obj/effect/mapping_helpers/ianbirthday/admin//so admins may birthday any room
	name = "generic birthday setup"
	icon_state = "bdayhelper"

/obj/effect/mapping_helpers/ianbirthday/admin/LateInitialize()
	birthday()
	qdel(src)

//Ian, like most dogs, loves a good new years eve party.
/obj/effect/mapping_helpers/iannewyear
	name = "Ian's New Years Helper"
	late = TRUE
	icon_state = "iansnewyrshelper"

/obj/effect/mapping_helpers/iannewyear/LateInitialize()
	if(check_holidays(NEW_YEAR))
		fireworks()
	qdel(src)

/obj/effect/mapping_helpers/iannewyear/proc/fireworks()
	var/area/a = get_area(src)
	var/list/table = list()//should only be one aka the front desk, but just in case...
	var/list/openturfs = list()

	for(var/thing in a.contents)
		if(istype(thing, /obj/structure/table/reinforced))
			table += thing
		else if(isopenturf(thing))
			if(locate(/obj/structure/bed/dogbed/ian) in thing)
				new /obj/item/clothing/head/costume/festive(thing)
				var/obj/item/reagent_containers/cup/glass/bottle/champagne/iandrink = new(thing)
				iandrink.name = "dog champagne"
				iandrink.pixel_y += 8
				iandrink.pixel_x += 8
			else
				openturfs += thing

	var/turf/fireworks_turf = get_turf(pick(table))
	var/obj/item/storage/box/matches/matchbox = new(fireworks_turf)
	matchbox.pixel_y += 8
	matchbox.pixel_x -= 3
	new /obj/item/storage/box/fireworks/dangerous(fireworks_turf) //dangerous version for extra holiday memes.

//lets mappers place notes on airlocks with custom info or a pre-made note from a path
/obj/effect/mapping_helpers/airlock_note_placer
	name = "Airlock Note Placer"
	late = TRUE
	icon_state = "airlocknoteplacer"
	var/note_info //for writing out custom notes without creating an extra paper subtype
	var/note_name //custom note name
	var/note_path //if you already have something wrote up in a paper subtype, put the path here

/obj/effect/mapping_helpers/airlock_note_placer/LateInitialize()
	var/turf/turf = get_turf(src)
	if(note_path && !istype(note_path, /obj/item/paper)) //don't put non-paper in the paper slot thank you
		log_mapping("[src] at [x],[y] had an improper note_path path, could not place paper note.")
		qdel(src)
		return
	if(locate(/obj/machinery/door/airlock) in turf)
		var/obj/machinery/door/airlock/found_airlock = locate(/obj/machinery/door/airlock) in turf
		if(note_path)
			found_airlock.note = note_path
			found_airlock.update_appearance()
			qdel(src)
			return
		if(note_info)
			var/obj/item/paper/paper = new /obj/item/paper(src)
			if(note_name)
				paper.name = note_name
			paper.add_raw_text("[note_info]")
			paper.update_appearance()
			found_airlock.note = paper
			paper.forceMove(found_airlock)
			found_airlock.update_appearance()
			qdel(src)
			return
		log_mapping("[src] at [x],[y] had no note_path or note_info, cannot place paper note.")
		qdel(src)
		return
	log_mapping("[src] at [x],[y] could not find an airlock on current turf, cannot place paper note.")
	qdel(src)

/**
 * ## trapdoor placer!
 *
 * This places an unlinked trapdoor in the tile its on (so someone with a remote needs to link it up first)
 * Pre-mapped trapdoors (unlike player-made ones) are not conspicuous by default so nothing stands out with them
 * Admins may spawn this in the round for additional trapdoors if they so desire
 * if YOU want to learn more about trapdoors, read about the component at trapdoor.dm
 * note: this is not a turf subtype because the trapdoor needs the type of the turf to turn back into
 */
/obj/effect/mapping_helpers/trapdoor_placer
	name = "trapdoor placer"
	late = TRUE
	icon_state = "trapdoor"

/obj/effect/mapping_helpers/trapdoor_placer/LateInitialize()
	var/turf/component_target = get_turf(src)
	component_target.AddComponent(/datum/component/trapdoor, starts_open = FALSE, conspicuous = FALSE)
	qdel(src)

/obj/effect/mapping_helpers/ztrait_injector
	name = "ztrait injector"
	icon_state = "ztrait"
	late = TRUE
	/// List of traits to add to this Z-level.
	var/list/traits_to_add = list()

/obj/effect/mapping_helpers/ztrait_injector/LateInitialize()
	var/datum/space_level/level = SSmapping.z_list[z]
	if(!level || !length(traits_to_add))
		return
	level.traits |= traits_to_add
	SSweather.update_z_level(level) //in case of someone adding a weather for the level, we want SSweather to update for that

/obj/effect/mapping_helpers/circuit_spawner
	name = "circuit spawner"
	icon_state = "circuit"
	/// The shell for the circuit.
	var/atom/movable/circuit_shell
	/// Capacity of the shell.
	var/shell_capacity = SHELL_CAPACITY_VERY_LARGE
	/// The url for the json. Example: "https://pastebin.com/raw/eH7VnP9d"
	var/json_url

/obj/effect/mapping_helpers/circuit_spawner/Initialize(mapload)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(spawn_circuit))

/obj/effect/mapping_helpers/circuit_spawner/proc/spawn_circuit()
	var/list/errors = list()
	var/obj/item/integrated_circuit/loaded/new_circuit = new(loc)
	var/json_data = load_data()
	new_circuit.load_circuit_data(json_data, errors)
	if(!circuit_shell)
		return
	circuit_shell = new(loc)
	var/datum/component/shell/shell_component = circuit_shell.GetComponent(/datum/component/shell)
	if(shell_component)
		shell_component.shell_flags |= SHELL_FLAG_CIRCUIT_UNMODIFIABLE|SHELL_FLAG_CIRCUIT_UNREMOVABLE
		shell_component.attach_circuit(new_circuit)
	else
		shell_component = circuit_shell.AddComponent(/datum/component/shell, \
			capacity = shell_capacity, \
			shell_flags = SHELL_FLAG_CIRCUIT_UNMODIFIABLE|SHELL_FLAG_CIRCUIT_UNREMOVABLE, \
			starting_circuit = new_circuit, \
			)

/obj/effect/mapping_helpers/circuit_spawner/proc/load_data()
	var/static/json_cache = list()
	var/static/query_in_progress = FALSE //We're using a single tmp file so keep it linear.
	if(query_in_progress)
		UNTIL(!query_in_progress)
	if(json_cache[json_url])
		return json_cache[json_url]
	log_asset("Circuit Spawner fetching json from: [json_url]")
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, json_url, "")
	query_in_progress = TRUE
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()
	if(response.errored || response.status_code != 200)
		query_in_progress = FALSE
		CRASH("Failed to fetch mapped custom json from url [json_url], code: [response.status_code], error: [response.error]")
	var/json_data = response["body"]
	json_cache[json_url] = json_data
	query_in_progress = FALSE
	return json_data

/obj/effect/mapping_helpers/broken_floor
	name = "broken floor"
	icon = 'icons/turf/damaged.dmi'
	icon_state = "damaged1"
	late = TRUE
	layer = ABOVE_NORMAL_TURF_LAYER

/obj/effect/mapping_helpers/broken_floor/Initialize(mapload)
	.=..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/mapping_helpers/broken_floor/LateInitialize()
	var/turf/open/floor/floor = get_turf(src)
	floor.break_tile()
	qdel(src)

/obj/effect/mapping_helpers/burnt_floor
	name = "burnt floor"
	icon = 'icons/turf/damaged.dmi'
	icon_state = "floorscorched1"
	late = TRUE
	layer = ABOVE_NORMAL_TURF_LAYER

/obj/effect/mapping_helpers/burnt_floor/Initialize(mapload)
	.=..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/mapping_helpers/burnt_floor/LateInitialize()
	var/turf/open/floor/floor = get_turf(src)
	floor.burn_tile()
	qdel(src)
