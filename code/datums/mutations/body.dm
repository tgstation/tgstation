//These mutations change your overall "form" somehow, like size

//Epilepsy gives a very small chance to have a seizure every life tick, knocking you unconscious.
/datum/mutation/epilepsy
	name = "Epilepsy"
	desc = "The subject sporadically suffers from seizures."
	instability = NEGATIVE_STABILITY_MODERATE
	quality = NEGATIVE
	text_gain_indication = span_danger("You get a headache.")
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/epilepsy/on_life(seconds_per_tick)
	if(SPT_PROB(0.5 * GET_MUTATION_SYNCHRONIZER(src), seconds_per_tick))
		trigger_seizure()

/datum/mutation/epilepsy/proc/trigger_seizure()
	if(owner.stat != CONSCIOUS)
		return
	owner.visible_message(span_danger("[owner] starts having a seizure!"), span_userdanger("You have a seizure!"))
	owner.Unconscious(200 * GET_MUTATION_POWER(src))
	owner.set_jitter(2000 SECONDS * GET_MUTATION_POWER(src)) //yes this number looks crazy but the jitter animations are amplified based on the duration.
	owner.add_mood_event("epilepsy", /datum/mood_event/epilepsy)
	addtimer(CALLBACK(src, PROC_REF(jitter_less)), 9 SECONDS)

/datum/mutation/epilepsy/proc/jitter_less()
	if(QDELETED(owner))
		return

	owner.set_jitter(20 SECONDS)

/datum/mutation/epilepsy/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOB_FLASHED, PROC_REF(get_flashed_nerd))

/datum/mutation/epilepsy/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_FLASHED)

/datum/mutation/epilepsy/proc/get_flashed_nerd()
	SIGNAL_HANDLER

	if(!prob(30))
		return
	trigger_seizure()


//Unstable DNA induces random mutations!
/datum/mutation/bad_dna
	name = "Unstable DNA"
	desc = "The subject will randomly mutate other mutations or features."
	instability = NEGATIVE_STABILITY_MAJOR
	quality = NEGATIVE
	text_gain_indication = span_danger("You feel strange.")
	locked = TRUE

/datum/mutation/bad_dna/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	to_chat(owner, text_gain_indication)
	var/mob/new_mob
	if(prob(95))
		switch(rand(1,3))
			if(1)
				new_mob = owner.easy_random_mutate(NEGATIVE + MINOR_NEGATIVE)
			if(2)
				new_mob = owner.random_mutate_unique_identity()
			if(3)
				new_mob = owner.random_mutate_unique_features()
	else
		new_mob = owner.easy_random_mutate(POSITIVE)
	if(new_mob && ismob(new_mob))
		owner = new_mob
	. = owner
	on_losing(owner)


//Cough gives you a chronic cough that causes you to drop items.
/datum/mutation/cough
	name = "Cough"
	desc = "The subject has a chronic cough."
	instability = NEGATIVE_STABILITY_MODERATE
	quality = MINOR_NEGATIVE
	text_gain_indication = span_danger("You start coughing.")
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/cough/on_life(seconds_per_tick)
	if(SPT_PROB(2.5 * GET_MUTATION_SYNCHRONIZER(src), seconds_per_tick) && owner.stat == CONSCIOUS)
		owner.drop_all_held_items()
		owner.emote("cough")
		if(GET_MUTATION_POWER(src) > 1)
			var/cough_range = GET_MUTATION_POWER(src) * 4
			var/turf/target = get_ranged_target_turf(owner, REVERSE_DIR(owner.dir), cough_range)
			owner.throw_at(target, cough_range, GET_MUTATION_POWER(src))

/datum/mutation/paranoia
	name = "Paranoia"
	desc = "The subject is easily terrified, and may suffer from hallucinations."
	instability = NEGATIVE_STABILITY_MODERATE
	quality = NEGATIVE
	text_gain_indication = span_danger("You feel screams echo through your mind...")
	text_lose_indication = span_notice("The screaming in your mind fades.")

/datum/mutation/paranoia/on_life(seconds_per_tick)
	if(SPT_PROB(2.5, seconds_per_tick) && owner.stat == CONSCIOUS)
		owner.emote("scream")
		if(prob(25))
			owner.adjust_hallucinations(40 SECONDS)

//Dwarfism shrinks your body and lets you pass tables.
/datum/mutation/dwarfism
	name = "Dwarfism"
	desc = "The subject's cells are more compact, making the subject appear smaller."
	quality = POSITIVE
	difficulty = 16
	instability = POSITIVE_INSTABILITY_MINOR
	conflicts = list(/datum/mutation/gigantism, /datum/mutation/acromegaly)
	locked = TRUE // Default intert species for now, so locked from regular pool.

/datum/mutation/dwarfism/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_DWARF, GENETIC_MUTATION)
	owner.visible_message(span_danger("[owner] suddenly shrinks!"), span_notice("Everything around you seems to grow.."))

/datum/mutation/dwarfism/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_DWARF, GENETIC_MUTATION)
	owner.visible_message(span_danger("[owner] suddenly grows!"), span_notice("Everything around you seems to shrink.."))

