/*
CONTAINS:
ORANGE SHOES
MUZZLE
CAKEHAT
SUNGLASSES
SWAT SUIT
CHAMELEON JUMPSUIT
SYNDICATE SHOES
DEATH COMMANDO GAS MASK
THERMAL GLASSES
*/


/*
/obj/item/clothing/fire_burn(obj/fire/raging_fire, datum/air_group/environment)
	if(raging_fire.internal_temperature > src.s_fire)
		spawn( 0 )
			var/t = src.icon_state
			src.icon_state = ""
			src.icon = 'b_items.dmi'
			flick(text("[]", t), src)
			spawn(14)
				del(src)
				return
			return
		return 0
	return 1
*/ //TODO FIX

/obj/item/clothing/gloves/examine()
	set src in usr
	..()
	return

/obj/item/clothing/gloves/latex/attackby(obj/item/weapon/cable_coil/O as obj, loc)
	if (istype(O) && O.amount==1)
		var/obj/item/latexballon/LB = new
		if (usr.get_inactive_hand()==src)
			usr.before_take_item(src)
			usr.put_in_inactive_hand(LB)
		else
			LB.loc = src.loc
		del(O)
		del(src)
	else
		return ..()


/obj/item/clothing/shoes/orange/attack_self(mob/user as mob)
	if (src.chained)
		src.chained = null
		src.slowdown = SHOES_SLOWDOWN
		new /obj/item/weapon/handcuffs( user.loc )
		src.icon_state = "orange"
	return

/obj/item/clothing/shoes/orange/attackby(H as obj, loc)
	..()
	if ((istype(H, /obj/item/weapon/handcuffs) && !( src.chained )))
		//H = null
		del(H)
		src.chained = 1
		src.slowdown = 15
		src.icon_state = "orange1"
	return

/obj/item/clothing/mask/muzzle/attack_paw(mob/user as mob)
	if (src == user.wear_mask)
		return
	else
		..()
	return

/obj/item/clothing/head/cakehat/var/processing = 0

/obj/item/clothing/head/cakehat/process()
	if(!onfire)
		processing_objects.Remove(src)
		return

	var/turf/location = src.loc
	if(istype(location, /mob/))
		var/mob/living/carbon/human/M = location
		if(M.l_hand == src || M.r_hand == src || M.head == src)
			location = M.loc

	if (istype(location, /turf))
		location.hotspot_expose(700, 1)


/obj/item/clothing/head/cakehat/attack_self(mob/user as mob)
	if(status > 1)	return
	src.onfire = !( src.onfire )
	if (src.onfire)
		src.force = 3
		src.damtype = "fire"
		src.icon_state = "cake1"

		processing_objects.Add(src)

	else
		src.force = null
		src.damtype = "brute"
		src.icon_state = "cake0"
	return


/obj/item/clothing/under/chameleon/New()
	..()

	for(var/U in typesof(/obj/item/clothing/under/color)-(/obj/item/clothing/under/color))

		var/obj/item/clothing/under/V = new U
		src.clothing_choices += V

	for(var/U in typesof(/obj/item/clothing/under/rank)-(/obj/item/clothing/under/rank))

		var/obj/item/clothing/under/V = new U
		src.clothing_choices += V

	return


/obj/item/clothing/under/chameleon/all/New()
	..()

	var/blocked = list(/obj/item/clothing/under/chameleon, /obj/item/clothing/under/chameleon/all)
	//to prevent an infinite loop

	for(var/U in typesof(/obj/item/clothing/under)-blocked)

		var/obj/item/clothing/under/V = new U
		src.clothing_choices += V



/obj/item/clothing/under/chameleon/attackby(obj/item/clothing/under/U as obj, mob/user as mob)
	..()

	if(istype(U, /obj/item/clothing/under/chameleon))
		user << "\red Nothing happens."
		return

	if(istype(U, /obj/item/clothing/under))

		if(src.clothing_choices.Find(U))
			user << "\red Pattern is already recognised by the suit."
			return

		src.clothing_choices += U

		user << "\red Pattern absorbed by the suit."

