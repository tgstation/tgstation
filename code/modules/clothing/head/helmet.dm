/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "Standard Security gear. Protects the head from impacts."
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	icon_state = "helmet"
	base_icon_state = "helmet"
	inhand_icon_state = "helmet"
	armor_type = /datum/armor/head_helmet
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	strip_delay = 60
	clothing_flags = SNUG_FIT | STACKABLE_HELMET_EXEMPT
	flags_cover = HEADCOVERSEYES|EARS_COVERED
	flags_inv = HIDEHAIR
	dog_fashion = /datum/dog_fashion/head/helmet

/datum/armor/head_helmet
	melee = 35
	bullet = 30
	laser = 30
	energy = 40
	bomb = 25
	fire = 50
	acid = 50
	wound = 10

/obj/item/clothing/head/helmet/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/clothing/head/helmet/sec
	var/flipped_visor = FALSE
	sound_vary = TRUE
	equip_sound = 'sound/items/handling/helmet/helmet_equip1.ogg'
	pickup_sound = 'sound/items/handling/helmet/helmet_pickup1.ogg'
	drop_sound = 'sound/items/handling/helmet/helmet_drop1.ogg'
	visor_toggle_up_sound = SFX_VISOR_UP
	visor_toggle_down_sound = SFX_VISOR_DOWN
	hair_mask = /datum/hair_mask/standard_hat_low

/obj/item/clothing/head/helmet/sec/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seclite_attachable, light_icon_state = "flight")

/obj/item/clothing/head/helmet/sec/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(issignaler(attacking_item))
		var/obj/item/assembly/signaler/attached_signaler = attacking_item
		// There's a flashlight in us. Remove it first, or it'll be lost forever!
		var/obj/item/flashlight/seclite/blocking_us = locate() in src
		if(blocking_us)
			to_chat(user, span_warning("[blocking_us] is in the way, remove it first!"))
			return TRUE

		if(!attached_signaler.secured)
			to_chat(user, span_warning("Secure [attached_signaler] first!"))
			return TRUE

		to_chat(user, span_notice("You add [attached_signaler] to [src]."))

		qdel(attached_signaler)
		var/obj/item/bot_assembly/secbot/secbot_frame = new(loc)
		user.put_in_hands(secbot_frame)

		qdel(src)
		return TRUE

	return ..()

/obj/item/clothing/head/helmet/sec/attack_self(mob/user)
	. = ..()
	if(.)
		return
	balloon_alert(user, "[flags_inv & HIDEHAIR ? "loosening" : "tightening"] straps...")
	if(!do_after(user, 3 SECONDS, src))
		return
	flags_inv ^= HIDEHAIR
	balloon_alert(user, "[flags_inv & HIDEHAIR ? "tightened" : "loosened"] straps")
	return TRUE

/obj/item/clothing/head/helmet/sec/click_alt(mob/user)
	flipped_visor = !flipped_visor
	balloon_alert(user, "visor flipped")
	// base_icon_state is modified for seclight attachment component
	base_icon_state = "[initial(base_icon_state)][flipped_visor ? "-novisor" : ""]"
	icon_state = base_icon_state
	if (flipped_visor)
		flags_cover &= ~HEADCOVERSEYES
		playsound(src, SFX_VISOR_DOWN, 20, TRUE, -1)
	else
		flags_cover |= HEADCOVERSEYES
		playsound(src, SFX_VISOR_UP, 20, TRUE, -1)
	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/head/helmet/press
	name = "press helmet"
	desc = "A blue helmet used to distinguish <i>non-combatant</i> \"PRESS\" members, like if anyone cares."
	icon_state = "helmet_press"
	sound_vary = TRUE
	equip_sound = 'sound/items/handling/helmet/helmet_equip1.ogg'
	pickup_sound = 'sound/items/handling/helmet/helmet_pickup1.ogg'
	drop_sound = 'sound/items/handling/helmet/helmet_drop1.ogg'

/obj/item/clothing/head/helmet/press/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "[icon_state]-emissive", src, alpha = src.alpha)

/obj/item/clothing/head/helmet/alt
	name = "bulletproof helmet"
	desc = "A bulletproof combat helmet that excels in protecting the wearer against traditional projectile weaponry and explosives to a minor extent."
	icon_state = "helmetalt"
	inhand_icon_state = "helmet"
	armor_type = /datum/armor/helmet_alt
	dog_fashion = null
	sound_vary = TRUE
	equip_sound = 'sound/items/handling/helmet/helmet_equip1.ogg'
	pickup_sound = 'sound/items/handling/helmet/helmet_pickup1.ogg'
	drop_sound = 'sound/items/handling/helmet/helmet_drop1.ogg'

