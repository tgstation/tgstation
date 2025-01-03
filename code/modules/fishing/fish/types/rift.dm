/obj/item/fish/starfish/chrystarfish
	name = "chrystarfish"
	fish_id = "chrystarfish"
	desc = "This is what happens when a cosmostarfish sneaks into the bluespace compartment of a hyperspace engine. Very pointy and damaging - leading cause of spaceship explosions in 2554."
	icon = 'icons/obj/aquarium/rift.dmi'
	dedicated_in_aquarium_icon = 'icons/obj/aquarium/rift.dmi'
	icon_state = "chrystarfish"
	force = 12
	sharpness = SHARP_POINTY
	wound_bonus = -10
	bare_wound_bonus = 15
	armour_penetration = 6
	demolition_mod = 1.2
	throwforce = 11
	throw_range = 8
	throw_speed = 4
	embed_type = /datum/embedding/chrystarfish
	attack_verb_continuous = list("stabs", "jabs")
	attack_verb_simple = list("stab", "jab")
	hitsound = SFX_SHATTER
	pickup_sound = 'sound/items/handling/materials/glass_pick_up.ogg'
	drop_sound = 'sound/items/handling/materials/glass_drop.ogg'

	sprite_width = 7
	sprite_height = 9

	average_size = 40
	average_weight = 1500
	food = /datum/reagent/bluespace
	feeding_frequency = 10 MINUTES
	health = 50
	death_text = "%SRC splinters apart into shards!"
	random_case_rarity = FISH_RARITY_GOOD_LUCK_FINDING_THIS
	fillet_type = /obj/item/stack/ore/bluespace_crystal
	num_fillets = 3
	stable_population = 3
	compatible_types = list(/obj/item/fish/starfish)
	fish_traits = list(/datum/fish_trait/antigrav)
	beauty = FISH_BEAUTY_EXCELLENT
	fish_movement_type = /datum/fish_movement/accelerando
	fishing_difficulty_modifier = 15
	favorite_bait = list(/obj/item/stack/ore/bluespace_crystal)
	// something something bluespace
	electrogenesis_power = 9 MEGA JOULES

// Basically a ninja star that's highly likely to embed and teleports you around if you don't stop to remove it. However it doesn't deal that much damage!
/datum/embedding/chrystarfish
	pain_mult = 1
	embed_chance = 85
	fall_chance = 3
	pain_chance = 9
	impact_pain_mult = 1
	remove_pain_mult = 2
	rip_time = 1.5 SECONDS
	ignore_throwspeed_threshold = TRUE // basically shaped like a shuriken
	jostle_chance = 15
	jostle_pain_mult = 1

