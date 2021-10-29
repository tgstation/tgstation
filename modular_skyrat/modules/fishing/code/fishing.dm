GLOBAL_LIST_INIT(fishing_weights, list(
	/obj/item/stack/ore/diamond = 1,
	/obj/item/stack/ore/bluespace_crystal = 1,
	/obj/item/stack/ore/gold = 2,
	/obj/item/stack/ore/uranium = 2,
	/obj/item/stack/ore/titanium = 3,
	/obj/item/stack/ore/silver = 3,
	/obj/item/stack/ore/iron = 5,
	/obj/item/stack/ore/glass = 5,
	/obj/item/xenoarch/strange_rock = 1,
))

/datum/component/fishing
	///the list of possible loot you can get from successfully fishing from this
	var/list/possible_loot = list()
	///whether this should generate fish when successfully fishing from this
	var/generate_fish = FALSE
	//the starting window for when to reel back in (too early before this)
	COOLDOWN_DECLARE(start_fishing_window)
	//the closing window for when to reel back in (too late past this)
	COOLDOWN_DECLARE(stop_fishing_window)
	///the timer for playing the sound for when to reel back in
	var/reel_sound_timer
	///to modify the parent with a bobber icon
	var/mutable_appearance/mutate_parent
	var/atom/atom_parent

/datum/component/fishing/Initialize(list/set_loot, allow_fishes = FALSE)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	atom_parent = parent
	if(set_loot)
		possible_loot = set_loot
	if(allow_fishes)
		generate_fish = TRUE
	RegisterSignal(parent, COMSIG_START_FISHING, .proc/start_fishing)
	RegisterSignal(parent, COMSIG_FINISH_FISHING, .proc/finish_fishing)

/datum/component/fishing/Destroy(force, silent)
	UnregisterSignal(parent, COMSIG_START_FISHING)
	UnregisterSignal(parent, COMSIG_FINISH_FISHING)
	if(reel_sound_timer)
		deltimer(reel_sound_timer)
	return ..()

/datum/component/fishing/proc/start_fishing()
	var/random_fish_time = rand(3 SECONDS, 6 SECONDS)
	COOLDOWN_START(src, start_fishing_window, random_fish_time)
	COOLDOWN_START(src, stop_fishing_window, random_fish_time + 2 SECONDS)
	if(reel_sound_timer)
		deltimer(reel_sound_timer)
	if(mutate_parent)
		atom_parent.cut_overlay(mutate_parent)
		QDEL_NULL(mutate_parent)
	reel_sound_timer = addtimer(CALLBACK(src, .proc/reel_sound), random_fish_time, TIMER_STOPPABLE)
	mutate_parent = mutable_appearance(icon = 'modular_skyrat/modules/fishing/icons/fishing.dmi', icon_state = "bobber")
	atom_parent.add_overlay(mutate_parent)

//rather than making a visual change, create a sound to reel back in
/datum/component/fishing/proc/reel_sound()
	playsound(atom_parent, 'sound/machines/ping.ogg', 35, FALSE)
	atom_parent.do_alert_animation()

/datum/component/fishing/proc/finish_fishing(atom/fisher = null, master_involved = FALSE)
	if(reel_sound_timer)
		deltimer(reel_sound_timer)
	if(mutate_parent)
		atom_parent.cut_overlay(mutate_parent)
		QDEL_NULL(mutate_parent)
	if(!fisher)
		return
	if(COOLDOWN_FINISHED(src, start_fishing_window) && !COOLDOWN_FINISHED(src, stop_fishing_window))
		var/turf/fisher_turf = get_turf(fisher)
		create_reward(fisher_turf)
		if(master_involved)
			create_reward(fisher_turf)

/datum/component/fishing/proc/create_reward(turf/spawning_turf)
	var/atom/spawning_reward
	switch(rand(1, 100))
		if(1 to 50)
			spawning_reward = pick_weight(GLOB.trash_loot)
			while(islist(spawning_reward))
				spawning_reward = pick_weight(spawning_reward)
		if(51 to 75)
			if(generate_fish)
				generate_fish(spawning_turf, random_fish_type())
		if(76 to 95)
			spawning_reward = pick_weight(possible_loot)
		if(96 to 100)
			spawning_reward = /obj/item/skillchip/fishing_master
	new spawning_reward(spawning_turf)
	atom_parent.visible_message(span_notice("Something flys out of [atom_parent]!"))

