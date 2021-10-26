
/obj/effect/mob_spawn/sentientmatter
	name = "Sentient Supermatter"
	//let ghosts take it over
	roundstart = FALSE
	death = FALSE
	banType = ROLE_GHOST_ROLE
	//while you will never see this mob spawn, the point of interest will use this icon.
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "darkmatter"
	//will be shown on the ghost roles menu
	mob_name = "supermatter crystal"
	short_desc = "Due to the infinite possibilities of an infinite plane of space inside the crystal, the supermatter has emerged as sentient!"
	flavour_text = "Chat up the chief engineer. Be annoying. Complain it's way too hot. Delaminate in a fit of rage. You know, things that supermatters do! \
	fair warning, there's not a whole lot to do as a supermatter so don't go in expecting a nail biter of a shift."
	//semi-abstract mob we will be talking "as the supermatter" from
	mob_type = /mob/living/simple_animal/sentientmatter
	///reference to the supermatter crystal we're inside
	var/obj/machinery/power/supermatter_crystal/obj_matter

/obj/effect/mob_spawn/sentientmatter/Initialize(mapload)
	. = ..()
	obj_matter = loc //on god respectfully, this should runtime to hell outside of a supermatter and that's GOOD
	RegisterSignal(obj_matter, COMSIG_PARENT_QDELETING, .proc/on_obj_matter_destroyed)

/obj/effect/mob_spawn/sentientmatter/Destroy()
	UnregisterSignal(obj_matter, COMSIG_PARENT_QDELETING)
	. = ..()

/obj/effect/mob_spawn/sentientmatter/proc/on_obj_matter_destroyed(datum/source, force)
	SIGNAL_HANDLER
	qdel(src)

/obj/effect/mob_spawn/sentientmatter/special(mob/mob_matter)
	mob_matter.forceMove(obj_matter) //stick em right in there

///semi-abstract mob that insides the supermatter to make the supermatter look like it's talking. kinda like how shades sit inside spirit holding weapons.
/mob/living/simple_animal/sentientmatter
	name = "supermatter crystal"
	//avoids really dumb shit
	maxHealth = INFINITY
	health = INFINITY
	status_flags = GODMODE
	//modifies how the sentientmatter speaks
	speech_span = SPAN_SUPERMATTER
	speak_emote = list("fractals", "delaminates", "stabilizes", "destabilizes")
	//special hud
	hud_type = /datum/hud/sentientmatter
	///reference to the supermatter crystal we're inside
	var/obj/machinery/power/supermatter_crystal/obj_matter

/mob/living/simple_animal/sentientmatter/Initialize(mapload, obj/machinery/power/supermatter_crystal/obj_matter)
	. = ..()
	src.obj_matter = obj_matter
	RegisterSignal(obj_matter, COMSIG_PARENT_QDELETING, .proc/on_obj_matter_destroyed)
	RegisterSignal(obj_matter, COMSIG_ATOM_RELAYMOVE, .proc/block_buckle_message)

/mob/living/simple_animal/sentientmatter/Destroy()
	obj_matter = null
	UnregisterSignal(obj_matter, list(COMSIG_PARENT_QDELETING, COMSIG_ATOM_RELAYMOVE, COMSIG_ATOM_UPDATE_OVERLAYS))
	. = ..()

/mob/living/simple_animal/update_health_hud()
	if(!hud_used)
		return
	switch(obj_matter.damage) //check the sm's health instead of ours as we die when the supermatter splodes
		if(0 to 300)
			hud_used.healths.icon_state = "supermatter_fine"
		if(301 to 700)
			hud_used.healths.icon_state = "supermatter_hurt"
		if(701 to explosion_point)
			hud_used.healths.icon_state = "supermatter_dying"

/mob/living/simple_animal/sentientmatter/Login()
	. = ..()
	RegisterSignal(obj_matter, COMSIG_ATOM_UPDATE_OVERLAYS, .proc/add_googly_eyes)
	obj_matter.update_icon(UPDATE_OVERLAYS)

/mob/living/simple_animal/sentientmatter/Logout()
	. = ..()
	UnregisterSignal(obj_matter, COMSIG_ATOM_UPDATE_OVERLAYS)
	obj_matter.update_icon(UPDATE_OVERLAYS)

/mob/living/simple_animal/sentientmatter/setDir(newdir)
	. = ..()
	obj_matter.dir = newdir

///signal fired from the supermatter
/datum/component/engraved/proc/on_update_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	var/static/image/googly_eyes
	if(isnull(googly_eyes))
		googly_eyes = iconstate2appearance('icons/mob/mob.dmi', "googly_eyes")
	overlays += googly_eyes

///signal fired from the supermatter destroying itself
/mob/living/simple_animal/sentientmatter/proc/on_obj_matter_destroyed(datum/source, force)
	SIGNAL_HANDLER
	qdel(src)

///signal fired from a mob moving inside the supermatter
/mob/living/simple_animal/sentientmatter/proc/block_buckle_message(datum/source, mob/living/user, direction)
	SIGNAL_HANDLER
	return COMSIG_BLOCK_RELAYMOVE
