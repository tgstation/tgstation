//trophy

/obj/item/crusher_trophy/hugglebipper_eye
	name = "hugglebipper eye"
	desc = "A beady hugglebipper eyebalal. Suitable as a trophy for a kinetic crusher."
	icon = 'icons/mob/simple/lavaland/hugglebipper.dmi'
	icon_state = "hb_eye"
	denied_type = /obj/item/crusher_trophy/hugglebipper_eye

/obj/item/crusher_trophy/hugglebipper_eye/effect_desc()
	return "mark detonation to heal if you are below half your life"

/obj/item/crusher_trophy/hugglebipper_eye/on_mark_detonation(mob/living/target, mob/living/user)
	if(user.health / user.maxHealth > 0.5)
		return
	user.heal_overall_damage(5, 5)
