// This contains all boxes that will be used on round-start spawning into a job.

// Ordinary survival box. Every crewmember gets one of these.
/obj/item/storage/box/survival
	name = "survival box"
	desc = "A box with the bare essentials of ensuring the survival of you and others."
	icon_state = "internals"
	illustration = "emergencytank"
	/// What type of mask are we going to use for this box?
	var/mask_type = /obj/item/clothing/mask/breath
	/// Which internals tank are we going to use for this box?
	var/internal_type = /obj/item/tank/internals/emergency_oxygen
	/// What medipen should be present in this box?
	var/medipen_type = /obj/item/reagent_containers/hypospray/medipen
	/// Are we crafted?
	var/crafted = FALSE

/obj/item/storage/box/survival/Initialize(mapload)
	. = ..()
	if(crafted || !HAS_TRAIT(SSstation, STATION_TRAIT_PREMIUM_INTERNALS))
		return
	atom_storage.max_slots += 2
	atom_storage.max_total_storage += 4
	name = "large [name]"
	transform = transform.Scale(1.25, 1)

/obj/item/storage/box/survival/PopulateContents()
	if(crafted)
		return
	if(!isnull(mask_type))
		new mask_type(src)

	if(!isplasmaman(loc))
		new internal_type(src)
	else
		new /obj/item/tank/internals/plasmaman/belt(src)

	if(!isnull(medipen_type))
		new medipen_type(src)

	if(HAS_TRAIT(SSstation, STATION_TRAIT_PREMIUM_INTERNALS))
		new /obj/item/flashlight/flare(src)
		new /obj/item/radio/off(src)

/obj/item/storage/box/survival/radio/PopulateContents()
	..() // we want the survival stuff too.
	new /obj/item/radio/off(src)

/obj/item/storage/box/survival/proc/wardrobe_removal()
	if(!isplasmaman(loc)) //We need to specially fill the box with plasmaman gear, since it's intended for one
		return
	var/obj/item/mask = locate(mask_type) in src
	var/obj/item/internals = locate(internal_type) in src
	new /obj/item/tank/internals/plasmaman/belt(src)
	qdel(mask) // Get rid of the items that shouldn't be
	qdel(internals)

// Mining survival box
/obj/item/storage/box/survival/mining
	mask_type = /obj/item/clothing/mask/gas/explorer/folded

/obj/item/storage/box/survival/mining/PopulateContents()
	..()
	new /obj/item/crowbar/red(src)

// Engineer survival box
/obj/item/storage/box/survival/engineer
	name = "extended-capacity survival box"
	desc = "A box with the bare essentials of ensuring the survival of you and others. This one is labelled to contain an extended-capacity tank."
	illustration = "extendedtank"
	internal_type = /obj/item/tank/internals/emergency_oxygen/engi

/obj/item/storage/box/survival/engineer/radio/PopulateContents()
	..() // we want the regular items too.
	new /obj/item/radio/off(src)

// Syndie survival box
/obj/item/storage/box/survival/syndie
	name = "operation-ready survival box"
	desc = "A box with the essentials of your operation. This one is labelled to contain an extended-capacity tank and a handy guide on survival."
	icon_state = "syndiebox"
	illustration = "extendedtank"
	mask_type = /obj/item/clothing/mask/gas/syndicate
	internal_type = /obj/item/tank/internals/emergency_oxygen/engi
	medipen_type =  /obj/item/reagent_containers/hypospray/medipen/atropine

/obj/item/storage/box/survival/syndie/PopulateContents()
	..()
	new /obj/item/tool_parcel(src)
	new /obj/item/paper/fluff/operative(src)

/obj/item/tool_parcel
	name = "operative toolkit care package"
	desc = "A small parcel. It contains a few items every operative needs."
	w_class =  WEIGHT_CLASS_SMALL
	icon = 'icons/obj/storage/wrapping.dmi'
	icon_state = "deliverypackage2"

/obj/item/tool_parcel/attack_self(mob/user)
	. = ..()
	new /obj/item/crowbar/red(get_turf(user))
	new /obj/item/screwdriver/red(get_turf(user))
	new /obj/item/weldingtool/mini(get_turf(user))
	new /obj/effect/decal/cleanable/wrapping(get_turf(user))
	if(prob(5))
		new /obj/item/storage/fancy/cigarettes/cigpack_syndicate(get_turf(user))
		new /obj/item/lighter(get_turf(user))
		to_chat(user, span_notice("...oh, someone left some cigarettes in here."))
	playsound(loc, 'sound/items/poster_ripped.ogg', 20, TRUE)
	qdel(src)

