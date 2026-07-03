/obj/structure/musician
	name = "Not A Piano"
	desc = "Something broke, contact coderbus."
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT | INTERACT_ATOM_REQUIRES_DEXTERITY
	integrity_failure = 0.25
	/// IF FALSE music stops when the piano is unanchored.
	var/can_play_unanchored = FALSE
	/// Our allowed list of instrument ids. This is nulled on initialize.
	var/list/allowed_instrument_ids = list("r3grand","r3harpsi","crharpsi","crgrand1","crbright1", "crichugan", "crihamgan","piano")
	/// Our song datum.
	var/datum/song/stationary/song

/obj/structure/musician/Initialize(mapload)
	. = ..()
	song = new(src, allowed_instrument_ids)
	allowed_instrument_ids = null

/obj/structure/musician/Destroy()
	QDEL_NULL(song)
	return ..()

/obj/structure/musician/proc/can_play(atom/music_player)
	if(!anchored && !can_play_unanchored)
		return FALSE
	if(!ismob(music_player))
		return FALSE
	var/mob/user = music_player
	if(!ISADVANCEDTOOLUSER(user))
		return FALSE
	if(user.incapacitated)
		return FALSE
	if(!Adjacent(user))
		return FALSE
	return TRUE

/obj/structure/musician/ui_interact(mob/user)
	return song.ui_interact(user)

/obj/structure/musician/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool, time = 4 SECONDS)
	update_icon(UPDATE_ICON_STATE) // BANDASTATION ADDITION
	return ITEM_INTERACT_SUCCESS

/obj/structure/musician/piano
	name = "space piano"
	desc = "This is a space piano, like a regular piano, but always in tune! Even if the musician isn't."
	icon = 'icons/obj/art/musician.dmi'
	icon_state = "piano"
	anchored = TRUE
	density = TRUE
	var/broken_icon_state = "pianobroken"

/obj/structure/musician/piano/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/falling_hazard, damage = 60, wound_bonus = 10, hardhat_safety = FALSE, crushes = TRUE, impact_sound = 'sound/effects/piano_hit.ogg')
	AddElement(/datum/element/climbable)
	AddElement(/datum/element/elevation, pixel_shift = 10)

/obj/structure/musician/piano/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/effects/piano_hit.ogg', 100, TRUE)
		if(BURN)
			playsound(src, 'sound/items/tools/welder.ogg', 100, TRUE)

/obj/structure/musician/piano/atom_break(damage_flag)
	. = ..()
	if(!broken)
		broken = TRUE
		icon_state = broken_icon_state

/obj/structure/musician/piano/unanchored
	anchored = FALSE

/obj/structure/musician/piano/minimoog
	name = "space minimoog"
	desc = "This is a minimoog, like a space piano, but more spacey!"
	icon_state = "minimoog"
	broken_icon_state = "minimoogbroken"
