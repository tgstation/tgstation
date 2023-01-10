/****************Explorer's Suit and Mask****************/
/obj/item/clothing/suit/hooded/explorer
	name = "explorer suit"
	desc = "An armoured suit for exploring harsh environments."
	icon_state = "explorer"
	icon = 'icons/obj/clothing/suits/utility.dmi'
	worn_icon = 'icons/mob/clothing/suits/utility.dmi'
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	cold_protection = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	hoodtype = /obj/item/clothing/head/hooded/explorer
	armor_type = /datum/armor/hooded_explorer
	allowed = list(
		/obj/item/flashlight,
		/obj/item/gun/energy/recharge/kinetic_accelerator,
		/obj/item/mining_scanner,
		/obj/item/pickaxe,
		/obj/item/resonator,
		/obj/item/storage/bag/ore,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/tank/internals,
		)
	resistance_flags = FIRE_PROOF

/datum/armor/hooded_explorer
	melee = 30
	bullet = 10
	laser = 10
	energy = 20
	bomb = 50
	fire = 50
	acid = 50

/obj/item/clothing/head/hooded/explorer
	name = "explorer hood"
	desc = "An armoured hood for exploring harsh environments."
	icon = 'icons/obj/clothing/head/utility.dmi'
	worn_icon = 'icons/mob/clothing/head/utility.dmi'
	icon_state = "explorer"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	armor_type = /datum/armor/hooded_explorer
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/hooded/explorer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)

/obj/item/clothing/head/hooded/explorer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)

/obj/item/clothing/mask/gas/explorer
	name = "explorer gas mask"
	desc = "A military-grade gas mask that can be connected to an air supply."
	icon_state = "gas_mining"
	inhand_icon_state = "explorer_gasmask"
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH
	visor_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	visor_flags_inv = HIDEFACIALHAIR
	visor_flags_cover = MASKCOVERSMOUTH
	actions_types = list(/datum/action/item_action/adjust)
	armor_type = /datum/armor/gas_explorer
	resistance_flags = FIRE_PROOF
	has_fov = FALSE

/datum/armor/gas_explorer
	melee = 10
	bullet = 5
	laser = 5
	energy = 5
	bio = 50
	fire = 20
	acid = 40
	wound = 5

/obj/item/clothing/mask/gas/explorer/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/gas/explorer/adjustmask(mob/user)
	. = ..()
	// adjusted = out of the way = smaller = can fit in boxes
	w_class = mask_adjusted ? WEIGHT_CLASS_SMALL : WEIGHT_CLASS_NORMAL
	inhand_icon_state = mask_adjusted ? "[initial(inhand_icon_state)]_up" : initial(inhand_icon_state)
	if(user)
		user.update_held_items()


/obj/item/clothing/mask/gas/explorer/examine(mob/user)
	. = ..()
	if(mask_adjusted || w_class == WEIGHT_CLASS_SMALL)
		return
	. += span_notice("You could fit this into a box if you adjusted it.")

/obj/item/clothing/mask/gas/explorer/folded
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/mask/gas/explorer/folded/Initialize(mapload)
	. = ..()
	adjustmask()

/obj/item/clothing/suit/hooded/cloak
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/hooded/cloak/goliath
	name = "goliath cloak"
	icon_state = "goliath_cloak"
	desc = "A staunch, practical cape made out of numerous monster materials, it is coveted amongst exiles & hermits."
	allowed = list(
		/obj/item/flashlight,
		/obj/item/knife/combat/bone,
		/obj/item/knife/combat/survival,
		/obj/item/organ/internal/monster_core,
		/obj/item/pickaxe,
		/obj/item/spear,
		/obj/item/tank/internals,
		)
	armor_type = /datum/armor/cloak_goliath
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/goliath
	body_parts_covered = CHEST|GROIN|ARMS

/datum/armor/cloak_goliath
	melee = 35
	bullet = 10
	laser = 25
	energy = 35
	bomb = 25
	fire = 60
	acid = 60

/obj/item/clothing/head/hooded/cloakhood/goliath
	name = "goliath cloak hood"
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	icon_state = "golhood"
	desc = "A protective & concealing hood."
	armor_type = /datum/armor/cloakhood_goliath
	clothing_flags = SNUG_FIT
	flags_inv = HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR
	transparent_protection = HIDEMASK

/datum/armor/cloakhood_goliath
	melee = 35
	bullet = 10
	laser = 25
	energy = 35
	bomb = 25
	fire = 60
	acid = 60

