// Plant analyzer
/obj/item/device/plant_analyzer
	name = "plant analyzer"
	desc = "A scanner used to evaluate a plant's various areas of growth."
	icon = 'icons/obj/device.dmi'
	icon_state = "hydro"
	item_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	slot_flags = SLOT_BELT
	origin_tech = "magnets=2;biotech=2"
	materials = list(MAT_METAL=30, MAT_GLASS=20)

// *************************************
// Hydroponics Tools
// *************************************

/obj/item/reagent_containers/spray/weedspray // -- Skie
	desc = "It's a toxic mixture, in spray form, to kill small weeds."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	name = "weed spray"
	icon_state = "weedspray"
	item_state = "spray"
	volume = 100
	container_type = OPENCONTAINER
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 10

/obj/item/reagent_containers/spray/weedspray/Initialize()
	. = ..()
	reagents.add_reagent("weedkiller", 100)

/obj/item/reagent_containers/spray/weedspray/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is huffing [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (TOXLOSS)

/obj/item/reagent_containers/spray/pestspray // -- Skie
	desc = "It's some pest eliminator spray! <I>Do not inhale!</I>"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	name = "pest spray"
	icon_state = "pestspray"
	item_state = "plantbgone"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	volume = 100
	container_type = OPENCONTAINER
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 10

/obj/item/reagent_containers/spray/pestspray/Initialize()
	. = ..()
	reagents.add_reagent("pestkiller", 100)

/obj/item/reagent_containers/spray/pestspray/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is huffing [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (TOXLOSS)

/obj/item/cultivator
	name = "cultivator"
	desc = "It's used for removing weeds or scratching your back."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "cultivator"
	item_state = "cultivator"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	origin_tech = "engineering=2;biotech=2"
	flags = CONDUCT
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=50)
	attack_verb = list("slashed", "sliced", "cut", "clawed")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/hatchet
	name = "hatchet"
	desc = "A very sharp axe blade upon a short fibremetal handle. It has a long history of chopping things, but now it is used for chopping wood."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "hatchet"
	item_state = "hatchet"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	flags = CONDUCT
	force = 12
	w_class = WEIGHT_CLASS_TINY
	throwforce = 15
	throw_speed = 3
	throw_range = 4
	materials = list(MAT_METAL = 15000)
	origin_tech = "materials=2;combat=2"
	attack_verb = list("chopped", "torn", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP

/obj/item/hatchet/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is chopping at [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return (BRUTELOSS)

/obj/item/scythe
	icon_state = "scythe0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "scythe"
	desc = "A sharp and curved blade on a long fibremetal handle, this tool makes it easy to reap what you sow."
	force = 13
	throwforce = 5
	throw_speed = 2
	throw_range = 3
	w_class = WEIGHT_CLASS_BULKY
	flags = CONDUCT
	armour_penetration = 20
	slot_flags = SLOT_BACK
	origin_tech = "materials=3;combat=2"
	attack_verb = list("chopped", "sliced", "cut", "reaped")
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/swiping = FALSE

/obj/item/scythe/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is beheading [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		var/obj/item/bodypart/BP = C.get_bodypart("head")
		if(BP)
			BP.drop_limb()
			playsound(loc,pick('sound/misc/desceration-01.ogg','sound/misc/desceration-02.ogg','sound/misc/desceration-01.ogg') ,50, 1, -1)
	return (BRUTELOSS)

/obj/item/scythe/pre_attackby(atom/A, mob/living/user, params)
	if(swiping || !istype(A, /obj/structure/spacevine) || get_turf(A) == get_turf(user))
		return ..()
	else
		var/turf/user_turf = get_turf(user)
		var/dir_to_target = get_dir(user_turf, get_turf(A))
		swiping = TRUE
		var/static/list/scythe_slash_angles = list(0, 45, 90, -45, -90)
		for(var/i in scythe_slash_angles)
			var/turf/T = get_step(user_turf, turn(dir_to_target, i))
			for(var/obj/structure/spacevine/V in T)
				if(user.Adjacent(V))
					melee_attack_chain(user, V)
		swiping = FALSE

// *************************************
// Nutrient defines for hydroponics
// *************************************


/obj/item/reagent_containers/glass/bottle/nutrient
	name = "bottle of nutrient"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	volume = 50
	w_class = WEIGHT_CLASS_TINY
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1,2,5,10,15,25,50)

/obj/item/reagent_containers/glass/bottle/nutrient/Initialize()
	. = ..()
	src.pixel_x = rand(-5, 5)
	src.pixel_y = rand(-5, 5)


/obj/item/reagent_containers/glass/bottle/nutrient/ez
	name = "bottle of E-Z-Nutrient"
	desc = "Contains a fertilizer that causes mild mutations with each harvest."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"

/obj/item/reagent_containers/glass/bottle/nutrient/ez/Initialize()
	. = ..()
	reagents.add_reagent("eznutriment", 50)

/obj/item/reagent_containers/glass/bottle/nutrient/l4z
	name = "bottle of Left 4 Zed"
	desc = "Contains a fertilizer that limits plant yields to no more than one and causes significant mutations in plants."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle18"

/obj/item/reagent_containers/glass/bottle/nutrient/l4z/Initialize()
	. = ..()
	reagents.add_reagent("left4zednutriment", 50)

/obj/item/reagent_containers/glass/bottle/nutrient/rh
	name = "bottle of Robust Harvest"
	desc = "Contains a fertilizer that increases the yield of a plant by 30% while causing no mutations."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle15"

/obj/item/reagent_containers/glass/bottle/nutrient/rh/Initialize()
	. = ..()
	reagents.add_reagent("robustharvestnutriment", 50)

/obj/item/reagent_containers/glass/bottle/nutrient/empty
	name = "bottle"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"

/obj/item/reagent_containers/glass/bottle/killer
	name = "bottle"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	volume = 50
	w_class = WEIGHT_CLASS_TINY
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1,2,5,10,15,25,50)

/obj/item/reagent_containers/glass/bottle/killer/weedkiller
	name = "bottle of weed killer"
	desc = "Contains a herbicide."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"

/obj/item/reagent_containers/glass/bottle/killer/weedkiller/Initialize()
	. = ..()
	reagents.add_reagent("weedkiller", 50)

/obj/item/reagent_containers/glass/bottle/killer/pestkiller
	name = "bottle of pest spray"
	desc = "Contains a pesticide."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle20"

/obj/item/reagent_containers/glass/bottle/killer/pestkiller/Initialize()
	. = ..()
	reagents.add_reagent("pestkiller", 50)
