/obj/item/device/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	icon = 'assemblies.dmi'
	icon_state = "mmi_empty"
	w_class = 3

	var/obj/item/brain/brain = null
	var/mob/living/carbon/brain/brainmob = null
	var/mob/living/silicon/robot = null
	var/obj/mecha = null
	var/locked = 0
	req_access = list(access_robotics)

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if(istype(O,/obj/item/brain) && !brain) //Time to stick a brain in it --NEO

			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] sticks \a [O] into \the [src]."))
			brain = O
			user.drop_item()
			O.loc = src

			//Adding the actual mob the brain's player gets moved to. --NEO
			brainmob = new /mob/living/carbon/brain
			brainmob.loc = src
			brainmob.name = brain.owner.real_name
			brainmob.real_name = brain.owner.real_name
			brainmob.container = src
			brain.owner.mind.transfer_to(brainmob)
			brainmob.client.screen.len = null

			name = "Man-Machine Interface:[brainmob.real_name]"
			icon_state = "mmi_full"
			locked = 1
			return
		if((istype(O,/obj/item/weapon/card/id)||istype(O,/obj/item/device/pda)) && brain)
			if(allowed(user))
				locked = !locked
				user << "\blue You [locked ? "lock" : "unlock"] the brain holder."
			else
				user << "\red Access denied."
			return
		if(brain)
			O.attack(brainmob, user)
			return
		..()


