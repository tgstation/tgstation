/obj/item/fish/starfish/chrystarfish
	name = "chrystarfish"
	desc = "This is what happens when a cosmostarfish sneaks into the bluespace compartment of a hyperspace engine. Very pointy and damaging - the biggest cause of spaceship explosions in 2554."
	icon = 'icons/obj/aquarium/fish.dmi'
	lefthand_file = 'icons/mob/inhands/fish_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fish_righthand.dmi'
	force = 12
	sharpness = SHARP_POINTY
	wound_bonus = -10
	bare_wound_bonus = 15
	armour_penetration = 6
	demolition_mod = 1.2
	throwforce = 11
	throw_range = 8
	attack_verb_continuous = list("stabs", "jabs")
	attack_verb_simple = list("stab", "jab")
	hitsound = SFX_DEFAULT_FISH_SLAP
	drop_sound = 'sound/mobs/non-humanoids/fish/fish_drop1.ogg'
	pickup_sound = SFX_FISH_PICKUP
	sound_vary = TRUE
	item_flags = SLOWS_WHILE_IN_HAND

	sprite_width
	sprite_height
	dedicated_in_aquarium_icon = 'icons/obj/aquarium/fish.dmi'
	dedicated_in_aquarium_icon_state
	aquarium_vc_color

	food = /datum/reagent/bluespace
	feeding_frequency = 10 MINUTES
	health = 300
	death_text = "%SRC splinters apart into shards!"
	random_case_rarity = FISH_RARITY_NOPE
	fillet_type = /obj/item/stack/sheet/bluespace_crystal
	num_fillets = 3
	stable_population = 3
	compatible_types = list(/obj/item/fish/starfish)
	fish_traits = list(/datum/fish_trait/antigrav)
	beauty = FISH_BEAUTY_EXCELLENT
	fish_movement_type = /datum/fish_movement/accelerando
	fishing_difficulty_modifier = 15
	favorite_bait = list(/obj/item/stack/sheet/bluespace_crystal)
	// something something bluespace
	electrogenesis_power = 9 MEGA JOULES

/obj/item/fish/starfish/chrystarfish/get_base_edible_reagents_to_add()
	return_list = ..()
	return_list[/datum/reagent/bluespace] = 5
	return return_list

