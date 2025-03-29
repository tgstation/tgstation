// This contains all boxes that will be used on round-start spawning into a job.

// Ordinary survival box. Every crewmember gets one of these.
/obj/item/storage/box/survival
	name = "survival box"
	desc = "A box with the bare essentials of ensuring the survival of you and others."
	icon_state = "internals"
	illustration = "emergencytank"
	storage_type = /datum/storage/box/survival

	/// What type of mask are we going to use for this box?
	var/mask_type = /obj/item/clothing/mask/breath
	/// Which internals tank are we going to use for this box?
	var/internal_type = /obj/item/tank/internals/emergency_oxygen
	/// What medipen should be present in this box?
	var/medipen_type = /obj/item/reagent_containers/hypospray/medipen
	/// Are we crafted?
	var/crafted = FALSE
	/// Should we contain an escape hook on maps with z-levels?
	var/give_hook = TRUE
	/// Do we get to benefit from Nanotrasen's largesse?
	var/give_premium_goods = TRUE

/obj/item/storage/box/survival/PopulateContents()
	if(crafted)
		return NONE

	. = list()
	if(!isnull(mask_type))
		. += mask_type

	if(!isnull(internal_type))
		. += internal_type

	if(!isnull(medipen_type))
		. += medipen_type

	if(give_premium_goods && HAS_TRAIT(SSstation, STATION_TRAIT_PREMIUM_INTERNALS))
		. += /obj/item/flashlight/flare
		. += /obj/item/radio/off

	if(HAS_TRAIT(SSstation, STATION_TRAIT_RADIOACTIVE_NEBULA))
		. += /obj/item/storage/pill_bottle/potassiodide

	if(give_hook && length(SSmapping.levels_by_trait(ZTRAIT_STATION)) > 1)
		. += /obj/item/climbing_hook/emergency

/obj/item/storage/box/survival/radio/PopulateContents()
	. = ..() // we want the survival stuff too.
	. += /obj/item/radio/off

/obj/item/storage/box/survival/proc/wardrobe_removal()
	if(!isplasmaman(loc)) //We need to specially fill the box with plasmaman gear, since it's intended for one
		return
	var/obj/item/mask = locate(mask_type) in src
	var/obj/item/internals = locate(internal_type) in src
	new /obj/item/tank/internals/plasmaman/belt(src)
	qdel(mask) // Get rid of the items that shouldn't be
	qdel(internals)

// Prisoners don't get an escape hook
/obj/item/storage/box/survival/prisoner
	give_hook = FALSE
	give_premium_goods = FALSE

// Mining survival box
/obj/item/storage/box/survival/mining
	mask_type = /obj/item/clothing/mask/gas/explorer/folded

/obj/item/storage/box/survival/mining/PopulateContents()
	. = ..()
	. += /obj/item/crowbar/red
	. += /obj/item/healthanalyzer/simple/miner

// Engineer survival box
/obj/item/storage/box/survival/engineer
	name = "extended-capacity survival box"
	desc = "A box with the bare essentials of ensuring the survival of you and others. This one is labelled to contain an extended-capacity tank."
	illustration = "extendedtank"
	internal_type = /obj/item/tank/internals/emergency_oxygen/engi

/obj/item/storage/box/survival/engineer/radio/PopulateContents()
	. = ..() // we want the regular items too.
	. += /obj/item/radio/off

// Syndie survival box
/obj/item/storage/box/survival/syndie
	name = "operation-ready survival box"
	desc = "A box with the essentials of your operation. This one is labelled to contain an extended-capacity tank and a handy guide on survival."
	icon_state = "syndiebox"
	illustration = "extendedtank"
	mask_type = /obj/item/clothing/mask/gas/syndicate
	internal_type = /obj/item/tank/internals/emergency_oxygen/engi
	medipen_type = /obj/item/reagent_containers/hypospray/medipen/atropine

/obj/item/storage/box/survival/syndie/PopulateContents(datum/storage_config/config)
	config.compute_max_item_count = TRUE

	. = ..()
	. += /obj/item/crowbar/red
	. += /obj/item/screwdriver/red
	. += /obj/item/weldingtool/mini
	. += /obj/item/paper/fluff/operative

