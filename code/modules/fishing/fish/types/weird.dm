/obj/item/fish/starfish/chrystarfish
	name = "chrystarfish"
	fish_id = "chrystarfish"
	desc = "This is what happens when a cosmostarfish sneaks into the bluespace compartment of a hyperspace engine. Very pointy and damaging - leading cause of spaceship explosions in 2554."
	icon = 'icons/obj/aquarium/weird.dmi'
	icon_state = "chrystarfish"
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
	throw_speed = 4
	embed_type = /datum/embed_data/throwing_star
	attack_verb_continuous = list("stabs", "jabs")
	attack_verb_simple = list("stab", "jab")
	hitsound = SFX_DEFAULT_FISH_SLAP
	drop_sound = 'sound/mobs/non-humanoids/fish/fish_drop1.ogg'
	pickup_sound = SFX_FISH_PICKUP
	sound_vary = TRUE
	item_flags = SLOWS_WHILE_IN_HAND

	sprite_width = 4
	sprite_height = 3
	dedicated_in_aquarium_icon = 'icons/obj/aquarium/fish.dmi'
	dedicated_in_aquarium_icon_state = ""

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

/datum/embed_data/chrystarfish
	pain_mult = 1
	embed_chance = 100
	fall_chance = 3

/obj/item/fish/starfish/chrystarfish/set_status(new_status, silent)
	. = ..()
	if(new_status == FISH_DEAD)
		new fillet_type(get_turf(src))
		playsound(src, SFX_SHATTER, 50)
		qdel(src)

// todo : embed causes constant teleport

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
		if(istype(thing, /obj/item/bodypart/chest))
			continue // don't want a gib
		stoplag(0.1 SECONDS)
		playsound(src, 'sound/effects/phasein.ogg', 15, TRUE)
		do_teleport(thing, get_turf(user), 2, asoundin = null, channel = TELEPORT_CHANNEL_BLUESPACE)
	qdel(src)
	return MANUAL_SUICIDE

/obj/item/fish/dolphish
	name = "walro-dolphish"
	fish_id = "walro-dolphish"
	desc = "Strange, bloodthirsty apex predator from beyond. A powerful weapon, but it -hates- being held."
	icon = 'icons/obj/aquarium/wide.dmi'
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
	sprite_width = 4
	sprite_height = 3
	dedicated_in_aquarium_icon = 'icons/obj/aquarium/fish.dmi'
	dedicated_in_aquarium_icon_state = ""


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
	// Maximum patience for below var.
	var/max_patience = 15
	// Counter of how much patience the fish currently has before it attacks its wielder.
	var/patience

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

	patience = FLOOR(patience - (patience_reduction * seconds_per_tick), max_patience)

	switch(patience)
		if(0)
			moc.visible_message(span_bolddanger("[src] bites directly into [moc]!"), span_userdanger("[src] bites directly into you!!"))
			moc.apply_damage(force, BRUTE, moc.get_active_hand(), wound_bonus = wound_bonus, bare_wound_bonus = bare_wound_bonus, sharpness = sharpness, attacking_item = src)
			forceMove(moc.drop_location())
		if(1 to 5)
			if(prob(60))
				visible_message(span_bolddanger("[src] thrashes wildly against [moc]'s grasp!"))
		if(6 to 11)
			if(prob(40))
				visible_message(span_danger("[src] flinches away from [moc]!"))
		if(11 to 15)
			if(prob(20))
				visible_message(span_notice("[src] seems uncomfortable in [moc]'s grasp."))

	return

