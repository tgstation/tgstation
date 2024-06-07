/// Amount of time to wait after someone dies to steal their body from their killers
#define IMMORTAL_PRE_ACTIVATION_TIME 10 SECONDS
/// Amount of time it takes a mob to return to the living world
#define IMMORTAL_RESURRECT_TIME 50 SECONDS

/**
 * Nobody will ever die ever again
 * Or if they do, they will be back
 */
/datum/grand_finale/immortality
	name = "Perpetuation"
	desc = "The ultimate use of your gathered power! Share with the crew the gift, or curse, of eternal life! \
		And why not just the crew? How about their pets too? And any other animals around here! \
		What if nobody died ever again!?"
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "asclepius_active"
	glow_colour = COLOR_PALE_GREEN
	minimum_time = 30 MINUTES // This is enormously disruptive but doesn't technically in of itself end the round.

/datum/grand_finale/immortality/trigger(mob/living/carbon/human/invoker)
	new /obj/effect/temp_visual/immortality_blast(get_turf(invoker))
	SEND_SOUND(world, sound('sound/magic/teleport_diss.ogg'))
	for (var/mob/living/alive_guy as anything in GLOB.mob_living_list)
		new /obj/effect/temp_visual/immortality_pulse(get_turf(alive_guy))
		if (!alive_guy.mind)
			continue
		to_chat(alive_guy, span_notice("You feel <b>extremely</b> healthy."))
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH, PROC_REF(something_died))

/// Called when something passes into the great beyond, make it not do that
/datum/grand_finale/immortality/proc/something_died(datum/source, mob/living/died, gibbed)
	SIGNAL_HANDLER
	if (died.stat != DEAD || HAS_TRAIT(died, TRAIT_PERMANENTLY_MORTAL) || died.flags_1 & HOLOGRAM_1)
		return
	var/body_type = died.type

	var/turf/died_turf = get_turf(died)
	var/list/nearby_turfs = circle_view_turfs(died_turf, 2)
	var/list/nearby_safe_turfs = list()
	for (var/turf/check_turf as anything in nearby_turfs)
		if (check_turf.is_blocked_turf(exclude_mobs = TRUE, source_atom = died))
			nearby_turfs -= check_turf
			continue
		if (islava(check_turf) || ischasm(check_turf))
			continue
		nearby_safe_turfs += check_turf
	if (length(nearby_safe_turfs)) // If you're in the middle of a 5x5 chasm, tough luck I guess
		died_turf = pick(nearby_safe_turfs)
	else if (length(nearby_turfs))
		died_turf = pick(nearby_turfs)

	var/saved_appearance = ishuman(died) ? new /datum/human_appearance_profile(died) : null

	var/datum/mind/dead_mind = HAS_TRAIT(died, TRAIT_SUICIDED) ? null : died.mind // There is a way out of the cycle
	if (!isnull(dead_mind))
		to_chat(died, span_boldnotice("Your spirit surges! You will return to life in [DisplayTimeText(IMMORTAL_PRE_ACTIVATION_TIME + IMMORTAL_RESURRECT_TIME)]."))
	animate(died, alpha = died.alpha, time = IMMORTAL_PRE_ACTIVATION_TIME / 2, flags = ANIMATION_PARALLEL)
	animate(alpha = 0, time = IMMORTAL_PRE_ACTIVATION_TIME / 2, easing = SINE_EASING | EASE_IN)
	addtimer(CALLBACK(src, PROC_REF(reverse_death), died, dead_mind, died_turf, body_type, saved_appearance), IMMORTAL_PRE_ACTIVATION_TIME, TIMER_DELETE_ME)

/// Create a ghost ready for revival
/datum/grand_finale/immortality/proc/reverse_death(mob/living/died, datum/mind/dead_mind, turf/died_turf, body_type, datum/human_appearance_profile/human_appearance)
	if (died.stat != DEAD)
		return
	var/ghost_type = ispath(body_type, /mob/living/carbon/human) ? /obj/effect/spectre_of_resurrection/human : /obj/effect/spectre_of_resurrection
	var/obj/effect/spectre_of_resurrection/ghost = new ghost_type(died_turf)
	var/mob/living/corpse = QDELETED(died) ? new body_type(ghost) : died
	if (!isnull(human_appearance))
		corpse.real_name = human_appearance.name
	corpse.alpha = initial(corpse.alpha)
	corpse.add_traits(list(TRAIT_NO_TELEPORT, TRAIT_AI_PAUSED), MAGIC_TRAIT)
	corpse.apply_status_effect(/datum/status_effect/grouped/stasis, MAGIC_TRAIT)
	ghost.set_up_resurrection(corpse, dead_mind, human_appearance)