/obj/item/fish/starfish/chrystarfish/flinch_on_eat(mob/living/eater, mob/living/feeder)
	if(status != FISH_ALIVE)
		return
	to_chat(feeder, span_warning("[src] slips out of the spacetime in pain!"))

	var/tp_range = 6 * clamp(weight/average_weight, 3, 9) // usually 6, plus or minus fish weight
	// teleports itself if on a turf otherwise its container - whatever it is
	do_teleport(isturf(loc) ? src : loc, get_turf(feeder), tp_range, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/item/fish/starfish/chrystarfish/suicide_act(mob/living/user)
	visible_message(span_suicide("[user] swallows [src] whole! It looks like they're trying to commit suicide!"))
	forcemove(user)
	// *everything*
	//playsound(src, 'sound/effects/phasein.ogg', 75, TRUE)
	for(var/obj/thing in user.contents)
		stoplag(0.1 SECONDS)
		playsound(src, 'sound/effects/phasein.ogg', 15, TRUE)
		do_teleport(thing, get_turf(user), 2, asoundin = null, channel = TELEPORT_CHANNEL_BLUESPACE)
	qdel(src)

/obj/item/fish/dolphish
	name = "walro-dolphish"
	desc = "Strange, bloodthirsty apex predator from beyond. A powerful weapon, but it -hates- being held."
	icon = 'icons/obj/aquarium/fish.dmi'
	lefthand_file = 'icons/mob/inhands/fish_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fish_righthand.dmi'
	force = 19
	sharpness = SHARP_POINTY
	wound_bonus = -5
	bare_wound_bonus = 20
	armour_penetration = 12
	block_chance = 33
	throwforce = 7
	throw_range = 4
	attack_verb_continuous = list("bites", "impales", "rams")
	attack_verb_simple = list("bite", "impale", "ram")
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	block_sound = 'sound/items/weapons/parry.ogg'
	drop_sound = 'sound/mobs/non-humanoids/fish/fish_drop1.ogg'
	pickup_sound = SFX_FISH_PICKUP
	sound_vary = TRUE

	base_pixel_x = -16
	pixel_x = -16
	sprite_width
	sprite_height
	dedicated_in_aquarium_icon = 'icons/obj/aquarium/fish.dmi'
	dedicated_in_aquarium_icon_state
	aquarium_vc_color

	required_fluid_type = AQUARIUM_FLUID_AIR
	required_temperature_min = BODYTEMP_COLD_DAMAGE_LIMIT // you mean just like a human? that's odd...
	required_temperature_max = BODYTEMP_HEAT_DAMAGE_LIMIT
	food = /datum/reagent/blood
	health = 600 // apex predator
	random_case_rarity = FISH_RARITY_GOOD_LUCK_FINDING_THIS
	fillet_type = /obj/item/food/fishmeat/fish_tail
	num_fillets = 1
	stable_population = 2
	fish_traits = list(/datum/fish_trait/wary, /datum/fish_trait/carnivore, /datum/fish_trait/necrophage, /datum/fish_trait/predator, /datum/fish_trait/territorial, /datum/fish_trait/stinger/datum/fish_trait/)
	fish_movement_type = /datum/fish_movement/choppy
	fishing_difficulty_modifier = 30
	favorite_bait = list()
	disliked_bait = list()
	average_size = 150
	average_weight = 2750
	weight_size_deviation = 0.5
	safe_air_limits = list(
		/datum/gas/oxygen = list(12, 100),
		/datum/gas/nitrogen,
		/datum/gas/carbon_dioxide = list(0, 10),
	)
	min_pressure = HAZARD_LOW_PRESSURE
	max_pressure = HAZARD_HIGH_PRESSURE
	beauty = FISH_BEAUTY_GREAT
	// Maximum patience for below var.
	var/max_patience = 15
	// Counter of how much patience the fish currently has before it attacks its wielder.
	var/patience
	// By default, lose one 'patience' per second it's held, and regain one per second it's not, up to max_patience cap.
	var/last_patience

/obj/item/fish/dolphish/get_force_rank()
	var/multiplier = 1
	switch(w_class)
		if(WEIGHT_CLASS_TINY)
			multiplier = 0.35
		if(WEIGHT_CLASS_SMALL)
			multiplier = 0.5
		if(WEIGHT_CLASS_NORMAL)
			multiplier = 0.75
		// bulky is avergae
		if(WEIGHT_CLASS_HUGE)
			multiplier = 1.15
		if(WEIGHT_CLASS_GIGANTIC)
			multiplier = 1.35

	if(status == FISH_DEAD)
		multiplier -= 0.35 // huge nerf if dead

	force *= multiplier
	attack_speed *= multiplier
	demolition_mod *= multiplier
	block_chance *= multiplier
	armour_penetration *= multiplier
	wound_bonus *= multiplier
	bare_wound_bonus *= multiplier

/obj/item/fish/dolphish/process(seconds_per_tick)
	. = ..()
	var/patience_reduction = 1

	var/turf/onturf = get_turf(loc)
	//gas check
	var/datum/gas_mixture/turf_gasmix = onturf.return_air()
	// likes water, gets sleepy, gets very sleepy
	if(turf_gasmix.gases[/datum/gas/water_vapor] && turf_gasmix.gases[/datum/gas/water_vapor][MOLES] >= 5)
		patience_reduction *= 0.5
	if(turf_gasmix.gases[/datum/gas/nitrous_oxide] && turf_gasmix.gases[/datum/gas/nitrous_oxide][MOLES] >= 5)
		patience_reduction *= 0.25
	if(turf_gasmix.gases[/datum/gas/healium] && turf_gasmix.gases[/datum/gas/healium][MOLES] >= 5)
		patience_reduction *= 0.1

	if(!ismob(loc))
		// dividing by the multiplier nets us an increasing value. happy dolphish gain patience quicker
		var/patience_bonus = (1 / patience_reduction)
		patience = FLOOR(patience + patience_bonus * seconds_per_tick, max_patience)
		return

	var/mob/living/moc = loc
	if(moc.mob_biotypes & MOB_AQUATIC)
		patience_reduction *= 0.6
	if(HAS_TRAIT(moc, TRAIT_IS_WET))
		patience_reduction *= 0.6

	last_patience = patience
	patience = FLOOR(patience - patience_reduction * seconds_per_tick, max_patience)

	switch(patience)
		// stage 1
		if(15 to 11)
			if(prob(20))
				visible_message(span_notice("[src] seems uncomfortable in [moc]'s grasp."))
		// stage 2
		if(11 to 6)
			if(prob(40))
				visible_message(span_danger("[src] flinches away from [moc[!"))
		// stage 3
		if(5 to 2)
			if(prob(60))
				visible_message(span_bolddanger("[src] thrashes wildly against [moc]'s grasp!"))
		if(0)
			moc.visible_message(span_bolddanger("[src] bites directly into [moc]!"), span_userdanger("[src] bites directly into you!!"))
			moc.apply_damage(force, BRUTE, user.get_active_hand(), wound_bonus = wound_bonus, bare_wound_bonus = bare_wound_bonus, sharpness = sharpness, attacking_item = src)
			forceMove(user.drop_location())

	return

/obj/item/fish/sockeye_salmon
	name = "chrystarfish"
	desc = "This is what happens when a cosmostarfish sneaks into the bluespace compartment of a hyperspace engine. Very pointy and damaging - the biggest cause of spaceship explosions in 2554."
	icon = 'icons/obj/aquarium/fish.dmi'
	lefthand_file = 'icons/mob/inhands/fish_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fish_righthand.dmi'
	force = 12
	sharpness = SHARP_POINTY
	wound_bonus = -10
	bare_wound_bonus = 15
	armour_penetration = 6
	throwforce = 11
	throw_range = 8
	attack_verb_continuous = list("stabs", "jabs")
	attack_verb_simple = list("stab", "jab")
	hitsound = SFX_DEFAULT_FISH_SLAP
	drop_sound = 'sound/mobs/non-humanoids/fish/fish_drop1.ogg'
	pickup_sound = SFX_FISH_PICKUP
	sound_vary = TRUE
	item_flags = SLOWS_WHILE_IN_HAND

	sprite_width
	sprite_height
	dedicated_in_aquarium_icon = 'icons/obj/aquarium/fish.dmi'
	dedicated_in_aquarium_icon_state
	aquarium_vc_color

	required_fluid_type = AQUARIUM_FLUID_AIR
	required_temperature_min = 0
	required_temperature_max = INFINITY
	datum/reagent/food = /datum/reagent/consumable/nutriment
	feeding_frequency = 5 MINUTES
	last_feeding
	status = FISH_ALIVE
	icon_state_dead
	health = 100
	death_text = "%SRC dies."
	random_case_rarity = FISH_RARITY_BASIC
	fillet_type = /obj/item/food/fishmeat
	num_fillets = 1
	stable_population = 1
	breeding_wait
	breeding_timeout = 2 MINUTES
	list/compatible_types
	list/spawn_types
	list/evolution_types
	list/fish_traits = list()
	fish_movement_type = /datum/fish_movement
	fishing_difficulty_modifier = 0
	list/favorite_bait = list()
	list/disliked_bait = list()
	size
	average_size = 50
	temp_size
	maximum_size
	weight
	average_weight = 1000
	temp_weight
	maximum_weight
	material_weight_mult = 1
	weight_size_deviation = 0.2
	list/safe_air_limits = list(
		/datum/gas/oxygen = list(12, 100),
		/datum/gas/nitrogen,
		/datum/gas/carbon_dioxide = list(0, 10),
		/datum/gas/water_vapor,
	)
	min_pressure = WARNING_LOW_PRESSURE
	max_pressure = HAZARD_HIGH_PRESSURE
	electrogenesis_power = 2 MEGA JOULES
	beauty = FISH_BEAUTY_GENERIC