/obj/item/fish/flumpulus
	name = "flumpulus"
	fish_id = "flumpulus"
	desc = "You can hardly even guess as to how this possibly counts as a fish. Inexplicably, you get the feeling that it could serve as a fantastic way to cushion a fall."
	icon = 'icons/obj/aquarium/weird.dmi'
	icon_state = "flumpulus"
	lefthand_file = 'icons/mob/inhands/fish_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fish_righthand.dmi'
	attack_verb_continuous = list("splats", "splorts")
	attack_verb_simple = list("splat", "splort")

	sprite_width = 4
	sprite_height = 3
	dedicated_in_aquarium_icon = 'icons/obj/aquarium/fish.dmi'
	dedicated_in_aquarium_icon_state = ""


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
		addtimer(CALLBACK(src, PROC_REF(flump_attack), user), 0.1 SECONDS * i)

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
	desc = "This crystalline fish is actually one of only two known silicon-based lifeforms, alongside xenomorphs.\
		It avoids death via oxygen-silicate reactions by organically shielding its exterior, allowing the thick scales to calcify into quartz, at the cost of rendering the fish functionally blind. \
		How xenomorphs manage it is a complete mystery bordering on bullshit."
	icon = 'icons/obj/aquarium/weird.dmi'
	icon_state = "gullion"
	lefthand_file = 'icons/mob/inhands/fish_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fish_righthand.dmi'
	attack_verb_continuous = list("stabs", "jabs")
	attack_verb_simple = list("stab", "jab")
	hitsound = SFX_DEFAULT_FISH_SLAP
	drop_sound = 'sound/mobs/non-humanoids/fish/fish_drop1.ogg'
	pickup_sound = SFX_FISH_PICKUP
	sprite_width = 4
	sprite_height = 3
	dedicated_in_aquarium_icon = 'icons/obj/aquarium/fish.dmi'
	dedicated_in_aquarium_icon_state = ""


	food = /datum/reagent/silicon
	feeding_frequency = 30 SECONDS
	health = 160
	death_text = "%SRC calcifies."
	random_case_rarity = FISH_RARITY_GOOD_LUCK_FINDING_THIS
	fillet_type = /obj/item/stack/sheet/mineral/diamond
	num_fillets = 3
	stable_population = 3
	fish_traits = list(/datum/fish_trait/heavy, /datum/fish_trait/parthenogenesis) // this thing is a diamond farm
	beauty = FISH_BEAUTY_EXCELLENT
	fish_movement_type = /datum/fish_movement/slow
	fishing_difficulty_modifier = 45 // thick hide
	favorite_bait = list(/obj/item/stack/sheet/mineral/diamond)
	fishing_difficulty_modifier = 22
	average_size = 60
	average_weight = 2000
	material_weight_mult = 4
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

/obj/item/fish/pete
	name = "Pete"
	fish_id = "Pete"
	desc = "This fish really is just like you. For real."
	icon = 'icons/obj/aquarium/weird.dmi'
	icon_state = "pete"
	lefthand_file = 'icons/mob/inhands/fish_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fish_righthand.dmi'
	attack_verb_continuous = list("stings", "smokes")
	attack_verb_simple = list("sting", "smoke")
	hitsound = SFX_SEAR
	damtype = BURN
	drop_sound = 'sound/mobs/non-humanoids/fish/fish_drop1.ogg'
	pickup_sound = SFX_FISH_PICKUP

	sprite_width = 4
	sprite_height = 3
	dedicated_in_aquarium_icon = 'icons/obj/aquarium/fish.dmi'
	dedicated_in_aquarium_icon_state = ""


	food = /datum/reagent/drug/nicotine
	feeding_frequency = 1 MINUTES // addict
	health = 70 // weak lungs
	death_text = "%SRC chokes."
	random_case_rarity = FISH_RARITY_GOOD_LUCK_FINDING_THIS
	fish_traits = list(/datum/fish_trait/wary, /datum/fish_trait/yucky)
	beauty = FISH_BEAUTY_EXCELLENT
	fish_movement_type = /datum/fish_movement/slow
	fishing_difficulty_modifier = 5
	favorite_bait = list(/obj/item/cigarette)
	average_size = 45
	average_weight = 900
	required_fluid_type = AQUARIUM_FLUID_AIR
	required_temperature_min = MIN_AQUARIUM_TEMP+33
	required_temperature_max = MIN_AQUARIUM_TEMP+66
	safe_air_limits = list(
		/datum/gas/oxygen,
	)
	var/cignited = FALSE

/obj/item/fish/pete/Initialize(mapload, apply_qualities)
	. = ..()
	name = GLOB.first_names_male // NO WOMEN

/obj/item/fish/pete/suicide_act(mob/living/carbon/user)
	visible_message(span_suicide("[user] takes a drag of [src]'s cigarette! It looks like they're trying to commit suicide!"))
	say("Hey, that's mine!")
	if(!iscarbon(user))
		return OXYLOSS
	var/obj/item/organ/lungs/old_lungs = user.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(!old_lungs)
		visible_message(span_suicide("[user] has no lungs to smoke with!"))
		return SHAME
	visible_message(span_suicide("[user]'s lungs give out! They couldn't handle a fish cigarette!"))
	var/obj/item/organ/smoker_lungs = new user.dna.species.smoker_lungs
	smoker_lungs.Insert(user, special = TRUE, movement_flags = DELETE_IF_REPLACED)
	user.reagents.add_reagent(/datum/reagent/drug/nicotine, 1000)
	qdel(src)
	return OXYLOSS