/// Store of data we use to recreate someone who was gibbed, like a simplified version of changeling profiles
/datum/human_appearance_profile
	/// The name of the profile / the name of whoever this profile source.
	var/name = "human"
	/// The DNA datum associated with our profile from the profile source
	var/datum/dna/dna
	/// The age of the profile source.
	var/age
	/// The body type of the profile source.
	var/physique
	/// The quirks of the profile source.
	var/list/quirks = list()
	/// The hair and facial hair gradient styles of the profile source.
	var/list/hair_gradient_style = list("None", "None")
	/// The hair and facial hair gradient colours of the profile source.
	var/list/hair_gradient_colours = list(null, null)
	/// The TTS voice of the profile source
	var/voice
	/// The TTS filter of the profile filter
	var/voice_filter = ""

/datum/human_appearance_profile/New(mob/living/carbon/human/target)
	copy_from(target)

/// Copy the appearance data of the target
/datum/human_appearance_profile/proc/copy_from(mob/living/carbon/human/target)
	target.dna.real_name = target.real_name
	dna = new target.dna.type()
	target.dna.copy_dna(dna)
	name = target.real_name
	age = target.age
	physique = target.physique

	for(var/datum/quirk/target_quirk as anything in target.quirks)
		LAZYADD(quirks, new target_quirk.type)

	voice = target.voice
	voice_filter = target.voice_filter

/// Make the targeted human look like this
/datum/human_appearance_profile/proc/apply_to(mob/living/carbon/human/target)
	target.real_name = name
	target.age = age
	target.physique = physique
	target.voice = voice
	target.voice_filter = voice_filter

	for(var/datum/quirk/target_quirk as anything in quirks)
		target_quirk.add_to_holder(target)

	dna.transfer_identity(target, TRUE)
	for(var/obj/item/bodypart/limb as anything in target.bodyparts)
		limb.update_limb(is_creating = TRUE)
	target.updateappearance(mutcolor_update = TRUE)
	target.domutcheck()
	target.regenerate_icons()


/// A ghostly image of a mob showing where and what is going to respawn
/obj/effect/spectre_of_resurrection
	name = "spectre"
	desc = "A frightening apparition, slowly growing more solid."
	icon_state = "blank_white"
	anchored = TRUE
	layer = MOB_LAYER
	plane = GAME_PLANE
	alpha = 0
	color = COLOR_PALE_GREEN
	light_range = 2
	light_color = COLOR_PALE_GREEN
	resistance_flags = parent_type::resistance_flags | SHUTTLE_CRUSH_PROOF
	/// Who are we reviving?
	var/mob/living/corpse
	/// Who if anyone is playing as them?
	var/datum/mind/dead_mind

/obj/effect/spectre_of_resurrection/Initialize(mapload)
	. = ..()
	animate(src, alpha = 150, time = 2 SECONDS)

/// Prepare to revive someone
/obj/effect/spectre_of_resurrection/proc/set_up_resurrection(mob/living/corpse, datum/mind/dead_mind, datum/human_appearance_profile/human_appearance)
	if (isnull(corpse))
		qdel(src)
		return

	src.corpse = corpse
	src.dead_mind = dead_mind
	corpse.forceMove(src)
	name = "spectre of [corpse]"
	setup_icon(corpse)
	DO_FLOATING_ANIM(src)

	RegisterSignal(corpse, COMSIG_LIVING_REVIVE, PROC_REF(on_corpse_revived))
	RegisterSignal(corpse, COMSIG_QDELETING, PROC_REF(on_corpse_deleted))
	RegisterSignal(dead_mind, COMSIG_QDELETING, PROC_REF(on_mind_lost))
	addtimer(CALLBACK(src, PROC_REF(revive)), IMMORTAL_RESURRECT_TIME, TIMER_DELETE_ME)

