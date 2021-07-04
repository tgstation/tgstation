/obj/structure/displaycase/freezeray
	start_showpiece_type = /obj/item/freeze_cube
	alert = FALSE

/obj/item/freeze_cube
	name = "freeze cube"
	desc = "A block of semi-clear ice treated with chemicals to behave as a throwable weapon. \
		Somehow, it does not transfer its freezing temperatures until it comes into contact with a living creature."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "freeze_cube"
	inhand_icon_state = "paintcan"
	throw_range = 5
	throwforce = 10
	damage_type = BURN
	COOLDOWN_DECLARE(freeze_cooldown)

/obj/item/freeze_cube/examine(mob/user)
	. = ..()
	. += span_notice("Throw this at objects or creatures to freeze them, it will boomerang back so be cautious!")

/obj/item/freeze_cube/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/caught = hit_atom.hitby(src, FALSE, FALSE, throwingdatum=throwingdatum)
	var/mob/thrown_by = thrownby?.resolve()
	if(ismovable(hit_atom) && !caught && (!thrown_by || thrown_by && COOLDOWN_FINISHED(src, freeze_cooldown)))
		freeze(hit_atom)
	if(thrown_by && !caught)
		addtimer(CALLBACK(src, /atom/movable.proc/throw_at, thrown_by, throw_range+2, throw_speed, null, TRUE), 1)

/obj/item/freeze_cube/proc/freeze(atom/movable/hit_atom)
	playsound(src, 'sound/effects/glassbr3.ogg', 50, TRUE)
	COOLDOWN_START(src, freeze_cooldown, 3 SECONDS)
	if(isobj(hit_atom))
		var/obj/hit_object = hit_atom
		if(hit_object.resistance_flags & FREEZE_PROOF)
			hit_object.visible_message(span_warning("[hit_object] is freeze-proof!"))
			return
		if(!(hit_object.obj_flags & FROZEN))
			hit_object.make_frozen_visual()
	else if(isliving(hit_atom))
		var/mob/living/hit_mob = hit_atom
		hit_mob.apply_status_effect(/datum/status_effect/freon/freeze_cube)
		hit_mob.adjust_bodytemperature(-100)