/obj/item/fish/pete/ignition_effect(atom/A, mob/user)
	. = ..()
	if(cignited)
		return .
	visible_message(span_notice("[src]'s cigarette is ignited by [user ? "[user]. [src] looks at [user.p_them()] and nods." : A]. "))
	cignited = TRUE
	update_icon_state()

/obj/item/fish/pete/update_icon_state()
	if(cignited && status == FISH_ALIVE)
		icon = "pete_smoking"
	else return ..()

// The reason you DON'T fish in rifts.
// This thing is a plague - throws itself around and envenoms those it hits.
// Worse, it's immune to the environment and revives either way.
/obj/item/fish/mossglob
	name = "mossglob"
	fish_id = "mossglob"
	desc = "This dreaded, malicious, and unkillable glob of moss is rumoured to be nature's revenge against fishermen."
	icon = 'icons/obj/aquarium/weird.dmi'
	icon_state = "mossglob"
	lefthand_file = 'icons/mob/inhands/fish_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fish_righthand.dmi'
	attack_verb_continuous = list("stings", "pricks")
	attack_verb_simple = list("sting", "prick")
	force = 11
	damtype = TOX
	sharpness = SHARP_POINTY
	wound_bonus = -5
	bare_wound_bonus = 15
	armour_penetration = 7
	throwforce = 9
	throw_range = 7
	hitsound = SFX_ALT_FISH_SLAP

	sprite_width = 4
	sprite_height = 3
	dedicated_in_aquarium_icon = 'icons/obj/aquarium/fish.dmi'
	dedicated_in_aquarium_icon_state = ""

	health = 500
	death_text = "%SRC decomposes."
	random_case_rarity = FISH_RARITY_NOPE
	// hand-tuned to be a plague
	fish_traits = list(
		/datum/fish_trait/wary, /datum/fish_trait/nocturnal, /datum/fish_trait/emulsijack, \
		/datum/fish_trait/yucky, /datum/fish_trait/lubed, /datum/fish_trait/revival, \
		/datum/fish_trait/toxin_immunity, /datum/fish_trait/hallucinogenic, \
		/datum/fish_trait/toxic_barbs, /datum/fish_trait/stinger, \
	)
	beauty = FISH_BEAUTY_DISGUSTING
	fish_movement_type = /datum/fish_movement/slow
	fishing_difficulty_modifier = 0
	favorite_bait = list(/obj/item/food/badrecipe)
	average_size = 150
	average_weight = 5000
	required_fluid_type = AQUARIUM_FLUID_ANY_WATER
	required_temperature_min = 0
	required_temperature_max = INFINITY
	min_pressure = 0
	max_pressure = INFINITY
	safe_air_limits = list()
	fillet_type = /obj/item/food/badrecipe/moldy/bacteria
	num_fillets = 3
	stable_population = 0

/obj/item/fish/mossglob/Initialize(mapload, apply_qualities)
	. = ..()
	AddElement(/datum/element/haunted, COLOR_GREEN)

// Babbelfish are psychic 'predators' that don't physically attack their prey, but emit a psychic aura that kills them, eating their corpses.
// When they die they emit a horrendous wail that deafens and debilitates people nearby - let alone fish.
/obj/item/fish/babbelfish
	name = "babbelfish"
	fish_id = "babbelfish"
	desc = "Babbelfish are both visually -and- psychically unsettling - their psychic wails damage the minds of those nearby. The effect is negligible on humans, but deadly for fish. \
		It is said that splitting one in two and inserting the pieces into each ear unlocks your psychic potential."
	icon = 'icons/obj/aquarium/weird.dmi'
	icon_state = "babbelfish"
	lefthand_file = 'icons/mob/inhands/fish_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fish_righthand.dmi'
	force = 7
	damtype = BRAIN
	attack_verb_continuous = list("screeches", "shrieks")
	attack_verb_simple = list("screech", "shriek")
	hitsound = SFX_DEFAULT_FISH_SLAP // todo shriek
	sound_vary = TRUE
	item_flags = SLOWS_WHILE_IN_HAND

	sprite_width = 4
	sprite_height = 3
	dedicated_in_aquarium_icon = 'icons/obj/aquarium/fish.dmi'
	dedicated_in_aquarium_icon_state = ""

	death_text = "%SRC emits a horrendous wail as it dies!"
	random_case_rarity = FISH_RARITY_NOPE
	health = 250
	fillet_type = /obj/item/food/fishmeat/quality
	num_fillets = 2
	stable_population = 3
	fish_traits = list(
		/datum/fish_trait/wary, /datum/fish_trait/picky_eater, /datum/fish_trait/heavy,
		/datum/fish_trait/emulsijack/psychic, /datum/fish_trait/necrophage,
	)
	beauty = FISH_BEAUTY_NULL // unsettling yet also awing
	fish_movement_type = /datum/fish_movement/slow
	fishing_difficulty_modifier = 15
	favorite_bait = list(/obj/item/organ/ears)