/datum/armor/helmet_alt
	melee = 15
	bullet = 60
	laser = 10
	energy = 10
	bomb = 40
	fire = 50
	acid = 50
	wound = 5

/obj/item/clothing/head/helmet/alt/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seclite_attachable, light_icon_state = "flight")

/obj/item/clothing/head/helmet/marine
	name = "tactical combat helmet"
	desc = "A tactical black helmet, sealed from outside hazards with a plate of glass and not much else."
	icon_state = "marine_command"
	base_icon_state = "marine_command"
	inhand_icon_state = "marine_helmet"
	armor_type = /datum/armor/helmet_marine
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	clothing_flags = STOPSPRESSUREDAMAGE | STACKABLE_HELMET_EXEMPT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	dog_fashion = null
	sound_vary = TRUE
	equip_sound = 'sound/items/handling/helmet/helmet_equip1.ogg'
	pickup_sound = 'sound/items/handling/helmet/helmet_pickup1.ogg'
	drop_sound = 'sound/items/handling/helmet/helmet_drop1.ogg'

/datum/armor/helmet_marine
	melee = 50
	bullet = 50
	laser = 30
	energy = 25
	bomb = 50
	bio = 100
	fire = 40
	acid = 50
	wound = 20

/obj/item/clothing/head/helmet/marine/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seclite_attachable, starting_light = new /obj/item/flashlight/seclite(src), light_icon_state = "flight")

/obj/item/clothing/head/helmet/marine/security
	name = "marine heavy helmet"
	icon_state = "marine_security"
	base_icon_state = "marine_security"

/obj/item/clothing/head/helmet/marine/engineer
	name = "marine utility helmet"
	icon_state = "marine_engineer"
	base_icon_state = "marine_engineer"

/obj/item/clothing/head/helmet/marine/medic
	name = "marine medic helmet"
	icon_state = "marine_medic"
	base_icon_state = "marine_medic"

/obj/item/clothing/head/helmet/marine/pmc
	icon_state = "marine"
	desc = "A tactical black helmet, designed to protect one's head from various injuries sustained in operations. Its stellar survivability making up is for its lack of space worthiness"
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	clothing_flags = null
	armor_type = /datum/armor/pmc

/obj/item/clothing/head/helmet/old
	name = "degrading helmet"
	desc = "Standard issue security helmet. Due to degradation the helmet's visor obstructs the users ability to see long distances."
	tint = 2
	sound_vary = TRUE
	equip_sound = 'sound/items/handling/helmet/helmet_equip1.ogg'
	pickup_sound = 'sound/items/handling/helmet/helmet_pickup1.ogg'
	drop_sound = 'sound/items/handling/helmet/helmet_drop1.ogg'

/obj/item/clothing/head/helmet/blueshirt
	name = "blue helmet"
	desc = "A reliable, blue tinted helmet reminding you that you <i>still</i> owe that engineer a beer."
	icon_state = "blueshift"
	inhand_icon_state = "blueshift_helmet"
	custom_premium_price = PAYCHECK_COMMAND
	sound_vary = TRUE
	equip_sound = 'sound/items/handling/helmet/helmet_equip1.ogg'
	pickup_sound = 'sound/items/handling/helmet/helmet_pickup1.ogg'
	drop_sound = 'sound/items/handling/helmet/helmet_drop1.ogg'


/obj/item/clothing/head/helmet/toggleable
	visor_vars_to_toggle = NONE
	dog_fashion = null
	///chat message when the visor is toggled down.
	var/toggle_message
	///chat message when the visor is toggled up.
	var/alt_toggle_message

/obj/item/clothing/head/helmet/toggleable/attack_self(mob/user)
	adjust_visor(user)

/obj/item/clothing/head/helmet/toggleable/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][up ? "up" : ""]"

