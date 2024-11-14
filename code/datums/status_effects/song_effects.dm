///Type of status effect applied by music played by the festival sect. Stacks upon itself, and removes all other song subtypes other than itself.
/datum/status_effect/song
	id = "pleaseno"
	alert_type = null
	var/aura_desc = "useless, buggy"

/datum/status_effect/song/on_apply()
	owner.visible_message(span_notice("[owner] is coated with a [aura_desc] aura!"))
	//removes every other song subtype except itself
	for(var/overridden_song_type in subtypesof(/datum/status_effect/song) - type)
		owner.remove_status_effect(overridden_song_type)
	return ..()

/datum/status_effect/song/on_remove()
	owner.visible_message(span_warning("[owner]'s [aura_desc] aura fades away..."))

/datum/status_effect/song/refresh(effect)
	duration += initial(duration) //slowly builds up, so the more times you get this status effect, the longer it lasts until it's gone.

/datum/status_effect/song/antimagic
	id = "antimagic"
	status_type = STATUS_EFFECT_REFRESH
	duration = 10 SECONDS
	aura_desc = "dull"

/datum/status_effect/song/antimagic/on_apply()
	ADD_TRAIT(owner, TRAIT_ANTIMAGIC, MAGIC_TRAIT)
	playsound(owner, 'sound/items/weapons/fwoosh.ogg', 75, FALSE)
	return ..()

/datum/status_effect/song/antimagic/on_remove()
	REMOVE_TRAIT(owner, TRAIT_ANTIMAGIC, MAGIC_TRAIT)
	return ..()

/datum/status_effect/song/antimagic/get_examine_text()
	return span_notice("[owner.p_They()] seem[owner.p_s()] to be covered in a dull, grey aura.")

/datum/status_effect/song/light
	id = "light_song"
	status_type = STATUS_EFFECT_REFRESH
	duration = 1 MINUTES
	aura_desc = "bright"
	/// lighting object that makes owner glow
	var/obj/effect/dummy/lighting_obj/moblight/mob_light_obj

/datum/status_effect/song/light/on_apply()
	mob_light_obj = owner.mob_light(3, 1.5, color = LIGHT_COLOR_DIM_YELLOW)
	playsound(owner, 'sound/items/weapons/fwoosh.ogg', 75, FALSE)
	return TRUE

/datum/status_effect/song/light/on_remove()
	QDEL_NULL(mob_light_obj)

/datum/status_effect/song/light_song/get_examine_text()
	return span_notice("[owner.p_They()] seem[owner.p_s()] to be covered in a glowing aura.")