/datum/mutation/acromegaly
	name = "Acromegaly"
	desc = "The subject's cells stack on top of one another, making the subject appear unusually tall."
	quality = MINOR_NEGATIVE
	difficulty = 16
	instability = NEGATIVE_STABILITY_MODERATE
	synchronizer_coeff = 1
	conflicts = list(/datum/mutation/dwarfism)

/datum/mutation/acromegaly/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_TOO_TALL, GENETIC_MUTATION)
	owner.visible_message(span_danger("[owner] suddenly grows tall!"), span_notice("You feel a small strange urge to fight small men with slingshots. Or maybe play some basketball."))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(head_bonk))
	owner.regenerate_icons()

/datum/mutation/acromegaly/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_TOO_TALL, GENETIC_MUTATION)
	owner.visible_message(span_danger("[owner] suddenly shrinks!"), span_notice("You return to your usual height."))
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(head_bonk))
	owner.regenerate_icons()

// This is specifically happening because they're not used to their new height and are stumbling around into machinery made for normal humans
/datum/mutation/acromegaly/proc/head_bonk(mob/living/parent)
	SIGNAL_HANDLER
	var/atom/movable/whacked_by = (locate(/obj/machinery/door/airlock) in parent.loc) || (locate(/obj/machinery/door/firedoor) in parent.loc) || (locate(/obj/structure/mineral_door) in parent.loc)
	if(!whacked_by || prob(100 - (8 *  GET_MUTATION_SYNCHRONIZER(src))))
		return
	to_chat(parent, span_danger("You hit your head on \the [whacked_by]'s header!"))
	var/dmg = HAS_TRAIT(parent, TRAIT_HEAD_INJURY_BLOCKED) ? rand(1,4) : rand(2,9)
	parent.apply_damage(dmg, BRUTE, BODY_ZONE_HEAD)
	parent.do_attack_animation(whacked_by, ATTACK_EFFECT_PUNCH)
	playsound(whacked_by, 'sound/effects/bang.ogg', 10, TRUE)
	parent.adjust_staggered_up_to(STAGGERED_SLOWDOWN_LENGTH, 10 SECONDS)

/datum/mutation/gigantism
	name = "Gigantism" //negative version of dwarfism
	desc = "The subject's cells are more spread out, making the subject appear larger."
	quality = MINOR_NEGATIVE
	difficulty = 12
	conflicts = list(/datum/mutation/dwarfism)

/datum/mutation/gigantism/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_GIANT, GENETIC_MUTATION)
	owner.update_transform(1.25)
	owner.visible_message(span_danger("[owner] suddenly grows!"), span_notice("Everything around you seems to shrink.."))

/datum/mutation/gigantism/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_GIANT, GENETIC_MUTATION)
	owner.update_transform(0.8)
	owner.visible_message(span_danger("[owner] suddenly shrinks!"), span_notice("Everything around you seems to grow.."))

//Clumsiness has a very large amount of small drawbacks depending on item.
/datum/mutation/clumsy
	name = "Clumsiness"
	desc = "The subject's brain functions are impaired, causing them to exhibit clown-like behavior."
	instability = NEGATIVE_STABILITY_MAJOR
	quality = MINOR_NEGATIVE
	text_gain_indication = span_danger("You feel lightheaded.")
	mutation_traits = list(TRAIT_CLUMSY)

//Tourettes causes you to randomly stand in place and shout.
/datum/mutation/tourettes
	name = "Tourette's Syndrome"
	desc = "The subject has a chronic twitching disorder, causing them to involuntarily shout or twitch."
	quality = NEGATIVE
	instability = 0
	text_gain_indication = span_danger("You twitch.")
	synchronizer_coeff = 1

