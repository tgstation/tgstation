/obj/structure/displaycase/freezeray
	start_showpiece_type = /obj/item/freeze_cube
	alert = FALSE

/obj/item/freeze_cube
	name = "freeze cube"
	desc = "A block of semi-clear ice treated with chemicals to behave as a throwable weapon. \
		Somehow, it does not transfer its freezing temperatures until it comes into contact with a living creature."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "freeze_cube"
	throwforce = 10
	damtype = BURN
	var/cooldown_time = 5 SECONDS
	COOLDOWN_DECLARE(freeze_cooldown)

/obj/item/freeze_cube/examine(mob/user)
	. = ..()
	. += span_notice("Throw this at objects or creatures to freeze them, it will boomerang back so be cautious!")

/obj/item/freeze_cube/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, quickstart = TRUE)
	. = ..()
	if(!.)
		return
	icon_state = "freeze_cube_thrown"
	addtimer(VARSET_CALLBACK(src, icon_state, initial(icon_state)), 1 SECONDS)

/obj/item/freeze_cube/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	icon_state = initial(icon_state)
	var/caught = hit_atom.hitby(src, FALSE, FALSE, throwingdatum=throwingdatum)
	var/mob/thrown_by = thrownby?.resolve()
	if(ismovable(hit_atom) && !caught && (!thrown_by || thrown_by && COOLDOWN_FINISHED(src, freeze_cooldown)))
		freeze(hit_atom)
	if(thrown_by && !caught)
		addtimer(CALLBACK(src, /atom/movable.proc/throw_at, thrown_by, throw_range+2, throw_speed, null, TRUE), 1)

/obj/item/freeze_cube/proc/freeze(atom/movable/hit_atom)
	playsound(src, 'sound/effects/glassbr3.ogg', 50, TRUE)
	COOLDOWN_START(src, freeze_cooldown, cooldown_time)
	if(isobj(hit_atom))
		var/obj/hit_object = hit_atom
		if(hit_object.resistance_flags & FREEZE_PROOF)
			hit_object.visible_message(span_warning("[hit_object] is freeze-proof!"))
			return
		if(!(hit_object.obj_flags & FROZEN))
			hit_object.make_frozen_visual()
	else if(isliving(hit_atom))
		var/mob/living/hit_mob = hit_atom
		SSmove_manager.stop_looping(hit_mob) //stops them mid pathing even if they're stunimmune
		hit_mob.apply_status_effect(/datum/status_effect/ice_block_talisman, 3 SECONDS)
