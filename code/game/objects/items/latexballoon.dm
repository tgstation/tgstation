/obj/item/latexballon
	name = "latex glove"
	desc = "Sterile and airtight."
	icon_state = "latexballon"
	inhand_icon_state = "greyscale_gloves"
	lefthand_file = 'icons/mob/inhands/clothing/gloves_righthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/gloves_lefthand.dmi'
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 7
	var/state
	var/datum/gas_mixture/air_contents = null

/obj/item/latexballon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/atmos_sensitive, mapload)

/obj/item/latexballon/proc/blow(obj/item/tank/tank, mob/user)
	if (icon_state == "latexballon_bursted")
		return
	icon_state = "latexballon_blow"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	inhand_icon_state = "latexballon"
	user.update_held_items()
	to_chat(user, span_notice("You blow up [src] with [tank]."))
	air_contents = tank.remove_air_volume(3)

/obj/item/latexballon/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return (exposed_temperature > T0C+100)

/obj/item/latexballon/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	burst()

/obj/item/latexballon/proc/burst()
	if (!air_contents || icon_state != "latexballon_blow")
		return
	playsound(src, 'sound/weapons/gun/pistol/shot.ogg', 100, TRUE)
	icon_state = "latexballon_bursted"
	inhand_icon_state = initial(inhand_icon_state)
	lefthand_file = initial(lefthand_file)
	righthand_file = initial(righthand_file)
	if(isliving(loc))
		var/mob/living/user = src.loc
		user.update_held_items()
	loc.assume_air(air_contents)

/obj/item/latexballon/ex_act(severity, target)
	burst()
	switch(severity)
		if (EXPLODE_DEVASTATE)
			qdel(src)
		if (EXPLODE_HEAVY)
			if (prob(50))
				qdel(src)

/obj/item/latexballon/bullet_act(obj/projectile/P)
	if(P.damage > 0)
		burst()
	return ..()

/obj/item/latexballon/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/tank))
		var/obj/item/tank/T = W
		blow(T, user)
		return
	if (W.get_sharpness() || W.get_temperature())
		burst()