/datum/mutation/tourettes/on_life(seconds_per_tick)
	if(SPT_PROB(5 * GET_MUTATION_SYNCHRONIZER(src), seconds_per_tick) && owner.stat == CONSCIOUS && !owner.IsStun())
		switch(rand(1, 3))
			if(1)
				owner.emote("twitch")
			if(2 to 3)
				owner.say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]", forced=name)
		var/w_offset =  rand(-2, 2)
		var/z_offset = rand(-1, 1)
		animate(owner, pixel_w = w_offset, pixel_z = z_offset, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
		animate(owner, pixel_w = -w_offset, pixel_z = -z_offset, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)


//Deafness makes you deaf.
/datum/mutation/deaf
	name = "Deafness"
	desc = "The subject is completely deaf and cannot hear anything."
	instability = NEGATIVE_STABILITY_MAJOR
	quality = NEGATIVE
	text_gain_indication = span_danger("You can't seem to hear anything.")
	mutation_traits = list(TRAIT_DEAF)

//Monified turns you into a monkey.
/datum/mutation/race
	name = "Monkified"
	desc = "A strange genome, believing to be what differentiates monkeys from humans."
	text_gain_indication = span_green("You feel unusually monkey-like.")
	text_lose_indication = span_notice("You feel like your old self.")
	quality = NEGATIVE
	instability = NEGATIVE_STABILITY_MAJOR // mmmonky
	remove_on_aheal = FALSE
	locked = TRUE //Species specific, keep out of actual gene pool
	warn_admins_on_inject = TRUE
	var/datum/species/original_species = /datum/species/human
	var/original_name

/datum/mutation/race/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	if(ismonkey(owner))
		return
	original_species = owner.dna.species.type
	original_name = owner.real_name
	owner.monkeyize()

/datum/mutation/race/on_losing(mob/living/carbon/human/owner)
	if(owner.stat == DEAD)
		return
	. = ..()
	if(.)
		return
	if(QDELETED(owner))
		return

	owner.fully_replace_character_name(null, original_name)
	owner.humanize(original_species)

/datum/mutation/glow
	name = "Glowy"
	desc = "The subject's skin emits a soft glow, illuminating the area around them."
	quality = POSITIVE
	text_gain_indication = span_notice("Your skin begins to glow softly.")
	instability = POSITIVE_INSTABILITY_MINI
	power_coeff = 1
	conflicts = list(/datum/mutation/glow/anti)
	var/glow_power = 2
	var/glow_range = 2.5
	var/glow_color
	var/obj/effect/dummy/lighting_obj/moblight/glow

/datum/mutation/glow/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	glow_color = get_glow_color()
	glow = owner.mob_light()

// Override modify here without a parent call, because we don't actually give an action.
/datum/mutation/glow/setup()
	if(!glow)
		return

	glow.set_light_range_power_color(glow_range * GET_MUTATION_POWER(src), glow_power, glow_color)

/datum/mutation/glow/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	QDEL_NULL(glow)

/// Returns a color for the glow effect
/datum/mutation/glow/proc/get_glow_color()
	return pick(COLOR_RED, COLOR_BLUE, COLOR_YELLOW, COLOR_GREEN, COLOR_PURPLE, COLOR_ORANGE)

/datum/mutation/glow/anti
	name = "Anti-Glow"
	desc = "The subject's skin absorbs light, making the area around them darker."
	text_gain_indication = span_notice("The light around you seems to disappear.")
	conflicts = list(/datum/mutation/glow)
	instability = POSITIVE_INSTABILITY_MINOR
	locked = TRUE
	glow_power = -1.5

/datum/mutation/glow/anti/get_glow_color()
	return COLOR_BLACK

/datum/mutation/strong
	name = "Strength"
	desc = "The subject's muscles slightly expand, improving general strength and workout efficiency."
	quality = POSITIVE
	text_gain_indication = span_notice("You feel strong.")
	instability = POSITIVE_INSTABILITY_MINOR
	difficulty = 16
	mutation_traits = list(TRAIT_STRENGTH)

/datum/mutation/stimmed
	name = "Stimmed"
	desc = "The subject's chemical balance is more robust, improving workout efficiency."
	quality = POSITIVE
	instability = POSITIVE_INSTABILITY_MINI
	text_gain_indication = span_notice("You feel stimmed.")
	difficulty = 16
	mutation_traits = list(TRAIT_STIMMED)

/datum/mutation/insulated
	name = "Insulated"
	desc = "The subject does not conduct electricity."
	quality = POSITIVE
	text_gain_indication = span_notice("Your fingertips go numb.")
	text_lose_indication = span_notice("Your fingertips regain feeling.")
	difficulty = 16
	instability = POSITIVE_INSTABILITY_MODERATE
	mutation_traits = list(TRAIT_SHOCKIMMUNE)

/datum/mutation/fire
	name = "Fiery Sweat"
	desc = "The subject's skin will randomly combust, though ultimately becomes more resilient to burning."
	quality = NEGATIVE
	text_gain_indication = span_warning("You feel hot.")
	text_lose_indication = span_notice("You feel a lot cooler.")
	conflicts = list(/datum/mutation/adaptation/heat)
	difficulty = 14
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/fire/on_life(seconds_per_tick)
	if(SPT_PROB((0.05+(100-dna.stability)/19.5) * GET_MUTATION_SYNCHRONIZER(src), seconds_per_tick))
		owner.adjust_fire_stacks(2 * GET_MUTATION_POWER(src))
		owner.ignite_mob()

/datum/mutation/fire/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	owner.physiology.burn_mod *= 0.5

/datum/mutation/fire/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.physiology.burn_mod *= 2

/datum/mutation/badblink
	name = "Spatial Instability"
	desc = "The subject has a very weak link to spatial reality, and may be displaced. Often causes extreme nausea."
	quality = NEGATIVE
	text_gain_indication = span_warning("The space around you twists sickeningly.")
	text_lose_indication = span_notice("The space around you settles back to normal.")
	difficulty = 18//high so it's hard to unlock and abuse
	instability = NEGATIVE_STABILITY_MODERATE
	synchronizer_coeff = 1
	energy_coeff = 1
	power_coeff = 1
	var/warpchance = 0

/datum/mutation/badblink/on_life(seconds_per_tick)
	if(SPT_PROB(warpchance, seconds_per_tick))
		var/warpmessage = pick(
		span_warning("With a sickening 720-degree twist of [owner.p_their()] back, [owner] vanishes into thin air."),
		span_warning("[owner] does some sort of strange backflip into another dimension. It looks pretty painful."),
		span_warning("[owner] does a jump to the left, a step to the right, and warps out of reality."),
		span_warning("[owner]'s torso starts folding inside out until it vanishes from reality, taking [owner] with it."),
		span_warning("One moment, you see [owner]. The next, [owner] is gone."))
		owner.visible_message(warpmessage, span_userdanger("You feel a wave of nausea as you fall through reality!"))
		var/warpdistance = rand(10, 15) * GET_MUTATION_POWER(src)
		do_teleport(owner, get_turf(owner), warpdistance, channel = TELEPORT_CHANNEL_FREE)
		owner.adjust_disgust(GET_MUTATION_SYNCHRONIZER(src) * (warpchance * warpdistance))
		warpchance = 0
		owner.visible_message(span_danger("[owner] appears out of nowhere!"))
	else
		warpchance += 0.0625 * seconds_per_tick / GET_MUTATION_ENERGY(src)

/datum/mutation/acidflesh
	name = "Acidic Flesh"
	desc = "The subject has acidic chemicals building up underneath the skin. This is often lethal."
	instability = NEGATIVE_STABILITY_MAJOR
	quality = NEGATIVE
	text_gain_indication = span_userdanger("A horrible burning sensation envelops you as your flesh turns to acid!")
	text_lose_indication = span_notice("A feeling of relief fills you as your flesh goes back to normal.")
	difficulty = 18//high so it's hard to unlock and use on others
	/// The cooldown for the warning message
	COOLDOWN_DECLARE(msgcooldown)

/datum/mutation/acidflesh/on_life(seconds_per_tick)
	if(SPT_PROB(13, seconds_per_tick))
		if(COOLDOWN_FINISHED(src, msgcooldown))
			to_chat(owner, span_danger("Your acid flesh bubbles..."))
			COOLDOWN_START(src, msgcooldown, 20 SECONDS)
		if(prob(15))
			owner.acid_act(rand(30, 50), 10)
			owner.visible_message(span_warning("[owner]'s skin bubbles and pops."), span_userdanger("Your bubbling flesh pops! It burns!"))
			playsound(owner,'sound/items/weapons/sear.ogg', 50, TRUE)

/datum/mutation/spastic
	name = "Spastic"
	desc = "The subject suffers from muscle spasms."
	instability = NEGATIVE_STABILITY_MODERATE
	quality = NEGATIVE
	text_gain_indication = span_warning("You flinch.")
	text_lose_indication = span_notice("Your flinching subsides.")
	difficulty = 16

/datum/mutation/spastic/on_acquiring()
	. = ..()
	if(!.)
		return
	owner.apply_status_effect(/datum/status_effect/spasms)

/datum/mutation/spastic/on_losing()
	if(..())
		return
	owner.remove_status_effect(/datum/status_effect/spasms)

/datum/mutation/extrastun
	name = "Two Left Feet"
	desc = "The subject's right foot is replaced with another left foot. Symptoms include kissing the floor when taking a step."
	instability = NEGATIVE_STABILITY_MODERATE
	quality = NEGATIVE
	text_gain_indication = span_warning("Your right foot feels... left.")
	text_lose_indication = span_notice("Your right foot feels alright.")
	difficulty = 16

/datum/mutation/extrastun/on_acquiring()
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/datum/mutation/extrastun/on_losing()
	. = ..()
	if(.)
		return
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)

