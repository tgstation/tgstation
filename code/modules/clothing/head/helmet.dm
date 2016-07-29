<<<<<<< HEAD
/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "Standard Security gear. Protects the head from impacts."
	icon_state = "helmet"
	flags = HEADBANGPROTECT
	item_state = "helmet"
	armor = list(melee = 40, bullet = 30, laser = 30,energy = 10, bomb = 25, bio = 0, rad = 0)
	flags_inv = HIDEEARS
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	strip_delay = 60
	burn_state = FIRE_PROOF
	flags_cover = HEADCOVERSEYES

	dog_fashion = /datum/dog_fashion/head/helmet


/obj/item/clothing/head/helmet/New()
	..()

/obj/item/clothing/head/helmet/emp_act(severity)
	..()

/obj/item/clothing/head/helmet/sec
	can_flashlight = 1

/obj/item/clothing/head/helmet/alt
	name = "bulletproof helmet"
	desc = "A bulletproof combat helmet that excels in protecting the wearer against traditional projectile weaponry and explosives to a minor extent."
	icon_state = "helmetalt"
	item_state = "helmetalt"
	armor = list(melee = 15, bullet = 40, laser = 10, energy = 10, bomb = 40, bio = 0, rad = 0)
	can_flashlight = 1
	dog_fashion = null

/obj/item/clothing/head/helmet/blueshirt
	icon_state = "blueshift"
	item_state = "blueshift"

/obj/item/clothing/head/helmet/riot
	name = "riot helmet"
	desc = "It's a helmet specifically designed to protect against close range attacks."
	icon_state = "riot"
	item_state = "helmet"
	toggle_message = "You pull the visor down on"
	alt_toggle_message = "You push the visor up on"
	can_toggle = 1
	flags = HEADBANGPROTECT
	armor = list(melee = 41, bullet = 15, laser = 5,energy = 5, bomb = 5, bio = 2, rad = 0)
	flags_inv = HIDEEARS|HIDEFACE
	strip_delay = 80
	actions_types = list(/datum/action/item_action/toggle)
	visor_flags_inv = HIDEFACE
	toggle_cooldown = 0
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	dog_fashion = null

/obj/item/clothing/head/helmet/attack_self(mob/user)
	if(can_toggle && !user.incapacitated())
		if(world.time > cooldown + toggle_cooldown)
			cooldown = world.time
			up = !up
			flags ^= visor_flags
			flags_inv ^= visor_flags_inv
			flags_cover ^= visor_flags_cover
			icon_state = "[initial(icon_state)][up ? "up" : ""]"
			user << "[up ? alt_toggle_message : toggle_message] \the [src]"

			user.update_inv_head()
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.head_update(src, forced = 1)

			if(active_sound)
				while(up)
					playsound(src.loc, "[active_sound]", 100, 0, 4)
					sleep(15)

/obj/item/clothing/head/helmet/justice
	name = "helmet of justice"
	desc = "WEEEEOOO. WEEEEEOOO. WEEEEOOOO."
	icon_state = "justice"
	toggle_message = "You turn off the lights on"
	alt_toggle_message = "You turn on the lights on"
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	can_toggle = 1
	toggle_cooldown = 20
	active_sound = 'sound/items/WEEOO1.ogg'
	dog_fashion = null

/obj/item/clothing/head/helmet/justice/escape
	name = "alarm helmet"
	desc = "WEEEEOOO. WEEEEEOOO. STOP THAT MONKEY. WEEEOOOO."
	icon_state = "justice2"
	toggle_message = "You turn off the light on"
	alt_toggle_message = "You turn on the light on"

/obj/item/clothing/head/helmet/swat
	name = "\improper SWAT helmet"
	desc = "An extremely robust, space-worthy helmet in a nefarious red and black stripe pattern."
	icon_state = "swatsyndie"
	item_state = "swatsyndie"
	armor = list(melee = 40, bullet = 30, laser = 30,energy = 30, bomb = 50, bio = 90, rad = 20)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	flags = STOPSPRESSUREDMAGE
	strip_delay = 80
	dog_fashion = null

/obj/item/clothing/head/helmet/swat/nanotrasen
	name = "\improper SWAT helmet"
	desc = "An extremely robust, space-worthy helmet with the Nanotrasen logo emblazoned on the top."
	icon_state = "swat"
	item_state = "swat"

/obj/item/clothing/head/helmet/thunderdome
	name = "\improper Thunderdome helmet"
	desc = "<i>'Let the battle commence!'</i>"
	flags_inv = HIDEEARS|HIDEHAIR
	icon_state = "thunderdome"
	item_state = "thunderdome"
	armor = list(melee = 40, bullet = 30, laser = 25,energy = 10, bomb = 25, bio = 10, rad = 0)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	strip_delay = 80
	dog_fashion = null

