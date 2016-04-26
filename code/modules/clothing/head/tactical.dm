/obj/item/clothing/head/helmet/tactical
	action_button_name = "Toggle Helmet Light"
	light_power = 1.5
	var/obj/item/device/flashlight/flashlight = null
	var/preattached = FALSE

/obj/item/clothing/head/helmet/tactical/New()
	..()
	if(preattached)
		flashlight = new /obj/item/device/flashlight/tactical(src)
	update_brightness()

/obj/item/clothing/head/helmet/tactical/examine(mob/user)
	..()
	if(src.flashlight)
		to_chat(user, "The helmet is mounted with a flashlight attachment, it is [flashlight.on ? "":"un"]lit.")

/obj/item/clothing/head/helmet/tactical/attackby(var/obj/item/I, mob/user, params)
	if(!src.flashlight && (I.type == /obj/item/device/flashlight || istype(I,/obj/item/device/flashlight/tactical))) //have to directly check for type because flashlights are the base type and not a child
		user.drop_item(I, src)
		flashlight = I

		update_brightness()
		user.update_action_buttons()
		user.update_inv_head()
		return
	if(isscrewdriver(I) && src.flashlight)
		flashlight.forceMove(get_turf(src))
		flashlight.update_brightness(user, playsound = FALSE)
		flashlight = null

		update_brightness()
		user.update_action_buttons()
		user.update_inv_head()
		return
	return ..()

obj/item/clothing/head/helmet/tactical/attack_self(mob/user)
	if(src.flashlight)
		flashlight.on = !flashlight.on
		if(get_turf(src))
			if(flashlight.on)
				playsound(get_turf(src), flashlight.sound_on, 50, 1)
			else
				playsound(get_turf(src), flashlight.sound_off, 50, 1)
	update_brightness()
	user.update_inv_head()

/obj/item/clothing/head/helmet/tactical/proc/update_brightness()
	if(flashlight && flashlight.on)
		set_light(flashlight.brightness_on)
	else
		set_light(0)
	update_icon()

/obj/item/clothing/head/helmet/tactical/update_icon()
	if(flashlight)
		icon_state = "[initial(icon_state)]_[flashlight.on]"
		action_button_name = "Toggle Helmet Light"
	else
		icon_state = initial(icon_state)
		action_button_name = null

/obj/item/clothing/head/helmet/tactical/sec
	name = "tactical helmet"
	desc = "Standard Security gear. Protects the head from impacts. Can be attached with a flashlight."
	icon_state = "helmet_sec"
	//we don't actually have anything special here because our parent, /obj/item/clothing/head/helmet, is already the default sec helmet...
/obj/item/clothing/head/helmet/tactical/sec/preattached
	preattached = 1

/obj/item/clothing/head/helmet/tactical/HoS
	name = "Head of Security Hat"
	desc = "The hat of the Head of Security. For showing the officers who's in charge."
	icon_state = "hoscap"
	flags = FPRINT
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)
	body_parts_covered = HEAD
	siemens_coefficient = 0.8

/obj/item/clothing/head/helmet/tactical/HoS/dermal
	name = "Dermal Armour Patch"
	desc = "You're not quite sure how you manage to take it on and off, but it implants nicely in your head."
	icon_state = "dermal"
	item_state = "dermal"
	siemens_coefficient = 0.6

/obj/item/clothing/head/helmet/tactical/warden
	name = "warden's hat"
	desc = "It's a special helmet issued to the Warden of a security force. Protects the head from impacts."
	icon_state = "policehelm"
	body_parts_covered = HEAD

/obj/item/clothing/head/helmet/tactical/riot
	name = "riot helmet"
	desc = "It's a helmet specifically designed to protect against close range attacks."
	icon_state = "riot"
	flags = FPRINT
	armor = list(melee = 82, bullet = 15, laser = 5,energy = 5, bomb = 5, bio = 2, rad = 0)
	siemens_coefficient = 0.7
	eyeprot = 1

/obj/item/clothing/head/helmet/tactical/swat
	name = "\improper SWAT helmet"
	desc = "They're often used by highly trained Swat Members."
	icon_state = "swat"
	flags = FPRINT
	item_state = "swat"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	heat_conductivity = INS_HELMET_HEAT_CONDUCTIVITY
	species_fit = list("Vox")
	pressure_resistance = 200 * ONE_ATMOSPHERE
	siemens_coefficient = 0.5
	eyeprot = 1