///Triggers on moved(). Randomly makes the owner trip
/datum/mutation/extrastun/proc/on_move()
	SIGNAL_HANDLER

	if(prob(99.5)) //The brawl mutation
		return
	if(owner.buckled || owner.body_position == LYING_DOWN || HAS_TRAIT(owner, TRAIT_IMMOBILIZED) || owner.throwing || owner.movement_type & (VENTCRAWLING | FLYING | FLOATING))
		return //remove the 'edge' cases
	to_chat(owner, span_danger("You trip over your own feet."))
	owner.Knockdown(30)

/datum/mutation/martyrdom
	name = "Internal Martyrdom"
	desc = "The subject violently tears itself apart when near death. The process is irreversible. \
		The effect is not known to damage anything nearby, but is very, VERY disorienting when observed."
	instability = NEGATIVE_STABILITY_MAJOR // free stability >:)
	locked = TRUE
	quality = POSITIVE //not that cloning will be an option a lot but generally lets keep this around i guess?
	text_gain_indication = span_warning("You get an intense feeling of heartburn.")
	text_lose_indication = span_notice("Your internal organs feel at ease.")

/datum/mutation/martyrdom/on_acquiring()
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(bloody_shower))

/datum/mutation/martyrdom/on_losing()
	. = ..()
	if(.)
		return TRUE
	UnregisterSignal(owner, COMSIG_MOB_STATCHANGE)

