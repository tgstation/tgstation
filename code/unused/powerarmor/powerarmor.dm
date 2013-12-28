/*
 * File Updated to match /tg/station code standards on the 28/12/2013 (UK/GMT) by RobRichards
 */

/obj/item/clothing/suit/space/powered
	name = "Powered armor"
	desc = "Not for rookies."
	icon_state = "swat"
	item_state = "swat"
	w_class = 4//bulky item


	flags = FPRINT | TABLEPASS | STOPSPRESSUREDMAGE | THICKMATERIAL
	body_parts_covered = CHEST|LEGS|FEET|ARMS
	armor = list(melee = 40, bullet = 30, laser = 20,energy = 15, bomb = 25, bio = 10, rad = 10)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/gun,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 9
	var/fuel = 0

	var/list/togglearmor = list(melee = 90, bullet = 70, laser = 60,energy = 40, bomb = 75, bio = 75, rad = 75)
	var/active = 0

	var/helmrequired = 1
	var/obj/item/clothing/head/space/powered/helm

	var/glovesrequired = 0
	var/obj/item/clothing/gloves/powered/gloves

	var/shoesrequired = 0
	var/obj/item/clothing/shoes/powered/shoes
	//Adding gloves and shoes as possible armor components. --NEO

	var/obj/item/powerarmor/servos/servos
	var/obj/item/powerarmor/reactive/reactive
	var/obj/item/powerarmor/atmoseal/atmoseal
	var/obj/item/powerarmor/power/power

/obj/item/clothing/suit/space/powered/New()
	verbs += /obj/item/clothing/suit/space/powered/proc/poweron

/obj/item/clothing/suit/space/powered/proc/poweron()
	set category = "Object"
	set name = "Activate armor systems"

	var/mob/living/carbon/human/user = usr

	if(user.stat)
		return //if you're unconscious or dead, no dicking with your armor. --NEO

	if(!istype(user))
		user << "<span class='danger'>This suit was engineered for human use only.</span>"
		return

	if(user.wear_suit!=src)
		user << "<span class='danger'>The suit functions best if you are inside of it.</span>"
		return

	if(helmrequired && !istype(user.head, /obj/item/clothing/head/space/powered))
		user << "<span class='danger'>Helmet missing, unable to initiate power-on procedure.</span>"
		return

	if(glovesrequired && !istype(user.gloves, /obj/item/clothing/gloves/powered))
		user << "<span class='danger'>Gloves missing, unable to initiate power-on procedure.</span>"
		return

	if(shoesrequired && !istype(user.shoes, /obj/item/clothing/shoes/powered))
		user << "<span class='danger'>Shoes missing, unable to initiate power-on procedure.</span>"
		return

	if(active)
		user << "<span class='danger'>The suit is already on, you can't turn it on twice.</span>"
		return

	if(!power || !power.checkpower())
		user << "<span class='danger'>Powersource missing or depleted.</span>"
		return

	verbs -= /obj/item/clothing/suit/space/powered/proc/poweron

	user << "<span class='notice'>Suit interlocks engaged.</span>"
	if(helmrequired)
		helm = user.head
		helm.canremove = 0
	if(glovesrequired)
		gloves = user.gloves
		gloves.canremove = 0
	if(shoesrequired)
		shoes = user.shoes
		shoes.canremove = 0
	canremove = 0
	sleep(20)

	if(atmoseal)
		atmoseal.toggle()
		sleep(20)

	if(reactive)
		reactive.toggle()
		sleep(20)

	if(servos)
		servos.toggle()
		sleep(20)

	user << "<span class='notice'>All systems online.</span>"
	active = 1
	power.process()

	verbs += /obj/item/clothing/suit/space/powered/proc/poweroff


/obj/item/clothing/suit/space/powered/proc/poweroff()
	set category = "Object"
	set name = "Deactivate armor systems"
	powerdown() //BYOND doesn't seem to like it if you try using a proc with vars in it as a verb, hence this. --NEO

/obj/item/clothing/suit/space/powered/proc/powerdown(sudden = 0)

	var/delay = sudden?0:20

	var/mob/living/carbon/human/user = usr

	if(user.stat && !sudden)
		return //if you're unconscious or dead, no dicking with your armor. --NEO

	if(!active)
		return

	verbs -= /obj/item/clothing/suit/space/powered/proc/poweroff

	if(sudden)
		user << "<span class='danger'><B>Your armor loses power!</B></span>"

	if(servos)
		servos.toggle(sudden)
		sleep(delay)

	if(reactive)
		reactive.toggle(sudden)
		sleep(delay)

	if(atmoseal)
		if(istype(atmoseal, /obj/item/powerarmor/atmoseal/optional) && helm)
			var/obj/item/powerarmor/atmoseal/optional/Atmo_seal = atmoseal
			Atmo_seal.helmtoggle(sudden)
		atmoseal.toggle(sudden)

		sleep(delay)

	if(!sudden)
		usr << "<span class='notice'>Suit interlocks disengaged.</span>"
		if(helm)
			helm.canremove = 1
			helm = null
		if(gloves)
			gloves.canremove = 1
			gloves = null
		if(shoes)
			shoes.canremove = 1
			gloves = null
		canremove = 1
		//Not a tabbing error, the thing only unlocks if you intentionally power-down the armor. --NEO
	sleep(delay)

	if(!sudden)
		usr << "<span class='notice'>All systems disengaged.</span>"

	active = 0
	verbs += /obj/item/clothing/suit/space/powered/proc/poweron



