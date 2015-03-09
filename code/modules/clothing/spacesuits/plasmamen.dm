// PLASMEN SHIT
// CAN'T WEAR UNLESS YOU'RE A PINK SKELLINGTON
/obj/item/clothing/suit/space/plasmaman
	name = "plasmaman suit"
	desc = "A special containment suit designed to protect a plasmaman's volatile body from outside exposure and quickly extinguish it in emergencies."
	w_class = 3
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs,/obj/item/weapon/tank)
	slowdown = 2
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 0)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = list("Plasmaman")
	flags = FPRINT  | PLASMAGUARD
	pressure_resistance = 40 * ONE_ATMOSPHERE //we can't change, so some resistance is needed

	icon_state = "plasmaman_suit"
	item_state = "plasmaman_suit"

	var/next_extinguish=0
	var/extinguish_cooldown=10 SECONDS
	var/extinguishes_left=10 // Yeah yeah, reagents, blah blah blah.  This should be simple.

/obj/item/clothing/suit/space/plasmaman/examine(mob/user)
	..()
	user << "<span class='info'>There are [extinguishes_left] extinguisher canisters left in this suit.</span>"

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
	name = "plasmaman helmet"
	desc = "A special containment helmet designed to protect a plasmaman's volatile body from outside exposure and quickly extinguish it in emergencies."
	flags = FPRINT | PLASMAGUARD
	pressure_resistance = 40 * ONE_ATMOSPHERE
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
	if(on)	user.SetLuminosity(user.luminosity + brightness_on)
	else	user.SetLuminosity(user.luminosity - brightness_on)
	user.update_inv_head()

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
	name = "plasmaman assistant suit"
	icon_state = "plasmamanAssistant_suit"
	slowdown = 1

/obj/item/clothing/head/helmet/space/plasmaman/assistant
	name = "plasmaman assistant helmet"
	icon_state = "plasmamanAssistant_helmet0"
	base_state = "plasmamanAssistant_helmet"

/obj/item/clothing/suit/space/plasmaman/atmostech
	name = "plasmaman atmospheric suit"
	icon_state = "plasmamanAtmos_suit"
	armor = list(melee = 20, bullet = 0, laser = 0,energy = 0, bomb = 25, bio = 100, rad = 0)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/head/helmet/space/plasmaman/atmostech
	name = "plasmaman atmospheric helmet"
	icon_state = "plasmamanAtmos_helmet0"
	base_state = "plasmamanAtmos_helmet"
	armor = list(melee = 20, bullet = 0, laser = 0,energy = 0, bomb = 25, bio = 100, rad = 0)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/space/plasmaman/engineer
	name = "plasmaman engineer suit"
	icon_state = "plasmamanEngineer_suit"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 80)
	pressure_resistance = 200 * ONE_ATMOSPHERE
	slowdown = 1

/obj/item/clothing/head/helmet/space/plasmaman/engineer
	name = "plasmaman engineer helmet"
	icon_state = "plasmamanEngineer_helmet0"
	base_state = "plasmamanEngineer_helmet"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 80)
	pressure_resistance = 200 * ONE_ATMOSPHERE

/obj/item/clothing/suit/space/plasmaman/engineer/ce
	name = "plasmaman chief engineer suit"
	icon_state = "plasmaman_CE"
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/head/helmet/space/plasmaman/engineer/ce
	name = "plasmaman chief engineer helmet"
	icon_state = "plasmaman_CE_helmet0"
	base_state = "plasmaman_CE_helmet"
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE


//SERVICE

/obj/item/clothing/suit/space/plasmaman/botanist
	name = "plasmaman botanist suit"
	icon_state = "plasmamanBotanist_suit"
	slowdown = 1

/obj/item/clothing/head/helmet/space/plasmaman/botanist
	name = "plasmaman botanist helmet"
	icon_state = "plasmamanBotanist_helmet0"
	base_state = "plasmamanBotanist_helmet"

/obj/item/clothing/suit/space/plasmaman/chaplain
	name = "plasmaman chaplain suit"
	icon_state = "plasmamanChaplain_suit"
	slowdown = 1