/datum/embedding/chrystarfish/jostle_effects()
	do_teleport(owner, get_turf(owner), 3, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
	owner.visible_message(span_danger("[owner] teleports as [parent] jostles inside of [owner.p_them()]!"))

/obj/item/fish/starfish/chrystarfish/set_status(new_status, silent)
	. = ..()
	if(new_status == FISH_DEAD)
		new fillet_type(get_turf(src))
		playsound(src, SFX_SHATTER, 50)
		qdel(src)

/obj/item/fish/starfish/chrystarfish/add_emissive()
	return

/obj/item/fish/starfish/chrystarfish/get_base_edible_reagents_to_add()
	var/list/return_list = ..()
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
	forceMove(user)
	// *everything*
	for(var/obj/thing in user.get_contents())
		if(QDELETED(thing) || istype(thing, /obj/item/bodypart/chest))
			continue // don't want a gib
		stoplag(0.1 SECONDS)
		playsound(src, 'sound/effects/phasein.ogg', 15, TRUE)
		do_teleport(thing, get_turf(user), 2, asoundin = null, channel = TELEPORT_CHANNEL_BLUESPACE)
	qdel(src)
	return MANUAL_SUICIDE

// Prevents the first 2 messages from spamming on each patience update.
#define PATIENCE_FLINCH "PATIENCE_FLINCH"
#define PATIENCE_UNCOMFY "PATIENCE_UNCOMFY"

/obj/item/fish/dolphish
	name = "walro-dolphish"
	fish_id = "walro-dolphish"
	desc = "Strange bloodthirsty apex predator from beyond. A powerful weapon, but it -hates- being held."
	icon = 'icons/obj/aquarium/wide.dmi'
	dedicated_in_aquarium_icon = 'icons/obj/aquarium/rift.dmi'
	icon_state = "dolphish"
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
	sprite_width = 13
	sprite_height = 9

	required_fluid_type = AQUARIUM_FLUID_AIR
	required_temperature_min = BODYTEMP_COLD_DAMAGE_LIMIT // you mean just like a human? that's odd...
	required_temperature_max = BODYTEMP_HEAT_DAMAGE_LIMIT
	food = /datum/reagent/blood
	health = 600 // apex predator
	random_case_rarity = FISH_RARITY_GOOD_LUCK_FINDING_THIS
	fillet_type = /obj/item/food/fishmeat/fish_tail
	num_fillets = 1
	stable_population = 3
	fish_traits = list(/datum/fish_trait/wary, /datum/fish_trait/carnivore, /datum/fish_trait/necrophage, /datum/fish_trait/predator, /datum/fish_trait/territorial, /datum/fish_trait/stinger)
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
	/// Maximum patience for below var.
	var/max_patience = 20
	/// Counter of how much patience the fish currently has before it attacks its wielder.
	var/patience = 20
	/// Ensures the last warning fx isn't repeated
	var/last_effect

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

/obj/item/fish/dolphish/do_fish_process(seconds_per_tick)
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
		patience = clamp(patience + patience_bonus * seconds_per_tick, 0, max_patience)
		return

	var/mob/living/moc = loc
	if(moc.mob_biotypes & MOB_AQUATIC)
		patience_reduction *= 0.6
	if(HAS_TRAIT(moc, TRAIT_IS_WET))
		patience_reduction *= 0.6

	patience = clamp(patience - (patience_reduction * seconds_per_tick), 0, max_patience)

	switch(patience)
		if(0)
			// No check, we always want sharky to bite jerky on 0
			moc.visible_message(span_bolddanger("[src] bites directly into [moc] and squirms away from [moc.p_their()] grasp!"), span_userdanger("[src] sinks its fangs into you!!"))
			moc.apply_damage(force, BRUTE, moc.get_active_hand(), wound_bonus = wound_bonus, bare_wound_bonus = bare_wound_bonus, sharpness = sharpness, attacking_item = src)
			forceMove(moc.drop_location())
			moc.painful_scream()
			patience = max_patience
			playsound(src, hitsound, 45)
		if(1 to 10)
			// No check, final warning as they struggle, also funny.
			visible_message(span_bolddanger("[src] thrashes against [moc]'s grasp!"))
			moc.shake_up_animation()
		if(10 to 15)
			if(last_effect == PATIENCE_FLINCH)
				return
			visible_message(span_danger("[src] flinches away from [moc]!"))
			moc.shake_up_animation()
			last_effect = PATIENCE_FLINCH
		if(15 to 20)
			if(last_effect == PATIENCE_UNCOMFY)
				return
			visible_message(span_notice("[src] seems uncomfortable in [moc]'s grasp."))
			last_effect = PATIENCE_UNCOMFY

	return

#undef PATIENCE_FLINCH
#undef PATIENCE_UNCOMFY

/obj/item/fish/flumpulus
	name = "flumpulus"
	fish_id = "flumpulus"
	desc = "You can hardly even guess as to how this possibly counts as a fish. Inexplicably, you get the feeling that it could serve as a fantastic way to cushion a fall."
	icon = 'icons/obj/aquarium/rift.dmi'
	dedicated_in_aquarium_icon = 'icons/obj/aquarium/rift.dmi'
	icon_state = "flumpulus"
	lefthand_file = 'icons/mob/inhands/fish_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fish_righthand.dmi'
	attack_verb_continuous = list("splats", "splorts")
	attack_verb_simple = list("splat", "splort")

	sprite_width = 10
	sprite_height = 9

	required_fluid_type = AQUARIUM_FLUID_AIR
	required_temperature_min = 0
	required_temperature_max = INFINITY
	food = /datum/reagent/consumable/nutriment/fat
	random_case_rarity = FISH_RARITY_GOOD_LUCK_FINDING_THIS
	fillet_type = /obj/item/food/meat/slab/human/mutant/slime
	num_fillets = 2
	stable_population = 2
	fish_traits = list()
	fish_movement_type = /datum/fish_movement/slow
	fishing_difficulty_modifier = 22
	favorite_bait = list()
	disliked_bait = list()
	// twice as big, half as heavy
	average_size = 100
	average_weight = 500
	material_weight_mult = 1
	weight_size_deviation = 0.6
	safe_air_limits = list(
		/datum/gas/nitrogen,
	)
	min_pressure = 0
	max_pressure = HAZARD_HIGH_PRESSURE
	beauty = FISH_BEAUTY_UGLY

/obj/item/fish/flumpulus/suicide_act(mob/living/user)
	visible_message(span_suicide("[user] swallows [src] whole! It looks like they're trying to commit suicide!"))
	forceMove(user)
	. = MANUAL_SUICIDE
	for(var/i in 1 to rand(5, 15))
		addtimer(CALLBACK(src, PROC_REF(flump_attack), user), 0.4 SECONDS * i)

/obj/item/fish/flumpulus/proc/flump_attack(mob/living/user)
	var/obj/item/organ/eyes/eyes = user.get_organ_slot(ORGAN_SLOT_EYES)
	var/obj/item/organ/eyes/new_eyes = pick(list(/obj/item/organ/eyes/snail, /obj/item/organ/eyes/night_vision/mushroom))
	new_eyes = new new_eyes(user)
	new_eyes.Insert(user)
	playsound(user, 'sound/effects/cartoon_sfx/cartoon_pop.ogg', 50, TRUE)
	user.visible_message("[user]'s [eyes ? eyes : "eye holes"] suddenly sprout stalks and turn into [new_eyes]!")
	ASYNC
		user.emote("scream")
		sleep(5 SECONDS)
		if(!QDELETED(eyes))
			eyes.visible_message(span_danger("[eyes] rapidly turn to dust."))
			eyes.dust()

/obj/item/fish/flumpulus/get_base_edible_reagents_to_add()
	var/list/return_list = ..()
	//return_list[/datum/reagent/flumpulus_extract] = 10
	return_list[/datum/reagent/medicine/oculine/flumpuline] = 10
	return return_list

/obj/item/fish/flumpulus/intercept_zImpact(list/falling_movables, levels)
	. = ..()
	if(status == FISH_DEAD)
		return .

	for(var/mob/living/fallen_mob in falling_movables)
		visible_message(span_danger("[src] flattens like a pancake as [fallen_mob] lands on top of it!"))
		adjust_health(initial(health) * 0.1) // very durable
		AddElement(/datum/element/squish, 15 SECONDS)
		fallen_mob.Paralyze(0.5 SECONDS)
		playsound(src, 'sound/effects/cartoon_sfx/cartoon_splat.ogg', 75)

	return FALL_INTERCEPTED | FALL_NO_MESSAGE

/obj/item/fish/gullion
	name = "gullion"
	fish_id = "gullion"
	desc = "This crystalline fish is actually one of only two known silicon-based lifeforms.\
		It avoids death via oxygen-silicate reactions by organically shielding its exterior, allowing the thick scales to calcify into quartz and diamond, at the cost of rendering the fish functionally blind. \
		How xenomorphs manage is a complete mystery bordering on bullshit."
	icon = 'icons/obj/aquarium/rift.dmi'
	dedicated_in_aquarium_icon = 'icons/obj/aquarium/rift.dmi'
	icon_state = "gullion"
	lefthand_file = 'icons/mob/inhands/fish_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fish_righthand.dmi'
	attack_verb_continuous = list("stabs", "jabs")
	attack_verb_simple = list("stab", "jab")
	hitsound = SFX_DEFAULT_FISH_SLAP
	pickup_sound = 'sound/items/handling/materials/glass_pick_up.ogg'
	drop_sound = 'sound/items/handling/materials/glass_drop.ogg'
	sprite_width = 7
	sprite_height = 5

	food = /datum/reagent/silicon
	feeding_frequency = 30 SECONDS
	health = 160
	death_text = "%SRC calcifies."
	random_case_rarity = FISH_RARITY_GOOD_LUCK_FINDING_THIS
	fillet_type = /obj/item/stack/sheet/mineral/diamond
	num_fillets = 2
	stable_population = 3
	fish_traits = list(/datum/fish_trait/heavy, /datum/fish_trait/parthenogenesis) // this thing is a diamond farm
	beauty = FISH_BEAUTY_EXCELLENT
	fish_movement_type = /datum/fish_movement/slow
	favorite_bait = list(/obj/item/stack/sheet/mineral/diamond)
	fishing_difficulty_modifier = 22
	average_size = 30
	average_weight = 2000
	weight_size_deviation = 0.3
	safe_air_limits = list(
		/datum/gas/oxygen = list(0, 2), // does NOT like oxygen
		/datum/gas/water_vapor,
	)
	required_fluid_type = AQUARIUM_FLUID_SULPHWATEVER
	required_temperature_min = 0
	required_temperature_max = BODYTEMP_HEAT_DAMAGE_LIMIT
	min_pressure = HAZARD_LOW_PRESSURE
	max_pressure = WARNING_HIGH_PRESSURE

/obj/item/fish/gullion/suicide_act(mob/living/user)
	visible_message(span_suicide("[user] swallows [src] whole! It looks like they're trying to commit suicide!"))
	forceMove(user)
	var/datum/gas_mixture/environment = user.loc.return_air()
	var/oxygen_in_air = check_gases(environment.gases, list(/datum/gas/oxygen))
	if(!oxygen_in_air || (status == FISH_DEAD))
		visible_message(span_suicide("[user] chokes and dies! (Wait, from the fish or from lack of air?)"))
		return OXYLOSS

	user.petrify(statue_timer = INFINITY)
	visible_message(span_suicide("[user]'s skin turns into quartz upon contact with the oxygen in the air!'"))
	qdel(src)
	return MANUAL_SUICIDE
