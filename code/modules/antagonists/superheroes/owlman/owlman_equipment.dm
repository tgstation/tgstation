/obj/item/clothing/suit/toggle/owlwings/owlman
	name = "Owlman's cloak"
	desc = "A soft brown cloak made of synthetic feathers. Soft to the touch, stylish, and a 2 meter wing span that will drive the ladies mad."

	clothing_flags = THICKMATERIAL
	armor = list(MELEE = 60, BULLET = 60, LASER = 50, ENERGY = 60, BOMB = 55, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)

/obj/item/clothing/mask/gas/owl_mask
	name = "Owlman's mask"
	desc = "Twoooo!"
	icon_state = "owl"

	body_parts_covered = HEAD
	clothing_flags = THICKMATERIAL
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDEEARS|HIDEEYES|HIDESNOUT
	armor = list(MELEE = 60, BULLET = 60, LASER = 50, ENERGY = 60, BOMB = 55, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)

/obj/item/storage/belt/champion/owlman
	name = "Owlman's belt"
	desc = "A golden belt of the best superhero. People argued about whose it is, but the truth is that it belongs to the Owlman."

/obj/item/storage/belt/champion/owlman/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 20
	STR.max_combined_w_class = 60
	STR.set_holdable(list(
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/multitool,
		/obj/item/flashlight,
		/obj/item/stack/cable_coil,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/geiger_counter,
		/obj/item/extinguisher/mini,
		/obj/item/radio,
		/obj/item/clothing/gloves,
		/obj/item/holosign_creator/atmos,
		/obj/item/holosign_creator/engineering,
		/obj/item/forcefield_projector,
		/obj/item/assembly/signaler,
		/obj/item/lightreplacer,
		/obj/item/construction/rcd,
		/obj/item/pipe_dispenser,
		/obj/item/inducer,
		/obj/item/plunger,
		/obj/item/airlock_painter,
		/obj/item/pipe_painter,
		/obj/item/reagent_containers/hypospray/medipen,
		/obj/item/grenade,
		/obj/item/restraints/handcuffs
		))

/obj/item/storage/belt/champion/owlman/PopulateContents()
	new /obj/item/screwdriver/nuke(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool/largetank(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/wirecutters(src)
	new /obj/item/multitool(src)
	new /obj/item/stack/cable_coil(src)

	new /obj/item/reagent_containers/hypospray/medipen/pumpup(src)
	new /obj/item/restraints/legcuffs/bola(src)
	new /obj/item/restraints/legcuffs/bola(src)
	new /obj/item/grenade/smokebomb(src)
	new /obj/item/grenade/smokebomb(src)
	new /obj/item/grenade/smokebomb(src)
	new /obj/item/grenade/smokebomb(src)

/obj/item/clothing/suit/hooded/wintercoat/owlman
	name = "Owlman's wintercoat"
	desc = "A wintercoat with cloth wings attached to it. Stylish and warm."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "owl_wings_cryo"
	worn_icon = 'icons/mob/clothing/suit.dmi'

	clothing_flags = THICKMATERIAL //We don't wanna to get fucked up by BuzzOn's bees, don't we?
	armor = list(MELEE = 60, BULLET = 60, LASER = 50, ENERGY = 60, BOMB = 55, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)

	hoodtype = /obj/item/clothing/head/hooded/winterhood/owlman
	actions_types = list(/datum/action/item_action/toggle_wings)

/obj/item/clothing/suit/hooded/wintercoat/owlman/Initialize()
	. = ..()
	allowed = GLOB.security_hardsuit_allowed

/obj/item/clothing/head/hooded/winterhood/owlman
	name = "brown winter hood"
	desc = "A brown winter hood with a bunch of synthetic feathers stuck to it."
	icon_state = "hood_owlman"

	clothing_flags = THICKMATERIAL
	armor = list(MELEE = 60, BULLET = 60, LASER = 50, ENERGY = 60, BOMB = 55, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)