/obj/item/storage/box/survival/centcom
	name = "emergency response survival box"
	desc = "A box with the bare essentials of ensuring the survival of your team. This one is labelled to contain a double tank."
	illustration = "extendedtank"
	internal_type = /obj/item/tank/internals/emergency_oxygen/double

/obj/item/storage/box/survival/centcom/PopulateContents()
	. = ..()
	new /obj/item/crowbar(src)

// Security survival box
/obj/item/storage/box/survival/security
	mask_type = /obj/item/clothing/mask/gas/sechailer

/obj/item/storage/box/survival/security/radio/PopulateContents()
	..() // we want the regular stuff too
	new /obj/item/radio/off(src)

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
	foldable = null
	icon_state = "box"
	inhand_icon_state = null
	alpha = 0

/obj/item/storage/box/mime/attack_hand(mob/user, list/modifiers)
	..()
	if(HAS_TRAIT(user, TRAIT_MIMING))
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
	foldable = null

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

/obj/item/storage/box/clown/attackby(obj/item/I, mob/user, params)
	if((istype(I, /obj/item/bodypart/arm/left/robot)) || (istype(I, /obj/item/bodypart/arm/right/robot)))
		if(contents.len) //prevent accidently deleting contents
			balloon_alert(user, "items inside!")
			return
		if(!user.temporarilyRemoveItemFromInventory(I))
			return
		qdel(I)
		balloon_alert(user, "wheels added, honk!")
		var/obj/item/bot_assembly/honkbot/A = new
		qdel(src)
		user.put_in_hands(A)
	else
		return ..()

/obj/item/storage/box/clown/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] opens [src] and gets consumed by [p_them()]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(user, 'sound/misc/scary_horn.ogg', 70, vary = TRUE)
	forceMove(user.drop_location())
	var/obj/item/clothing/head/mob_holder/consumed = new(src, user)
	consumed.desc = "It's [user.real_name]! It looks like [user.p_they()] committed suicide!"
	return OXYLOSS

// Special stuff for medical hugboxes.
/obj/item/storage/box/hug/medical/PopulateContents()
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/reagent_containers/hypospray/medipen(src)

//Clown survival box
/obj/item/storage/box/survival/hug
	name = "box of hugs"
	desc = "A special box for sensitive people."
	icon_state = "hugbox"
	illustration = "heart"
	foldable = null
	mask_type = null

//Mime survival box
/obj/item/storage/box/survival/hug/black
	icon_state = "hugbox_black"
	illustration = "heart_black"

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
	for(var/i in 1 to 7)
		var/plush_path = /obj/effect/spawner/random/entertainment/plushie
		new plush_path(src)

/obj/item/storage/box/survival/mining/bonus
	mask_type = null
	internal_type = /obj/item/tank/internals/emergency_oxygen/double

/obj/item/storage/box/survival/mining/bonus/PopulateContents()
	..()
	new /obj/item/gps/mining(src)
	new /obj/item/t_scanner/adv_mining_scanner(src)

/obj/item/storage/box/miner_modkits
	name = "miner modkit/trophy box"
	desc = "Contains every modkit and trophy in the game."

/obj/item/storage/box/miner_modkits/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(/obj/item/borg/upgrade/modkit, /obj/item/crusher_trophy))
	atom_storage.numerical_stacking = TRUE

/obj/item/storage/box/miner_modkits/PopulateContents()
	for(var/trophy in subtypesof(/obj/item/crusher_trophy))
		new trophy(src)
	for(var/modkit in subtypesof(/obj/item/borg/upgrade/modkit))
		for(var/i in 1 to 10) //minimum cost ucrrently is 20, and 2 pkas, so lets go with that
			new modkit(src)

/obj/item/storage/box/skillchips
	name = "box of skillchips"
	desc = "Contains one copy of every skillchip"

/obj/item/storage/box/skillchips/PopulateContents()
	var/list/skillchips = subtypesof(/obj/item/skillchip)

	for(var/skillchip in skillchips)
		new skillchip(src)

/obj/item/storage/box/skillchips/science
	name = "box of science job skillchips"
	desc = "Contains spares of every science job skillchip."

/obj/item/storage/box/skillchips/science/PopulateContents()
	new/obj/item/skillchip/job/roboticist(src)
	new/obj/item/skillchip/job/roboticist(src)

/obj/item/storage/box/skillchips/engineering
	name = "box of engineering job skillchips"
	desc = "Contains spares of every engineering job skillchip."

/obj/item/storage/box/skillchips/engineering/PopulateContents()
	new/obj/item/skillchip/job/engineer(src)
	new/obj/item/skillchip/job/engineer(src)