/// Copy appearance from ressurecting mob
/obj/effect/spectre_of_resurrection/proc/setup_icon(mob/living/corpse)
	icon = initial(corpse.icon)
	icon_state = initial(corpse.icon_state)

/obj/effect/spectre_of_resurrection/Destroy(force)
	QDEL_NULL(corpse)
	dead_mind = null
	return ..()

/obj/effect/spectre_of_resurrection/Exited(atom/movable/gone, direction)
	. = ..()
	if (gone != corpse)
		return // Weird but ok
	UnregisterSignal(corpse, list(COMSIG_LIVING_REVIVE, COMSIG_QDELETING))
	corpse = null
	qdel(src)

/// Bring our body back to life
/obj/effect/spectre_of_resurrection/proc/revive()
	if (!isnull(dead_mind))
		if (dead_mind.current == corpse)
			dead_mind.grab_ghost(force = TRUE)
		else
			dead_mind.transfer_to(corpse, force_key_move = TRUE)
	corpse.revive(HEAL_ALL) // The signal is sent even if they weren't actually dead

/// Remove our stored corpse back to the living world
/obj/effect/spectre_of_resurrection/proc/on_corpse_revived()
	SIGNAL_HANDLER
	if (isnull(corpse))
		return
	visible_message(span_boldnotice("[corpse] suddenly shudders to life!"))
	corpse.remove_traits(list(TRAIT_NO_TELEPORT, TRAIT_AI_PAUSED), MAGIC_TRAIT)
	corpse.remove_status_effect(/datum/status_effect/grouped/stasis, MAGIC_TRAIT)
	corpse.forceMove(loc)

/// If the body is destroyed then we can't come back, F
/obj/effect/spectre_of_resurrection/proc/on_corpse_deleted()
	SIGNAL_HANDLER
	qdel(src)

/// If the mind is deleted somehow we just don't transfer it on revival
/obj/effect/spectre_of_resurrection/proc/on_mind_lost()
	SIGNAL_HANDLER
	dead_mind = null

/// A ressurection spectre with extra behaviour for humans
/obj/effect/spectre_of_resurrection/human
	/// Stored data used to restore someone to a fascimile of what they were before
	var/datum/human_appearance_profile/human_appearance

/obj/effect/spectre_of_resurrection/human/set_up_resurrection(mob/living/corpse, datum/mind/dead_mind, datum/human_appearance_profile/human_appearance)
	. = ..()
	src.human_appearance = human_appearance

// We just use a generic floating human appearance to save unecessary costly icon operations
/obj/effect/spectre_of_resurrection/human/setup_icon(mob/living/corpse)
	return

// Apply stored human details
/obj/effect/spectre_of_resurrection/human/on_corpse_revived()
	if (isnull(corpse))
		return
	human_appearance?.apply_to(corpse)
	return ..()


/// Visual flair on the wizard when cast
/obj/effect/temp_visual/immortality_blast
	name = "immortal wave"
	duration = 2.5 SECONDS
	icon = 'icons/effects/96x96.dmi'
	icon_state = "boh_tear"
	color = COLOR_PALE_GREEN
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/immortality_blast/Initialize(mapload)
	. = ..()
	transform *= 0
	animate(src, transform = matrix(), time = 1.5 SECONDS, easing = ELASTIC_EASING)
	animate(transform = matrix() * 3, time = 1 SECONDS, alpha = 0, easing = SINE_EASING | EASE_OUT)


/// Visual flair on living creatures who have become immortal
/obj/effect/temp_visual/immortality_pulse
	name = "immortal pulse"
	duration = 1 SECONDS
	icon = 'icons/effects/anomalies.dmi'
	icon_state = "dimensional_overlay"
	color = COLOR_PALE_GREEN

/obj/effect/temp_visual/immortality_pulse/Initialize(mapload)
	. = ..()
	transform *= 0
	animate(src, transform = matrix() * 1.5, alpha = 0, time = 1 SECONDS, easing = SINE_EASING | EASE_OUT)

#undef IMMORTAL_PRE_ACTIVATION_TIME
#undef IMMORTAL_RESURRECT_TIME
