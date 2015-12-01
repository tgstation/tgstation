/obj/item/clothing/suit/powered
	name = "Powered armor"
	desc = "Not for rookies."
	icon_state = "swat"
	item_state = "swat"
	w_class = 4//bulky item

	protective_temperature = 1000
	flags = FPRINT | TABLEPASS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
	armor = list(melee = 40, bullet = 30, laser = 20,energy = 15, bomb = 25, bio = 10, rad = 10)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/gun,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 9
	var/fuel = 0

	var/list/togglearmor = list(melee = 90, bullet = 70, laser = 60,energy = 40, bomb = 75, bio = 75, rad = 75)
	var/active = 0

	var/helmrequired = 1
	var/obj/item/clothing/head/powered/helm

	var/glovesrequired = 0
	var/obj/item/clothing/gloves/powered/gloves

	var/shoesrequired = 0
	var/obj/item/clothing/shoes/powered/shoes
	//Adding gloves and shoes as possible armor components. --NEO

	var/obj/item/powerarmor/servos/servos
	var/obj/item/powerarmor/reactive/reactive
	var/obj/item/powerarmor/atmoseal/atmoseal
	var/obj/item/powerarmor/power/power

	New()
		verbs += /obj/item/clothing/suit/powered/proc/poweron

	proc/poweron()
		set category = "Object"
		set name = "Activate armor systems"

		var/mob/living/carbon/human/user = usr

		if(user.stat)
			return //if you're unconscious or dead, no dicking with your armor. --NEO

		if(!istype(user))
			to_chat(user, "<span class='warning'>This suit was engineered for human use only.</span>")
			return

		if(user.wear_suit!=src)
			to_chat(user, "<span class='warning'>The suit functions best if you are inside of it.</span>")
			return

		if(helmrequired && !istype(user.head, /obj/item/clothing/head/powered))
			to_chat(user, "<span class='warning'>Helmet missing, unable to initiate power-on procedure.</span>")
			return

		if(glovesrequired && !istype(user.gloves, /obj/item/clothing/gloves/powered))
			to_chat(user, "<span class='warning'>Gloves missing, unable to initiate power-on procedure.</span>")
			return

		if(shoesrequired && !istype(user.shoes, /obj/item/clothing/shoes/powered))
			to_chat(user, "<span class='warning'>Shoes missing, unable to initiate power-on procedure.</span>")
			return

		if(active)
			to_chat(user, "<span class='warning'>The suit is already on, you can't turn it on twice.</span>")
			return

		if(!power || !power.checkpower())
			to_chat(user, "<span class='warning'>Powersource missing or depleted.</span>")
			return

		verbs -= /obj/item/clothing/suit/powered/proc/poweron

		to_chat(user, "<span class='notice'>Suit interlocks engaged.</span>")
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

		to_chat(user, "<span class='notice'>All systems online.</span>")
		active = 1
		power.process()

		verbs += /obj/item/clothing/suit/powered/proc/poweroff


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

		verbs -= /obj/item/clothing/suit/powered/proc/poweroff

		if(sudden)
			to_chat(user, "<span class='warning'>Your armor loses power!</span>")

		if(servos)
			servos.toggle(sudden)
			sleep(delay)

		if(reactive)
			reactive.toggle(sudden)
			sleep(delay)

		if(atmoseal)
			if(istype(atmoseal, /obj/item/powerarmor/atmoseal/optional) && helm)
				atmoseal:helmtoggle(sudden)
			atmoseal.toggle(sudden)

			sleep(delay)

		if(!sudden)
			to_chat(usr, "<span class='notice'>Suit interlocks disengaged.</span>")
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
			to_chat(usr, "<span class='notice'>All systems disengaged.</span>")

		active = 0
		verbs += /obj/item/clothing/suit/powered/proc/poweron



	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(power && istype(power,/obj/item/powerarmor/power/plasma))
			switch(W.type)
				if(/obj/item/stack/sheet/mineral/plasma)
					if(fuel < 50)
						to_chat(user, "<span class='notice'>You feed some refined plasma into the armor's generator.</span>")
						power:fuel += 25
						W:amount--
						if (W:amount <= 0)
							del(W)
						return
					else
						to_chat(user, "<span class='warning'>The generator already has plenty of plasma.</span>")
						return

				if(/obj/item/weapon/ore/plasma) //raw plasma has impurities, so it doesn't provide as much fuel. --NEO
					if(fuel < 50)
						to_chat(user, "<span class='notice'>You feed some plasma into the armor's generator.</span>")
						power:fuel += 15
						del(W)
						return
					else
						to_chat(user, "<span class='warning'>The generator already has plenty of plasma.</span>")
						return

		..()

/obj/item/clothing/head/powered
	name = "Powered armor"
	icon_state = "swat"
	desc = "Not for rookies."
	flags = FPRINT | TABLEPASS | HEADCOVERSEYES | HEADCOVERSMOUTH
	see_face = 0.0
	item_state = "swat"
	armor = list(melee = 40, bullet = 30, laser = 20,energy = 15, bomb = 25, bio = 10, rad = 10)
	var/obj/item/clothing/suit/powered/parent

	proc/atmotoggle()
		set category = "Object"
		set name = "Toggle helmet seals"

		var/mob/living/carbon/human/user = usr

		if(!istype(user))
			to_chat(user, "<span class='warning'>This helmet is not rated for nonhuman use.</span>")
			return

		if(user.head != src)
			to_chat(user, "<span class='warning'>Can't engage the seals without wearing the helmet.</span>")
			return

		if(!user.wear_suit || !istype(user.wear_suit,/obj/item/clothing/suit/powered))
			to_chat(user, "<span class='warning'>This helmet can only couple with powered armor.</span>")
			return

		var/obj/item/clothing/suit/powered/armor = user.wear_suit

		if(!armor.atmoseal || !istype(armor.atmoseal, /obj/item/powerarmor/atmoseal/optional))
			to_chat(user, "<span class='warning'>This armor's atmospheric seals are missing or incompatible.</span>")
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


obj/item/clothing/suit/powered/spawnable/badmin
	New()
		servos = new /obj/item/powerarmor/servos(src)
		servos.parent = src
		reactive = new /obj/item/powerarmor/reactive(src)
		reactive.parent = src
		atmoseal = new /obj/item/powerarmor/atmoseal/optional/adminbus(src)
		atmoseal.parent = src
		power = new /obj/item/powerarmor/power(src)
		power.parent = src

		verbs += /obj/item/clothing/suit/powered/proc/poweron

		var/obj/item/clothing/head/powered/helm = new /obj/item/clothing/head/powered(src.loc)
		helm.verbs += /obj/item/clothing/head/powered/proc/atmotoggle

obj/item/clothing/suit/powered/spawnable/regular
	New()
		servos = new /obj/item/powerarmor/servos(src)
		servos.parent = src
		reactive = new /obj/item/powerarmor/reactive/centcomm(src)
		reactive.parent = src
		atmoseal = new /obj/item/powerarmor/atmoseal/optional/adminbus(src)
		atmoseal.parent = src
		power = new /obj/item/powerarmor/power(src)
		power.parent = src

		verbs += /obj/item/clothing/suit/powered/proc/poweron

		var/obj/item/clothing/head/powered/helm = new /obj/item/clothing/head/powered(src.loc)
		helm.verbs += /obj/item/clothing/head/powered/proc/atmotoggle