/obj/item/clothing/head/helmet/space/plasmaman/chaplain
	name = "plasmaman chaplain helmet"
	icon_state = "plasmamanChaplain_helmet0"
	base_state = "plasmamanChaplain_helmet"
	
/obj/item/clothing/suit/space/plasmaman/clown
	name = "plasmaman clown suit"
	icon_state = "plasmaman_Clown"
	slowdown = 1

/obj/item/clothing/head/helmet/space/plasmaman/clown
	name = "plasmaman clown helmet"
	icon_state = "plasmaman_Clown_helmet0"
	base_state = "plasmaman_Clown_helmet"
	
/obj/item/clothing/suit/space/plasmaman/mime
	name = "plasmaman mime suit"
	icon_state = "plasmaman_Mime"
	slowdown = 1

/obj/item/clothing/head/helmet/space/plasmaman/mime
	name = "plasmaman mime helmet"
	icon_state = "plasmaman_Mime_helmet0"
	base_state = "plasmaman_Mime_helmet"

/obj/item/clothing/suit/space/plasmaman/service
	name = "plasmaman service suit"
	icon_state = "plasmamanService_suit"
	slowdown = 1

/obj/item/clothing/head/helmet/space/plasmaman/service
	name = "plasmaman service helmet"
	icon_state = "plasmamanService_helmet0"
	base_state = "plasmamanService_helmet"

/obj/item/clothing/suit/space/plasmaman/janitor
	name = "plasmaman janitor suit"
	icon_state = "plasmamanJanitor_suit"
	slowdown = 1

/obj/item/clothing/head/helmet/space/plasmaman/janitor
	name = "plasmaman janitor helmet"
	icon_state = "plasmamanJanitor_helmet0"
	base_state = "plasmamanJanitor_helmet"


//CARGO

/obj/item/clothing/suit/space/plasmaman/cargo
	name = "plasmaman cargo suit"
	icon_state = "plasmamanCargo_suit"
	slowdown = 1

/obj/item/clothing/head/helmet/space/plasmaman/cargo
	name = "plasmaman cargo helmet"
	icon_state = "plasmamanCargo_helmet0"
	base_state = "plasmamanCargo_helmet"

/obj/item/clothing/suit/space/plasmaman/miner
	name = "plasmaman miner suit"
	icon_state = "plasmamanMiner_suit"
	armor = list(melee = 30, bullet = 5, laser = 15,energy = 5, bomb = 30, bio = 100, rad = 20)

/obj/item/clothing/head/helmet/space/plasmaman/miner
	name = "plasmaman miner helmet"
	icon_state = "plasmamanMiner_helmet0"
	base_state = "plasmamanMiner_helmet"
	armor = list(melee = 30, bullet = 5, laser = 15,energy = 5, bomb = 30, bio = 100, rad = 20)


// MEDSCI

/obj/item/clothing/suit/space/plasmaman/medical
	name = "plasmaman medical suit"
	icon_state = "plasmamanMedical_suit"
	slowdown = 1

/obj/item/clothing/head/helmet/space/plasmaman/medical
	name = "plasmaman medical helmet"
	icon_state = "plasmamanMedical_helmet0"
	base_state = "plasmamanMedical_helmet"

/obj/item/clothing/suit/space/plasmaman/medical/paramedic
	name = "plasmaman paramedic suit"
	icon_state = "plasmaman_Paramedic"
	slowdown = 1

/obj/item/clothing/head/helmet/space/plasmaman/medical/paramedic
	name = "plasmaman paramedic helmet"
	icon_state = "plasmaman_Paramedic_helmet0"
	base_state = "plasmaman_Paramedic_helmet"

/obj/item/clothing/suit/space/plasmaman/medical/chemist
	name = "plasmaman chemist suit"
	icon_state = "plasmaman_Chemist"
	slowdown = 1

/obj/item/clothing/head/helmet/space/plasmaman/medical/chemist
	name = "plasmaman chemist helmet"
	icon_state = "plasmaman_Chemist_helmet0"
	base_state = "plasmaman_Chemist_helmet"

/obj/item/clothing/suit/space/plasmaman/medical/cmo
	name = "plasmaman chief medical officer suit"
	icon_state = "plasmaman_CMO"