/obj/item/clothing/head/helmet/toggleable/riot
	name = "riot helmet"
	desc = "It's a helmet specifically designed to protect against close range attacks."
	icon_state = "riot"
	inhand_icon_state = "riot_helmet"
	toggle_message = "You pull the visor down on"
	alt_toggle_message = "You push the visor up on"
	armor_type = /datum/armor/toggleable_riot
	flags_inv = HIDEHAIR|HIDEEARS|HIDEFACE|HIDESNOUT
	strip_delay = 80
	actions_types = list(/datum/action/item_action/toggle)
	visor_flags_inv = HIDEFACE|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	clothing_traits = list(TRAIT_HEAD_INJURY_BLOCKED)
	sound_vary = TRUE
	equip_sound = 'sound/items/handling/helmet/helmet_equip1.ogg'
	pickup_sound = 'sound/items/handling/helmet/helmet_pickup1.ogg'
	drop_sound = 'sound/items/handling/helmet/helmet_drop1.ogg'
	visor_toggle_up_sound = SFX_VISOR_UP
	visor_toggle_down_sound = SFX_VISOR_DOWN

/obj/item/clothing/head/helmet/toggleable/riot/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, 2)

/datum/armor/toggleable_riot
	melee = 50
	bullet = 10
	laser = 10
	energy = 10
	fire = 80
	acid = 80
	wound = 15

/obj/item/clothing/head/helmet/balloon
	name = "balloon helmet"
	desc = "A helmet made out of balloons. Its likes saw great usage in the Great Clown - Mime War. Surprisingly resistant to fire. Mimes were doing unspeakable things."
	icon_state = "helmet_balloon"
	inhand_icon_state = "helmet_balloon"
	armor_type = /datum/armor/balloon
	flags_inv = HIDEHAIR|HIDEEARS|HIDESNOUT
	resistance_flags = FIRE_PROOF
	dog_fashion = null

/datum/armor/balloon
	melee = 10
	fire = 60
	acid = 50

/obj/item/clothing/head/helmet/toggleable/justice
	name = "helmet of justice"
	desc = "WEEEEOOO. WEEEEEOOO. WEEEEOOOO."
	icon_state = "justice"
	inhand_icon_state = "justice_helmet"
	toggle_message = "You turn off the lights on"
	alt_toggle_message = "You turn on the lights on"
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	///Cooldown for toggling the visor.
	COOLDOWN_DECLARE(visor_toggle_cooldown)
	///Looping sound datum for the siren helmet
	var/datum/looping_sound/siren/weewooloop
	sound_vary = TRUE
	equip_sound = 'sound/items/handling/helmet/helmet_equip1.ogg'
	pickup_sound = 'sound/items/handling/helmet/helmet_pickup1.ogg'
	drop_sound = 'sound/items/handling/helmet/helmet_drop1.ogg'
	visor_toggle_up_sound = SFX_VISOR_UP
	visor_toggle_down_sound = SFX_VISOR_DOWN

/obj/item/clothing/head/helmet/toggleable/justice/adjust_visor(mob/living/user)
	if(!COOLDOWN_FINISHED(src, visor_toggle_cooldown))
		return FALSE
	COOLDOWN_START(src, visor_toggle_cooldown, 2 SECONDS)
	return ..()

/obj/item/clothing/head/helmet/toggleable/justice/visor_toggling()
	. = ..()
	if(up)
		weewooloop.start()
	else
		weewooloop.stop()

/obj/item/clothing/head/helmet/toggleable/justice/Initialize(mapload)
	. = ..()
	weewooloop = new(src, FALSE, FALSE)

/obj/item/clothing/head/helmet/toggleable/justice/Destroy()
	QDEL_NULL(weewooloop)
	return ..()

/obj/item/clothing/head/helmet/toggleable/justice/escape
	name = "alarm helmet"
	desc = "WEEEEOOO. WEEEEEOOO. STOP THAT MONKEY. WEEEOOOO."
	icon_state = "justice2"

/obj/item/clothing/head/helmet/swat
	name = "\improper SWAT helmet"
	desc = "An extremely robust, space-worthy helmet in a nefarious red and black stripe pattern."
	icon_state = "swatsyndie"
	inhand_icon_state = "swatsyndie_helmet"
	armor_type = /datum/armor/helmet_swat
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	clothing_flags = STOPSPRESSUREDAMAGE | STACKABLE_HELMET_EXEMPT
	strip_delay = 80
	resistance_flags = FIRE_PROOF | ACID_PROOF
	dog_fashion = null
	clothing_traits = list(TRAIT_HEAD_INJURY_BLOCKED)
	sound_vary = TRUE
	equip_sound = 'sound/items/handling/helmet/helmet_equip1.ogg'
	pickup_sound = 'sound/items/handling/helmet/helmet_pickup1.ogg'
	drop_sound = 'sound/items/handling/helmet/helmet_drop1.ogg'

/obj/item/clothing/head/helmet/swat/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, 3)

