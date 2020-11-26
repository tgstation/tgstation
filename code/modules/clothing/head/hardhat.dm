/obj/item/clothing/head/hardhat
	name = "hard hat"
	desc = "A piece of headgear used in dangerous working conditions to protect the head. Comes with a built-in flashlight."
	icon_state = "hardhat0_yellow"
	inhand_icon_state = "hardhat0_yellow"
	armor = list(MELEE = 15, BULLET = 5, LASER = 20, ENERGY = 10, BOMB = 20, BIO = 10, RAD = 20, FIRE = 100, ACID = 50, WOUND = 10) // surprisingly robust against head trauma
	flags_inv = 0
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	clothing_flags = SNUG_FIT
	resistance_flags = FIRE_PROOF
	dynamic_hair_suffix = "+generic"
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 4
	light_power = 0.8
	light_on = FALSE
	dog_fashion = /datum/dog_fashion/head

	///Determines used sprites: `hardhat[on]_[hat_type]` and `hardhat[on]_[hat_type]2` (lying down sprite)
	var/hat_type = "yellow"
	///Whether the headlamp is on or off.
	var/on = FALSE


/obj/item/clothing/head/hardhat/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/clothing/head/hardhat/attack_self(mob/living/user)
	toggle_helmet_light(user)

/obj/item/clothing/head/hardhat/proc/toggle_helmet_light(mob/living/user)
	on = !on
	if(on)
		turn_on(user)
	else
		turn_off(user)
	update_icon()

/obj/item/clothing/head/hardhat/update_icon_state()
	icon_state = inhand_icon_state = "hardhat[on]_[hat_type]"

/obj/item/clothing/head/hardhat/proc/turn_on(mob/user)
	set_light_on(TRUE)

/obj/item/clothing/head/hardhat/proc/turn_off(mob/user)
	set_light_on(FALSE)

/obj/item/clothing/head/hardhat/orange
	icon_state = "hardhat0_orange"
	inhand_icon_state = "hardhat0_orange"
	hat_type = "orange"
	dog_fashion = null

/obj/item/clothing/head/hardhat/red
	icon_state = "hardhat0_red"
	inhand_icon_state = "hardhat0_red"
	hat_type = "red"
	dog_fashion = null
	name = "firefighter helmet"
	clothing_flags = STOPSPRESSUREDAMAGE
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT

/obj/item/clothing/head/hardhat/red/upgraded
	name = "workplace-ready firefighter helmet"
	desc = "By applying state of the art lighting technology to a fire helmet, and using photo-chemical hardening methods, this hardhat will protect you from robust workplace hazards."
	icon_state = "hardhat0_purple"
	inhand_icon_state = "hardhat0_purple"
	light_range = 5
	resistance_flags = FIRE_PROOF | ACID_PROOF
	custom_materials = list(/datum/material/iron = 4000, /datum/material/glass = 1000, /datum/material/plastic = 3000, /datum/material/silver = 500)
	hat_type = "purple"

/obj/item/clothing/head/hardhat/white
	icon_state = "hardhat0_white"
	inhand_icon_state = "hardhat0_white"
	hat_type = "white"
	clothing_flags = STOPSPRESSUREDAMAGE
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	dog_fashion = /datum/dog_fashion/head

/obj/item/clothing/head/hardhat/dblue
	icon_state = "hardhat0_dblue"
	inhand_icon_state = "hardhat0_dblue"
	hat_type = "dblue"
	dog_fashion = null

/obj/item/clothing/head/hardhat/atmos
	icon_state = "hardhat0_atmos"
	inhand_icon_state = "hardhat0_atmos"
	hat_type = "atmos"
	dog_fashion = null
	name = "atmospheric technician's firefighting helmet"
	desc = "A firefighter's helmet, able to keep the user cool in any situation."
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | BLOCK_GAS_SMOKE_EFFECT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF

/obj/item/clothing/head/hardhat/weldhat
	name = "welding hard hat"
	desc = "A piece of headgear used in dangerous working conditions to protect the head. Comes with a built-in flashlight AND welding shield! The bulb seems a little smaller though."
	light_range = 3 //Needs a little bit of tradeoff
	dog_fashion = null
	actions_types = list(/datum/action/item_action/toggle_helmet_light, /datum/action/item_action/toggle_welding_screen)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	flags_inv = HIDEEYES | HIDEFACE
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	visor_flags_inv = HIDEEYES | HIDEFACE
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF

/obj/item/clothing/head/hardhat/weldhat/Initialize()
	. = ..()
	update_icon()

/obj/item/clothing/head/hardhat/weldhat/attack_self(mob/living/user)
	toggle_helmet_light(user)

/obj/item/clothing/head/hardhat/weldhat/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE))
		toggle_welding_screen(user)

/obj/item/clothing/head/hardhat/weldhat/proc/toggle_welding_screen(mob/living/user)
	if(weldingvisortoggle(user))
		playsound(src, 'sound/mecha/mechmove03.ogg', 50, TRUE) //Visors don't just come from nothing
	update_icon()

/obj/item/clothing/head/hardhat/weldhat/worn_overlays(isinhands)
	. = ..()
	if(!isinhands)
		. += mutable_appearance('icons/mob/clothing/head.dmi', "weldhelmet")
		if(!up)
			. += mutable_appearance('icons/mob/clothing/head.dmi', "weldvisor")

/obj/item/clothing/head/hardhat/weldhat/update_overlays()
	. = ..()
	if(!up)
		. += "weldvisor"

/obj/item/clothing/head/hardhat/weldhat/orange
	icon_state = "hardhat0_orange"
	inhand_icon_state = "hardhat0_orange"
	hat_type = "orange"

/obj/item/clothing/head/hardhat/weldhat/white
	desc = "A piece of headgear used in dangerous working conditions to protect the head. Comes with a built-in flashlight AND welding shield!" //This bulb is not smaller
	icon_state = "hardhat0_white"
	inhand_icon_state = "hardhat0_white"
	light_range = 4 //Boss always takes the best stuff
	hat_type = "white"
	clothing_flags = STOPSPRESSUREDAMAGE
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT

/obj/item/clothing/head/hardhat/weldhat/dblue
	icon_state = "hardhat0_dblue"
	inhand_icon_state = "hardhat0_dblue"
	hat_type = "dblue"