/datum/mutation/martyrdom/proc/bloody_shower(datum/source, new_stat)
	SIGNAL_HANDLER

	if(new_stat != HARD_CRIT)
		return
	var/list/organs = owner.get_organs_for_zone(BODY_ZONE_HEAD, TRUE)

	for(var/obj/item/organ/I in organs)
		qdel(I)

	explosion(owner, light_impact_range = 2, adminlog = TRUE, explosion_cause = src)
	for(var/mob/living/carbon/human/splashed in view(2, owner))
		var/obj/item/organ/eyes/eyes = splashed.get_organ_slot(ORGAN_SLOT_EYES)
		if(eyes)
			to_chat(splashed, span_userdanger("You are blinded by a shower of blood!"))
			eyes.apply_organ_damage(5)
		else
			to_chat(splashed, span_userdanger("You are knocked down by a wave of... blood?!"))
		splashed.Stun(2 SECONDS)
		splashed.set_eye_blur_if_lower(40 SECONDS)
		splashed.adjust_confusion(3 SECONDS)
	for(var/mob/living/silicon/borgo in view(2, owner))
		to_chat(borgo, span_userdanger("Your sensors are disabled by a shower of blood!"))
		borgo.Paralyze(6 SECONDS)
	owner.investigate_log("has been gibbed by the martyrdom mutation.", INVESTIGATE_DEATHS)
	owner.gib(DROP_ALL_REMAINS)

/datum/mutation/headless
	name = "H.A.R.S."
	desc = "Short for \"Head Allergic Rejection Syndrome\", the subject's body rejects the head, causing its brain to recede into the chest. \
		Reversing this mutation is very dangerous, though it will regenerate non-vital head organs."
	instability = NEGATIVE_STABILITY_MAJOR
	difficulty = 12 //pretty good for traitors
	quality = NEGATIVE //holy shit no eyes or tongue or ears
	text_gain_indication = span_warning("Something feels off.")
	warn_admins_on_inject = TRUE

/datum/mutation/headless/on_acquiring()
	. = ..()
	if(!.)
		return

	var/obj/item/organ/brain/brain = owner.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(brain)
		brain.Remove(owner, special = TRUE, movement_flags = NO_ID_TRANSFER)
		brain.zone = BODY_ZONE_CHEST
		brain.Insert(owner, special = TRUE, movement_flags = NO_ID_TRANSFER)

	var/obj/item/bodypart/head/head = owner.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		owner.visible_message(span_warning("[owner]'s head splatters with a sickening crunch!"), ignored_mobs = list(owner))
		new /obj/effect/gibspawner/generic(get_turf(owner), owner)
		head.drop_organs()
		head.dismember(dam_type = BRUTE, silent = TRUE)
		qdel(head)
	RegisterSignal(owner, COMSIG_ATTEMPT_CARBON_ATTACH_LIMB, PROC_REF(abort_attachment))

/datum/mutation/headless/on_losing()
	. = ..()
	if(.)
		return TRUE

	UnregisterSignal(owner, COMSIG_ATTEMPT_CARBON_ATTACH_LIMB)
	var/successful = owner.regenerate_limb(BODY_ZONE_HEAD)
	if(!successful)
		stack_trace("HARS mutation head regeneration failed! (usually caused by headless syndrome having a head)")
		return TRUE
	var/obj/item/organ/brain/brain = owner.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(brain)
		brain.Remove(owner, special = TRUE, movement_flags = NO_ID_TRANSFER)
		brain.zone = initial(brain.zone)
		brain.Insert(owner, special = TRUE, movement_flags = NO_ID_TRANSFER)

	owner.dna.species.regenerate_organs(owner, replace_current = FALSE, excluded_zones = list(BODY_ZONE_CHEST)) //replace_current needs to be FALSE to prevent weird adding and removing mutation healing
	owner.apply_damage(damage = 50, damagetype = BRUTE, def_zone = BODY_ZONE_HEAD) //and this to DISCOURAGE organ farming, or at least not make it free.
	owner.visible_message(span_warning("[owner]'s head returns with a sickening crunch!"), span_warning("Your head regrows with a sickening crack! Ouch."))
	new /obj/effect/gibspawner/generic(get_turf(owner), owner)

/datum/mutation/headless/proc/abort_attachment(datum/source, obj/item/bodypart/new_limb, special) //you aren't getting your head back
	SIGNAL_HANDLER

	if(istype(new_limb, /obj/item/bodypart/head))
		return COMPONENT_NO_ATTACH

// You bleed faster but regenerate blood faster
/datum/mutation/bloodier
	name = "Hypermetabolic Blood"
	desc = "The subject's becomes hypermetabolic, causing it to produce blood at a much faster rate."
	quality = POSITIVE
	instability = POSITIVE_INSTABILITY_MINOR
	text_gain_indication = span_notice("You can feel your heartbeat pick up.")
	text_lose_indication = span_notice("You heartbeat slows back down.")
	difficulty = 16
	synchronizer_coeff = 1
	power_coeff = 1

	/// Modifies the bleed rate of the owner
	var/bleed_rate = 1.5
	/// Modifies the blood regeneration rate of the owner
	var/blood_regen_rate = 6
	/// Tracks if we've modified the physiology of the owner
	VAR_PRIVATE/physiology_modified = FALSE

/datum/mutation/bloodier/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	if(!physiology_modified)
		owner.physiology.bleed_mod *= bleed_rate
		owner.physiology.blood_regen_mod *= blood_regen_rate
		physiology_modified = TRUE

