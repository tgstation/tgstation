/// Ratwood's rot of the dead (datums/components/rotting.dm, /datum/component/rot/corpse): a human that dies on a medieval
/// map rots. Past 20 minutes dead its flesh rots - the limbs take the colour of rot and will not serve a body raised from
/// them, the body loses 8 constitution and flies buzz over it while it lies in the open; past 40 minutes the rotted limbs
/// fall to bones and the body bleeds no more. A body nobody is in turns to dust once it is bones (Ratwood looks for bones
/// from 35 minutes on). Lying in the physician's, the church or the graveyard keeps the rot from working on a body, though
/// its time still runs, as at Ratwood. Life ends the rot and its debuff (Ratwood's revival lifts that), not what it did:
/// rogue_remove_rot() undoes it - Pestra's cure, an admin's rejuvenation. Goblins rot their own way (rockhill/species.dm),
/// skeletons do not rot. As Ratwood's SSroguerot the rot ticks every two seconds.
/// For later blocks: rogue_start_rot(), rogue_rot_amount(), rogue_rot_stage(), rogue_has_rot(), rogue_remove_rot() on the
/// body, COMSIG_LIVING_ROGUE_ROT_TICK and COMSIG_LIVING_ROGUE_ROT_STAGE from it (burial/_defines.dm).
/// Not ported: the stench of rot (Ratwood's pollution), deadites rising past DEAD_TO_ZOMBIE_TIME and Pestra's mercy
/// (stage 5, through COMSIG_LIVING_ROGUE_ROT_TICK), the rot of beasts (Ratwood /datum/component/rot/simple).

/// TG's skeleton sprites, the look of bare bones.
#define ROGUE_BONES_ICON 'icons/mob/human/bodyparts.dmi'
/// The goblin's parts draw their own bones (rockhill/species.dm, rogue_skeleton).
#define ROGUE_GOBLIN_LIMB_ID "rogue_goblin"

PROCESSING_SUBSYSTEM_DEF(rogue_rot)
	name = "Rogue Rot"
	ss_flags = SS_BACKGROUND|SS_POST_FIRE_TIMING
	wait = 2 SECONDS
	stat_tag = "RR"

/// Every human that dies on a medieval map starts to rot.
/datum/controller/subsystem/processing/rogue_rot/Initialize()
	if(rogue_combat_enabled())
		RegisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH, PROC_REF(on_mob_death))
	return SS_INIT_SUCCESS

/// Ratwood death(): a body not torn apart starts to rot (LoadComponent(rot_type)).
/datum/controller/subsystem/processing/rogue_rot/proc/on_mob_death(datum/source, mob/living/died, gibbed)
	SIGNAL_HANDLER
	if(gibbed || !ishuman(died) || QDELETED(died))
		return
	var/mob/living/carbon/human/corpse = died
	corpse.rogue_start_rot()

/// Where a corpse does not rot while it lies there (Ratwood rot_protected_areas): the physician's, the church, the
/// graveyard. Ratwood's desert church, exposed church and Death's Edge are not on the Rockhill map.
GLOBAL_LIST_INIT(rogue_rot_sanctuaries, typecacheof(list(
	/area/rogue/indoors/town/physician,
	/area/rogue/indoors/town/church,
	/area/rogue/outdoors/town/church,
	/area/rogue/outdoors/town/graveyard,
	/area/rogue/outdoors/town/roofs/church,
)))

/// The rot of a corpse (Ratwood /datum/component/rot/corpse): on the dead body until it lives again or turns to dust.
/datum/component/rogue_corpse_rot
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Deciseconds the body has rotted (Ratwood amount).
	var/amount = 0
	/// world.time of the last tick (Ratwood last_process).
	var/last_tick = 0
	/// What the rot had made of the body at the last tick (ROGUE_ROT_*).
	var/stage = ROGUE_ROT_FRESH
	/// The flies over rotten flesh (Ratwood fliesloop).
	var/datum/looping_sound/rogue_flies/flies

/datum/component/rogue_corpse_rot/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/carbon/corpse = parent
	stage = corpse.rogue_rot_stage()
	flies = new(parent, FALSE)
	START_PROCESSING(SSrogue_rot, src)

/datum/component/rogue_corpse_rot/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))
	RegisterSignal(parent, COMSIG_LIVING_POST_FULLY_HEAL, PROC_REF(on_full_heal))

/datum/component/rogue_corpse_rot/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_REVIVE, COMSIG_LIVING_POST_FULLY_HEAL))