/datum/armor/helmet_swat
	melee = 40
	bullet = 30
	laser = 30
	energy = 40
	bomb = 50
	bio = 90
	fire = 100
	acid = 100
	wound = 15

/obj/item/clothing/head/helmet/swat/nanotrasen
	name = "\improper SWAT helmet"
	desc = "An extremely robust helmet with the Nanotrasen logo emblazoned on the top."
	icon_state = "swat"
	inhand_icon_state = "swat_helmet"
	clothing_flags = STACKABLE_HELMET_EXEMPT
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF


/obj/item/clothing/head/helmet/thunderdome
	name = "\improper Thunderdome helmet"
	desc = "<i>'Let the battle commence!'</i>"
	flags_inv = HIDEEARS|HIDEHAIR
	icon_state = "thunderdome"
	inhand_icon_state = "thunderdome_helmet"
	armor_type = /datum/armor/helmet_thunderdome
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	strip_delay = 80
	dog_fashion = null

/datum/armor/helmet_thunderdome
	melee = 80
	bullet = 80
	laser = 50
	energy = 50
	bomb = 100
	bio = 100
	fire = 90
	acid = 90

/obj/item/clothing/head/helmet/thunderdome/holosuit
	cold_protection = null
	heat_protection = null
	armor_type = /datum/armor/thunderdome_holosuit

/datum/armor/thunderdome_holosuit
	melee = 10
	bullet = 10

/obj/item/clothing/head/helmet/roman
	name = "\improper Roman helmet"
	desc = "An ancient helmet made of bronze and leather."
	flags_inv = HIDEEARS|HIDEHAIR
	flags_cover = HEADCOVERSEYES
	armor_type = /datum/armor/helmet_roman
	resistance_flags = FIRE_PROOF
	icon_state = "roman"
	inhand_icon_state = "roman_helmet"
	strip_delay = 100
	dog_fashion = null

/datum/armor/helmet_roman
	melee = 25
	laser = 25
	energy = 10
	bomb = 10
	fire = 100
	acid = 50
	wound = 5

/obj/item/clothing/head/helmet/roman/fake
	desc = "An ancient helmet made of plastic and leather."
	armor_type = /datum/armor/none

/obj/item/clothing/head/helmet/roman/legionnaire
	name = "\improper Roman legionnaire helmet"
	desc = "An ancient helmet made of bronze and leather. Has a red crest on top of it."
	icon_state = "roman_c"

/obj/item/clothing/head/helmet/roman/legionnaire/fake
	desc = "An ancient helmet made of plastic and leather. Has a red crest on top of it."
	armor_type = /datum/armor/none

/obj/item/clothing/head/helmet/gladiator
	name = "gladiator helmet"
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	inhand_icon_state = "gladiator_helmet"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR
	flags_cover = HEADCOVERSEYES
	dog_fashion = null

/obj/item/clothing/head/helmet/taghelm
	flags_cover = HEADCOVERSEYES
	// Offer about the same protection as a hardhat.
	armor_type = /datum/armor/helmet_taghelm
	dog_fashion = null
	sound_vary = TRUE
	equip_sound = 'sound/items/handling/helmet/helmet_equip1.ogg'
	pickup_sound = 'sound/items/handling/helmet/helmet_pickup1.ogg'
	drop_sound = 'sound/items/handling/helmet/helmet_drop1.ogg'

/datum/armor/helmet_taghelm
	melee = 15
	bullet = 10
	laser = 20
	energy = 10
	bomb = 20
	acid = 50

/obj/item/clothing/head/helmet/taghelm/red
	name = "red laser tag helmet"
	desc = "They have chosen their own end."
	icon_state = "redtaghelm"
	inhand_icon_state = "redtag_helmet"

/obj/item/clothing/head/helmet/taghelm/blue
	name = "blue laser tag helmet"
	desc = "They'll need more men."
	icon_state = "bluetaghelm"
	inhand_icon_state = "bluetag_helmet"

/obj/item/clothing/head/helmet/knight
	name = "medieval helmet"
	desc = "A classic metal helmet."
	icon_state = "knight_green"
	inhand_icon_state = "knight_helmet"
	armor_type = /datum/armor/helmet_knight
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	resistance_flags = NONE
	strip_delay = 80
	dog_fashion = null
	clothing_traits = list(TRAIT_HEAD_INJURY_BLOCKED)

/obj/item/clothing/head/helmet/knight/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, 3)