/datum/mutation/bloodier/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	if(physiology_modified)
		owner.physiology.bleed_mod /= bleed_rate
		owner.physiology.blood_regen_mod /= blood_regen_rate
		physiology_modified = FALSE // just in case

/datum/mutation/bloodier/setup()
	if(owner && physiology_modified)
		owner.physiology.bleed_mod /= bleed_rate
		owner.physiology.blood_regen_mod /= blood_regen_rate
		physiology_modified = FALSE

	bleed_rate = clamp(initial(bleed_rate) * GET_MUTATION_SYNCHRONIZER(src) * GET_MUTATION_POWER(src), 1, 2)
	blood_regen_rate = clamp(initial(blood_regen_rate) * GET_MUTATION_POWER(src), 4, 12)

	if(owner && !physiology_modified) // redundant but just in case
		owner.physiology.bleed_mod *= bleed_rate
		owner.physiology.blood_regen_mod *= blood_regen_rate
		physiology_modified = TRUE
	return TRUE

// You eat rocks
/datum/mutation/rock_eater
	name = "Rock Eater"
	desc = "The subject's body is able to digest rocks and minerals."
	quality = POSITIVE
	instability = POSITIVE_INSTABILITY_MINI
	text_gain_indication = span_notice("You feel a craving for rocks.")
	text_lose_indication = span_notice("You could go for a normal meal.")
	difficulty = 12
	mutation_traits = list(TRAIT_ROCK_EATER)
	conflicts = list(/datum/mutation/rock_absorber)

// You eat rock but also get buffs from them
/datum/mutation/rock_absorber
	name = "Rock Absorber"
	desc = "The subject's body is able to digest rocks and minerals, taking on their properties."
	quality = POSITIVE
	instability = POSITIVE_INSTABILITY_MAJOR
	text_gain_indication = span_notice("You feel a supreme craving for rocks.")
	text_lose_indication = span_notice("You could go for a normal meal.")
	mutation_traits = list(TRAIT_ROCK_EATER, TRAIT_ROCK_METAMORPHIC)
	conflicts = list(/datum/mutation/rock_eater)
	locked = TRUE

/datum/mutation/rock_absorber/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(. || QDELING(owner) || HAS_TRAIT(owner, TRAIT_ROCK_METAMORPHIC))
		return
	owner.remove_status_effect(/datum/status_effect/golem)
	owner.remove_status_effect(/datum/status_effect/golem_lightbulb)

// Soft crit is disabed
/datum/mutation/inexorable
	name = "Inexorable"
	desc = "The subject's body can push on beyond the limits of normal human endurance, though the process causes internal damage to the body."
	quality = POSITIVE
	instability = POSITIVE_INSTABILITY_MODERATE
	text_gain_indication = span_notice("You feel inexorable.")
	text_lose_indication = span_notice("You suddenly feel more human.")
	difficulty = 24
	synchronizer_coeff = 1
	mutation_traits = list(TRAIT_NOSOFTCRIT, TRAIT_ANALGESIA)

/datum/mutation/inexorable/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	if(!.)
		return
	RegisterSignal(acquirer, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(check_health))
	check_health()

/datum/mutation/inexorable/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	UnregisterSignal(owner, COMSIG_LIVING_HEALTH_UPDATE)
	REMOVE_TRAIT(owner, TRAIT_SOFTSPOKEN, REF(src))

/datum/mutation/inexorable/proc/check_health(...)
	SIGNAL_HANDLER
	if(owner.health > owner.crit_threshold || owner.stat != CONSCIOUS)
		REMOVE_TRAIT(owner, TRAIT_SOFTSPOKEN, REF(src))
	else
		ADD_TRAIT(owner, TRAIT_SOFTSPOKEN, REF(src))

/datum/mutation/inexorable/on_life(seconds_per_tick)
	if(owner.health > owner.crit_threshold || owner.stat != CONSCIOUS || HAS_TRAIT(owner, TRAIT_STASIS))
		return
	if(HAS_TRAIT(owner, TRAIT_NOCRITDAMAGE) && owner.health <= owner.hardcrit_threshold + 10)
		return
	// Gives you 30 seconds of being in fake soft crit... give or take
	if(HAS_TRAIT(owner, TRAIT_TOXIMMUNE) || HAS_TRAIT(owner, TRAIT_TOXINLOVER))
		owner.adjust_brute_loss(1 * seconds_per_tick * GET_MUTATION_SYNCHRONIZER(src), forced = TRUE)
	else
		owner.adjust_tox_loss(0.5 * seconds_per_tick * GET_MUTATION_SYNCHRONIZER(src), forced = TRUE)
		owner.adjust_brute_loss(0.5 * seconds_per_tick * GET_MUTATION_SYNCHRONIZER(src), forced = TRUE)
	// Offsets suffocation but not entirely
	owner.adjust_oxy_loss(-0.5 * seconds_per_tick, forced = TRUE)

