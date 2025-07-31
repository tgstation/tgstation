/**
 * # Outfit datums
 *
 * This is a clean system of applying outfits to mobs, if you need to equip someone in a uniform
 * this is the way to do it cleanly and properly.
 *
 * You can also specify an outfit datum on a job to have it auto equipped to the mob on join
 *
 * /mob/living/carbon/human/proc/equipOutfit(outfit) is the mob level proc to equip an outfit
 * and you pass it the relevant datum outfit
 *
 * outfits can also be saved as json blobs downloadable by a client and then can be uploaded
 * by that user to recreate the outfit, this is used by admins to allow for custom event outfits
 * that can be restored at a later date
 */
/datum/outfit
	///Name of the outfit (shows up in the equip admin verb)
	var/name = "Naked"

	/// Type path of item to go in the idcard slot
	var/id = null

	/// Type path of ID card trim associated with this outfit.
	var/id_trim = null

	/// Type path of item to go in uniform slot
	var/uniform = null

	/// Type path of item to go in suit slot
	var/suit = null

	/**
	  * Type path of item to go in suit storage slot
	  *
	  * (make sure it's valid for that suit)
	  */
	var/suit_store = null

	/// Type path of item to go in back slot
	var/back = null

	/**
	  * list of items that should go in the backpack of the user
	  *
	  * Format of this list should be: list(path=count,otherpath=count)
	  */
	var/list/backpack_contents = null

	/// Type path of item to go in belt slot
	var/belt = null

	/**
	  * list of items that should go in the belt of the user
	  *
	  * Format of this list should be: list(path=count,otherpath=count)
	  */
	var/list/belt_contents = null

	/// Type path of item to go in ears slot
	var/ears = null

	/// Type path of item to go in the glasses slot
	var/glasses = null

	/// Type path of item to go in gloves slot
	var/gloves = null

	/// Type path of item to go in head slot
	var/head = null

	/// Type path of item to go in mask slot
	var/mask = null

	/// Type path of item to go in neck slot
	var/neck = null

	/// Type path of item to go in shoes slot
	var/shoes = null

	/// Type path of item for left pocket slot
	var/l_pocket = null

	/// Type path of item for right pocket slot
	var/r_pocket = null

	///Type path of item to go in the right hand
	var/l_hand = null

	//Type path of item to go in left hand
	var/r_hand = null

	/// Any clothing accessory item
	var/accessory = null

	/// Internals box. Will be inserted at the start of backpack_contents
	var/box

	/**
	  * extra types for chameleon outfit changes, mostly guns
	  *
	  * Valid values are a single typepath or list of typepaths
	  *
	  * These are all added and returns in the list for get_chamelon_diguise_info proc
	  */
	var/list/chameleon_extras

	/**
	  * Any implants the mob should start implanted with
	  *
	  * Format of this list is (typepath, typepath, typepath)
	  */
	var/list/implants = null

	///ID of the slot containing a gas tank
	var/internals_slot = null

	/**
	  * Any skillchips the mob should have in their brain.
	  *
	  * Format of this list is (typepath, typepath, typepath)
	  */
	var/list/skillchips = null

	///Should we preload some of this job's items?
	var/preload = FALSE

	/// Any undershirt. While on humans it is a string, here we use paths to stay consistent with the rest of the equips.
	var/datum/sprite_accessory/undershirt = null
	var/datum/sprite_accessory/underwear = null
	var/datum/sprite_accessory/socks = null

/**
 * Called at the start of the equip proc
 *
 * Override to change the value of the slots depending on client prefs, species and
 * other such sources of change
 *
 * Extra Arguments
 * * visuals_only true if this is only for display (in the character setup screen)
 *
 * If visuals_only is true, you can omit any work that doesn't visually appear on the character sprite
 */
/datum/outfit/proc/pre_equip(mob/living/carbon/human/user, visuals_only = FALSE)
	//to be overridden for customization depending on client prefs,species etc
	return

/**
 * Called after the equip proc has finished
 *
 * All items are on the mob at this point, use this proc to toggle internals
 * fiddle with id bindings and accesses etc
 *
 * Extra Arguments
 * * visuals_only true if this is only for display (in the character setup screen)
 *
 * If visuals_only is true, you can omit any work that doesn't visually appear on the character sprite
 */
/datum/outfit/proc/post_equip(mob/living/carbon/human/user, visuals_only = FALSE)
	//to be overridden for toggling internals, id binding, access etc
	return

