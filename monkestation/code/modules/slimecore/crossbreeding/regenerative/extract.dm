/// Returns the typepath to the status effect that should be applied to the target when this extract is used on them.
/obj/item/slimecross/regenerative/proc/get_status_path()
	var/color_path = text2path("/datum/status_effect/regenerative_extract/[colour]")
	if(ispath(color_path, /datum/status_effect/regenerative_extract))
		return color_path
	return /datum/status_effect/regenerative_extract

/obj/item/slimecross/regenerative/proc/can_use(mob/living/target, mob/living/user)
	if(target.stat == DEAD)
		to_chat(user, span_warning("[src] will not work on the dead!"))
		return FALSE
	if(target.has_status_effect(/datum/status_effect/regenerative_extract))
		to_chat(user, span_warning("[target == user ? "You are" : "[target] is"] already being healed by a regenerative extract!"))
		return FALSE
	return TRUE

/obj/item/slimecross/regenerative/afterattack(mob/living/target, mob/user, prox)
	. = ..()
	if(!prox || !isliving(target) || !can_use(target, user))
		return
	if(target != user)
		user.visible_message(span_notice("[user] crushes [src] over [target], the milky goo coating [target.p_their()] injuries!"),
			span_notice("You squeeze [src], and it bursts over [target], the milky goo beginning to regenerate [target.p_their()] injuries."))
	else
		user.visible_message(span_notice("[user] crushes [src] over [user.p_them()]self, the milky goo quickly regenerating all of [user.p_their()] injuries!"),
			span_notice("You squeeze [src], and it bursts in your hand, splashing you with milky goo which quickly regenerates your injuries!"))
	core_effect_before(target, user)
	apply_effect(target)
	core_effect(target, user)
	playsound(target, 'sound/effects/splat.ogg', vol = 40, vary = TRUE)
	qdel(src)

/obj/item/slimecross/regenerative/proc/apply_effect(mob/living/target)
	target.apply_status_effect(get_status_path())

/obj/item/slimecross/regenerative/silver/core_effect(mob/living/target, mob/user)
	return // handled by the status effect

/obj/item/slimecross/regenerative/lightpink/core_effect(mob/living/target, mob/living/user)
	if(!isliving(user))
		return
	if(target == user)
		return
	if(!user.has_status_effect(/datum/status_effect/regenerative_extract))
		apply_effect(user)
		to_chat(user, span_notice("Some of the milky goo sprays onto you, as well!"))
	else
		to_chat(user, span_warning("Some of the milky goo sprays onto you, but slides off due to the regenerative effect..."))

/obj/item/slimecross/regenerative/rainbow/can_use(mob/living/target, mob/living/user)
	if(target.has_status_effect(/datum/status_effect/slime_regen_cooldown))
		to_chat(user, span_warning("[target == user ? "You are" : "[target] is"] still recovering from the last regenerative extract!"))
		return FALSE
	return ..()
