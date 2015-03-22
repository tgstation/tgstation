/spell/aoe_turf/conjure/forcewall
	name = "Forcewall"
	desc = "Create a wall of pure energy at your location."
	summon_type = list(/obj/effect/forcefield)
	duration = 300
	charge_max = 100
	spell_flags = 0
	range = 0
	cast_sound = null

	hud_state = "wiz_shield"

/spell/aoe_turf/conjure/forcewall/mime
	name = "Invisible wall"
	desc = "Create an invisible wall on your location."
	school = "mime"
	panel = "Mime"
	summon_type = list(/obj/effect/forcefield/mime)
	invocation_type = SpI_EMOTE
	invocation = "mimes placing their hands on a flat surfacing, and pushing against it."
	charge_max = 300
	cast_sound = null

	override_base = "grey"
	hud_state = "mime_wall"

/obj/effect/forcefield
	desc = "A space wizard's magic wall."
	name = "FORCEWALL"
	icon = 'icons/effects/effects.dmi'
	icon_state = "m_shield"
	anchored = 1.0
	opacity = 0
	density = 1
	unacidable = 1

/obj/effect/forcefield/bullet_act(var/obj/item/projectile/Proj, var/def_zone)
	var/turf/T = get_turf(src.loc)
	if(T)
		for(var/mob/M in T)
			Proj.on_hit(M,M.bullet_act(Proj, def_zone))
	return

/obj/effect/forcefield/mime
	icon_state = "empty"
	name = "invisible wall"
	desc = "You have a bad feeling about this."

/obj/effect/forcefield/cultify()
	new /obj/effect/forcefield/cult(get_turf(src))
	qdel(src)
	return
