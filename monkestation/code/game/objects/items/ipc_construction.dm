/// IPC Building
/obj/item/ipc_chest
	name = "ipc chest"
	desc = "A complex metal chest cavity with standard limb sockets and pseudomuscle anchors."
	icon = 'icons/mob/species/ipc/bodyparts.dmi'
	icon_state = "synthchest"

/obj/item/ipc_chest/Initialize(mapload)
	. = ..()
	var/mob/living/carbon/human/species/ipc/ipc_body = new /mob/living/carbon/human/species/ipc(get_turf(src))
	/// Remove those bodyparts
	for(var/ipc_body_parts in ipc_body.bodyparts)
		var/obj/item/bodypart/bodypart = ipc_body_parts
		if(bodypart.body_part != CHEST)
			if(bodypart.dismemberable)
				QDEL_NULL(bodypart)
	/// Remove those organs
	for (var/organs in ipc_body.internal_organs)
		qdel(organs)

	/// Update current body to be limbless
	ipc_body.update_icon()
	/// Null deathsound and emote ability
	ipc_body.deathsound = null
	ADD_TRAIT(ipc_body, TRAIT_EMOTEMUTE, type)
	ipc_body.death()
	/// Reapply deathsound and emote ability
	ipc_body.deathsound = "sound/voice/borg_deathsound.ogg"
	REMOVE_TRAIT(ipc_body, TRAIT_EMOTEMUTE, type)
	/// Remove placeholder ipc_chest
	qdel(src)