/obj/item/clothing/head/helmet/roman
	name = "roman helmet"
	desc = "An ancient helmet made of bronze and leather."
	flags_inv = HIDEEARS|HIDEHAIR
	flags_cover = HEADCOVERSEYES
	armor = list(melee = 25, bullet = 0, laser = 25, energy = 10, bomb = 10, bio = 0, rad = 0)
	icon_state = "roman"
	item_state = "roman"
	strip_delay = 100
	dog_fashion = null

/obj/item/clothing/head/helmet/roman/legionaire
	name = "roman legionaire helmet"
	desc = "An ancient helmet made of bronze and leather. Has a red crest on top of it."
	icon_state = "roman_c"
	item_state = "roman_c"

/obj/item/clothing/head/helmet/gladiator
	name = "gladiator helmet"
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	item_state = "gladiator"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR
	flags_cover = HEADCOVERSEYES
	dog_fashion = null

/obj/item/clothing/head/helmet/redtaghelm
	name = "red laser tag helmet"
	desc = "They have chosen their own end."
	icon_state = "redtaghelm"
	flags_cover = HEADCOVERSEYES
	item_state = "redtaghelm"
	armor = list(melee = 15, bullet = 10, laser = 20,energy = 10, bomb = 20, bio = 0, rad = 0)
	// Offer about the same protection as a hardhat.
	dog_fashion = null

/obj/item/clothing/head/helmet/bluetaghelm
	name = "blue laser tag helmet"
	desc = "They'll need more men."
	icon_state = "bluetaghelm"
	flags_cover = HEADCOVERSEYES
	item_state = "bluetaghelm"
	armor = list(melee = 15, bullet = 10, laser = 20,energy = 10, bomb = 20, bio = 0, rad = 0)
	// Offer about the same protection as a hardhat.
	dog_fashion = null

/obj/item/clothing/head/helmet/knight
	name = "medieval helmet"
	desc = "A classic metal helmet."
	icon_state = "knight_green"
	item_state = "knight_green"
	armor = list(melee = 41, bullet = 15, laser = 5,energy = 5, bomb = 5, bio = 2, rad = 0)
	flags = null
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	strip_delay = 80
	dog_fashion = null

/obj/item/clothing/head/helmet/knight/blue
	icon_state = "knight_blue"
	item_state = "knight_blue"

/obj/item/clothing/head/helmet/knight/yellow
	icon_state = "knight_yellow"
	item_state = "knight_yellow"

/obj/item/clothing/head/helmet/knight/red
	icon_state = "knight_red"
	item_state = "knight_red"

/obj/item/clothing/head/helmet/knight/templar
	name = "crusader helmet"
	desc = "Deus Vult."
	icon_state = "knight_templar"
	item_state = "knight_templar"

/obj/item/clothing/head/helmet/skull
	name = "skull helmet"
	desc = "An intimidating tribal helmet, it doesn't look very comfortable."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	flags_cover = HEADCOVERSEYES
	armor = list(melee = 25, bullet = 25, laser = 25, energy = 10, bomb = 10, bio = 5, rad = 20)
	icon_state = "skull"
	item_state = "skull"
	strip_delay = 100

//LightToggle

/obj/item/clothing/head/helmet/update_icon()

	var/state = "[initial(icon_state)]"
	if(F)
		if(F.on)
			state += "-flight-on" //"helmet-flight-on" // "helmet-cam-flight-on"
		else
			state += "-flight" //etc.

	icon_state = state

	if(istype(loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc
		H.update_inv_head()

	return

/obj/item/clothing/head/helmet/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/toggle_helmet_flashlight)
		toggle_helmlight()
	else
		..()

/obj/item/clothing/head/helmet/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/flashlight/seclite))
		var/obj/item/device/flashlight/seclite/S = I
		if(can_flashlight)
			if(!F)
				if(!user.unEquip(S))
					return
				user << "<span class='notice'>You click [S] into place on [src].</span>"
				if(S.on)
					SetLuminosity(0)
				F = S
				S.loc = src
				update_icon()
				update_helmlight(user)
				verbs += /obj/item/clothing/head/helmet/proc/toggle_helmlight
				var/datum/action/A = new /datum/action/item_action/toggle_helmet_flashlight(src)
				if(loc == user)
					A.Grant(user)
		return

	if(istype(I, /obj/item/weapon/screwdriver))
		if(F)
			for(var/obj/item/device/flashlight/seclite/S in src)
				user << "<span class='notice'>You unscrew the seclite from [src].</span>"
				F = null
				S.loc = get_turf(user)
				update_helmlight(user)
				S.update_brightness(user)
				update_icon()
				usr.update_inv_head()
				verbs -= /obj/item/clothing/head/helmet/proc/toggle_helmlight
			for(var/datum/action/item_action/toggle_helmet_flashlight/THL in actions)
				qdel(THL)
			return

	..()