// When someone refactors demoralizers to not be omega hardcoded for syndicate this fish should get it

// todo add examine_:more

/obj/item/fish/babbelfish/set_status(new_status, silent)
	. = ..()
	if(new_status != FISH_DEAD)
		return
	visible_message(span_userdanger("[src] emits a horrendous wailing as it perishes!"))
	manual_emote("wails!")
	playsound(src, 'sound/mobs/non-humanoids/fish/fish_death2.ogg', 100)
	var/list/mob/living/mobs_in_range = get_hearers_in_range(7, src)
	for(var/mob/living/screeched in mobs_in_range)
		if(screeched.can_block_magic(MAGIC_RESISTANCE_MIND, charge_cost = 1))
			to_chat(screeched, span_notice("You resist the psychic wail!"))
			continue
		var/power = 1
		if(!screeched.can_hear()) // bit weaker if deaf. but its still psychic
			power *= 0.5
		var/affect_time = 15 SECONDS * power
		// it really fucks you over
		screeched.Knockdown(affect_time)
		screeched.adjust_disgust(affect_time)
		screeched.adjust_stutter(affect_time)
		screeched.adjust_slurring(affect_time)
		screeched.adjust_dizzy(affect_time)
		screeched.adjust_staggered(affect_time)
		screeched.adjust_jitter(affect_time)
		screeched.adjust_confusion(affect_time)
		screeched.adjust_hallucinations(affect_time)
		screeched.adjust_eye_blur(affect_time)
		if(iscarbon(screeched))
			var/mob/living/carbon/carbon_screeched = screeched
			carbon_screeched.vomit()

	var/affected = 0
	for(var/obj/item/fish/fishie in range(7, src))
		if(!isfish(fishie))
			continue
		if(HAS_TRAIT(fishie, TRAIT_RESIST_PSYCHIC))
			continue
		fishie.set_status(FISH_DEAD)
		affected++
	if(affected)
		visible_message(span_bolddanger("[src]'s wail kills [affected] fish nearby!")) // m-m-m-m-m-MONSTER KILL

/obj/item/fish/babbelfish/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(loc != user)
		return
	if((user.usable_hands < 2) && !HAS_TRAIT(user, TRAIT_STRENGTH))
		to_chat(user, span_notice("[src] is too dense to twist apart with only one hand."))
		return

	to_chat(user, span_danger("You start pulling and twisting [src], attempting to split it down the middle..."))
	if(!do_after(user, 2.5 SECONDS, src))
		return

	playsound(get_turf(user), 'sound/effects/wounds/crack1.ogg', 60)
	set_status(FISH_DEAD)
	var/cracked = new /obj/item/organ/ears/babbelfish(user)
	user.put_in_hands(cracked)
	qdel(src)

// These ears grant amazing and supernatural hearing, but they also screw over your knowledge of language.
/obj/item/organ/ears/babbelfish
	name = "split babbelfish halves"
	icon = 'icons/obj/aquarium/weird.dmi'
	icon_state = "babbelfish"