/obj/item/clothing/suit/hooded/cloak/drake
	name = "drake armour"
	icon_state = "dragon"
	desc = "A suit of armour fashioned from the remains of an ash drake."
	allowed = list(
		/obj/item/flashlight,
		/obj/item/gun/energy/recharge/kinetic_accelerator,
		/obj/item/mining_scanner,
		/obj/item/pickaxe,
		/obj/item/resonator,
		/obj/item/spear,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/tank/internals,
		)
	armor_type = /datum/armor/cloak_drake
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/drake
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	transparent_protection = HIDEGLOVES|HIDESUITSTORAGE|HIDEJUMPSUIT|HIDESHOES

/datum/armor/cloak_drake
	melee = 65
	bullet = 15
	laser = 40
	energy = 40
	bomb = 70
	bio = 60
	fire = 100
	acid = 100

/obj/item/clothing/head/hooded/cloakhood/drake
	name = "drake helm"
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	icon_state = "dragon"
	desc = "The skull of a dragon."
	armor_type = /datum/armor/cloakhood_drake
	clothing_flags = SNUG_FIT
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

/datum/armor/cloakhood_drake
	melee = 65
	bullet = 15
	laser = 40
	energy = 40
	bomb = 70
	bio = 60
	fire = 100
	acid = 100

/obj/item/clothing/suit/hooded/cloak/godslayer
	name = "godslayer armour"
	icon_state = "godslayer"
	desc = "A suit of armour fashioned from the remnants of a knight's armor, and parts of a wendigo."
	allowed = list(
		/obj/item/flashlight,
		/obj/item/gun/energy/recharge/kinetic_accelerator,
		/obj/item/mining_scanner,
		/obj/item/pickaxe,
		/obj/item/resonator,
		/obj/item/spear,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/tank/internals,
		)
	armor_type = /datum/armor/cloak_godslayer
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/godslayer
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	resistance_flags = FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	transparent_protection = HIDEGLOVES|HIDESUITSTORAGE|HIDEJUMPSUIT|HIDESHOES
	/// Amount to heal when the effect is triggered
	var/heal_amount = 500
	/// Time until the effect can take place again
	var/effect_cooldown_time = 10 MINUTES
	/// Current cooldown for the effect
	COOLDOWN_DECLARE(effect_cooldown)
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)

/datum/armor/cloak_godslayer
	melee = 50
	bullet = 25
	laser = 25
	energy = 25
	bomb = 50
	bio = 50
	fire = 100
	acid = 100

/obj/item/clothing/head/hooded/cloakhood/godslayer
	name = "godslayer helm"
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	icon_state = "godslayer"
	desc = "The horns and skull of a wendigo, held together by the remaining icey energy of a demonic miner."
	armor_type = /datum/armor/cloakhood_godslayer
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	flash_protect = FLASH_PROTECTION_WELDER
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	resistance_flags = FIRE_PROOF | ACID_PROOF | FREEZE_PROOF

/datum/armor/cloakhood_godslayer
	melee = 50
	bullet = 25
	laser = 25
	energy = 25
	bomb = 50
	bio = 50
	fire = 100
	acid = 100

/obj/item/clothing/suit/hooded/cloak/godslayer/examine(mob/user)
	. = ..()
	if(loc == user && !COOLDOWN_FINISHED(src, effect_cooldown))
		. += "You feel like the revival effect will be able to occur again in [COOLDOWN_TIMELEFT(src, effect_cooldown) / 10] seconds."

/obj/item/clothing/suit/hooded/cloak/godslayer/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_OCLOTHING)
		RegisterSignal(user, COMSIG_MOB_STATCHANGE, PROC_REF(resurrect))
		return
	UnregisterSignal(user, COMSIG_MOB_STATCHANGE)

/obj/item/clothing/suit/hooded/cloak/godslayer/dropped(mob/user)
	..()
	UnregisterSignal(user, COMSIG_MOB_STATCHANGE)

/obj/item/clothing/suit/hooded/cloak/godslayer/proc/resurrect(mob/living/carbon/user, new_stat)
	SIGNAL_HANDLER
	if(new_stat > CONSCIOUS && new_stat < DEAD && COOLDOWN_FINISHED(src, effect_cooldown))
		COOLDOWN_START(src, effect_cooldown, effect_cooldown_time) //This needs to happen first, otherwise there's an infinite loop
		user.heal_ordered_damage(heal_amount, damage_heal_order)
		user.visible_message(span_notice("[user] suddenly revives, as their armor swirls with demonic energy!"), span_notice("You suddenly feel invigorated!"))
		playsound(user.loc, 'sound/magic/clockwork/ratvar_attack.ogg', 50)