/datum/armor/helmet_knight
	melee = 50
	bullet = 10
	laser = 10
	energy = 10
	fire = 80
	acid = 80

/obj/item/clothing/head/helmet/knight/blue
	icon_state = "knight_blue"

/obj/item/clothing/head/helmet/knight/yellow
	icon_state = "knight_yellow"

/obj/item/clothing/head/helmet/knight/red
	icon_state = "knight_red"

/obj/item/clothing/head/helmet/knight/greyscale
	name = "knight helmet"
	desc = "A classic medieval helmet, if you hold it upside down you could see that it's actually a bucket."
	icon_state = "knight_greyscale"
	inhand_icon_state = null
	armor_type = /datum/armor/knight_greyscale
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS //Can change color and add prefix

/obj/item/clothing/head/helmet/durathread
	name = "durathread helmet"
	desc = "A helmet made from durathread and leather."
	icon_state = "durathread"
	inhand_icon_state = "durathread_helmet"
	resistance_flags = FLAMMABLE
	armor_type = /datum/armor/helmet_durathread
	strip_delay = 60

/datum/armor/helmet_durathread
	melee = 20
	bullet = 10
	laser = 30
	energy = 40
	bomb = 15
	fire = 40
	acid = 50
	wound = 5

/obj/item/clothing/head/helmet/rus_helmet
	name = "russian helmet"
	desc = "It can hold a bottle of vodka."
	icon_state = "rus_helmet"
	inhand_icon_state = "rus_helmet"
	armor_type = /datum/armor/helmet_rus_helmet
	sound_vary = TRUE
	equip_sound = 'sound/items/handling/helmet/helmet_equip1.ogg'
	pickup_sound = 'sound/items/handling/helmet/helmet_pickup1.ogg'
	drop_sound = 'sound/items/handling/helmet/helmet_drop1.ogg'

/datum/armor/helmet_rus_helmet
	melee = 25
	bullet = 30
	energy = 10
	bomb = 10
	fire = 20
	acid = 50
	wound = 5

/obj/item/clothing/head/helmet/rus_helmet/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/helmet)

/obj/item/clothing/head/helmet/rus_ushanka
	name = "battle ushanka"
	desc = "100% bear."
	icon_state = "rus_ushanka"
	inhand_icon_state = "rus_ushanka"
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	armor_type = /datum/armor/helmet_rus_ushanka

/datum/armor/helmet_rus_ushanka
	melee = 25
	bullet = 20
	laser = 20
	energy = 30
	bomb = 20
	bio = 50
	fire = -10
	acid = 50
	wound = 5

/obj/item/clothing/head/helmet/elder_atmosian
	name = "\improper Elder Atmosian Helmet"
	desc = "A superb helmet made with the toughest and rarest materials available to man."
	icon_state = "h2helmet"
	inhand_icon_state = "h2_helmet"
	armor_type = /datum/armor/helmet_elder_atmosian
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS //Can change color and add prefix
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/datum/armor/helmet_elder_atmosian
	melee = 25
	bullet = 20
	laser = 30
	energy = 30
	bomb = 85
	bio = 10
	fire = 65
	acid = 40
	wound = 15

/obj/item/clothing/head/helmet/military
	name = "Crude Helmet"
	desc = "A cheaply made kettle helmet with an added faceplate to protect your eyes and mouth."
	icon_state = "military"
	inhand_icon_state = "knight_helmet"
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	flash_protect = FLASH_PROTECTION_FLASH
	strip_delay = 80
	dog_fashion = null
	armor_type = /datum/armor/helmet_military
	sound_vary = TRUE
	equip_sound = 'sound/items/handling/helmet/helmet_equip1.ogg'
	pickup_sound = 'sound/items/handling/helmet/helmet_pickup1.ogg'
	drop_sound = 'sound/items/handling/helmet/helmet_drop1.ogg'

/datum/armor/helmet_military
	melee = 45
	bullet = 25
	laser = 25
	energy = 25
	bomb = 25
	fire = 10
	acid = 50
	wound = 20

/obj/item/clothing/head/helmet/military/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/clothing_fov_visor, FOV_90_DEGREES)

/obj/item/clothing/head/helmet/knight/warlord
	name = "golden barbute helmet"
	desc = "There is no man behind the helmet, only a terrible thought."
	icon_state = "warlord"
	inhand_icon_state = null
	armor_type = /datum/armor/helmet_warlord
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEMASK|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	flash_protect = FLASH_PROTECTION_FLASH
	slowdown = 0.2

