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