/obj/item/clothing/under/chameleon/verb/change()
	set name = "Change Color"
	set category = "Object"
	set src in usr

	if(icon_state == "psyche")
		usr << "\red Your suit is malfunctioning"
		return

	var/obj/item/clothing/under/A

	A = input("Select Colour to change it to", "BOOYEA", A) in clothing_choices

	if(!A)
		return

	permeability_coefficient = 0.90

	name = A.name
	desc = A.desc
	icon_state = A.icon_state
	item_state = A.item_state
	usr.update_clothing()
	color = A.color

/obj/item/clothing/under/chameleon/emp_act(severity)
	name = "Groovy Jumpsuit"
	desc = "A groovy jumpsuit! It seems to have a small dial on the wrist, that won't stop spinning."
	icon_state = "psyche"
	color = "psyche"
	spawn(200)
		name = "Black Jumpsuit"
		icon_state = "bl_suit"
		color = "black"
		desc = null
	..()

/obj/item/clothing/under/chameleon/psyche/emp_act(severity)
	return

/*
/obj/item/clothing/suit/swat_suit/death_commando
	name = "Death Commando Suit"
	icon_state = "death_commando_suit"
	item_state = "death_commando_suit"
	flags = FPRINT | TABLEPASS | SUITSPACE*/

/obj/item/clothing/mask/gas/death_commando
	name = "Death Commando Mask"
	icon_state = "death_commando_mask"
	item_state = "death_commando_mask"

/obj/item/clothing/under/rank/New()
	sensor_mode = pick(0,1,2,3)
	..()

/obj/item/clothing/under/verb/toggle()
	set name = "Toggle Suit Sensors"
	set category = "Object"
	var/mob/M = usr
	if (istype(M, /mob/dead/)) return
	if (usr.stat) return
	if(src.has_sensor >= 2)
		usr << "The controls are locked."
		return 0
	if(src.has_sensor <= 0)
		usr << "This suit does not have any sensors"
		return 0
	src.sensor_mode += 1
	if(src.sensor_mode > 3)
		src.sensor_mode = 0
	switch(src.sensor_mode)
		if(0)
			usr << "You disable your suit's remote sensing equipment."
		if(1)
			usr << "Your suit will now report whether you are live or dead."
		if(2)
			usr << "Your suit will now report your vital lifesigns."
		if(3)
			usr << "Your suit will now report your vital lifesigns as well as your coordinate position."
	..()

/obj/item/clothing/under/examine()
	set src in view()
	..()
	switch(src.sensor_mode)
		if(0)
			usr << "Its sensors appear to be disabled."
		if(1)
			usr << "Its binary life sensors appear to be enabled."
		if(2)
			usr << "Its vital tracker appears to be enabled."
		if(3)
			usr << "Its vital tracker and tracking beacon appear to be enabled."


/obj/item/clothing/head/helmet/welding/attack_self()
	toggle()

/obj/item/clothing/head/helmet/welding/verb/toggle()
	set category = "Object"
	set name = "Adjust welding mask"
	if(src.up)
		src.up = !src.up
		src.see_face = !src.see_face
		src.flags |= HEADCOVERSEYES
		icon_state = "welding"
		usr << "You flip the mask down to protect your eyes."
	else
		src.up = !src.up
		src.see_face = !src.see_face
		src.flags &= ~HEADCOVERSEYES
		icon_state = "weldingup"
		usr << "You push the mask up out of your face."
	usr.update_clothing()

/obj/item/clothing/shoes/magboots/verb/toggle()
	set name = "Toggle Magboots"
	set category = "Object"
	if(src.magpulse)
		src.flags &= ~NOSLIP
		src.slowdown = SHOES_SLOWDOWN
		src.magpulse = 0
		icon_state = "magboots0"
		usr << "You disable the mag-pulse traction system."
	else
		src.flags |= NOSLIP
		src.slowdown = 2
		src.magpulse = 1
		icon_state = "magboots1"
		usr << "You enable the mag-pulse traction system."

/obj/item/clothing/shoes/magboots/examine()
	set src in view()
	..()
	var/state = "disabled"
	if(src.flags&NOSLIP)
		state = "enabled"
	usr << "Its mag-pulse traction system appears to be [state]."