#define EQUIP_OUTFIT_ITEM(item_path, slot_name) if(##item_path) { \
	user.equip_to_slot_or_del(SSwardrobe.provide_type(##item_path, user), ##slot_name, TRUE, indirect_action = TRUE); \
	var/obj/item/outfit_item = user.get_item_by_slot(##slot_name); \
	if (outfit_item && outfit_item.type == ##item_path) { \
		outfit_item.on_outfit_equip(user, visuals_only, ##slot_name); \
	} \
}

/**
 * Equips all defined types and paths to the mob passed in
 *
 * Extra Arguments
 * * visuals_only true if this is only for display (in the character setup screen)
 *
 * If visuals_only is true, you can omit any work that doesn't visually appear on the character sprite
 */
/datum/outfit/proc/equip(mob/living/carbon/human/user, visuals_only = FALSE)
	pre_equip(user, visuals_only)

	//Start with uniform,suit,backpack for additional slots
	if(uniform)
		EQUIP_OUTFIT_ITEM(uniform, ITEM_SLOT_ICLOTHING)
	if(suit)
		EQUIP_OUTFIT_ITEM(suit, ITEM_SLOT_OCLOTHING)
	if(belt)
		EQUIP_OUTFIT_ITEM(belt, ITEM_SLOT_BELT)
	if(gloves)
		EQUIP_OUTFIT_ITEM(gloves, ITEM_SLOT_GLOVES)
	if(shoes)
		EQUIP_OUTFIT_ITEM(shoes, ITEM_SLOT_FEET)
	if(head)
		EQUIP_OUTFIT_ITEM(head, ITEM_SLOT_HEAD)
	if(mask)
		EQUIP_OUTFIT_ITEM(mask, ITEM_SLOT_MASK)
	if(neck)
		EQUIP_OUTFIT_ITEM(neck, ITEM_SLOT_NECK)
	if(ears)
		EQUIP_OUTFIT_ITEM(ears, ITEM_SLOT_EARS)
	if(glasses)
		EQUIP_OUTFIT_ITEM(glasses, ITEM_SLOT_EYES)
	if(back)
		EQUIP_OUTFIT_ITEM(back, ITEM_SLOT_BACK)
	if(id)
		EQUIP_OUTFIT_ITEM(id, ITEM_SLOT_ID)
	if(!visuals_only && id_trim && user.wear_id)
		var/obj/item/card/id/id_card = user.wear_id
		if(!istype(id_card)) //If an ID wasn't found in their ID slot, it's probably something holding their ID like a wallet or PDA
			id_card = locate() in user.wear_id

		if(istype(id_card)) //Make sure that we actually found an ID to modify, otherwise this runtimes and cancels equipping the outfit
			id_card.registered_age = user.age
			if(id_trim)
				if(!SSid_access.apply_trim_to_card(id_card, id_trim))
					WARNING("Unable to apply trim [id_trim] to [id_card] in outfit [name].")
				user.update_ID_card()

	if(suit_store)
		EQUIP_OUTFIT_ITEM(suit_store, ITEM_SLOT_SUITSTORE)

	if(undershirt)
		user.undershirt = initial(undershirt.name)

	if(underwear)
		user.underwear = initial(underwear.name)

	if(socks)
		user.socks = initial(socks.name)

	if(accessory)
		var/obj/item/clothing/under/U = user.w_uniform
		if(U)
			U.attach_accessory(SSwardrobe.provide_type(accessory, user))
		else
			WARNING("Unable to equip accessory [accessory] in outfit [name]. No uniform present!")

	if(l_hand)
		user.put_in_l_hand(SSwardrobe.provide_type(l_hand, user), visuals_only = visuals_only)
	if(r_hand)
		user.put_in_r_hand(SSwardrobe.provide_type(r_hand, user), visuals_only = visuals_only)

	if(!visuals_only) // Items in pockets or backpack don't show up on mob's icon.
		if(l_pocket)
			EQUIP_OUTFIT_ITEM(l_pocket, ITEM_SLOT_LPOCKET)
		if(r_pocket)
			EQUIP_OUTFIT_ITEM(r_pocket, ITEM_SLOT_RPOCKET)

		if(box)
			if(!backpack_contents)
				backpack_contents = list()
			backpack_contents.Insert(1, box)
			backpack_contents[box] = 1

		if(backpack_contents)
			for(var/path in backpack_contents)
				var/number = backpack_contents[path]
				if(!isnum(number))//Default to 1
					number = 1
				for(var/i in 1 to number)
					user.equip_to_storage(SSwardrobe.provide_type(path, user), ITEM_SLOT_BACK, indirect_action = TRUE, del_on_fail = TRUE)

		if(belt_contents)
			for(var/path in belt_contents)
				var/number = belt_contents[path]
				if(!isnum(number))//Default to 1
					number = 1
				for(var/i in 1 to number)
					user.equip_to_storage(SSwardrobe.provide_type(path, user), ITEM_SLOT_BELT, indirect_action = TRUE, del_on_fail = TRUE)

	post_equip(user, visuals_only)

	if(!visuals_only)
		apply_fingerprints(user)
		if(internals_slot)
			if(internals_slot & ITEM_SLOT_HANDS)
				var/obj/item/tank/internals/internals = user.is_holding_item_of_type(/obj/item/tank/internals)
				if(internals)
					user.open_internals(internals)
			else
				user.open_internals(user.get_item_by_slot(internals_slot))
		if(implants)
			for(var/implant_type in implants)
				var/obj/item/implant/implanter = SSwardrobe.provide_type(implant_type, user)
				implanter.implant(user, null, TRUE)

		// Insert the skillchips associated with this outfit into the target.
		if(skillchips)
			for(var/skillchip_path in skillchips)
				var/obj/item/skillchip/skillchip_instance = SSwardrobe.provide_type(skillchip_path)
				var/implant_msg = user.implant_skillchip(skillchip_instance)
				if(implant_msg)
					stack_trace("Failed to implant [user] with [skillchip_instance], on job [src]. Failure message: [implant_msg]")
					qdel(skillchip_instance)
					return

				var/activate_msg = skillchip_instance.try_activate_skillchip(TRUE, TRUE)
				if(activate_msg)
					CRASH("Failed to activate [user]'s [skillchip_instance], on job [src]. Failure message: [activate_msg]")


	user.update_body()
	return TRUE

#undef EQUIP_OUTFIT_ITEM

/**
 * Apply a fingerprint from the passed in human to all items in the outfit
 *
 * Used for forensics setup when the mob is first equipped at roundstart
 * essentially calls add_fingerprint to every defined item on the human
 *
 */
/datum/outfit/proc/apply_fingerprints(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(user.back)
		user.back.add_fingerprint(user, ignoregloves = TRUE)
		for(var/obj/item/item in user.back.contents)
			item.add_fingerprint(user, ignoregloves = TRUE)
	if(user.wear_id)
		user.wear_id.add_fingerprint(user, ignoregloves = TRUE)
	if(user.w_uniform)
		user.w_uniform.add_fingerprint(user, ignoregloves = TRUE)
	if(user.wear_suit)
		user.wear_suit.add_fingerprint(user, ignoregloves = TRUE)
	if(user.wear_mask)
		user.wear_mask.add_fingerprint(user, ignoregloves = TRUE)
	if(user.wear_neck)
		user.wear_neck.add_fingerprint(user, ignoregloves = TRUE)
	if(user.head)
		user.head.add_fingerprint(user, ignoregloves = TRUE)
	if(user.shoes)
		user.shoes.add_fingerprint(user, ignoregloves = TRUE)
	if(user.gloves)
		user.gloves.add_fingerprint(user, ignoregloves = TRUE)
	if(user.ears)
		user.ears.add_fingerprint(user, ignoregloves = TRUE)
	if(user.glasses)
		user.glasses.add_fingerprint(user, ignoregloves = TRUE)
	if(user.belt)
		user.belt.add_fingerprint(user, ignoregloves = TRUE)
		for(var/obj/item/item in user.belt.contents)
			item.add_fingerprint(user, ignoregloves = TRUE)
	if(user.s_store)
		user.s_store.add_fingerprint(user, ignoregloves = TRUE)
	if(user.l_store)
		user.l_store.add_fingerprint(user, ignoregloves = TRUE)
	if(user.r_store)
		user.r_store.add_fingerprint(user, ignoregloves = TRUE)
	for(var/obj/item/item in user.held_items)
		item.add_fingerprint(user, ignoregloves = TRUE)
	return TRUE

/// Return a list of all the types that are required to disguise as this outfit type
/datum/outfit/proc/get_chameleon_disguise_info()
	var/list/types = list(uniform, suit, back, belt, gloves, shoes, head, mask, neck, ears, glasses, id, l_pocket, r_pocket, suit_store, r_hand, l_hand)
	types += chameleon_extras
	types += skillchips
	list_clear_nulls(types)
	return types

/// Return a list of types to pregenerate for later equipping
/// This should not be things that do unique stuff in Initialize() based off their location, since we'll be storing them for a while
/datum/outfit/proc/get_types_to_preload()
	var/list/preload = list()
	preload += id
	preload += uniform
	preload += suit
	preload += suit_store
	preload += back
	//Load in backpack gear and shit
	for(var/type_to_load in backpack_contents)
		var/num_to_load = backpack_contents[type_to_load]
		if(!isnum(num_to_load))
			num_to_load = 1
		for(var/i in 1 to num_to_load)
			preload += type_to_load
	//Load in belt gear and shit
	for(var/type_to_load in belt_contents)
		var/num_to_load = belt_contents[type_to_load]
		if(!isnum(num_to_load))
			num_to_load = 1
		for(var/i in 1 to num_to_load)
			preload += type_to_load
	preload += belt
	preload += ears
	preload += glasses
	preload += gloves
	preload += head
	preload += mask
	preload += neck
	preload += shoes
	preload += l_pocket
	preload += r_pocket
	preload += l_hand
	preload += r_hand
	preload += accessory
	preload += box
	for(var/implant_type in implants)
		preload += implant_type
	for(var/skillpath in skillchips)
		preload += skillpath

	return preload

/// Return a json list of this outfit
/datum/outfit/proc/get_json_data()
	. = list()
	.["outfit_type"] = type
	.["name"] = name
	.["uniform"] = uniform
	.["suit"] = suit
	.["back"] = back
	.["belt"] = belt
	.["gloves"] = gloves
	.["shoes"] = shoes
	.["head"] = head
	.["mask"] = mask
	.["neck"] = neck
	.["ears"] = ears
	.["glasses"] = glasses
	.["id"] = id
	.["id_trim"] = id_trim
	.["l_pocket"] = l_pocket
	.["r_pocket"] = r_pocket
	.["suit_store"] = suit_store
	.["r_hand"] = r_hand
	.["l_hand"] = l_hand
	.["internals_slot"] = internals_slot
	.["backpack_contents"] = backpack_contents
	.["belt_contents"] = belt_contents
	.["box"] = box
	.["implants"] = implants
	.["accessory"] = accessory

/// Copy most vars from another outfit to this one
/datum/outfit/proc/copy_from(datum/outfit/target)
	name = target.name
	uniform = target.uniform
	suit = target.suit
	back = target.back
	belt = target.belt
	gloves = target.gloves
	shoes = target.shoes
	head = target.head
	mask = target.mask
	neck = target.neck
	ears = target.ears
	glasses = target.glasses
	id = target.id
	id_trim = target.id_trim
	l_pocket = target.l_pocket
	r_pocket = target.r_pocket
	suit_store = target.suit_store
	r_hand = target.r_hand
	l_hand = target.l_hand
	internals_slot = target.internals_slot
	backpack_contents = target.backpack_contents
	belt_contents = target.belt_contents
	box = target.box
	implants = target.implants
	accessory = target.accessory

/// Prompt the passed in mob client to download this outfit as a json blob
/datum/outfit/proc/save_to_file(mob/admin)
	var/stored_data = get_json_data()
	var/json = json_encode(stored_data)
	//Kinda annoying but as far as i can tell you need to make actual file.
	var/f = file("data/TempOutfitUpload")
	fdel(f)
	WRITE_FILE(f,json)
	admin << ftp(f,"[name].json")

/// Create an outfit datum from a list of json data
/datum/outfit/proc/load_from(list/outfit_data)
	//This could probably use more strict validation
	name = outfit_data["name"]
	uniform = text2path(outfit_data["uniform"])
	suit = text2path(outfit_data["suit"])
	back = text2path(outfit_data["back"])
	belt = text2path(outfit_data["belt"])
	gloves = text2path(outfit_data["gloves"])
	shoes = text2path(outfit_data["shoes"])
	head = text2path(outfit_data["head"])
	mask = text2path(outfit_data["mask"])
	neck = text2path(outfit_data["neck"])
	ears = text2path(outfit_data["ears"])
	glasses = text2path(outfit_data["glasses"])
	id = text2path(outfit_data["id"])
	id_trim = text2path(outfit_data["id_trim"])
	l_pocket = text2path(outfit_data["l_pocket"])
	r_pocket = text2path(outfit_data["r_pocket"])
	suit_store = text2path(outfit_data["suit_store"])
	r_hand = text2path(outfit_data["r_hand"])
	l_hand = text2path(outfit_data["l_hand"])
	internals_slot = outfit_data["internals_slot"]
	var/list/backpack = outfit_data["backpack_contents"]
	backpack_contents = list()
	for(var/item in backpack)
		var/itype = text2path(item)
		if(itype)
			backpack_contents[itype] = backpack[item]
	var/list/beltpack = outfit_data["belt_contents"]
	belt_contents = list()
	for(var/item in beltpack)
		var/itype = text2path(item)
		if(itype)
			belt_contents[itype] = belt[item]
	box = text2path(outfit_data["box"])
	var/list/impl = outfit_data["implants"]
	implants = list()
	for(var/I in impl)
		var/imptype = text2path(I)
		if(imptype)
			implants += imptype
	accessory = text2path(outfit_data["accessory"])
	return TRUE

/datum/outfit/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---")
	VV_DROPDOWN_OPTION(VV_HK_TO_OUTFIT_EDITOR, "Outfit Editor")

/datum/outfit/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_TO_OUTFIT_EDITOR])
		if(!check_rights(NONE))
			return
		usr.client.open_outfit_editor(src)