/obj/item/clothing/head/helmet/proc/toggle_helmlight()
	set name = "Toggle Helmetlight"
	set category = "Object"
	set desc = "Click to toggle your helmet's attached flashlight."

	if(!F)
		return

	var/mob/user = usr
	if(user.incapacitated())
		return
	if(!isturf(user.loc))
		user << "<span class='warning'>You cannot turn the light on while in this [user.loc]!</span>"
	F.on = !F.on
	user << "<span class='notice'>You toggle the helmetlight [F.on ? "on":"off"].</span>"

	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_helmlight(user)
	return

/obj/item/clothing/head/helmet/proc/update_helmlight(mob/user = null)
	if(F)
		if(F.on)
			if(loc == user)
				user.AddLuminosity(F.brightness_on)
			else if(isturf(loc))
				SetLuminosity(F.brightness_on)
		else
			if(loc == user)
				user.AddLuminosity(-F.brightness_on)
			else if(isturf(loc))
				SetLuminosity(0)
		update_icon()

	else
		if(loc == user)
			user.AddLuminosity(-5)
		else if(isturf(loc))
			SetLuminosity(0)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/head/helmet/pickup(mob/user)
	..()
	if(F)
		if(F.on)
			user.AddLuminosity(F.brightness_on)
			SetLuminosity(0)


/obj/item/clothing/head/helmet/dropped(mob/user)
	..()
	if(F)
		if(F.on)
			user.AddLuminosity(-F.brightness_on)
			SetLuminosity(F.brightness_on)
=======
/obj/item/clothing/head/helmet
	name = "helmet"
	icon_state = "helmet_sec"
	item_state = "helmet"
	flags = FPRINT
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	body_parts_covered = HEAD|EARS|EYES
	heat_conductivity = HELMET_HEAT_CONDUCTIVITY
	max_heat_protection_temperature = HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.7

/obj/item/clothing/head/helmet/siren
	name = "siren helmet"
	desc = "For the officer that's off patrolling all the nation."
	icon_state = "helmetgoofy" //Sprites courtesy of Blithering
	light_power = 2.5
	light_range = 4
	light_color = LIGHT_COLOR_RED
	action_button_name = "Activate Siren"
	var/spamcheck = 0

/obj/item/clothing/head/helmet/siren/attack_self(mob/user)
	if(spamcheck)
		return
	playsound(get_turf(src), 'sound/voice/woopwoop.ogg', 100, 1, vary = 0)
	user.visible_message("<span class='warning'>[user]'s [name] rasps, \"WOOP WOOP!\"</span>", \
						"<span class='warning'>Your [name] rasps, \"WOOP WOOP!\"</span>", \
						"<span class='warning'>You hear a siren: \"WOOP WOOP!\"</span>")

	var/list/bystanders = get_hearers_in_view(world.view, src)
	flick_overlay(image('icons/mob/talk.dmi', user, "hail", MOB_LAYER+1), clients_in_moblist(bystanders), 15)
	spamcheck = 1
	spawn(15)
		spamcheck = 0

/obj/item/clothing/head/helmet/dredd //same stats as /obj/item/clothing/head/helmet/tactical/swat
	name = "Judge Helmet"
	desc = "Judge, Jury, and Executioner."
	icon_state = "dredd-helmet"
	item_state = "dredd-helmet"
	flags = FPRINT
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	heat_conductivity = INS_HELMET_HEAT_CONDUCTIVITY
	species_fit = list()
	pressure_resistance = 200 * ONE_ATMOSPHERE
	siemens_coefficient = 0.5
	eyeprot = 1

/obj/item/clothing/head/helmet/thunderdome
	name = "\improper Thunderdome helmet"
	desc = "<i>'Let the battle commence!'</i>"
	icon_state = "thunderdome"
	flags = FPRINT
	item_state = "thunderdome"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/gladiator
	name = "gladiator helmet"
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	flags = FPRINT
	item_state = "gladiator"
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/roman
	name = "roman helmet"
	desc = "An ancient helmet made of bronze and leather."
	armor = list(melee = 20, bullet = 0, laser = 20, energy = 10, bomb = 10, bio = 0, rad = 0)
	icon_state = "roman"
	item_state = "roman"

/obj/item/clothing/head/helmet/roman/legionaire
	name = "roman legionaire helmet"
	desc = "An ancient helmet made of bronze and leather. Has a red crest on top of it."
	armor = list(melee = 25, bullet = 0, laser = 25, energy = 10, bomb = 10, bio = 0, rad = 0)
	icon_state = "roman_c"
	item_state = "roman_c"