/datum/component/rogue_corpse_rot/Destroy(force)
	STOP_PROCESSING(SSrogue_rot, src)
	QDEL_NULL(flies)
	return ..()

/// Ratwood process(): the time since the last tick is added to the rot (ten a second, its deciseconds), then it works.
/datum/component/rogue_corpse_rot/process(seconds_per_tick)
	if(last_tick)
		amount += world.time - last_tick
	last_tick = world.time
	rot_tick()

/// Ratwood /datum/component/rot/corpse/process() past the counting: what the rot does to the body at its age.
/datum/component/rogue_corpse_rot/proc/rot_tick()
	var/mob/living/carbon/corpse = parent
	if(corpse.stat != DEAD)
		qdel(src)
		return
	if(HAS_TRAIT(corpse, TRAIT_DNR))
		return
	if(SEND_SIGNAL(corpse, COMSIG_LIVING_ROGUE_ROT_TICK, amount) & COMPONENT_ROGUE_ROT_SPARE)
		return
	var/area/corpse_area = get_area(corpse)
	if(is_type_in_typecache(corpse_area, GLOB.rogue_rot_sanctuaries))
		return
	if(!(corpse.mob_biotypes & (MOB_ORGANIC|MOB_UNDEAD)))
		qdel(src)
		return
	var/flesh_time = rogue_value("rot_flesh_time")
	var/bones_time = rogue_value("rot_bones_time")
	var/dust_time = rogue_value("rot_dust_time")
	var/rotten = FALSE
	var/changed = FALSE
	var/dust = FALSE
	for(var/obj/item/bodypart/part as anything in corpse.bodyparts)
		if(part.rogue_rottable())
			if(!part.rogue_rotted)
				if(amount > flesh_time)
					part.rogue_rot_flesh()
					rotten = TRUE
					changed = TRUE
			else if(amount > bones_time)
				part.rogue_skeletonize()
				ADD_TRAIT(corpse, TRAIT_NOBLOOD, ROGUE_ROT_TRAIT)
				changed = TRUE
			else
				rotten = TRUE
		// Ratwood dusts the bodies of NPCs, not of players: one with nobody in it once it is bones.
		if(part.rogue_skeleton && amount > dust_time && !corpse.client)
			dust = TRUE
	if(dust)
		qdel(src)
		corpse.dust(drop_items = TRUE, give_moodlet = FALSE)
		return
	if(changed)
		corpse.apply_status_effect(/datum/status_effect/rogue_rotted_corpse)
		corpse.update_body_parts(TRUE)
	// Flies come to rotten flesh in the open, not to a body in a grave or a coffin.
	if(rotten && isopenturf(corpse.loc))
		flies.start()
	else
		flies.stop()
	var/new_stage = corpse.rogue_rot_stage()
	if(new_stage != stage)
		var/old_stage = stage
		stage = new_stage
		SEND_SIGNAL(corpse, COMSIG_LIVING_ROGUE_ROT_STAGE, new_stage, old_stage)

/// Ratwood revive(): a body that lives again stops rotting and loses the debuff (Ratwood's revival lifts it), not the
/// rotted flesh; an admin's rejuvenation undoes the rot too (Ratwood fully_heal(admin_revive)). A failed revival changes
/// nothing.
/datum/component/rogue_corpse_rot/proc/on_revive(mob/living/carbon/source, full_heal_flags)
	SIGNAL_HANDLER
	if(source.stat == DEAD)
		return
	source.remove_status_effect(/datum/status_effect/rogue_rotted_corpse)
	if(full_heal_flags & HEAL_ADMIN)
		source.rogue_remove_rot()
	if(!QDELETED(src))
		qdel(src)

/// Ratwood fully_heal(): a body healed whole starts its rot over.
/datum/component/rogue_corpse_rot/proc/on_full_heal(mob/living/carbon/source, heal_flags)
	SIGNAL_HANDLER
	amount = 0
	last_tick = world.time

/// Ratwood fliesloop: flies over rotten flesh.
/datum/looping_sound/rogue_flies
	mid_sounds = 'modular_redtard/burial/sound/fliesloop.ogg'
	mid_length = 6 SECONDS
	volume = 50
	extra_range = 0

/// Ratwood debuff/rotted_zombie: a rotted body is the weaker for it, until it lives again or the rot is cured. It tells
/// on a body raised as it lies (stage 5).
/datum/status_effect/rogue_rotted_corpse
	id = "rogue_rotted_corpse"
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/rogue_rotted_corpse

