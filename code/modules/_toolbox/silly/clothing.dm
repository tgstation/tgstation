//adding things to vending machines with out editing vending machine files
/obj/machinery/vending/clothing/New()
	if(type == /obj/machinery/vending/clothing)
		products += list(/obj/item/clothing/under/tracksuit/spawn_with_vodka = 1,/obj/item/clothing/suit/hooded/filthypink = 1)
	. = ..()

/obj/machinery/vending/autodrobe/New()
	if(type == /obj/machinery/vending/autodrobe)
		products += list(/obj/item/clothing/mask/balaclava/skull = 1)
	. = ..()

/obj/item/vending_refill/autodrobe/New()
	..()
	charges = list(34, 2, 3)
	init_charges = list(34, 2, 3)

//volodyah's pink suit

/obj/item/clothing/suit/hooded/filthypink
	name = "filthy pink suit"
	desc = "Makes you want to record a 'Harlem Shake' video."
	icon = 'icons/oldschool/clothing/suititem.dmi'
	icon_state = "filthypink"
	item_state = "p_suit"
	alternate_worn_icon = 'icons/oldschool/clothing/suitmob.dmi'
	body_parts_covered = CHEST|GROIN|ARMS
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0, fire = 0, acid = 0)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank/internals/emergency_oxygen,/obj/item/toy,/obj/item/storage/fancy/cigarettes,/obj/item/lighter)
	hoodtype = /obj/item/clothing/head/hooded/filthypink

/obj/item/clothing/head/hooded/filthypink
	name = "filthy pink hood"
	desc = null
	icon = 'icons/oldschool/clothing/headitem.dmi'
	icon_state = "filthypink"
	alternate_worn_icon = 'icons/oldschool/clothing/headmob.dmi'
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS

//Yolodyahs skull mask

/obj/item/clothing/mask/balaclava/skull
	name = "skull balaclava"
	desc = "LOADSASCARY"
	icon = 'icons/oldschool/clothing/maskitem.dmi'
	icon_state = "skullbalaclava"
	item_state = "bgloves"
	alternate_worn_icon = 'icons/oldschool/clothing/maskmob.dmi'

//track suit
/obj/item/clothing/under/tracksuit
	name = "track suit"
	desc = null
	icon = 'icons/oldschool/clothing/uniformitem.dmi'
	icon_state = "slav_track_suit"
	item_state = "bl_suit"
	alternate_worn_icon = 'icons/oldschool/clothing/uniformmob.dmi'

/obj/item/clothing/under/tracksuit/spawn_with_vodka/New()
	. = ..()
	if(loc)
		var/obj/item/reagent_containers/food/drinks/bottle/vodka/V = new(loc)
		V.layer = layer-0.1
		var/obj/item/reagent_containers/food/snacks/sausage/S = new(loc)
		S.layer = V.layer-0.1

/obj/effect/mob_spawn/human/plasma_miner
	name = "Plasma Rig Miner"
	desc = null
	mob_name = "Rig Miner"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper"
	density = TRUE
	roundstart = FALSE
	death = FALSE
	mob_species = /datum/species/plasmaman
	flavour_text = ""/*"<span class='big bold'>You are a sentient ecosystem,</span><b> an example of the mastery over life that your creators possessed. Your masters, benevolent as they were, created uncounted \
	seed vaults and spread them across the universe to every planet they could chart. You are in one such seed vault. Your goal is to cultivate and spread life wherever it will go while waiting \
	for contact from your creators. Estimated time of last contact: Deployment, 5x10^3 millennia ago.</b>"*/
	assignedrole = "Rig Miner"
	lock_to_zlevel = 1
	uniform = /obj/item/clothing/under/plasmaman
	shoes = /obj/item/clothing/shoes/workboots/mining
	gloves = /obj/item/clothing/gloves/combat
	glasses = /obj/item/clothing/glasses/meson
	mask = /obj/item/clothing/mask/breath
	head = /obj/item/clothing/head/helmet/space/plasmaman
	back = /obj/item/tank/internals/plasmaman
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/survival

/obj/effect/mob_spawn/human/plasma_miner/create(ckey, name)
	. = ..()
	if(istype(.,/mob/living/carbon))
		var/mob/living/carbon/M = .
		for(var/obj/item/tank/internals/plasmaman/F in M)
			M.internal = F
			break
		M.real_name = generate_plasmaman_name()
		if(M.mind)
			M.mind.name = M.real_name

/obj/item/storage/box/survival/plasmaman/PopulateContents()
	. = ..()
	for(var/obj/item/tank/internals/emergency_oxygen/E in src)
		qdel(E)
		new /obj/item/tank/internals/plasmaman/belt/full(src)

//botany belt
/obj/item/storage/belt/botany
	name = "botanist belt"
	desc = "Can carry things like seeds, plant nutrients and other things like that."
	icon = 'icons/oldschool/clothing/beltitem.dmi'
	alternate_worn_icon = 'icons/oldschool/clothing/beltmob.dmi'
	icon_state = "bbelt"
	item_state = "bbelt"
	lefthand_file = 'icons/oldschool/inhand_left.dmi'
	righthand_file = 'icons/oldschool/inhand_right.dmi'
	storage_slots = 7
	can_hold = list(
		/obj/item/reagent_containers/food/snacks,
		/obj/item/device/flashlight,
		/obj/item/device/radio,
		/obj/item/device/plant_analyzer,
		/obj/item/seeds,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/spray,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/disk/plantgene,
		/obj/item/reagent_containers/dropper,
		/obj/item/paper,
		/obj/item/grown,
		/obj/item/storage/box/matches,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter,
		/obj/item/storage/fancy/rollingpapers,
		/obj/item/rollingpaper,
		/obj/item/clothing/mask/cigarette
		)