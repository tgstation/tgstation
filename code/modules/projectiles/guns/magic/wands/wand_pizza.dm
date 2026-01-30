/**
 * Turns things you hit into pizza.
 */
/obj/item/gun/magic/wand/pizza
	name = "wand of snacking"
	desc = "The incredible power of this wand transforms certain objects and surfaces into edible pizza."
	school = SCHOOL_TRANSMUTATION
	ammo_type = /obj/item/ammo_casing/magic/pizza
	icon_state = "polywand"
	base_icon_state = "polywand"
	fire_sound = 'sound/effects/magic/staff_change.ogg'
	max_charges = 20

/obj/item/gun/magic/wand/pizza/zap_self(mob/living/user, suicide = FALSE)
	to_chat(user, span_notice("You can't bring yourself to commit to a permanent transformation into pizza right now."))
	return

/obj/item/gun/magic/wand/pizza/do_suicide(mob/living/user)
	charges--
	playsound(user, fire_sound, 50, TRUE)
	var/turf/user_loc = get_turf(user)
	user.unequip_everything()
	new /obj/effect/particle_effect/fluid/smoke(user_loc)
	var/obj/item/food/pizzaslice/margherita/pizza = new(user_loc)
	pizza.name = "[user.real_name] slice"
	user.ghostize()
	qdel(user)
	return MANUAL_SUICIDE

/obj/item/ammo_casing/magic/pizza
	projectile_type = /obj/projectile/magic/pizza
	harmful = FALSE

/obj/projectile/magic/pizza
	name = "bolt of snacking"
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "pizzamargherita"

/obj/projectile/magic/pizza/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/turf/hit_turf = get_turf(target)
	var/datum/dimension_theme/pizza/converter = new()
	if(!converter.can_convert(hit_turf))
		return
	converter.apply_theme(hit_turf)
