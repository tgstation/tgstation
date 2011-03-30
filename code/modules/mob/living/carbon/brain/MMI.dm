/obj/item/device/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	icon = 'assemblies.dmi'
	icon_state = "mmi_empty"
	w_class = 3
	origin_tech = "biotech=3"

	var/obj/item/brain/brain = null
	var/mob/living/silicon/robot = null
	var/obj/mecha = null
	var/locked = 0
	req_access = list(access_robotics)

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if(istype(O,/obj/item/brain) && !brain) //Time to stick a brain in it --NEO
			if(!O:owner)
				user << "\red You aren't sure where this brain came from, but you're pretty sure it's a useless brain."
				return
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] sticks \a [O] into \the [src]."))
			brain = O
			user.drop_item()
			O.loc = src
			brain.brainmob.container = src
			brain.brainmob.stat = 0
			locked = 1
			name = "Man-Machine Interface:[brain.brainmob.real_name]"
			icon_state = "mmi_full"
			return

		if((istype(O,/obj/item/weapon/card/id)||istype(O,/obj/item/device/pda)) && brain)
			if(allowed(user))
				locked = !locked
				user << "\blue You [locked ? "lock" : "unlock"] the brain holder."
			else
				user << "\red Access denied."
			return
		if(brain)
			O.attack(brain.brainmob, user)
			return
		..()


	attack_self(mob/user as mob)
		if(!brain)
			user << "\red You upend the MMI, but there's nothing in it."
		else if(locked)
			user << "\red You upend the MMI, but the brain is clamped into place."
		else
			user << "\blue You upend the MMI, spilling the brain onto the floor."
			brain.loc = user.loc
			brain.brainmob.container = null
			brain.brainmob.death()
			brain = null
			icon_state = "mmi_empty"
			name = "Man-Machine Interface"



