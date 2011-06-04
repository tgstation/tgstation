/*
CONTAINS:
ORANGE SHOES
MUZZLE
CAKEHAT
SUNGLASSES
SWAT SUIT
CHAMELEON JUMPSUIT
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
		processing_items.Remove(src)
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

		processing_items.Add(src)

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

	desc = null
	permeability_coefficient = 0.90

	desc = A.desc
	name = A.name
	icon_state = A.icon_state
	item_state = A.item_state
	color = A.color

/obj/item/clothing/under/chameleon/emp_act(severity)
	name = "psychedelic"
	desc = "Groovy!"
	icon_state = "psyche"
	color = "psyche"
	spawn(200)
		name = "Black Jumpsuit"
		icon_state = "bl_suit"
		color = "black"
		desc = null
	..()

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

/obj/item/clothing/suit/armor/powered
	name = "Powered armor"
	desc = "Not for rookies."
	icon_state = "swat"
	item_state = "swat"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	heat_transfer_coefficient = 0.02
	radiation_protection = 0.25
	protective_temperature = 1000
	flags = FPRINT | TABLEPASS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
	armor = list(melee = 40, bullet = 30, laser = 20, taser = 15, bomb = 25, bio = 10, rad = 10)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/gun,/obj/item/weapon/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 9
	var/fuel = 0
	var/list/togglearmor = list(melee = 90, bullet = 30, laser = 60, taser = 40, bomb = 75, bio = 75, rad = 75)
	var/active = 0
	var/obj/item/clothing/head/helmet/powered/helm = null

	New()
		verbs += /obj/item/clothing/suit/armor/powered/proc/poweron

	proc/poweron()
		set category = "Object"
		set name = "Activate armor systems"

		var/mob/living/carbon/human/user = usr

		if(user.stat)
			return //if you're unconscious or dead, no dicking with your armor. --NEO

		if(!istype(user))
			user << "\red This suit was engineered for human use only."
			return

		if(user.wear_suit!=src)
			user << "\red The suit functions best if you are inside of it."
			return

		if(!istype(user.head, /obj/item/clothing/head/helmet/powered))
			user << "\red Helmet missing, unable to initiate power-on procedure."
			return

		if(active)
			user << "\red The suit is already on, you can't turn it on twice."
			return

		if(fuel < 1)
			user << "\red Insufficient fuel."
			return

		verbs -= /obj/item/clothing/suit/armor/powered/proc/poweron

		user << "\blue Suit interlocks engaged."
		helm = user.head
		helm.canremove = 0
		canremove = 0
		sleep(20)

		user << "\blue Atmospheric seals engaged."
		flags |= SUITSPACE
		helm.flags |= HEADSPACE
		sleep(20)

		user << "\blue Reactive armor systems engaged."
		var/list/switchover = list()
		for (var/armorvar in togglearmor)
			switchover[armorvar] = "[togglearmor[armorvar]]"
			togglearmor[armorvar] = "[armor[armorvar]]"
			armor[armorvar] = "[switchover[armorvar]]"
			helm.armor[armorvar] = armor[armorvar]
		sleep(20)

		user << "\blue Movement assist servos engaged."
		slowdown = 2.5
		sleep(20)

		user << "\blue All systems online."
		active = 1
		powered()
		verbs += /obj/item/clothing/suit/armor/powered/proc/poweroff


	proc/poweroff()
		set category = "Object"
		set name = "Deactivate armor systems"
		powerdown() //BYOND doesn't seem to like it if you try using a proc with vars in it as a verb, hence this. --NEO

	proc/powerdown(sudden = 0)

		var/delay = sudden?0:20

		var/mob/living/carbon/human/user = usr

		if(user.stat && !sudden)
			return //if you're unconscious or dead, no dicking with your armor. --NEO

		if(!active)
			return

		verbs -= /obj/item/clothing/suit/armor/powered/proc/poweroff

		if(sudden)
			user << "\red Your armor loses power!"

		if(!sudden)
			user << "\blue Movement assist servos disengaged."
		slowdown = 9
		sleep(delay)


		if(!sudden)
			user << "\blue Reactive armor systems disengaged."
		var/list/switchover = list()
		for (var/armorvar in armor)
			switchover[armorvar] = "[togglearmor[armorvar]]"
			togglearmor[armorvar] = "[armor[armorvar]]"
			armor[armorvar] = "[switchover[armorvar]]"
			helm.armor[armorvar] = armor[armorvar]
		sleep(delay)

		if(!sudden)
			user << "\blue Atmospheric seals disengaged."
		flags &= ~SUITSPACE
		helm.flags &= ~HEADSPACE
		sleep(delay)

		if(!sudden)
			user << "\blue Suit interlocks disengaged."
			helm.canremove = 1
			canremove = 1
			helm = null
			//Not a tabbing error, the thing only unlocks if you intentionally power-down the armor. --NEO
		sleep(20)

		if(!sudden)
			user << "\blue All systems disengaged."
		active = 0


		verbs += /obj/item/clothing/suit/armor/powered/proc/poweron

	proc/powered()
		if (fuel > 0 && active)
			fuel--
			spawn(50)
				powered()
			return
		else if (active)
			powerdown(1)
			return

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W, /obj/item/stack/sheet/plasma))
			if(fuel < 50)
				user << "\blue You feed some plasma into the armor's generator."
				fuel += 25
				W:amount--
				if (W:amount <= 0)
					del(W)
				return
			else
				user << "\red The generator already has plenty of plasma."
				return
		else
			..()


/obj/item/clothing/head/helmet/powered
	name = "Powered armor helmet"
	icon_state = "swat"
	desc = "Not for rookies."
	flags = FPRINT | TABLEPASS | HEADCOVERSEYES | HEADCOVERSMOUTH
	see_face = 0.0
	item_state = "swat"
	permeability_coefficient = 0.01
	armor = list(melee = 40, bullet = 30, laser = 20, taser = 15, bomb = 25, bio = 10, rad = 10)