/obj/item/clothing/head/helmet/space/plasmaman/medical/cmo
	name = "plasmaman chief medical officer helmet"
	icon_state = "plasmaman_CMO_helmet0"
	base_state = "plasmaman_CMO_helmet"

/obj/item/clothing/suit/space/plasmaman/science
	name = "plasmaman scientist suit"
	icon_state = "plasmamanScience_suit"
	slowdown = 1

/obj/item/clothing/head/helmet/space/plasmaman/science
	name = "plasmaman scientist helmet"
	icon_state = "plasmamanScience_helmet0"
	base_state = "plasmamanScience_helmet"

/obj/item/clothing/suit/space/plasmaman/science/rd
	name = "plasmaman research director suit"
	icon_state = "plasmaman_RD"

/obj/item/clothing/head/helmet/space/plasmaman/science/rd
	name = "plasmaman research director helmet"
	icon_state = "plasmaman_RD_helmet0"
	base_state = "plasmaman_RD_helmet"


//SECURITY

/obj/item/clothing/suit/space/plasmaman/security
	name = "plasmaman security suit"
	icon_state = "plasmamanSecurity_suit"
	slowdown = 1
	armor = list(melee = 40, bullet = 15, laser = 35,energy = 5, bomb = 35, bio = 100, rad = 20)

/obj/item/clothing/head/helmet/space/plasmaman/security
	name = "plasmaman security helmet"
	icon_state = "plasmamanSecurity_helmet0"
	base_state = "plasmamanSecurity_helmet"
	armor = list(melee = 40, bullet = 15, laser = 35,energy = 5, bomb = 35, bio = 100, rad = 20)

/obj/item/clothing/suit/space/plasmaman/security/hos
	name = "plasmaman head of security suit"
	icon_state = "plasmaman_HoS"

/obj/item/clothing/head/helmet/space/plasmaman/security/hos
	name = "plasmaman head of security helmet"
	icon_state = "plasmaman_HoS_helmet0"
	base_state = "plasmaman_HoS_helmet"

/obj/item/clothing/suit/space/plasmaman/security/hop
	name = "plasmaman head of personnel suit"
	icon_state = "plasmaman_HoP"

/obj/item/clothing/head/helmet/space/plasmaman/security/hop
	name = "plasmaman head of personnel helmet"
	icon_state = "plasmaman_HoP_helmet0"
	base_state = "plasmaman_HoP_helmet"

/obj/item/clothing/suit/space/plasmaman/security/captain
	name = "plasmaman captain suit"
	icon_state = "plasmaman_Captain"

/obj/item/clothing/head/helmet/space/plasmaman/security/captain
	name = "plasmaman captain helmet"
	icon_state = "plasmaman_Captain_helmet0"
	base_state = "plasmaman_Captain_helmet"

//NUKEOPS

/obj/item/clothing/suit/space/plasmaman/nuclear
	name = "blood red plasmaman suit"
	icon_state = "plasmaman_Nukeops"
	slowdown = 1
	armor = list(melee = 60, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 60)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/gun,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs)
	siemens_coefficient = 0.6

/obj/item/clothing/head/helmet/space/plasmaman/nuclear
	name = "blood red plasmaman helmet"
	icon_state = "plasmaman_Nukeops_helmet0"
	base_state = "plasmaman_Nukeops_helmet"
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 35, bio = 100, rad = 60)
	siemens_coefficient = 0.6
	var/obj/machinery/camera/camera

/obj/item/clothing/head/helmet/space/plasmaman/nuclear/attack_self(mob/user)
	if(camera)
		..(user)
	else
		camera = new /obj/machinery/camera(src)
		camera.network = list("NUKE")
		cameranet.removeCamera(camera)
		camera.c_tag = user.name
		user << "<span class='notice'>User scanned as [camera.c_tag]. Camera activated.</span>"

/obj/item/clothing/head/helmet/space/plasmaman/nuclear/examine(mob/user)
	..()
	if(get_dist(user,src) <= 1)
		user << "<span class='info'>This helmet has a built-in camera. It's [camera ? "" : "in"]active.</span>"