/datum/armor/helmet_warlord
	melee = 70
	bullet = 60
	laser = 70
	energy = 70
	bomb = 40
	fire = 50
	acid = 50
	wound = 30

/obj/item/clothing/head/helmet/durability/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	take_damage(1, BRUTE, 0, 0)

/obj/item/clothing/head/helmet/durability/watermelon
	name = "watermelon helmet"
	desc = "A helmet cut out from a watermelon. Might take a few hits, but don't expect it whitstand much."
	icon_state = "watermelon"
	inhand_icon_state = "watermelon"
	flags_inv = HIDEEARS
	dog_fashion = /datum/dog_fashion/head/watermelon
	armor_type = /datum/armor/helmet_watermelon
	max_integrity = 15

/obj/item/clothing/head/helmet/durability/watermelon/fire_resist
	resistance_flags = FIRE_PROOF
	armor_type = /datum/armor/helmet_watermelon_fr

/datum/armor/helmet_watermelon
	melee = 15
	bullet = 10
	energy = 10
	bomb = 10
	fire = 0
	acid = 25
	wound = 5

/datum/armor/helmet_watermelon_fr
	melee = 15
	bullet = 10
	energy = 10
	bomb = 10
	fire = 15
	acid = 30
	wound = 5

/obj/item/clothing/head/helmet/durability/holymelon
	name = "holymelon helmet"
	desc = "A helmet from a hollowed out holymelon. Might take a few hits, but don't expect it to withstand much."
	icon_state = "holymelon"
	inhand_icon_state = "holymelon"
	flags_inv = HIDEEARS
	dog_fashion = /datum/dog_fashion/head/holymelon
	armor_type = /datum/armor/helmet_watermelon
	max_integrity = 15

/obj/item/clothing/head/helmet/durability/holymelon/fire_resist
	resistance_flags = FIRE_PROOF
	armor_type = /datum/armor/helmet_watermelon_fr

/obj/item/clothing/head/helmet/durability/holymelon/Initialize(mapload)
	. = ..()

	AddComponent(
		/datum/component/anti_magic, \
		antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY, \
		inventory_flags = ITEM_SLOT_OCLOTHING, \
		charges = 1, \
		drain_antimagic = CALLBACK(src, PROC_REF(drain_antimagic)), \
		expiration = CALLBACK(src, PROC_REF(decay)) \
	)

/obj/item/clothing/head/helmet/durability/holymelon/proc/drain_antimagic(mob/user)
	to_chat(user, span_warning("[src] looses a bit of its shimmer and glossiness..."))

/obj/item/clothing/head/helmet/durability/holymelon/proc/decay()
	take_damage(8, BRUTE, 0, 0)

/obj/item/clothing/head/helmet/durability/barrelmelon
	name = "barrelmelon helmet"
	desc = "A helmet from hollowed out barrelmelon. As sturdy as if made from actual wood, though its rigid structure makes it break up quicker."
	icon_state = "barrelmelon"
	inhand_icon_state = "barrelmelon"
	flags_inv = HIDEEARS
	dog_fashion = /datum/dog_fashion/head/barrelmelon
	armor_type = /datum/armor/helmet_barrelmelon
	max_integrity = 10

/obj/item/clothing/head/helmet/durability/barrelmelon/fire_resist
	resistance_flags = FIRE_PROOF
	armor_type = /datum/armor/helmet_barrelmelon_fr

/datum/armor/helmet_barrelmelon
	melee = 25
	bullet = 20
	energy = 15
	bomb = 10
	fire = 0
	acid = 35
	wound = 10

/datum/armor/helmet_barrelmelon_fr
	melee = 25
	bullet = 20
	energy = 15
	bomb = 10
	fire = 20
	acid = 40
	wound = 10

/obj/item/clothing/head/helmet/dragoon
	name = "drachen helmet"
	desc = "A chainmail helmet with dragon scales attached to the skeleton, with ash-covered mythril plate reinforcement covering it."
	icon_state = "dragoonhelm"
	base_icon_state = "dragoonhelm"
	inhand_icon_state = "dragoonhelm"
	clothing_flags = SNUG_FIT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	dog_fashion = /datum/dog_fashion/head/dragoon
	sound_vary = TRUE
	equip_sound = 'sound/items/handling/helmet/helmet_equip1.ogg'
	pickup_sound = 'sound/items/handling/helmet/helmet_pickup1.ogg'
	drop_sound = 'sound/items/handling/helmet/helmet_drop1.ogg'
