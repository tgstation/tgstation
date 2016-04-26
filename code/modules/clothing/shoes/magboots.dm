/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	var/base_state = "magboots"
	var/magpulse = 0
	var/mag_slow = 2
//	flags = NOSLIP //disabled by default
	action_button_name = "Toggle Magboots"
	species_fit = list("Vox")

	var/stomp_attack_power = 20

/obj/item/clothing/shoes/magboots/on_kick(mob/living/carbon/human/user, mob/living/victim)
	if(!stomp_attack_power) return

	var/turf/T = get_turf(src)
	if(magpulse && victim.lying && T == victim.loc && !istype(T, /turf/space)) //To stomp on somebody, you have to be on the same tile as them. You can't be in space, and they have to be lying
		//NUCLEAR MAGBOOT STUMP INCOMING (it takes 3 seconds)

		user.visible_message("<span class='danger'>\The [user] slowly raises his foot above the lying [victim.name], preparing to stomp on \him.</span>")
		toggle()

		if(do_after(user, src, 3 SECONDS))
			if(magpulse) return //Magboots enabled
			if(!victim.lying || (victim.loc != T)) return //Victim moved
			if(locate(/obj/structure/table) in T) //Can't curbstomp on a table
				to_chat(user, "<span class='info'>There is a table in the way!</span>")
				return

			user.attack_log += "\[[time_stamp()]\] Magboot-stomped <b>[user] ([user.ckey])</b>"
			victim.attack_log += "\[[time_stamp()]\] Was magboot-stomped by <b>[src] ([victim.ckey])</b>"

			victim.visible_message("<span class='danger'>\The [user] crushes \the [victim] with the activated [src.name]!", "<span class='userdanger'>\The [user] crushes you with \his [src.name]!</span>")
			victim.adjustBruteLoss(stomp_attack_power)
			playsound(get_turf(victim), 'sound/effects/gib3.ogg', 100, 1)
		else
			return

		toggle()
		playsound(get_turf(victim), 'sound/mecha/mechstep.ogg', 100, 1)

/obj/item/clothing/shoes/magboots/verb/toggle()
	set name = "Toggle Magboots"
	set category = "Object"
	set src in usr
	if(usr.isUnconscious())
		return
	if(src.magpulse)
		src.flags &= ~NOSLIP
		src.slowdown = SHOES_SLOWDOWN
		src.magpulse = 0
		icon_state = "[base_state]0"
		to_chat(usr, "You disable the mag-pulse traction system.")
	else
		src.flags |= NOSLIP
		src.slowdown = mag_slow
		src.magpulse = 1
		icon_state = "[base_state]1"
		to_chat(usr, "You enable the mag-pulse traction system.")
	usr.update_inv_shoes()	//so our mob-overlays update

/obj/item/clothing/shoes/magboots/attack_self()
	src.toggle()
	..()
	return

/obj/item/clothing/shoes/magboots/examine(mob/user)
	..()
	var/state = "disabled"
	if(src.flags&NOSLIP)
		state = "enabled"
	to_chat(user, "<span class='info'>Its mag-pulse traction system appears to be [state].</span>")

//CE
/obj/item/clothing/shoes/magboots/elite
	desc = "Advanced magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "advanced magboots"
	icon_state = "CE-magboots0"
	base_state = "CE-magboots"
	mag_slow = 1

//Atmos techies die angry
/obj/item/clothing/shoes/magboots/atmos
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle. These are painted in the colors of an atmospheric technician."
	name = "atmospherics magboots"
	icon_state = "atmosmagboots0"
	base_state = "atmosmagboots"

//Death squad
/obj/item/clothing/shoes/magboots/deathsquad
	desc = "Very expensive and advanced magnetic boots, used only by the elite during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "deathsquad magboots"
	icon_state = "DS-magboots0"
	base_state = "DS-magboots"
	mag_slow = 0