/obj/item/clothing/suit/space/powered/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(power && istype(power,/obj/item/powerarmor/power/plasma))
		var/obj/item/powerarmor/power/plasma/Plasma_power = power
		switch(W.type)
			if(/obj/item/stack/sheet/mineral/plasma)
				var/obj/item/stack/sheet/mineral/plasma/P = W
				if(fuel < 50)
					user << "<span class='notice'>You feed some refined plasma into the armor's generator.</span>"
					Plasma_power.fuel += 25
					P.amount--
					if (P.amount <= 0)
						del(P)
					return
				else
					user << "<span class='danger'>The generator already has plenty of plasma.</span>"
					return

			if(/obj/item/weapon/ore/plasma) //raw plasma has impurities, so it doesn't provide as much fuel. --NEO
				if(fuel < 50)
					user << "<span class='notice'>You feed some plasma into the armor's generator.</span>"
					Plasma_power.fuel += 15
					del(W)
					return
				else
					user << "<span class='danger'>The generator already has plenty of plasma.</span>"
					return

		..()

/obj/item/clothing/head/space/powered
	name = "Powered armor"
	icon_state = "swat"
	desc = "Not for rookies."
	flags = FPRINT | TABLEPASS | HEADCOVERSEYES | HEADCOVERSMOUTH | STOPSPRESSUREDMAGE | THICKMATERIAL | BLOCKHAIR
	item_state = "swat"
	armor = list(melee = 40, bullet = 30, laser = 20,energy = 15, bomb = 25, bio = 10, rad = 10)
	var/obj/item/clothing/suit/space/powered/parent

/obj/item/clothing/head/space/powered/proc/atmotoggle()
	set category = "Object"
	set name = "Toggle helmet seals"

	var/mob/living/carbon/human/user = usr

	if(!istype(user))
		user << "<span class='danger'>This helmet is engineered for human use.</span>"
		return
	if(user.head != src)
		user << "<span class='danger'>Can't engage the seals without wearing the helmet.</span>"
		return

	if(!user.wear_suit || !istype(user.wear_suit,/obj/item/clothing/suit/space/powered))
		user << "<span class='danger'>This helmet can only couple with powered armor.</span>"
		return

	var/obj/item/clothing/suit/space/powered/armor = user.wear_suit

	if(!armor.atmoseal || !istype(armor.atmoseal, /obj/item/powerarmor/atmoseal/optional))
		user << "<span class='danger'>This armor's atmospheric seals are missing or incompatible.</span>"
		return

	armor.atmoseal:helmtoggle(0,1)



/obj/item/clothing/gloves/powered
	name = "Powered armor"
	icon_state = "swat"
	desc = "Not for rookies."
	flags = FPRINT | TABLEPASS
	item_state = "swat"
	armor = list(melee = 40, bullet = 30, laser = 20,energy = 15, bomb = 25, bio = 10, rad = 10)

/obj/item/clothing/shoes/powered
	name = "Powered armor"
	icon_state = "swat"
	desc = "Not for rookies."
	flags = FPRINT | TABLEPASS
	item_state = "swat"
	armor = list(melee = 40, bullet = 30, laser = 20,energy = 15, bomb = 25, bio = 10, rad = 10)


obj/item/clothing/suit/space/powered/spawnable/badmin/New()
	servos = new /obj/item/powerarmor/servos(src)
	servos.parent = src
	reactive = new /obj/item/powerarmor/reactive(src)
	reactive.parent = src
	atmoseal = new /obj/item/powerarmor/atmoseal/optional/adminbus(src)
	atmoseal.parent = src
	power = new /obj/item/powerarmor/power(src)
	power.parent = src

	verbs += /obj/item/clothing/suit/space/powered/proc/poweron

	var/obj/item/clothing/head/space/powered/helm = new /obj/item/clothing/head/space/powered(src.loc)
	helm.verbs += /obj/item/clothing/head/space/powered/proc/atmotoggle

obj/item/clothing/suit/space/powered/spawnable/regular/New()
	servos = new /obj/item/powerarmor/servos(src)
	servos.parent = src
	reactive = new /obj/item/powerarmor/reactive/Centcom(src)
	reactive.parent = src
	atmoseal = new /obj/item/powerarmor/atmoseal/optional/adminbus(src)
	atmoseal.parent = src
	power = new /obj/item/powerarmor/power(src)
	power.parent = src

	verbs += /obj/item/clothing/suit/space/powered/proc/poweron

	var/obj/item/clothing/head/space/powered/helm = new /obj/item/clothing/head/space/powered(src.loc)
	helm.verbs += /obj/item/clothing/head/space/powered/proc/atmotoggle
