//the one boulder to rule them all, rust reference
/obj/item/boulder/true_boulder
	name = "One rock to rule them all"
	desc = "A stone that is well weighted and easy to hold, one side is easy and comfortable to hold, you could easily bash somebodys head in with this or mine a metal node."
	icon_state = "ore"
	icon = 'icons/obj/ore.dmi'
	item_flags = NO_MAT_REDEMPTION | SLOWS_WHILE_IN_HAND
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 25 // rock
	throw_range = 5
	force = 25 // the one rock to rule them all
	armour_penetration = 100 //the rock does not care what you wear
	block_chance = 25 // funny
	tk_throw_range = 0 // no fancy magic tricks with the rock
	throw_speed = 0.5
	slowdown = 2
	drag_slowdown = 1.5 // It's still a big rock.

/obj/item/fake_items/time_stopper/no_anchor
	anchored = 0

/obj/item/fake_items/wabbajack/no_anchor
	anchored = 0

/obj/item/fake_items/abductor_win_stick/no_anchor
	anchored = 0

/obj/item/reagent_containers/condiment/protein/wizbulk
	name = "WIZ BULK, UNNATURAL GAIN FOR THE UNNATURALLY TALENTED"
	desc = "It has a small part on the back that says 'doesnt work for the not magically attuned'"

/obj/item/nullrod/claymore/chainsaw_sword/kyle
	name = "kyle"
	desc = "An chainsaw sword that has its blade heated up to be nearly white hot, why the fuck is it named kyle? why not like, the incinerator or heretic melter or something."
	damtype = BURN
	chaplain_spawnable = FALSE
	station_holy_item = FALSE
	force = 30

//mobs start here
/mob/living/basic/wizard/buffwiz
	name = "Buff wizard"
	desc = "Well i guess not all wizards let their physical form go"
	speed = 0
	maxHealth = 500
	health = 500
	melee_damage_lower = 50
	melee_damage_upper = 50

/mob/living/basic/wizard/tired
	name = "over-worked wizard"
	desc = "This wizard doesnt seem hostile and pays you no mind, they continue working frantically as they do something to the modsuit- it appears like theyre changing it, somehow, maybe you can steal from him a bit."
	speed = 0
	maxHealth = 75
	health = 75
	melee_damage_lower = 4
	melee_damage_upper = 4
	faction = list(FACTION_NEUTRAL)

/mob/living/basic/wizard/high_magus
	name = "High Magus"
	desc = "The high magus of this area, still only a slightly above average wizard"
	speed = 0
	maxHealth = 750
	health = 750
	melee_damage_lower = 25
	melee_damage_upper = 25

/mob/living/basic/skeleton/templar/academy
	name = "undead knight gaurd"
	desc = "The reanimated remains of a knight, this one appears to be a gaurd."
	loot = list(
		/obj/effect/decal/remains/human,
		/obj/item/clothing/suit/armor/riot/knight/greyscale,
		/obj/item/clothing/head/helmet/knight/greyscale,
		/obj/item/claymore/weak,
		/obj/item/shield/buckler,
	)
	outfit = /datum/outfit/academy_knight
	faction = list(ROLE_WIZARD)

/datum/outfit/academy_knight
	name = "Knight"
	uniform = /obj/item/clothing/under/costume/gamberson/military
	mask = /obj/item/clothing/mask/bandana
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/armor/riot/knight/greyscale
	back = /obj/item/storage/backpack/cultpack
	head = /obj/item/clothing/head/helmet/knight/greyscale
	l_hand = /obj/item/claymore
	r_hand = /obj/item/shield/buckler

/mob/living/basic/trooper/nanotrasen/ranged/elite/traitor
	name = "Traitor Nanotrasen Elite Assault Officer"
	desc = "A nanotrasen elite assault officer turned traitor"
	faction = list(ROLE_WIZARD)

/mob/living/basic/skeleton/templar/leader
	name = "Knight leader"
	desc = "This one isnt trapped behind glass or being ordered around like the others, this one must be in charge of the others"
	maxHealth = 450
	health = 450
	melee_damage_lower = 35
	melee_damage_upper = 35
