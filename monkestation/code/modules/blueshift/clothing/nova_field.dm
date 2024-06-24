/obj/item/clothing/under/rank/expeditionary_corps
	name = "expeditionary corps uniform"
	desc = "A rugged uniform for those who see the worst at the edges of the galaxy."
	icon_state = "exp_corps"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/uniforms.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/uniform.dmi'
	armor_type = /datum/armor/clothing_under/rank_expeditionary_corps
	strip_delay = 7 SECONDS
	alt_covers_chest = TRUE
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/datum/armor/clothing_under/rank_expeditionary_corps
	fire = 15
	acid = 15

/obj/item/storage/belt/military/expeditionary_corps
	name = "expeditionary corps chest rig"
	desc = "A set of tactical webbing worn by the now-defunct Vanguard Expeditionary Corps."
	icon_state = "webbing_exp_corps"
	worn_icon_state = "webbing_exp_corps"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/belts.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/belt.dmi'
	uses_advanced_reskins = TRUE
	unique_reskin = list(
		"Webbing" = list(
			RESKIN_ICON_STATE = "webbing_exp_corps",
			RESKIN_WORN_ICON_STATE = "webbing_exp_corps"
		),
		"Belt" = list(
			RESKIN_ICON_STATE = "belt_exp_corps",
			RESKIN_WORN_ICON_STATE = "belt_exp_corps"
		),
	)

/obj/item/storage/belt/military/expeditionary_corps/combat_tech
	name = "combat tech's chest rig"

/obj/item/storage/belt/military/expeditionary_corps/combat_tech/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/wirecutters(src)
	new /obj/item/multitool(src)
	new /obj/item/stack/cable_coil(src)

/obj/item/storage/belt/military/expeditionary_corps/field_medic
	name = "field medic's chest rig"

/obj/item/storage/belt/military/expeditionary_corps/field_medic/PopulateContents()
	new /obj/item/scalpel(src)
	new /obj/item/circular_saw/field_medic(src)
	new /obj/item/hemostat(src)
	new /obj/item/retractor(src)
	new /obj/item/cautery(src)
	new /obj/item/surgical_drapes(src)
	new /obj/item/bonesetter(src)

/obj/item/storage/belt/military/expeditionary_corps/pointman
	name = "pointman's chest rig"

/obj/item/storage/belt/military/expeditionary_corps/pointman/PopulateContents()
	new /obj/item/reagent_containers/cup/glass/bottle/whiskey(src)
	new /obj/item/stack/sheet/plasteel(src,5)
	new /obj/item/reagent_containers/cup/bottle/morphine(src)

/obj/item/storage/belt/military/expeditionary_corps/marksman
	name = "marksman's chest rig"

/obj/item/storage/belt/military/expeditionary_corps/marksman/PopulateContents()
	new /obj/item/binoculars(src)
	new /obj/item/storage/fancy/cigarettes/cigpack_robust(src)
	new /obj/item/lighter(src)
	new /obj/item/clothing/mask/bandana/skull(src)

/obj/item/clothing/shoes/combat/expeditionary_corps
	name = "expeditionary corps boots"
	desc = "High speed, low drag combat boots."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	icon_state = "exp_corps"
	inhand_icon_state = "jackboots"

/obj/item/clothing/gloves/color/black/expeditionary_corps
	name = "expeditionary corps gloves"
	icon_state = "exp_corps"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/hands.dmi'
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	uses_advanced_reskins = FALSE
	unique_reskin = NONE

/obj/item/clothing/gloves/chief_engineer/expeditionary_corps
	name = "expeditionary corps insulated gloves"
	icon_state = "exp_corps_eng"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/hands.dmi'
	worn_icon_state = "exp_corps"
	resistance_flags = FIRE_PROOF
	armor_type = /datum/armor/chief_engineer_expeditionary_corps

/datum/armor/chief_engineer_expeditionary_corps
	fire = 80
	acid = 50

/obj/item/clothing/gloves/latex/nitrile/expeditionary_corps
	name = "expeditionary corps medic gloves"
	icon_state = "exp_corps_med"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/hands.dmi'
	worn_icon_state = "exp_corps"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	armor_type = /datum/armor/nitrile_expeditionary_corps

/datum/armor/nitrile_expeditionary_corps
	fire = 80
	acid = 50

/obj/item/storage/backpack/duffelbag/expeditionary_corps
	name = "expeditionary corps bag"
	desc = "A large bag for holding extra tactical supplies."
	icon_state = "exp_corps"
	inhand_icon_state = "backpack"
	icon = 'monkestation/code/modules/blueshift/icons/backpack.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob_backpack.dmi'
	uses_advanced_reskins = TRUE
	unique_reskin = list(
		"Backpack" = list(
			RESKIN_ICON_STATE = "exp_corps",
			RESKIN_WORN_ICON_STATE = "exp_corps"
		),
		"Belt" = list(
			RESKIN_ICON_STATE = "exp_corps_satchel",
			RESKIN_WORN_ICON_STATE = "exp_corps_satchel"
		),
	)

