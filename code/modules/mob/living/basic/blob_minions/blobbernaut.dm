/**
 * Player-piloted brute mob. Mostly just a "move and click" kind of guy.
 * Has a variant which takes damage when away from blob tiles
 */
/mob/living/basic/blobbernaut
	name = "blobbernaut"
	desc = "A hulking, mobile chunk of blobmass."
	icon = 'icons/mob/nonhuman-player/blob.dmi'
	icon_state = "blobbernaut"
	icon_living = "blobbernaut"
	icon_dead = "blobbernaut_dead"
	unique_name = TRUE
	pass_flags = PASSBLOB
	faction = list(ROLE_BLOB)
	combat_mode = TRUE
	health = BLOBMOB_BLOBBERNAUT_HEALTH
	maxHealth = BLOBMOB_BLOBBERNAUT_HEALTH
	damage_coeff = list(BRUTE = 0.5, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	melee_damage_lower = BLOBMOB_BLOBBERNAUT_DMG_SOLO_LOWER
	melee_damage_upper = BLOBMOB_BLOBBERNAUT_DMG_SOLO_UPPER
	obj_damage = BLOBMOB_BLOBBERNAUT_DMG_OBJ
	attack_verb_continuous = "slams"
	attack_verb_simple = "slam"
	attack_sound = 'sound/effects/blobattack.ogg'
	bubble_icon = "blob"
	speak_emote = null
	verb_say = "gurgles"
	verb_ask = "demands"
	verb_exclaim = "roars"
	verb_yell = "bellows"
	force_threshold = 10
	pressure_resistance = 50
	mob_size = MOB_SIZE_LARGE
	hud_type = /datum/hud/living/blobbernaut
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	// ... Blob colored lighting
	lighting_cutoff_red = 20
	lighting_cutoff_green = 40
	lighting_cutoff_blue = 30
	initial_language_holder = /datum/language_holder/empty
	gold_core_spawnable = HOSTILE_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/blobbernaut

/mob/living/basic/blobbernaut/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_BLOB_ALLY, INNATE_TRAIT)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_BLOBBERNAUT, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	RegisterSignal(src, COMSIG_LIVING_TRY_SPEECH, PROC_REF(on_try_speech))

/mob/living/basic/blobbernaut/death(gibbed)
	flick("blobbernaut_death", src)
	return ..()

/// We're mute but we intercept it via signals so that blobs with overminds can broadcast to them
/mob/living/basic/blobbernaut/proc/on_try_speech()
	SIGNAL_HANDLER
	return COMPONENT_CANNOT_SPEAK

/// This variant is the one actually spawned by blob factories, takes damage when away from blob tiles
/mob/living/basic/blobbernaut/minion
	gold_core_spawnable = NO_SPAWN
	/// Is our factory dead?
	var/orphaned = FALSE

/mob/living/basic/blobbernaut/minion/Life(seconds_per_tick, times_fired)
	. = ..()
	var/damage_sources = 0
	var/list/blobs_in_area = range(2, src)

	if (!(locate(/obj/structure/blob) in blobs_in_area))
		damage_sources++

	if (orphaned)
		damage_sources++
	else
		var/particle_colour = atom_colours[FIXED_COLOUR_PRIORITY] || COLOR_BLACK
		if (locate(/obj/structure/blob/special/core) in blobs_in_area)
			heal_overall_damage(maxHealth * BLOBMOB_BLOBBERNAUT_HEALING_CORE * seconds_per_tick)
			var/obj/effect/temp_visual/heal/heal_effect = new /obj/effect/temp_visual/heal(get_turf(src))
			heal_effect.color = particle_colour

		if (locate(/obj/structure/blob/special/node) in blobs_in_area)
			heal_overall_damage(maxHealth * BLOBMOB_BLOBBERNAUT_HEALING_NODE * seconds_per_tick)
			var/obj/effect/temp_visual/heal/heal_effect = new /obj/effect/temp_visual/heal(get_turf(src))
			heal_effect.color = particle_colour

	if (damage_sources == 0)
		return FALSE

	// take 2.5% of max health as damage when not near the blob or if the naut has no factory, 5% if both
	apply_damage(maxHealth * BLOBMOB_BLOBBERNAUT_HEALTH_DECAY * damage_sources * seconds_per_tick, damagetype = TOX) // We reduce brute damage
	var/mutable_appearance/harming = mutable_appearance('icons/mob/nonhuman-player/blob.dmi', "nautdamage", MOB_LAYER + 0.01)
	harming.appearance_flags = RESET_COLOR
	harming.color = atom_colours[FIXED_COLOUR_PRIORITY] || COLOR_WHITE
	harming.dir = dir
	flick_overlay_view(harming, 0.8 SECONDS)

/// Called by the blob creation power to give us a mind and a basic task orientation
/mob/living/basic/blobbernaut/minion/proc/assign_key(ckey, datum/blobstrain/blobstrain)
	key = ckey
	flick("blobbernaut_produce", src)
	health = maxHealth / 2 // Start out injured to encourage not beelining away from the blob
	SEND_SOUND(src, sound('sound/effects/blobattack.ogg'))
	SEND_SOUND(src, sound('sound/effects/attackblob.ogg'))
	to_chat(src, span_infoplain("You are powerful, hard to kill, and slowly regenerate near nodes and cores, [span_cultlarge("but will slowly die if not near the blob")] or if the factory that made you is killed."))
	to_chat(src, span_infoplain("You can communicate with other blobbernauts and overminds <b>telepathically</b> by attempting to speak normally"))
	to_chat(src, span_infoplain("Your overmind's blob reagent is: <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font>!"))
	to_chat(src, span_infoplain("The <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font> reagent [blobstrain.shortdesc ? "[blobstrain.shortdesc]" : "[blobstrain.description]"]"))

/// Set our attack damage based on blob's properties
/mob/living/basic/blobbernaut/minion/proc/on_strain_updated(mob/camera/blob/overmind, datum/blobstrain/new_strain)
	if (isnull(overmind))
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)
		attack_verb_continuous = initial(attack_verb_continuous)
		return
	melee_damage_lower = BLOBMOB_BLOBBERNAUT_DMG_LOWER
	melee_damage_upper = BLOBMOB_BLOBBERNAUT_DMG_UPPER
	attack_verb_continuous = new_strain.blobbernaut_message

/// Called by our factory to inform us that it's not going to support us financially any more
/mob/living/basic/blobbernaut/minion/proc/on_factory_destroyed()
	orphaned = TRUE
	to_chat(src, span_userdanger("Your factory was destroyed! You feel yourself dying!"))
	throw_alert("nofactory", /atom/movable/screen/alert/nofactory)