/obj/item/storage/box/survival/centcom
	name = "emergency response survival box"
	desc = "A box with the bare essentials of ensuring the survival of your team. This one is labelled to contain a double tank."
	illustration = "extendedtank"
	internal_type = /obj/item/tank/internals/emergency_oxygen/double

/obj/item/storage/box/survival/centcom/PopulateContents()
	. = ..()
	. += /obj/item/crowbar

// Security survival box
/obj/item/storage/box/survival/security
	mask_type = /obj/item/clothing/mask/gas/sechailer

/obj/item/storage/box/survival/security/radio/PopulateContents()
	. = ..() // we want the regular stuff too
	. += /obj/item/radio/off

// Medical survival box
/obj/item/storage/box/survival/medical
	mask_type = /obj/item/clothing/mask/breath/medical

/obj/item/storage/box/survival/crafted
	crafted = TRUE

/obj/item/storage/box/survival/engineer/crafted
	crafted = TRUE

//Mime spell boxes

/obj/item/storage/box/mime
	name = "invisible box"
	desc = "Unfortunately not large enough to trap the mime."
	foldable_result = null
	icon_state = "box"
	inhand_icon_state = null
	alpha = 0

/obj/item/storage/box/mime/attack_hand(mob/user, list/modifiers)
	..()
	if(HAS_MIND_TRAIT(user, TRAIT_MIMING))
		alpha = 255

/obj/item/storage/box/mime/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	if (iscarbon(old_loc))
		alpha = 0
	return ..()

/obj/item/storage/box/hug
	name = "box of hugs"
	desc = "A special box for sensitive people."
	icon_state = "hugbox"
	illustration = "heart"
	foldable_result = null

/obj/item/storage/box/hug/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] clamps the box of hugs on [user.p_their()] jugular! Guess it wasn't such a hugbox after all.."))
	return BRUTELOSS

/obj/item/storage/box/hug/attack_self(mob/user)
	..()
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, SFX_RUSTLE, 50, vary=TRUE, extrarange=-5)
	user.visible_message(span_notice("[user] hugs [src]."),span_notice("You hug [src]."))

/obj/item/storage/box/hug/black
	icon_state = "hugbox_black"
	illustration = "heart_black"

// clown box, we also use this for the honk bot assembly
/obj/item/storage/box/clown
	name = "clown box"
	desc = "A colorful cardboard box for the clown"
	illustration = "clown"

/obj/item/storage/box/clown/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/bodypart/arm/left/robot) && !istype(tool, /obj/item/bodypart/arm/right/robot))
		return ..()
	if(contents.len) //prevent accidently deleting contents
		balloon_alert(user, "items inside!")
		return ITEM_INTERACT_BLOCKING
	if(!user.temporarilyRemoveItemFromInventory(tool))
		return ITEM_INTERACT_BLOCKING
	qdel(tool)
	loc.balloon_alert(user, "wheels added, honk!")
	var/obj/item/bot_assembly/honkbot/A = new
	qdel(src)
	user.put_in_hands(A)
	return ITEM_INTERACT_SUCCESS

/obj/item/storage/box/clown/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] opens [src] and gets consumed by [p_them()]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(user, 'sound/misc/scary_horn.ogg', 70, vary = TRUE)
	forceMove(user.drop_location())
	var/obj/item/clothing/head/mob_holder/consumed = new(src, user)
	consumed.desc = "It's [user.real_name]! It looks like [user.p_they()] committed suicide!"
	return OXYLOSS

// Special stuff for medical hugboxes.
/obj/item/storage/box/hug/medical/PopulateContents()
	return list(
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/ointment,
		/obj/item/reagent_containers/hypospray/medipen,
	)

//Clown survival box
/obj/item/storage/box/survival/hug
	name = "box of hugs"
	desc = "A special box for sensitive people."
	icon_state = "hugbox"
	illustration = "heart"
	foldable_result = null
	mask_type = null
	var/random_funny_internals = TRUE

/obj/item/storage/box/survival/hug/PopulateContents()
	if(!random_funny_internals)
		return ..()

	internal_type = pick(
		/obj/item/tank/internals/emergency_oxygen/engi/clown/n2o,
		/obj/item/tank/internals/emergency_oxygen/engi/clown/bz,
		/obj/item/tank/internals/emergency_oxygen/engi/clown/helium,
	)

	return ..()