/obj/item/clothing/head/helmet/hopcap
	name = "Head of Personnel's Cap"
	desc = "Papers, Please."
	armor = list(melee = 25, bullet = 0, laser = 15, energy = 10, bomb = 5, bio = 0, rad = 0)
	item_state = "hopcap"
	icon_state = "hopcap"
	body_parts_covered = HEAD

/obj/item/clothing/head/helmet/aviatorhelmet
	name = "Aviator Helmet"
	desc = "Help the Bombardier!"
	armor = list(melee = 25, bullet = 0, laser = 20, energy = 10, bomb = 10, bio = 0, rad = 0)
	item_state = "aviator_helmet"
	icon_state = "aviator_helmet"
	species_restricted = list("exclude",VOX_SHAPED)

/obj/item/clothing/head/helmet/piratelord
	name = "pirate lord's helmet"
	desc = "The headwear of an all powerful and bloodthirsty pirate lord. Simply looking at it sends chills down your spine."
	armor = list(melee = 75, bullet = 75, laser = 75,energy = 75, bomb = 75, bio = 100, rad = 90)
	icon_state = "piratelord"

/obj/item/clothing/head/helmet/biker
	name = "Biker's Helmet"
	desc = "This helmet should protect you from russians and masked vigilantes."
	armor = list(melee = 25, bullet = 15, laser = 20, energy = 10, bomb = 10, bio = 0, rad = 0)
	icon_state = "biker_helmet"
	body_parts_covered = FULL_HEAD

/obj/item/clothing/head/helmet/richard
	name = "Richard"
	desc = "Do you like hurting people?"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	icon_state = "richard"
	body_parts_covered = FULL_HEAD|BEARD

/obj/item/clothing/head/helmet/megahelmet
	name = "DRN-001 Helmet"
	desc = "The helmet of the DRN-001 model. A simple, sturdy blue helmet."
	icon_state = "megahelmet"
	flags = FPRINT
	item_state = "megahelmet"
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/protohelmet
	name = "Prototype Helmet"
	desc = "Shiny red helmet with white accents and a built in shaded visor that does absolutely nothing, nothing but look rad as hell."
	icon_state = "protohelmet"
	flags = FPRINT
	item_state = "protohelmet"
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/breakhelmet
	name = "Broken Helmet"
	desc = "The product of twelve years of work by an eccentric and brilliant loner. A helmet belonging to the perfect man; an unbeatable machine."
	icon_state = "breakhelmet"
	flags = FPRINT
	body_parts_covered = FULL_HEAD|BEARD
	item_state = "breakhelmet"
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/megaxhelmet
	name = "Maverick Hunter Helmet"
	desc = "Heavily armored upgrade to the DRN-001 model's helmet, now comes with a pointless red crystal thing!"
	icon_state = "megaxhelmet"
	flags = FPRINT
	item_state = "megaxhelmet"
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/volnutthelmet
	name = "Digouter Helmet"
	desc = "A sturdy helmet, fortified to protect from falling rocks or buster shots"
	icon_state = "volnutthelmet"
	flags = FPRINT
	item_state = "volnutthelmet"
	armor = list(melee = 50, bullet = 40, laser = 40,energy = 40, bomb = 5, bio = 0, rad = 0)
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/joehelmet
	name = "Sniper Helmet"
	desc = "Helmet belonging to one of the many mass produced 'Joe' type robots."
	icon_state = "joehelmet"
	flags = FPRINT
	body_parts_covered = FULL_HEAD|BEARD
	item_state = "joehelmet"
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/doomguy
	name = "Doomguy's helmet"
	desc = ""
	icon_state = "doom"
	flags = FPRINT
	item_state = "doom"
	armor = list(melee = 50, bullet = 40, laser = 40,energy = 40, bomb = 5, bio = 0, rad = 0)
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/knight
	name = "medieval helmet"
	desc = "A classic metal helmet."
	icon_state = "knight_green"
	item_state = "knight_green"
	body_parts_covered = FULL_HEAD|BEARD
	armor = list(melee = 20, bullet = 5, laser = 2,energy = 2, bomb = 2, bio = 2, rad = 0)
	flags = FPRINT
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/knight/blue
	icon_state = "knight_blue"
	item_state = "knight_blue"

/obj/item/clothing/head/helmet/knight/yellow
	icon_state = "knight_yellow"
	item_state = "knight_yellow"

/obj/item/clothing/head/helmet/knight/red
	icon_state = "knight_red"
	item_state = "knight_red"

/obj/item/clothing/head/helmet/knight/templar
	name = "crusader helmet"
	desc = "Deus Vult."
	icon_state = "knight_templar"
	item_state = "knight_templar"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