/datum/mutation/limb_regeneration
	name = "Regeneration"
	desc = "The subject's body is able to regenerate lost limbs or organs while sleeping, given ample rest and nutrients."
	quality = POSITIVE
	instability = POSITIVE_INSTABILITY_MODERATE
	text_gain_indication = span_notice("You feel a strange tingling.")
	text_lose_indication = span_notice("The strange tingling feeling fades.")
	difficulty = 20
	synchronizer_coeff = 1
	power_coeff = 1

	/// Threshold of nutrition required to regenerate limbs/organs
	var/nutrition_threshold = NUTRITION_LEVEL_FED * 0.85
	/// If TRUE we notified the user they could probably use the mutation if they eat/slept first - comes with a bonus to trigger chance
	VAR_PRIVATE/notified_of_ability = FALSE

/datum/mutation/limb_regeneration/can_acquire(mob/living/carbon/human/acquirer)
	return !HAS_TRAIT(acquirer, TRAIT_NOHUNGER)

/datum/mutation/limb_regeneration/on_life(seconds_per_tick)
	if(!SPT_PROB(7.5 * (notified_of_ability ? 4 : 1) * (GET_MUTATION_POWER(src) ** 2), seconds_per_tick))
		return

	var/list/missing_limbs = owner.get_missing_limbs()
	var/list/missing_important_organs = owner.get_missing_organs(include_appendix = (GET_MUTATION_SYNCHRONIZER(src) == 1)) // appendix can regrow if you don't have syncronizer
	var/list/missing_special_organs = list()
	for(var/organ_type in owner.dna?.species?.mutant_organs)
		if(!owner.get_organ_by_type(organ_type) && should_visual_organ_apply_to(organ_type, owner))
			missing_special_organs += organ_type

	if(!length(missing_limbs) && !length(missing_important_organs) && !length(missing_special_organs))
		return

	if(owner.nutrition <= nutrition_threshold)
		if(owner.stat == UNCONSCIOUS && !notified_of_ability)
			to_chat(owner, span_green("You feel a strange tingling, as if your body is trying to do something - though you feel like you could use a meal first."))
			notified_of_ability = TRUE
		return
	if(owner.stat != UNCONSCIOUS)
		if(owner.nutrition > nutrition_threshold && !notified_of_ability)
			to_chat(owner, span_green("You feel a strange tingling, as if your body is trying to do something - though you feel like you could use a nap first."))
			notified_of_ability = TRUE
		return

	notified_of_ability = FALSE
	// "core organs" and limbs are prioritized
	if(length(missing_important_organs) || length(missing_limbs))
		if(length(missing_important_organs) && (prob(50) || !length(missing_limbs)))
			var/replacement_type = owner.dna.species.get_mutant_organ_type_for_slot(pick(missing_important_organs))
			var/obj/item/organ/replacement = new replacement()
			replacement.Insert(owner, special = TRUE)
			to_chat(owner, span_green("The tingingling feeling builds to a climax, until ultimately you feel a new [replacement] where your old one was!"))
		else
			var/replacing_zone = pick(missing_limbs)
			owner.regenerate_limb(replacing_zone)
			var/obj/item/bodypart/replacement = owner.get_bodypart(replacing_zone)
			to_chat(owner, span_green("The tingling feeling builds to a climax, until ultimately you feel a new [replacement.plaintext_zone] where your old one was!"))
			owner.visible_message(span_warning("[owner]'s [replacement.plaintext_zone] reforms, making a loud, grotesque sound!"), ignored_mobs = list(owner))
		owner.adjust_nutrition(-NUTRITION_LEVEL_FULL * 0.5 * GET_MUTATION_SYNCHRONIZER(src))
		playsound(owner, 'sound/effects/magic/demon_consume.ogg', 33, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return

	// "cosmetic" organs are second priority and cheaper to regenerate
	if(length(missing_special_organs))
		var/replacement_type = pick(missing_special_organs)
		var/obj/item/organ/replacement = new replacement_type()
		replacement.Insert(owner, special = TRUE)
		to_chat(owner, span_green("The tingling feeling builds to a climax, until ultimately you feel a new [replacement] where your old one was!"))
		if(replacement.organ_flags & ORGAN_EXTERNAL)
			owner.visible_message(span_warning("[owner]'s [replacement] reforms, making a loud, grotesque sound!"), ignored_mobs = list(owner))
		owner.adjust_nutrition(-NUTRITION_LEVEL_FULL * 0.3 * GET_MUTATION_SYNCHRONIZER(src))
		playsound(owner, 'sound/effects/magic/demon_consume.ogg', 33, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return

	stack_trace("Limb regeneration failed to find a missing limb or organ to regenerate for [owner] despite passing the checks")

/datum/mutation/chemical_allergy
	name = "Chemical Allergy"
	desc = "The subject's body is allergic to almost all forms of medicine or drug - causing a temporary flux of genetic instability, among other side effects."
	quality = NEGATIVE
	instability = NEGATIVE_STABILITY_MAJOR
	text_gain_indication = span_warning("You feel a strange irritation in your skin.")
	text_lose_indication = span_notice("The irritation in your skin subsides.")
	difficulty = 20

	/// Typecache of reagents that trigger the allergy
	var/static/list/danger_reagents
	/// If we're currently experiencing negative effects
	VAR_PRIVATE/was_experiencing_allergy = FALSE

/datum/mutation/chemical_allergy/New()
	. = ..()
	if(length(danger_reagents))
		return

	danger_reagents = typecacheof(list(
		/datum/reagent/medicine,
		/datum/reagent/drug,
	)) - typecacheof(list(
		/datum/reagent/medicine/adminordrazine,
		/datum/reagent/medicine/epinephrine,
		/datum/reagent/medicine/mannitol,
		/datum/reagent/medicine/mutadone,
		/datum/reagent/medicine/sansufentanyl,
	))

/datum/mutation/chemical_allergy/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	if(!.)
		return
	RegisterSignal(acquirer, COMSIG_LIVING_HEALTHSCAN, PROC_REF(on_healthscan))

/datum/mutation/chemical_allergy/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	UnregisterSignal(owner, COMSIG_LIVING_HEALTHSCAN)

/datum/mutation/chemical_allergy/proc/on_healthscan(datum/source, list/render_list, advanced, mob/user, mode, tochat)
	SIGNAL_HANDLER

	render_list += "<span class='alert ml-1'>"
	render_list += conditional_tooltip("Chemical Allergy", "Subject will react negatively to most forms of medicine - \
		avoid administering chemicals as a part of treatment unless absolutely necessary.", tochat)
	render_list += "</span><br>"

/datum/mutation/chemical_allergy/on_life(seconds_per_tick)
	if(!has_danger_reagent())
		if(was_experiencing_allergy)
			was_experiencing_allergy = FALSE
			instability *= 2
			owner.dna.update_instability()
		return
	if(!SPT_PROB(80, seconds_per_tick))
		return
	if(!was_experiencing_allergy)
		was_experiencing_allergy = TRUE
		instability *= 0.5 // halves the negative instability it rewards, which could push you into danger territory!
		owner.dna.update_instability()

	if(SPT_PROB(66, seconds_per_tick))
		owner.set_stutter_if_lower(4 SECONDS)
	if(SPT_PROB(33, seconds_per_tick))
		owner.adjust_disgust(12, DISGUST_LEVEL_VERYDISGUSTED)
		owner.adjust_tox_loss(1 * seconds_per_tick, forced = TRUE)
	if(SPT_PROB(12, seconds_per_tick))
		owner.adjust_jitter_up_to(6 SECONDS, 36 SECONDS)
	if(SPT_PROB(6, seconds_per_tick))
		owner.adjust_confusion_up_to(4 SECONDS, 12 SECONDS)

/datum/mutation/chemical_allergy/proc/has_danger_reagent()
	for(var/datum/reagent/reagent as anything in owner.reagents?.reagent_list)
		if(!is_type_in_typecache(reagent, danger_reagents))
			continue
		if(!reagent.metabolizing || reagent.volume < 1)
			continue
		return TRUE

	return FALSE

/datum/mutation/venomous_strikes
	name = "Venomous"
	desc = "The subject's body produces a minor toxin that can be injected into others through scratches or bites. \
		They will also filter out the same variety of toxin from their own bloodstream should they be exposed to it themselves."
	quality = POSITIVE
	instability = POSITIVE_INSTABILITY_MODERATE
	text_gain_indication = span_notice("You teeth and nails feel sharper.")
	text_lose_indication = span_notice("You teeth and nails feel duller.")
	/// Type of chem to inject
	var/venom_type = /datum/reagent/toxin
	/// Amount of chem to inject per attack
	var/venom_amount = 3

/datum/mutation/venomous_strikes/on_acquiring(mob/living/carbon/human/owner)
	text_gain_indication = (owner.get_active_hand()?.unarmed_attack_effect == ATTACK_EFFECT_CLAW) ? span_notice("You teeth and claws feel sharper.") : initial(text_gain_indication)
	. = ..()
	if(!.)
		return
	apply_venom()

/datum/mutation/venomous_strikes/on_losing(mob/living/carbon/human/owner)
	text_lose_indication = (owner.get_active_hand()?.unarmed_attack_effect == ATTACK_EFFECT_CLAW) ? span_notice("You teeth and claws feel duller.") : initial(text_lose_indication)
	. = ..()
	if(.)
		return
	remove_venom()

/datum/mutation/venomous_strikes/vv_edit_var(var_name, var_value)
	if(var_name != NAMEOF(src, venom_type) && var_name != NAMEOF(src, venom_amount))
		return ..()

	remove_venom()
	. = ..()
	apply_venom()

/datum/mutation/venomous_strikes/pre_apply_chromosome()
	apply_venom()

/datum/mutation/venomous_strikes/post_apply_chromosome()
	remove_venom()

/datum/mutation/venomous_strikes/proc/apply_venom()
	owner.AddElement(/datum/element/venomous, venom_type, venom_amount * GET_MUTATION_POWER(src), INJECT_CHECK_IGNORE_SPECIES)

/datum/mutation/venomous_strikes/proc/remove_venom()
	owner.RemoveElement(/datum/element/venomous, venom_type, venom_amount * GET_MUTATION_POWER(src), INJECT_CHECK_IGNORE_SPECIES)

/datum/mutation/venomous_strikes/on_life(seconds_per_tick)
	owner.reagents.remove_reagent(venom_type, round(venom_amount * 0.33, CHEMICAL_VOLUME_ROUNDING) * seconds_per_tick)
