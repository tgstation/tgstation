/obj/item/organ/internal/brain/darkspawn
	name = "tumorous mass"
	desc = "A fleshy growth that was dug out of the skull of a Nightmare."

/obj/item/organ/internal/brain/shadow/nightmare/on_insert(mob/living/carbon/brain_owner)
	. = ..()
	RegisterSignal(brain_owner, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(dodge_bullets))

/obj/item/organ/internal/brain/shadow/nightmare/on_remove(mob/living/carbon/brain_owner)
	. = ..()
	UnregisterSignal(brain_owner, COMSIG_ATOM_PRE_BULLET_ACT)

/obj/item/organ/internal/brain/darkspawn/proc/dodge_bullets(mob/living/carbon/human/source, obj/projectile/hitting_projectile, def_zone)
	SIGNAL_HANDLER
	var/turf/dodge_turf = source.loc
	if((!istype(dodge_turf) || dodge_turf.get_lumcount() >= SHADOW_SPECIES_LIGHT_THRESHOLD) && !source.has_status_effect(/datum/status_effect/shadow_dance))
		return NONE
	source.visible_message(
		span_danger("[source] dances in the shadows, evading [hitting_projectile]!"),
		span_danger("You evade [hitting_projectile] with the cover of darkness!"),
	)
	playsound(source, SFX_BULLET_MISS, 75, TRUE)
	return COMPONENT_BULLET_PIERCED

/obj/item/organ/internal/eyes/shadow/darkspawn
	sight_flags = SEE_MOBS