/obj/item/clothing/suit/armor/vest/expeditionary_corps
	name = "expeditionary corps armor vest"
	desc = "An armored vest that provides okay protection against most types of damage. Includes concealable sleeves for your arms."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suits/armor.dmi'
	icon_state = "exp_corps"
	body_parts_covered = CHEST|GROIN|ARMS
	armor_type = /datum/armor/vest_expeditionary_corps
	cold_protection = CHEST|GROIN|ARMS
	heat_protection = CHEST|GROIN|ARMS
	dog_fashion = null
	allowed = list(
		/obj/item/melee,
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/flashlight,
		/obj/item/gun,
		/obj/item/knife,
		/obj/item/reagent_containers,
		/obj/item/restraints/handcuffs,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/storage/belt/holster,
		)


/datum/armor/vest_expeditionary_corps
	melee = 30
	bullet = 30
	laser = 30
	energy = 30
	bomb = 40
	fire = 80
	acid = 100
	wound = 10

/obj/item/clothing/head/helmet/expeditionary_corps
	name = "expeditionary corps helmet"
	desc = "A robust helmet worn by Expeditionary Corps troopers. Alt+click it to toggle the NV system."
	icon_state = "exp_corps"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head/helmet.dmi'
	armor_type = /datum/armor/helmet_expeditionary_corps
	var/nightvision = FALSE
	var/mob/living/carbon/current_user
	actions_types = list(/datum/action/item_action/toggle_nv)

/datum/armor/helmet_expeditionary_corps
	melee = 20
	bullet = 20
	laser = 20
	energy = 20
	bomb = 30
	fire = 80
	acid = 100
	wound = 10

/datum/action/item_action/toggle_nv
	name = "Toggle Nightvision"

/datum/action/item_action/toggle_nv/Trigger(trigger_flags)
	var/obj/item/clothing/head/helmet/expeditionary_corps/my_helmet = target
	if(!my_helmet.current_user)
		return
	my_helmet.nightvision = !my_helmet.nightvision
	if(my_helmet.nightvision)
		to_chat(owner, span_notice("You flip the NV goggles down."))
		my_helmet.enable_nv()
	else
		to_chat(owner, span_notice("You flip the NV goggles up."))
		my_helmet.disable_nv()
	my_helmet.update_appearance()

/obj/item/clothing/head/helmet/expeditionary_corps/equipped(mob/user, slot)
	. = ..()
	current_user = user

/obj/item/clothing/head/helmet/expeditionary_corps/proc/enable_nv(mob/user)
	if(current_user)
		var/obj/item/organ/internal/eyes/my_eyes = current_user.get_organ_by_type(/obj/item/organ/internal/eyes)
		if(my_eyes)
			my_eyes.color_cutoffs = list(10, 30, 10)
			my_eyes.flash_protect = FLASH_PROTECTION_SENSITIVE
		current_user.add_client_colour(/datum/client_colour/glass_colour/lightgreen)

/obj/item/clothing/head/helmet/expeditionary_corps/proc/disable_nv()
	if(current_user)
		var/obj/item/organ/internal/eyes/my_eyes = current_user.get_organ_by_type(/obj/item/organ/internal/eyes)
		if(my_eyes)
			my_eyes.color_cutoffs = initial(my_eyes.color_cutoffs)
			my_eyes.flash_protect = initial(my_eyes.flash_protect)
		current_user.remove_client_colour(/datum/client_colour/glass_colour/lightgreen)
		current_user.update_sight()

/obj/item/clothing/head/helmet/expeditionary_corps/AltClick(mob/user)
	if(!current_user)
		return

	nightvision = !nightvision
	if(nightvision)
		to_chat(user, span_notice("You flip the NV goggles down."))
		enable_nv()
	else
		to_chat(user, span_notice("You flip the NV goggles up."))
		disable_nv()
	update_appearance()
	return

/obj/item/clothing/head/helmet/expeditionary_corps/dropped(mob/user)
	. = ..()
	disable_nv()
	current_user = null

/obj/item/clothing/head/helmet/expeditionary_corps/Destroy()
	disable_nv()
	current_user = null
	return ..()

/obj/item/clothing/head/helmet/expeditionary_corps/update_icon_state()
	. = ..()
	if(nightvision)
		icon_state = "exp_corps_on"
	else
		icon_state = "exp_corps"