/datum/status_effect/rogue_rotted_corpse/on_apply()
	owner.attributes?.set_variable_attribute_modifier(id, list(ROGUE_STAT_CONSTITUTION = -rogue_value("rot_constitution_penalty")))
	return TRUE

/datum/status_effect/rogue_rotted_corpse/on_remove()
	owner.attributes?.remove_attribute_modifier(id)
	return ..()

/atom/movable/screen/alert/status_effect/rogue_rotted_corpse
	name = "Decomposing Corpse"
	desc = "You've been dead for some time.. your body is finally starting to give out on you."
	icon = ROGUE_COMBAT_ALERTS_ICON
	icon_state = "rotted_body"

/mob/living/carbon/human
	/// Laid in a grave and covered over (Ratwood buried): set for those not awake when the earth closed over them, cleared
	/// for whoever climbs out awake. For Necra's rites (stage 5).
	var/rogue_buried = FALSE

/// Starts the rot of this corpse if its flesh rots as Ratwood's humans do. Returns the rot, or null.
/mob/living/carbon/proc/rogue_start_rot()
	if(stat != DEAD || !rogue_rots())
		return null
	return LoadComponent(/datum/component/rogue_corpse_rot)

/// Whether this body rots as Ratwood's humans do (their rot_type /datum/component/rot/corpse).
/mob/living/carbon/proc/rogue_rots()
	return FALSE

/// A human of flesh rots; a goblin rots to bones its own way (rockhill/species.dm), a skeleton has nothing to rot.
/mob/living/carbon/human/rogue_rots()
	if(istype(dna?.species, /datum/species/rogue_goblin))
		return FALSE
	for(var/obj/item/bodypart/part as anything in bodyparts)
		if(part.rogue_rottable())
			return TRUE
	return FALSE

/// How long this corpse has rotted, in deciseconds; 0 for a body that is not rotting.
/mob/living/carbon/proc/rogue_rot_amount()
	var/datum/component/rogue_corpse_rot/rot = GetComponent(/datum/component/rogue_corpse_rot)
	return rot ? rot.amount : 0

/// What the rot has made of this body: ROGUE_ROT_FRESH, ROGUE_ROT_ROTTEN (a limb of rotted flesh) or ROGUE_ROT_BONES
/// (a limb gone to bones).
/mob/living/carbon/proc/rogue_rot_stage()
	. = ROGUE_ROT_FRESH
	for(var/obj/item/bodypart/part as anything in bodyparts)
		if(part.rogue_skeleton)
			return ROGUE_ROT_BONES
		if(part.rogue_rotted)
			. = ROGUE_ROT_ROTTEN

/// Ratwood check_bodyparts_for_rot(): any limb rotted or gone to bones.
/mob/living/carbon/proc/rogue_has_rot()
	return rogue_rot_stage() != ROGUE_ROT_FRESH

/// Ratwood remove_rot(): the rot is washed out of the body - its count, the rotted flesh, the bones (flesh again), the
/// debuff and the flies. TRUE if there was rot. For Pestra's cure, Necra's rites and the like.
/mob/living/carbon/proc/rogue_remove_rot()
	var/old_stage = rogue_rot_stage()
	var/datum/component/rogue_corpse_rot/rot = GetComponent(/datum/component/rogue_corpse_rot)
	if(rot)
		rot.amount = 0
		rot.stage = ROGUE_ROT_FRESH
		rot.flies?.stop()
	for(var/obj/item/bodypart/part as anything in bodyparts)
		part.rogue_clean_rot()
	REMOVE_TRAIT(src, TRAIT_NOBLOOD, ROGUE_ROT_TRAIT)
	remove_status_effect(/datum/status_effect/rogue_rotted_corpse)
	update_body_parts(TRUE)
	if(old_stage == ROGUE_ROT_FRESH)
		return FALSE
	SEND_SIGNAL(src, COMSIG_LIVING_ROGUE_ROT_STAGE, ROGUE_ROT_FRESH, old_stage)
	return TRUE

/obj/item/bodypart
	/// Rotted flesh (Ratwood rotted): the colour of rot, and no use to a living body until the rot is cured.
	var/rogue_rotted = FALSE
	/// What the limb looked like before it went to bones, to put back when the rot is cured.
	var/list/rogue_flesh_look
	/// Overlays of the flesh (ears, markings) taken off while the limb is bones.
	var/list/rogue_hidden_overlays

/// Flesh that can rot (Ratwood is_organic_limb() and not skeletonized).
/obj/item/bodypart/proc/rogue_rottable()
	return !rogue_skeleton && IS_ORGANIC_LIMB(src) && (biological_state & BIO_FLESH)

