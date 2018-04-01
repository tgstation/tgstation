/*
	Hippiestation changeling mutations
	Contains:
		Chitinous Suit
		Arm Cannon
		Tesla Arm
*/

/***************************************\
|************CHITINOUS SUIT!************|
\***************************************/

/obj/effect/proc_holder/changeling/suit/chitinous_suit
	name = "Chitinous Suit"
	desc = "We form a suit to protect ourselves from both attacks, and space. Requires a chemical upkeep."
	helptext = "We create a suit that will protect ourselves from space, and attacks from enemy lifeforms. It will reduce our chemical recharge rate while active."
	chemical_cost = 15
	dna_cost = 2
	req_human = 1
	recharge_slowdown = 0.60 // running around in a full suit w/ armblade is gonna be really costly now

	suit_type = /obj/item/clothing/suit/armor/changeling
	helmet_type = /obj/item/clothing/head/helmet/changeling
	suit_name_simple = "armor"
	helmet_name_simple = "helmet"

/obj/item/clothing/suit/armor/changeling
	flags_1 = NODROP_1 | DROPDEL_1 | STOPSPRESSUREDMAGE_1
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/device/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/oxygen)
	armor = list("melee" = 40, "bullet" = 40, "laser" = 20, "energy" = 20, "bomb" = 10, "bio" = 4, "rad" = 0, "fire" = 0, "acid" = 90)
	flags_inv = HIDEJUMPSUIT
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/armor/changeling/Initialize()
	. = ..()
	if(ismob(loc))
		loc.visible_message("<span class='warning'>[loc.name]\'s flesh turns black, quickly transforming into a hard, chitinous mass!</span>", "<span class='warning'>We harden our flesh, creating a suit of armor!</span>", "<span class='italics'>You hear organic matter ripping and tearing!</span>")
	START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/armor/changeling/process()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.reagents.add_reagent("salbutamol", REAGENTS_METABOLISM) // you'll be able to breathe in SPACE, sort've not really.

/obj/item/clothing/head/helmet/changeling
	desc = "A tough, hard covering of black chitin with translucent chitin in front."
	icon_state = "lingarmorhelmet"
	flags_1 = NODROP_1 | DROPDEL_1 | STOPSPRESSUREDMAGE_1
	armor = list("melee" = 40, "bullet" = 40, "laser" = 20, "energy" = 20, "bomb" = 10, "bio" = 4, "rad" = 0, "fire" = 0, "acid" = 90)
	flags_inv = HIDEEARS|HIDEHAIR|HIDEEYES|HIDEFACIALHAIR|HIDEFACE
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT

/***************************************\
|***************ARM CANNON**************|
\***************************************/

/obj/effect/proc_holder/changeling/weapon/armcannon
	name = "Arm Cannon"
	desc = "We transform our arm into a ballistic weapon. Devours our chemicals, and has a rather slow recharge rate."
	helptext = "You shoot at people and they die. Cannot be used in lesser form."
	chemical_cost = 35
	dna_cost = 4
	req_human = 1
	weapon_type = /obj/item/gun/magic/ling_armcannon
	weapon_name_simple = "arm cannon"
	silent = FALSE

/obj/item/gun/magic/ling_armcannon
	name = "armcannon"
	desc = "A ballistic weapon comparable to a Glock 17, made out of our own arm. It stirs and mixes chemicals to create its ammunition."
	icon = 'hippiestation/icons/obj/items_and_weapons.dmi'
	icon_state = "gun_arm"
	item_state = "gun_arm"
	lefthand_file = 'hippiestation/icons/mob/inhands/changeling_lefthand.dmi'
	righthand_file = 'hippiestation/icons/mob/inhands/changeling_righthand.dmi'
	flags_1 = ABSTRACT_1 | NODROP_1 | DROPDEL_1
	w_class = WEIGHT_CLASS_HUGE
	ammo_type = /obj/item/ammo_casing/magic/ling_armcannon
	fire_sound = 'sound/effects/splat.ogg'
	force = 7 // if you really have to hit someone.
	max_charges = 12
	recharge_rate = 2

/obj/item/gun/magic/ling_armcannon/Initialize(mapload, silent)
	. = ..()
	if(ismob(loc))
		if(!silent)
			loc.visible_message("<span class='warning'>[loc.name]\'s arm twists and contorts into a cannon!</span>", "<span class='warning'>Our arm twists and mutates, transforming it into a cannon.</span>", "<span class='italics'>You hear organic matter ripping and tearing!</span>")

/obj/item/ammo_casing/magic/ling_armcannon
	name = "gelatinous bullet"
	desc = "A bullet formed out of some jelly-like mass."
	projectile_type = /obj/item/projectile/bullet/c9mm/changeling
	caliber = "cornpotato pizza" // Is this var ever actually used?
	icon_state = "tentacle_end"
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect

/obj/item/projectile/bullet/c9mm/changeling
	name = "gelatinous bullet"
	impact_effect_type = /obj/effect/temp_visual/impact_effect
	icon = 'hippiestation/icons/obj/projectiles.dmi'
	icon_state = "changeling_bullet"

/***************************************\
|**************TESLA CLAW***************|
\***************************************/

/obj/effect/proc_holder/changeling/weapon/tesla
	name = "Tesla Claw"
	desc = "We transform our arm into a claw capable of channeling electricity. Can stun our opponents."
	helptext = "You shoot at people and they die. Cannot be used in lesser form."
	chemical_cost = 25
	dna_cost = 4
	req_human = 1
	weapon_type = /obj/item/melee/baton/stungun/changeling
	weapon_name_simple = "tesla claw"
	silent = FALSE

/obj/item/melee/baton/stungun/changeling
	name = "tesla claw"
	desc = "A claw made out of mutated flesh, which is capable of generating electricity."
	icon = 'hippiestation/icons/obj/items_and_weapons.dmi'
	icon_state = "teslaclaw"
	item_state = "teslaclaw"
	lefthand_file = 'hippiestation/icons/mob/inhands/changeling_lefthand.dmi'
	righthand_file = 'hippiestation/icons/mob/inhands/changeling_righthand.dmi'
	flags_1 = ABSTRACT_1 | NODROP_1 | DROPDEL_1
	w_class = WEIGHT_CLASS_HUGE
	force = 0
	throwforce = 5
	stunforce = 50
	hitcost = 125
	throw_hit_chance = 20
	attack_verb = list("poked")
	selfcharge = 1
	charge_sections = 2
	shaded_charge = 1
	charge_tick = 0
	charge_delay = 7

/obj/item/melee/baton/stungun/changeling/Initialize(mapload, silent)
	. = ..()
	if(ismob(loc))
		if(!silent)
			loc.visible_message("<span class='warning'>[loc.name]\'s hand grows out into a claw, with electricity surging through!</span>", "<span class='warning'>Our arm twists and mutates, transforming it into a Tesla Claw.</span>", "<span class='italics'>You hear organic matter ripping and tearing!</span>")

/obj/item/melee/baton/stungun/changeling/update_icon()
	if(status)
		icon_state = "teslaclaw_active"
		item_state = "teslaclaw_active"
	else if(!cell)
		icon_state = null
	else
		icon_state = "teslaclaw"
		item_state = "teslaclaw"
