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
	playsound(owner, 'sound/weapons/fwoosh.ogg', 75, FALSE)
	return ..()

/datum/status_effect/song/antimagic/on_remove()
	REMOVE_TRAIT(owner, TRAIT_ANTIMAGIC, MAGIC_TRAIT)
	return ..()

/datum/status_effect/song/antimagic/get_examine_text()
	return span_notice("[owner.p_they(TRUE)] seem[owner.p_s()] to be covered in a dull, grey aura.")