/// Ratwood rotted = TRUE: the flesh takes the colour of rot (on a limb drawn in the body's colour) and gives out
/// (BODYPART_DISABLED_ROT; Ratwood spares the undead, here a deadite's rising lifts it). The owner's body is redrawn by
/// whoever rots it.
/obj/item/bodypart/proc/rogue_rot_flesh()
	if(rogue_rotted)
		return FALSE
	rogue_rotted = TRUE
	if(should_draw_greyscale)
		add_color_override(ROGUE_ROT_SKIN_COLOR, ROGUE_LIMB_COLOR_ROT)
	if(rogue_value("rot_limbs_give_out"))
		ADD_TRAIT(src, TRAIT_PARALYSIS, ROGUE_ROT_TRAIT)
	RegisterSignal(src, COMSIG_BODYPART_CHECKED_FOR_INJURY, PROC_REF(rogue_rot_injury_line))
	return TRUE

/// Ratwood skeletonize(): the rotted flesh falls away to bones, drawn as TG's skeleton - no hair, eyes or ears on a skull,
/// no colour of flesh. The owner's body is redrawn by whoever does it.
/obj/item/bodypart/proc/rogue_skeletonize()
	if(rogue_skeleton)
		return FALSE
	if(!rogue_rotted)
		rogue_rot_flesh()
	rogue_skeleton = TRUE
	remove_color_override(ROGUE_LIMB_COLOR_ROT)
	if(limb_id == ROGUE_GOBLIN_LIMB_ID)
		return TRUE
	rogue_flesh_look = list(
		"limb_id" = limb_id,
		"icon_static" = icon_static,
		"greyscale" = should_draw_greyscale,
		"dimorphic" = is_dimorphic,
	)
	limb_id = SPECIES_SKELETON
	icon_static = ROGUE_BONES_ICON
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	rogue_bones_look(TRUE)
	for(var/datum/bodypart_overlay/simple/overlay in bodypart_overlays)
		LAZYADD(rogue_hidden_overlays, overlay)
		remove_bodypart_overlay(overlay, update = FALSE)
	return TRUE

/// Puts back the flesh a limb lost to bones.
/obj/item/bodypart/proc/rogue_restore_flesh()
	rogue_skeleton = FALSE
	if(rogue_flesh_look)
		limb_id = rogue_flesh_look["limb_id"]
		icon_static = rogue_flesh_look["icon_static"]
		should_draw_greyscale = rogue_flesh_look["greyscale"]
		is_dimorphic = rogue_flesh_look["dimorphic"]
		rogue_bones_look(FALSE)
		rogue_flesh_look = null
	for(var/datum/bodypart_overlay/overlay as anything in rogue_hidden_overlays)
		add_bodypart_overlay(overlay, update = FALSE)
	rogue_hidden_overlays = null

/// What else a limb changes going to bones and back: an arm's hand is the plain skeleton's, a skull has no hair, eyes or
/// lips.
/obj/item/bodypart/proc/rogue_bones_look(bones)
	return

/obj/item/bodypart/arm/rogue_bones_look(bones)
	if(bones)
		rogue_flesh_look["sexed_hand"] = rogue_sexed_hand
		rogue_sexed_hand = FALSE
	else
		rogue_sexed_hand = rogue_flesh_look["sexed_hand"]

/obj/item/bodypart/head/rogue_bones_look(bones)
	if(bones)
		rogue_flesh_look["head_flags"] = head_flags
		head_flags = NONE
	else
		head_flags = rogue_flesh_look["head_flags"]

/// Ratwood clean_body_parts(): flesh again, of its own colour, and of use.
/obj/item/bodypart/proc/rogue_clean_rot()
	if(rogue_skeleton)
		rogue_restore_flesh()
	if(!rogue_rotted)
		return
	rogue_rotted = FALSE
	remove_color_override(ROGUE_LIMB_COLOR_ROT)
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, ROGUE_ROT_TRAIT)
	UnregisterSignal(src, COMSIG_BODYPART_CHECKED_FOR_INJURY)

/// Ratwood's limb status "is necrotic" / "is skeletonized", in the check of one's own body.
/obj/item/bodypart/proc/rogue_rot_injury_line(obj/item/bodypart/source, mob/living/carbon/human/examiner, list/check_list, list/limb_damage)
	SIGNAL_HANDLER
	check_list += span_danger("Your [plaintext_zone] is [rogue_skeleton ? "skeletonized" : "necrotic"].")

#undef ROGUE_BONES_ICON
#undef ROGUE_GOBLIN_LIMB_ID