//	icon_state = "ears"
	desc = "Both halves of a babbelfish after being twisted apart. The legends claim these can unlock your psychic potential. It probably wasn't worth hearing that wail, though."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EARS
	gender = PLURAL
	organ_traits = list(TRAIT_XRAY_HEARING, TRAIT_GOOD_HEARING)

	healing_factor = STANDARD_ORGAN_HEALING * 5
	decay_factor = 0

	low_threshold_passed = span_noticealien("Psychic whispers make it a bit difficult to hear sometimes..")
	now_failing = span_noticealien("Psychic noise is overcrowding your senses!")
	now_fixed = span_noticealien("The psychic noise starts to disappear.")
	low_threshold_cleared = span_noticealien("The whispers leave you alone.")

	bang_protect = 5
	damage_multiplier = 0.1
	var/bound_component
	var/datum/language_holder/removal_holder

/obj/item/organ/ears/babbelfish/Initialize(mapload)
	. = ..()
	removal_holder = new(src)

/obj/item/organ/ears/babbelfish/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	var/obj/item/organ/ears/ears = user.get_organ_slot(ORGAN_SLOT_EARS)
	if(!ears)
		to_chat(user, span_notice("You don't have any ears to shove [src] into!"))
		return
	to_chat(user, span_danger("You start shoving [src] into your ears. Probably a bad idea."))
	if(!do_after(user, 2.5 SECONDS, src))
		return
	user.apply_damage(25, BRUTE, user.get_bodypart(ears.zone), attacking_item = src)
	to_chat(user, span_notice("As you're shoving them in, the [src] take on a life of their own and brutishly crawl right into your ears, taking their place entirely while maiming your [ears.zone]!"))
	// bad moodlet
	Insert(user, special = TRUE, movement_flags = DELETE_IF_REPLACED)

/obj/item/organ/ears/babbelfish/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	..()
	bound_component = organ_owner.AddComponent(
		/datum/component/anti_magic, \
		antimagic_flags = MAGIC_RESISTANCE_MIND, \
		inventory_flags = null, \
		charges = maxHealth * 0.1, \
		drain_antimagic = CALLBACK(src, PROC_REF(on_drain_magic)), \
		expiration = CALLBACK(src, PROC_REF(on_expire)), \
	)

	if(HAS_MIND_TRAIT(organ_owner, TRAIT_TOWER_OF_BABEL))
		to_chat(organ_owner, span_noticealien("You don't feel that much different this time. Looks like your brain has attuned to the [src]'s effect."))
		return

	if(!removal_holder)
		removal_holder = new(src)
	removal_holder.copy_languages(organ_owner.get_language_holder(), LANGUAGE_BABEL)

	switch(rand(1, 100))
		if(1 to 45)
			// Can understand nothing
			organ_owner.remove_all_languages(source = ALL)
			//but speak everything
			organ_owner.grant_all_languages(language_flags = SPOKEN_LANGUAGE, grant_omnitongue = FALSE, source = LANGUAGE_BABEL)
			to_chat(organ_owner, span_noticealien("You feel like you've been given the first half of a cosmic puzzle!"))
		if(46 to 90)
			// Can speak nothing
			organ_owner.remove_all_languages(source = ALL)
			// but understand everything
			organ_owner.grant_all_languages(language_flags = UNDERSTOOD_LANGUAGE, grant_omnitongue = FALSE, source = LANGUAGE_BABEL)
			to_chat(organ_owner, span_noticealien("You feel like you've been given the second half of a cosmic puzzle!"))
		if(91 to 100)
			// jackpot!
			organ_owner.grant_all_languages(language_flags = ALL, grant_omnitongue = TRUE, source = LANGUAGE_BABEL)
			to_chat(organ_owner, span_noticealien("You feel like you've been given both halves of a cosmic puzzle!"))
			to_chat(organ_owner, span_boldnicegreen("So <i>that's</i> what they said to you that one time..."))

	if(organ_owner.mind)
		ADD_TRAIT(organ_owner.mind, TRAIT_TOWER_OF_BABEL, MAGIC_TRAIT) // only one roll per mind

/obj/item/organ/ears/babbelfish/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()

	organ_owner.copy_languages(removal_holder)
	to_chat(organ_owner, span_notice("You feel significantly more mundane."))
	qdel(removal_holder)
	qdel(bound_component)

/obj/item/organ/ears/babbelfish/proc/on_drain_magic(mob/user)
	to_chat(user, span_noticealien("Your [src] pop as they protect your mind from psychic phenomena!"))
	adjustEarDamage(ddeaf = 20)

/obj/item/organ/ears/babbelfish/proc/on_expire(mob/user)
	to_chat(user, span_noticealien("Your [src] suddenly burst apart!"))
	apply_organ_damage(maxHealth, maxHealth)
