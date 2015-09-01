/obj/item/weapon/implant
	name = "implant"
	icon = 'icons/obj/implants.dmi'
	icon_state = "generic" //Shows up as the action button icon
	action_button_is_hands_free = 1
	origin_tech = "materials=2;biotech=3;programming=2"

	var/activated = 1 //1 for implant types that can be activated, 0 for ones that are "always on" like loyalty implants
	var/implanted = null
	var/mob/living/imp_in = null
	item_color = "b"
	var/allow_multiple = 0
	var/uses = -1


/obj/item/weapon/implant/proc/trigger(emote, mob/source)
	return

/obj/item/weapon/implant/proc/activate()
	return

/obj/item/weapon/implant/ui_action_click()
	activate("action_button")


//What does the implant do upon injection?
//return 1 if the implant injects
//return -1 if the implant fails to inject
//return 0 if there is no room for implant
/obj/item/weapon/implant/proc/implant(var/mob/source, var/mob/user)
	var/obj/item/weapon/implant/imp_e = locate(src.type) in source
	if(!allow_multiple && imp_e && imp_e != src)
		if(imp_e.uses < initial(imp_e.uses)*2)
			if(uses == -1)
				imp_e.uses = -1
			else
				imp_e.uses = min(imp_e.uses + uses, initial(imp_e.uses)*2)
			qdel(src)
			return 1
		else
			return 0


	if(activated)
		action_button_name = "Activate [src.name]"
	src.loc = source
	imp_in = source
	implanted = 1
	if(istype(source, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = source
		H.sec_hud_set_implants()

	if(user)
		add_logs(user, source, "implanted", object="[name]")

	return 1

/obj/item/weapon/implant/proc/removed(var/mob/source)
	src.loc = null
	imp_in = null
	implanted = 0

	if(istype(source, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = source
		H.sec_hud_set_implants()

	return 1

/obj/item/weapon/implant/Destroy()
	if(imp_in)
		removed(imp_in)
	return ..()


/obj/item/weapon/implant/proc/get_data()
	return "No information available"

/obj/item/weapon/implant/dropped(mob/user)
	. = 1
	qdel(src)
	return .

/obj/item/weapon/implant/tracking
	name = "tracking implant"
	desc = "Track with this."
	activated = 0
	origin_tech = "materials=2;magnets=2;programming=2;biotech=2"
	var/id = 1.0

/obj/item/weapon/implant/tracking/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Tracking Beacon<BR>
				<b>Life:</b> 10 minutes after death of host<BR>
				<b>Important Notes:</b> None<BR>
				<HR>
				<b>Implant Details:</b> <BR>
				<b>Function:</b> Continuously transmits low power signal. Useful for tracking.<BR>
				<b>Special Features:</b><BR>
				<i>Neuro-Safe</i>- Specialized shell absorbs excess voltages self-destructing the chip if
				a malfunction occurs thereby securing safety of subject. The implant will melt and
				disintegrate into bio-safe elements.<BR>
				<b>Integrity:</b> Gradient creates slight risk of being overcharged and frying the
				circuitry. As a result neurotoxins can cause massive damage.<HR>
				Implant Specifics:<BR>"}
	return dat

/obj/item/weapon/implant/weapons_auth
	name = "firearms authentication implant"
	desc = "Lets you shoot your guns"
	icon_state = "auth"
	origin_tech = "materials=2;magnets=2;programming=2;biotech=5;syndicate=5"
	activated = 0

/obj/item/weapon/implant/weapons_auth/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Firearms Authentication Implant<BR>
				<b>Life:</b> 4 hours after death of host<BR>
				<b>Implant Details:</b> <BR>
				<b>Function:</b> Allows operation of implant-locked weaponry, preventing equipment from falling into enemy hands."}
	return dat


/obj/item/weapon/implant/adrenalin
	name = "adrenal implant"
	desc = "Removes all stuns and knockdowns."
	icon_state = "adrenal"
	origin_tech = "materials=2;biotech=4;combat=3;syndicate=4"
	uses = 3

/obj/item/weapon/implant/adrenalin/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Cybersun Industries Adrenaline Implant<BR>
				<b>Life:</b> Five days.<BR>
				<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
				<HR>
				<b>Implant Details:</b> Subjects injected with implant can activate an injection of medical cocktails.<BR>
				<b>Function:</b> Removes stuns, increases speed, and has a mild healing effect.<BR>
				<b>Integrity:</b> Implant can only be used three times before reserves are depleted."}
	return dat

/obj/item/weapon/implant/adrenalin/activate()
	if(uses < 1)	return 0
	uses--
	imp_in << "<span class='notice'>You feel a sudden surge of energy!</span>"
	imp_in.SetStunned(0)
	imp_in.SetWeakened(0)
	imp_in.SetParalysis(0)
	imp_in.adjustStaminaLoss(-75)
	imp_in.lying = 0
	imp_in.update_canmove()

	imp_in.reagents.add_reagent("synaptizine", 10)
	imp_in.reagents.add_reagent("omnizine", 10)
	imp_in.reagents.add_reagent("stimulants", 10)


/obj/item/weapon/implant/emp
	name = "emp implant"
	desc = "Triggers an EMP."
	icon_state = "emp"
	origin_tech = "materials=2;biotech=3;magnets=4;syndicate=4"
	uses = 2

/obj/item/weapon/implant/emp/activate()
	if (src.uses < 1)	return 0
	src.uses--
	empulse(imp_in, 3, 5)
