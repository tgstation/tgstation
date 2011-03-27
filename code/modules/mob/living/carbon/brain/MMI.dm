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


	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if(istype(O,/obj/item/brain) && !brain)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] sticks \a [O] into \the [src]."))
			src.brain = O
			user.drop_item()
			O.loc = src
			icon_state = "mmi_full"
			brainmob = new /mob/living/carbon/brain
			brainmob.loc = src
			brainmob.name = brain.owner.real_name
			brainmob.real_name = brain.owner.real_name
			brainmob.container = src
			brain.owner.mind.transfer_to(brainmob)
			src.brainmob.client.screen.len = null
			src.name = "Man-Machine Interface:[brainmob.real_name]"
			return
		..()

