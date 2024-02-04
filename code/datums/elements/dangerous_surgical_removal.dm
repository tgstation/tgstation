/**
 * ## DANGEROUS SURGICAL REMOVAL ELEMENT
 *
 * Makes the organ explode when removed surgically.
 * That's about it.
 */
/datum/element/dangerous_surgical_removal
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// The detonation timer for the exploding organ.
	var/fuse_time = 3 SECONDS
	/// How strong the explosion is. Usually quite harmless as far as explosions go.
	var/explosion_strength = 1
	// If any of these flags are on the organ, it won't prime upon removal.
	var/flag_blockers = (ORGAN_FAILING|ORGAN_EMP)

/datum/element/dangerous_surgical_removal/Attach(datum/target, fuse_time = 3 SECONDS, explosion_strength = 1, flag_blockers = (ORGAN_FAILING|ORGAN_EMP))
	. = ..()

	if(!isorgan(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignals(target, list(COMSIG_MOB_EMOTE, COMSIG_ORGAN_SURGICALLY_REMOVED), PROC_REF(on_surgical_removal))

	src.fuse_time = fuse_time
	src.explosion_strength = explosion_strength
	src.flag_blockers = flag_blockers

/datum/element/dangerous_surgical_removal/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ORGAN_SURGICALLY_REMOVED)

/datum/element/dangerous_surgical_removal/proc/on_surgical_removal(obj/item/organ/source, mob/living/user, mob/living/carbon/old_owner, target_zone, obj/item/tool)
	SIGNAL_HANDLER
	if(source.organ_flags & flag_blockers)
		return
	playsound(source, 'sound/effects/fuse.ogg', vol = 45)
	var/mutable_appearance/sparks = mutable_appearance('icons/effects/welding_effect.dmi', "welding_sparks", GASFIRE_LAYER, source, ABOVE_LIGHTING_PLANE)
	source.add_overlay(sparks)
	LAZYADD(source.update_overlays_on_z, sparks)
	source.visible_message(span_userdanger("As [user] pulls [source] from [old_owner]'s body, it begins making a concerning sizzling noise..."))
	animate(source, time = 1, pixel_z = 12, easing = ELASTIC_EASING)
	animate(time = 1, pixel_z = 0, easing = BOUNCE_EASING)
	for(var/i in 1 to 32)
		animate(color = (i % 2) ? COLOR_WHITE : COLOR_ORANGE, time = 1, easing = QUAD_EASING)

	ASYNC
		user.put_in_hands(source, del_on_fail = FALSE, forced = TRUE)
		stoplag(fuse_time)
		explosion(source, devastation_range = 0, heavy_impact_range = round(explosion_strength * 0.5), light_impact_range = explosion_strength, flame_range = explosion_strength * 1.5, flash_range = explosion_strength * 2, explosion_cause = source)
		qdel(source)