/obj/item/clothing/suit/lawyer/verb/toggle()
	set name = "Toggle Jacket Buttons"
	set category = "Object"
	if(src.icon_state == "suitjacket_blue_open")
		src.icon_state = "suitjacket_blue"
		src.item_state = "suitjacket_blue"
		usr << "You button up the suit jacket."
	else if(src.icon_state == "suitjacket_blue")
		src.icon_state = "suitjacket_blue_open"
		src.item_state = "suitjacket_blue_open"
		usr << "You unbutton the suit jacket."
	else
		usr << "Sorry! The suit you're wearing doesn't have buttons!"
	usr.update_clothing()

/obj/item/clothing/suit/storage/labcoat/verb/toggle()
	set name = "Toggle Labcoat Buttons"
	set category = "Object"
	if(src.icon_state == "labcoat_open")
		src.icon_state = "labcoat"
		usr << "You button up the labcoat."
	else if(src.icon_state == "labcoat")
		src.icon_state = "labcoat_open"
		usr << "You unbutton the labcoat."
	else if(src.icon_state == "labcoat_cmo_open")
		src.icon_state = "labcoat_cmo"
		usr << "You button up the labcoat."
	else if(src.icon_state == "labcoat_cmo")
		src.icon_state = "labcoat_cmo_open"
		usr << "You unbutton the labcoat."
	else if(src.icon_state == "labcoat_gen_open")
		src.icon_state = "labcoat_gen"
		usr << "You button up the labcoat."
	else if(src.icon_state == "labcoat_gen")
		src.icon_state = "labcoat_gen_open"
		usr << "You unbutton the labcoat."
	else if(src.icon_state == "labcoat_chem_open")
		src.icon_state = "labcoat_chem"
		usr << "You button up the labcoat."
	else if(src.icon_state == "labcoat_chem")
		src.icon_state = "labcoat_chem_open"
		usr << "You unbutton the labcoat."
	else if(src.icon_state == "labcoat_vir_open")
		src.icon_state = "labcoat_vir"
		usr << "You button up the labcoat."
	else if(src.icon_state == "labcoat_vir")
		src.icon_state = "labcoat_vir_open"
		usr << "You unbutton the labcoat."
	else if(src.icon_state == "labcoat_tox_open")
		src.icon_state = "labcoat_tox"
		usr << "You button up the labcoat."
	else if(src.icon_state == "labcoat_tox")
		src.icon_state = "labcoat_tox_open"
		usr << "You unbutton the labcoat."
	else if(src.icon_state == "labgreen_open")
		src.icon_state = "labgreen"
		usr << "You button up the labcoat."
	else if(src.icon_state == "labgreen")
		src.icon_state = "labgreen_open"
		usr << "You unbutton the labcoat."
	else if(src.icon_state == "labcoat_pink_open")
		src.icon_state = "labcoat_pink"
		usr << "You button up the labcoat."
	else if(src.icon_state == "labcoat_pink")
		src.icon_state = "labcoat_pink_open"
		usr << "You unbutton the labcoat."
	else if(src.icon_state == "labcoat_sleeve_open")
		src.icon_state = "labcoat_sleeve"
		usr << "You button up the labcoat."
	else if(src.icon_state == "labcoat_sleeve")
		src.icon_state = "labcoat_sleeve_open"
		usr << "You unbutton the labcoat."

	else
		usr << "Sorry! The suit you're wearing doesn't have buttons!"
	usr.update_clothing()

/obj/item/clothing/head/ushanka/attack_self(mob/user as mob)
	if(src.icon_state == "ushankadown")
		src.icon_state = "ushankaup"
		src.item_state = "ushankaup"
		user << "You raise the ear flaps on the ushanka."
	else
		src.icon_state = "ushankadown"
		src.item_state = "ushankadown"
		user << "You lower the ear flaps on the ushanka."


/obj/item/clothing/glasses/thermal/emp_act(severity)
	if(istype(src.loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = src.loc
		M << "\red The Optical Thermal Scanner overloads and blinds you!"
		if(M.glasses == src)
			M.eye_blind = 3
			M.eye_blurry = 5
			M.disabilities |= 1
			spawn(100)
				M.disabilities &= ~1
	..()


