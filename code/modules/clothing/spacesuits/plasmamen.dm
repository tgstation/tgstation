// PLASMEN SHIT
// CAN'T WEAR UNLESS YOU'RE A PINK SKELLINGTON
/obj/item/clothing/suit/space/plasmaman
	w_class = 3
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs,/obj/item/weapon/tank)
	slowdown = 2
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 0)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECITON_TEMPERATURE
	species_restricted = list("Plasmaman")
	flags = FPRINT | TABLEPASS | STOPSPRESSUREDMAGE | PLASMAGUARD

	icon_state = "plasmaman_suit"
	item_state = "plasmaman_suit"

	var/next_extinguish=0
	var/extinguish_cooldown=10 SECONDS
	var/extinguishes_left=10 // Yeah yeah, reagents, blah blah blah.  This should be simple.

/obj/item/clothing/suit/space/plasmaman/examine()
	set src in view()
	..()
	usr << "There are [extinguishes_left] extinguisher canisters left in this suit."
/obj/item/clothing/suit/space/plasmaman/proc/Extinguish(var/mob/user)
	var/mob/living/carbon/human/H=user
	if(extinguishes_left)
		if(next_extinguish > world.time)
			return

		next_extinguish = world.time + extinguish_cooldown
		extinguishes_left--
		H << "<span class='warning'>Your suit automatically extinguishes the fire.</span>"
		H.ExtinguishMob()

/obj/item/clothing/head/helmet/space/plasmaman
	flags = FPRINT | TABLEPASS | HEADCOVERSEYES | BLOCKHAIR | STOPSPRESSUREDMAGE | PLASMAGUARD
	species_restricted = list("Plasmaman")

	icon_state = "plasmaman_helmet0"
	item_state = "plasmaman_helmet0"
	var/base_state = "plasmaman_helmet"
	var/brightness_on = 4 //luminosity when on
	var/on = 0
	var/no_light=0 // Disable the light on the atmos suit
	action_button_name = "Toggle Helmet Light"

/obj/item/clothing/head/helmet/space/plasmaman/attack_self(mob/user)
	if(!isturf(user.loc))
		user << "You cannot turn the light on while in this [user.loc]" //To prevent some lighting anomalities.
		return
	if(no_light)
		return
	on = !on
	icon_state = "[base_state][on]"
//	item_state = "rig[on]-[_color]"
	if(on)	user.SetLuminosity(user.luminosity + brightness_on)
	else	user.SetLuminosity(user.luminosity - brightness_on)

/obj/item/clothing/head/helmet/space/plasmaman/pickup(mob/user)
	if(on)
		user.SetLuminosity(user.luminosity + brightness_on)
//		user.UpdateLuminosity()
		SetLuminosity(0)

/obj/item/clothing/head/helmet/space/plasmaman/dropped(mob/user)
	if(on)
		user.SetLuminosity(user.luminosity - brightness_on)
//		user.UpdateLuminosity()
		SetLuminosity(brightness_on)



// ENGINEERING
/obj/item/clothing/suit/space/plasmaman/assistant
	icon_state = "plasmamanAssistant_suit"

/obj/item/clothing/head/helmet/space/plasmaman/assistant
	icon_state = "plasmamanAssistant_helmet0"
	base_state = "plasmamanAssistant_helmet"

/obj/item/clothing/suit/space/plasmaman/atmostech
	icon_state = "plasmamanAtmos_suit"

/obj/item/clothing/head/helmet/space/plasmaman/atmostech
	icon_state = "plasmamanAtmos_helmet0"
	base_state = "plasmamanAtmos_helmet"

/obj/item/clothing/suit/space/plasmaman/engineer
	icon_state = "plasmamanEngineer_suit"

/obj/item/clothing/head/helmet/space/plasmaman/engineer
	icon_state = "plasmamanEngineer_helmet0"
	base_state = "plasmamanEngineer_helmet"


//SERVICE

/obj/item/clothing/suit/space/plasmaman/botanist
	icon_state = "plasmamanBotanist_suit"

/obj/item/clothing/head/helmet/space/plasmaman/botanist
	icon_state = "plasmamanBotanist_helmet0"
	base_state = "plasmamanBotanist_helmet"

/obj/item/clothing/suit/space/plasmaman/chaplain
	icon_state = "plasmamanChaplain_suit"

/obj/item/clothing/head/helmet/space/plasmaman/chaplain
	icon_state = "plasmamanChaplain_helmet0"
	base_state = "plasmamanChaplain_helmet"

/obj/item/clothing/suit/space/plasmaman/service
	icon_state = "plasmamanService_suit"

/obj/item/clothing/head/helmet/space/plasmaman/service
	icon_state = "plasmamanService_helmet0"
	base_state = "plasmamanService_helmet"

/obj/item/clothing/suit/space/plasmaman/janitor
	icon_state = "plasmamanJanitor_suit"

/obj/item/clothing/head/helmet/space/plasmaman/janitor
	icon_state = "plasmamanJanitor_helmet0"
	base_state = "plasmamanJanitor_helmet"


//CARGO

/obj/item/clothing/suit/space/plasmaman/cargo
	icon_state = "plasmamanCargo_suit"

/obj/item/clothing/head/helmet/space/plasmaman/cargo
	icon_state = "plasmamanCargo_helmet0"
	base_state = "plasmamanCargo_helmet"

/obj/item/clothing/suit/space/plasmaman/miner
	icon_state = "plasmamanMiner_suit"

/obj/item/clothing/head/helmet/space/plasmaman/miner
	icon_state = "plasmamanMiner_helmet0"
	base_state = "plasmamanMiner_helmet"


// MEDSCI

/obj/item/clothing/suit/space/plasmaman/medical
	icon_state = "plasmamanMedical_suit"

/obj/item/clothing/head/helmet/space/plasmaman/medical
	icon_state = "plasmamanMedical_helmet0"
	base_state = "plasmamanMedical_helmet"

/obj/item/clothing/suit/space/plasmaman/science
	icon_state = "plasmamanScience_suit"

/obj/item/clothing/head/helmet/space/plasmaman/science
	icon_state = "plasmamanScience_helmet0"
	base_state = "plasmamanScience_helmet"


//SECURITY

/obj/item/clothing/suit/space/plasmaman/security
	icon_state = "plasmamanSecurity_suit"

/obj/item/clothing/head/helmet/space/plasmaman/security
	icon_state = "plasmamanSecurity_helmet0"
	base_state = "plasmamanSecurity_helmet"