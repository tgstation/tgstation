/datum/antagonist/bitrunning_glitch/cyber_tac
	name = ROLE_CYBER_TAC
	preview_outfit = /datum/outfit/cyber_police/tactical
	threat = 50
	show_in_antagpanel = TRUE

/datum/antagonist/bitrunning_glitch/cyber_tac/on_gain()
	. = ..()

	if(!ishuman(owner.current))
		stack_trace("humans only for this position")
		return

	convert_agent(owner.current, /datum/outfit/cyber_police/tactical)

/datum/outfit/cyber_police/tactical
	name = ROLE_CYBER_TAC
	back = /obj/item/mod/control/pre_equipped/glitch
	l_hand = /obj/item/gun/ballistic/automatic/m90

	backpack_contents = list(
		/obj/item/ammo_box/magazine/m223,
		/obj/item/ammo_box/magazine/m223,
		/obj/item/ammo_box/magazine/m223,
	)

/datum/outfit/cyber_police/tactical/post_equip(mob/living/carbon/human/user, visualsOnly)
	. = ..()

	var/obj/item/implant/weapons_auth/auth = new(user)
	auth.implant(user)

/obj/item/mod/control/pre_equipped/glitch
	theme = /datum/mod_theme/glitch
	applied_cell = /obj/item/stock_parts/cell/bluespace
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/jump_jet,
		/obj/item/mod/module/flashlight,
	)
	default_pins = list(
		/obj/item/mod/module/armor_booster,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/jump_jet,
	)

/datum/armor/mod_theme_glitch
	melee = 15
	bullet = 20
	laser = 35
	bomb = 65
	bio = 100
	fire = 100
	acid = 100
	wound = 100

/datum/mod_theme/glitch
	name = "glitch"
	desc = "A modsuit outfitted for elite Cyber Authority units to track, capture, and eliminate organic intruders."
	extended_desc = "The Cyber Authority function as a digital police force, patrolling the digital realm and enforcing the law. Cyber Tac units are the elite of the elite, outfitted with lethal weaponry and fast mobility specially designed to quell organic uprisings."
	default_skin = "glitch"
	armor_type = /datum/armor/mod_theme_glitch
	resistance_flags = FIRE_PROOF|ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY + 3
	siemens_coefficient = 0
	slowdown_inactive = 1
	slowdown_active = 0.5
	ui_theme = "terminal"
	inbuilt_modules = list(/obj/item/mod/module/armor_booster)
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
	)
	skins = list(
		"glitch" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

