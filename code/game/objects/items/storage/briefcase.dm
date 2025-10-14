/obj/item/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon = 'icons/obj/storage/case.dmi'
	icon_state = "briefcase"
	inhand_icon_state = "briefcase"
	lefthand_file = 'icons/mob/inhands/equipment/briefcase_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/briefcase_righthand.dmi'
	obj_flags = CONDUCTS_ELECTRICITY
	force = 8
	hitsound = SFX_SWING_HIT
	throw_speed = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("bashes", "batters", "bludgeons", "thrashes", "whacks")
	attack_verb_simple = list("bash", "batter", "bludgeon", "thrash", "whack")
	resistance_flags = FLAMMABLE
	max_integrity = 150
	storage_type = /datum/storage/briefcase

	/// The path of the folder that gets spawned in New()
	var/folder_path = /obj/item/folder

/obj/item/storage/briefcase/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/cuffable_item)

/obj/item/storage/briefcase/PopulateContents()
	new /obj/item/pen(src)
	var/obj/item/folder/folder = new folder_path(src)
	for(var/i in 1 to 6)
		new /obj/item/paper(folder)

/obj/item/storage/briefcase/lawyer
	folder_path = /obj/item/folder/blue

/obj/item/storage/briefcase/lawyer/PopulateContents()
	new /obj/item/stamp/law(src)
	..()

/obj/item/storage/briefcase/suicide_act(mob/living/user)
	var/list/papers_found = list()
	var/turf/item_loc = get_turf(src)

	if(!item_loc)
		return OXYLOSS

	for(var/obj/item/potentially_paper in contents)
		if(istype(potentially_paper, /obj/item/paper) || istype(potentially_paper, /obj/item/paperplane))
			papers_found += potentially_paper
	if(!papers_found.len || !item_loc)
		user.visible_message(span_suicide("[user] bashes [user.p_them()]self in the head with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		return BRUTELOSS

	user.visible_message(span_suicide("[user] opens [src] and all of [user.p_their()] papers fly out!"))
	for(var/obj/item/paper as anything in papers_found)	//Throws the papers in a random direction
		var/turf/turf_to_throw_at = prob(20) ? item_loc : get_ranged_target_turf(item_loc, pick(GLOB.alldirs))
		paper.throw_at(turf_to_throw_at, 2)

	stoplag(1 SECONDS)
	user.say("ARGGHH, HOW WILL I GET THIS WORK DONE NOW?!!")
	user.visible_message(span_suicide("[user] looks overwhelmed with paperwork! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/storage/briefcase/sniper
	desc = "Its label reads \"genuine hardened Captain leather\", but suspiciously has no other tags or branding. Smells like L'Air du Temps."
	force = 10

/obj/item/storage/briefcase/sniper/PopulateContents()
	..() // in case you need any paperwork done after your rampage
	new /obj/item/gun/ballistic/rifle/sniper_rifle/syndicate(src)
	new /obj/item/clothing/neck/tie/red/hitman(src)
	new /obj/item/clothing/under/syndicate/sniper(src)
	new /obj/item/ammo_box/magazine/sniper_rounds(src)
	new /obj/item/ammo_box/magazine/sniper_rounds(src)
	new /obj/item/ammo_box/magazine/sniper_rounds/disruptor(src)

/**
 * Secure briefcase
 * Uses the lockable storage component to give it a lock.
 */
/obj/item/storage/briefcase/secure
	name = "secure briefcase"
	desc = "A large briefcase with a digital locking system."
	icon_state = "secure"
	base_icon_state = "secure"
	inhand_icon_state = "sec-case"

/obj/item/storage/briefcase/secure/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/lockable_storage)

/// Base container used for gimmick disks.
/obj/item/storage/briefcase/secure/digital_storage
	name = "digi-case"
	desc = "It's made of AUTHENTIC digital leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "secure"
	base_icon_state = "secure"
	inhand_icon_state = "sec-case"

/obj/item/storage/briefcase/secure/digital_storage/PopulateContents()
	return

///Syndie variant of Secure Briefcase. Contains space cash, slightly more robust.
/obj/item/storage/briefcase/secure/syndie
	force = 15

/obj/item/storage/briefcase/secure/syndie/PopulateContents()
	. = ..()
	for(var/iterator in 1 to 5)
		new /obj/item/stack/spacecash/c1000(src)

/// A briefcase that contains various sought-after spoils
/obj/item/storage/briefcase/secure/riches/PopulateContents()
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/gun/ballistic/automatic/pistol(src)
	new /obj/item/suppressor(src)
	new /obj/item/melee/baton/telescopic(src)
	new /obj/item/clothing/mask/balaclava(src)
	new /obj/item/bodybag(src)
	new /obj/item/soap/nanotrasen(src)

/obj/item/storage/briefcase/hitchiker/PopulateContents()
	new /obj/item/food/sandwich/peanut_butter_jelly(src)
	new /obj/item/food/sandwich/peanut_butter_jelly(src)
	new /obj/item/reagent_containers/cup/glass/waterbottle/large(src)
	new /obj/item/soap(src)
	new /obj/item/pillow/random(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/tank/internals/emergency_oxygen(src)

//Briefcase item that contains the launchpad.
/obj/item/storage/briefcase/launchpad
	var/obj/machinery/launchpad/briefcase/pad

/obj/item/storage/briefcase/launchpad/Initialize(mapload)
	pad = new(null, src) //spawns pad in nullspace to hide it from briefcase contents
	. = ..()

/obj/item/storage/briefcase/launchpad/Destroy()
	if(!QDELETED(pad))
		qdel(pad)
	pad = null
	return ..()

/obj/item/storage/briefcase/launchpad/PopulateContents()
	new /obj/item/pen(src)
	new /obj/item/launchpad_remote(src, pad)

/obj/item/storage/briefcase/launchpad/attack_self(mob/user)
	if(!isturf(user.loc)) //no setting up in a locker
		return
	add_fingerprint(user)
	user.visible_message(span_notice("[user] starts setting down [src]..."), span_notice("You start setting up [pad]..."))
	if(do_after(user, 3 SECONDS, target = user))
		pad.forceMove(get_turf(src))
		pad.update_indicator()
		pad.closed = FALSE
		user.transferItemToLoc(src, pad, TRUE)
		atom_storage.close_all()

/obj/item/storage/briefcase/launchpad/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/launchpad_remote))
		return ..()
	var/obj/item/launchpad_remote/remote = tool
	if(remote.pad == WEAKREF(src.pad))
		return ..()
	remote.pad = WEAKREF(src.pad)
	to_chat(user, span_notice("You link [pad] to [remote]."))
	return ITEM_INTERACT_BLOCKING