/turf/open/water/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/fishing, set_loot = GLOB.fishing_weights, allow_fishes = TRUE)

/turf/open/lava/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/fishing, set_loot = GLOB.fishing_weights, allow_fishes = FALSE)

/obj/item/skillchip/fishing_master
	name = "Fishing Master skillchip"
	desc = "A master of fishing, capable of wrangling the whole ocean if we must."
	auto_traits = list(TRAIT_FISHING_MASTER)
	skill_name = "Fishing Master"
	skill_description = "Master the ability to fish."
	skill_icon = "certificate"
	activate_message = "<span class='notice'>The fish and junk become far more visible beneath the surface.</span>"
	deactivate_message = "<span class='notice'>The surface begins to cloud up, making it hard to see beneath.</span>"

/obj/item/fishing_rod
	name = "fishing rod"
	desc = "A wonderful item that can be used to fish from bodies of liquids."
	icon = 'modular_skyrat/modules/fishing/icons/fishing.dmi'
	icon_state = "normal_rod"
	inhand_icon_state = "normal_rod"
	lefthand_file = 'modular_skyrat/modules/fishing/icons/fishing_left.dmi'
	righthand_file = 'modular_skyrat/modules/fishing/icons/fishing_right.dmi'
	///the target that is currently being fished from
	var/atom/target_atom
	///the mob that picked up/equiped the rod and will be listened to
	var/mob/listening_to

/obj/item/fishing_rod/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/obj/item/fishing_rod/Destroy()
	if(listening_to)
		UnregisterSignal(listening_to, COMSIG_MOVABLE_MOVED)
		listening_to = null
	if(target_atom)
		SEND_SIGNAL(target_atom, COMSIG_FINISH_FISHING, fisher = src)
		target_atom = null
	return ..()

/obj/item/fishing_rod/equipped(mob/user, slot, initial)
	. = ..()
	if(listening_to == user)
		return
	if(listening_to)
		UnregisterSignal(listening_to, COMSIG_MOVABLE_MOVED)
	if(target_atom)
		SEND_SIGNAL(target_atom, COMSIG_FINISH_FISHING, fisher = src)
		target_atom = null
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/check_movement)
	listening_to = user

/obj/item/fishing_rod/dropped(mob/user, silent)
	. = ..()
	if(listening_to)
		UnregisterSignal(listening_to, COMSIG_MOVABLE_MOVED)
		listening_to = null
	if(target_atom)
		SEND_SIGNAL(target_atom, COMSIG_FINISH_FISHING, fisher = src)
		target_atom = null

/obj/item/fishing_rod/proc/check_movement()
	if(!listening_to)
		return
	if(!target_atom)
		return
	if(get_dist(target_atom, listening_to) >= 4)
		SEND_SIGNAL(target_atom, COMSIG_FINISH_FISHING, fisher = src)

/obj/item/fishing_rod/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(get_dist(target, user) >= 4)
		return
	if(target_atom)
		if(HAS_TRAIT(user, TRAIT_FISHING_MASTER))
			SEND_SIGNAL(target_atom, COMSIG_FINISH_FISHING, fisher = src, master_involved = TRUE)
			target_atom = null
			return
		SEND_SIGNAL(target_atom, COMSIG_FINISH_FISHING, fisher = src)
		target_atom = null
		return
	var/check_fishable = target.GetComponent(/datum/component/fishing)
	if(!check_fishable)
		return ..()
	target_atom = target
	if(ismovable(target_atom))
		RegisterSignal(target_atom, COMSIG_MOVABLE_MOVED, .proc/check_movement, override = TRUE)
	SEND_SIGNAL(target_atom, COMSIG_START_FISHING)

/datum/crafting_recipe/fishing_rod_primitive
	name = "Primitive Fishing Rod"
	result = /obj/item/fishing_rod
	reqs = list(/obj/item/stack/sheet/animalhide/goliath_hide = 2,
				/obj/item/stack/sheet/sinew = 2)
	category = CAT_MISC

/datum/crafting_recipe/fishing_rod
	name = "Fishing Rod"
	result = /obj/item/fishing_rod
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/stack/cable_coil = 2)
	category = CAT_MISC