//Mime survival box
/obj/item/storage/box/survival/hug/black
	icon_state = "hugbox_black"
	illustration = "heart_black"
	random_funny_internals = FALSE

//Duplicated suicide/attack self procs, since the survival boxes are a subtype of box/survival
/obj/item/storage/box/survival/hug/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] clamps the box of hugs on [user.p_their()] jugular! Guess it wasn't such a hugbox after all.."))
	return BRUTELOSS

/obj/item/storage/box/survival/hug/attack_self(mob/user)
	..()
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, SFX_RUSTLE, 50, vary=TRUE, extrarange=-5)
	user.visible_message(span_notice("[user] hugs [src]."),span_notice("You hug [src]."))

/obj/item/storage/box/hug/plushes
	name = "tactical cuddle kit"
	desc = "A lovely little box filled with soft, cute plushies, perfect for calming down people who have just suffered a traumatic event. Legend has it there's a special part of hell \
	for Medical Officers who just take the box for themselves."

/obj/item/storage/box/hug/plushes/PopulateContents()
	for(var/_ in 1 to 7)
		new /obj/effect/spawner/random/entertainment/plushie(src)

	. = list()
	for(var/obj/item/insert as anything in src)
		insert.moveToNullspace()
		. += insert

/obj/item/storage/box/survival/mining/bonus
	mask_type = null
	internal_type = /obj/item/tank/internals/emergency_oxygen/double

/obj/item/storage/box/survival/mining/bonus/PopulateContents()
	. = ..()
	. += /obj/item/gps/mining
	. += /obj/item/t_scanner/adv_mining_scanner

/obj/item/storage/box/miner_modkits
	name = "miner modkit/trophy box"
	desc = "Contains every modkit and trophy in the game."
	storage_type = /datum/storage/box/minor_modkits

/obj/item/storage/box/miner_modkits/PopulateContents(datum/storage_config/config)
	config.compute_max_values()

	. = list()
	for(var/trophy in subtypesof(/obj/item/crusher_trophy))
		. += trophy
	for(var/modkit in subtypesof(/obj/item/borg/upgrade/modkit))
		for(var/i in 1 to 10) //minimum cost ucrrently is 20, and 2 pkas, so lets go with that
			. += modkit

/obj/item/storage/box/skillchips
	name = "box of skillchips"
	desc = "Contains one copy of every skillchip"

/obj/item/storage/box/skillchips/PopulateContents(datum/storage_config/config)
	config.compute_max_values()

	return subtypesof(/obj/item/skillchip)

/obj/item/storage/box/skillchips/science
	name = "box of science job skillchips"
	desc = "Contains spares of every science job skillchip."

/obj/item/storage/box/skillchips/science/PopulateContents()
	return list(
		/obj/item/skillchip/job/roboticist,
		/obj/item/skillchip/job/roboticist,
	)

/obj/item/storage/box/skillchips/engineering
	name = "box of engineering job skillchips"
	desc = "Contains spares of every engineering job skillchip."

/obj/item/storage/box/skillchips/engineering/PopulateContents()
	return list(
		/obj/item/skillchip/job/engineer,
		/obj/item/skillchip/job/engineer,
	)

///Chaplin boxes
/obj/item/storage/box/itemset/crusader/blue/PopulateContents(datum/storage_config/config)
	config.contents_are_exceptions = TRUE
	config.compute_max_item_weight = TRUE
	config.compute_max_total_weight = TRUE

	return list(
		/obj/item/clothing/suit/chaplainsuit/armor/crusader/blue,
		/obj/item/clothing/head/helmet/plate/crusader/blue,
		/obj/item/clothing/gloves/plate/blue,
		/obj/item/clothing/shoes/plate/blue,
	)

/obj/item/storage/box/itemset/crusader/red/PopulateContents(datum/storage_config/config)
	config.contents_are_exceptions = TRUE
	config.compute_max_item_weight = TRUE
	config.compute_max_total_weight = TRUE

	return list(
		/obj/item/clothing/suit/chaplainsuit/armor/crusader/red,
		/obj/item/clothing/head/helmet/plate/crusader/red,
		/obj/item/clothing/gloves/plate/red,
		/obj/item/clothing/shoes/plate/red,
	)
