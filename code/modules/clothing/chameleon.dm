#define EMP_RANDOMISE_TIME 300

/datum/action/item_action/chameleon/drone/randomise
	name = "Randomise Headgear"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "random"

/datum/action/item_action/chameleon/drone/randomise/Trigger(trigger_flags)
	if(!IsAvailable(feedback = TRUE))
		return

	// Damn our lack of abstract interfeces
	if (istype(target, /obj/item/clothing/head/chameleon/drone))
		var/obj/item/clothing/head/chameleon/drone/X = target
		X.chameleon_action.random_look(owner)
	if (istype(target, /obj/item/clothing/mask/chameleon/drone))
		var/obj/item/clothing/mask/chameleon/drone/Z = target
		Z.chameleon_action.random_look(owner)

	return 1


/datum/action/item_action/chameleon/drone/togglehatmask
	name = "Toggle Headgear Mode"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'

/datum/action/item_action/chameleon/drone/togglehatmask/New()
	..()

	if (istype(target, /obj/item/clothing/head/chameleon/drone))
		button_icon_state = "drone_camogear_helm"
	if (istype(target, /obj/item/clothing/mask/chameleon/drone))
		button_icon_state = "drone_camogear_mask"

/datum/action/item_action/chameleon/drone/togglehatmask/Trigger(trigger_flags)
	if(!IsAvailable(feedback = TRUE))
		return

	// No point making the code more complicated if no non-drone
	// is ever going to use one of these

	var/mob/living/simple_animal/drone/D

	if(isdrone(owner))
		D = owner
	else
		return

	// The drone unEquip() proc sets head to null after dropping
	// an item, so we need to keep a reference to our old headgear
	// to make sure it's deleted.
	var/obj/old_headgear = target
	var/obj/new_headgear

	if(istype(old_headgear, /obj/item/clothing/head/chameleon/drone))
		new_headgear = new /obj/item/clothing/mask/chameleon/drone()
	else if(istype(old_headgear, /obj/item/clothing/mask/chameleon/drone))
		new_headgear = new /obj/item/clothing/head/chameleon/drone()
	else
		to_chat(owner, span_warning("You shouldn't be able to toggle a camogear helmetmask if you're not wearing it."))
	if(new_headgear)
		// Force drop the item in the headslot, even though
		// it's has TRAIT_NODROP
		D.dropItemToGround(target, TRUE)
		qdel(old_headgear)
		// where is `ITEM_SLOT_HEAD` defined? WHO KNOWS
		D.equip_to_slot(new_headgear, ITEM_SLOT_HEAD)
	return 1


/datum/action/chameleon_outfit
	name = "Select Chameleon Outfit"
	button_icon_state = "chameleon_outfit"
	var/list/outfit_options //By default, this list is shared between all instances. It is not static because if it were, subtypes would not be able to have their own. If you ever want to edit it, copy it first.

/datum/action/chameleon_outfit/New()
	..()
	initialize_outfits()

/datum/action/chameleon_outfit/proc/initialize_outfits()
	var/static/list/standard_outfit_options
	if(!standard_outfit_options)
		standard_outfit_options = list()
		for(var/path in subtypesof(/datum/outfit/job))
			var/datum/outfit/O = path
			standard_outfit_options[initial(O.name)] = path
		sortTim(standard_outfit_options, GLOBAL_PROC_REF(cmp_text_asc))
	outfit_options = standard_outfit_options

/datum/action/chameleon_outfit/Trigger(trigger_flags)
	return select_outfit(owner)

/datum/action/chameleon_outfit/proc/select_outfit(mob/user)
	if(!user || !IsAvailable(feedback = TRUE))
		return FALSE
	var/selected = tgui_input_list(user, "Select outfit to change into", "Chameleon Outfit", outfit_options)
	if(isnull(selected))
		return FALSE
	if(!IsAvailable(feedback = TRUE) || QDELETED(src) || QDELETED(user))
		return FALSE
	if(isnull(outfit_options[selected]))
		return FALSE
	var/outfit_type = outfit_options[selected]
	var/datum/outfit/job/O = new outfit_type()
	var/list/outfit_types = O.get_chameleon_disguise_info()
	var/datum/job/job_datum = SSjob.GetJobType(O.jobtype)

	for(var/V in user.chameleon_item_actions)
		var/datum/action/item_action/chameleon/change/A = V
		var/done = FALSE
		for(var/T in outfit_types)
			for(var/name in A.chameleon_list)
				if(A.chameleon_list[name] == T)
					A.apply_job_data(job_datum)
					A.update_look(user, T)
					outfit_types -= T
					done = TRUE
					break
			if(done)
				break

	//suit hoods
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		//make sure they are actually wearing the suit, not just holding it, and that they have a chameleon hat
		if(istype(H.wear_suit, /obj/item/clothing/suit/chameleon) && istype(H.head, /obj/item/clothing/head/chameleon))
			var/helmet_type
			if(ispath(O.suit, /obj/item/clothing/suit/hooded))
				var/obj/item/clothing/suit/hooded/hooded = O.suit
				helmet_type = initial(hooded.hoodtype)
			if(helmet_type)
				var/obj/item/clothing/head/chameleon/hat = H.head
				hat.chameleon_action.update_look(user, helmet_type)
	qdel(O)
	return TRUE


/datum/action/item_action/chameleon/change
	name = "Chameleon Change"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED
	var/list/chameleon_blacklist = list() //This is a typecache
	var/list/chameleon_list = list()
	var/chameleon_type = null
	var/chameleon_name = "Item"

	var/emp_timer

/datum/action/item_action/chameleon/change/Grant(mob/M)
	if(M && (owner != M))
		if(!M.chameleon_item_actions)
			M.chameleon_item_actions = list(src)
			var/datum/action/chameleon_outfit/O = new /datum/action/chameleon_outfit()
			O.Grant(M)
		else
			M.chameleon_item_actions |= src
	..()

/datum/action/item_action/chameleon/change/Remove(mob/M)
	if(M && (M == owner))
		LAZYREMOVE(M.chameleon_item_actions, src)
		if(!LAZYLEN(M.chameleon_item_actions))
			var/datum/action/chameleon_outfit/O = locate(/datum/action/chameleon_outfit) in M.actions
			qdel(O)
	..()

/datum/action/item_action/chameleon/change/proc/initialize_disguises()
	name = "Change [chameleon_name] Appearance"
	build_all_button_icons()

	chameleon_blacklist |= typecacheof(target.type)
	for(var/V in typesof(chameleon_type))
		if(ispath(V) && ispath(V, /obj/item))
			var/obj/item/I = V
			if(chameleon_blacklist[V] || (initial(I.item_flags) & ABSTRACT) || !initial(I.icon_state))
				continue
			var/chameleon_item_name = "[initial(I.name)] ([initial(I.icon_state)])"
			chameleon_list[chameleon_item_name] = I


/datum/action/item_action/chameleon/change/proc/select_look(mob/user)
	var/obj/item/picked_item
	var/picked_name = tgui_input_list(user, "Select [chameleon_name] to change into", "Chameleon Settings", sort_list(chameleon_list, GLOBAL_PROC_REF(cmp_typepaths_asc)))
	if(isnull(picked_name))
		return
	if(isnull(chameleon_list[picked_name]))
		return
	picked_item = chameleon_list[picked_name]
	update_look(user, picked_item)

/datum/action/item_action/chameleon/change/proc/random_look(mob/user)
	var/picked_name = pick(chameleon_list)
	// If a user is provided, then this item is in use, and we
	// need to update our icons and stuff

	if(user)
		update_look(user, chameleon_list[picked_name])

	// Otherwise, it's likely a random initialisation, so we
	// don't have to worry

	else
		update_item(chameleon_list[picked_name])

/datum/action/item_action/chameleon/change/proc/update_look(mob/user, obj/item/picked_item)
	if(istype(target, /obj/item/gun/energy/laser/chameleon))
		var/obj/item/gun/energy/laser/chameleon/chameleon_gun = target
		chameleon_gun.set_chameleon_disguise(picked_item)
	if(isliving(user))
		var/mob/living/C = user
		if(C.stat != CONSCIOUS)
			return

		update_item(picked_item)
		var/obj/item/thing = target
		thing.update_slot_icon()
	build_all_button_icons()

/datum/action/item_action/chameleon/change/proc/update_item(obj/item/picked_item)
	var/atom/atom_target = target
	atom_target.name = initial(picked_item.name)
	atom_target.desc = initial(picked_item.desc)
	atom_target.icon_state = initial(picked_item.icon_state)
	if(isitem(atom_target))
		var/obj/item/item_target = target
		item_target.worn_icon = initial(picked_item.worn_icon)
		item_target.lefthand_file = initial(picked_item.lefthand_file)
		item_target.righthand_file = initial(picked_item.righthand_file)
		if(initial(picked_item.greyscale_colors))
			if(initial(picked_item.greyscale_config_worn))
				item_target.worn_icon = SSgreyscale.GetColoredIconByType(initial(picked_item.greyscale_config_worn), initial(picked_item.greyscale_colors))
			if(initial(picked_item.greyscale_config_inhand_left))
				item_target.lefthand_file = SSgreyscale.GetColoredIconByType(initial(picked_item.greyscale_config_inhand_left), initial(picked_item.greyscale_colors))
			if(initial(picked_item.greyscale_config_inhand_right))
				item_target.righthand_file = SSgreyscale.GetColoredIconByType(initial(picked_item.greyscale_config_inhand_right), initial(picked_item.greyscale_colors))
		item_target.worn_icon_state = initial(picked_item.worn_icon_state)
		item_target.inhand_icon_state = initial(picked_item.inhand_icon_state)
		if(isclothing(item_target) && ispath(picked_item, /obj/item/clothing))
			var/obj/item/clothing/clothing_target = item_target
			var/obj/item/clothing/picked_clothing = picked_item
			clothing_target.flags_cover = initial(picked_clothing.flags_cover)
	if(initial(picked_item.greyscale_config) && initial(picked_item.greyscale_colors))
		atom_target.icon = SSgreyscale.GetColoredIconByType(initial(picked_item.greyscale_config), initial(picked_item.greyscale_colors))
	else
		atom_target.icon = initial(picked_item.icon)

/datum/action/item_action/chameleon/change/Trigger(trigger_flags)
	if(!IsAvailable(feedback = TRUE))
		return

	select_look(owner)
	return 1

/datum/action/item_action/chameleon/change/proc/emp_randomise(amount = EMP_RANDOMISE_TIME)
	START_PROCESSING(SSprocessing, src)
	random_look(owner)

	var/new_value = world.time + amount
	if(new_value > emp_timer)
		emp_timer = new_value

/datum/action/item_action/chameleon/change/process()
	if(world.time > emp_timer)
		STOP_PROCESSING(SSprocessing, src)
		return
	random_look(owner)

/datum/action/item_action/chameleon/change/proc/apply_job_data(datum/job/job_datum)
	return

/datum/action/item_action/chameleon/change/id/update_item(obj/item/picked_item)
	..()
	var/obj/item/card/id/advanced/chameleon/agent_card = target
	if(istype(agent_card))
		var/obj/item/card/id/copied_card = picked_item

		// If the outfit comes with a special trim override, we'll steal some stuff from that.
		var/new_trim = initial(copied_card.trim)

		if(new_trim)
			SSid_access.apply_trim_to_chameleon_card(agent_card, new_trim, TRUE)

		// If the ID card hasn't been forged, we'll check if there has been an assignment set already by any new trim.
		// If there has not, we set the assignment to the copied card's default as well as copying over the the
		// default registered name from the copied card.
		if(!agent_card.forged)
			if(!agent_card.assignment)
				agent_card.assignment = initial(copied_card.assignment)

			agent_card.registered_name = initial(copied_card.registered_name)

		agent_card.icon_state = initial(copied_card.icon_state)
		if(ispath(copied_card, /obj/item/card/id/advanced))
			var/obj/item/card/id/advanced/copied_advanced_card = copied_card
			agent_card.assigned_icon_state = initial(copied_advanced_card.assigned_icon_state)

		agent_card.update_label()
		agent_card.update_icon()

/datum/action/item_action/chameleon/change/id/apply_job_data(datum/job/job_datum)
	..()
	var/obj/item/card/id/advanced/chameleon/agent_card = target
	if(istype(agent_card) && istype(job_datum))
		agent_card.forged = TRUE

		// job_outfit is going to be a path.
		var/datum/outfit/job/job_outfit = job_datum.outfit
		if(!job_outfit)
			return

		// copied_card is also going to be a path.
		var/obj/item/card/id/copied_card = initial(job_outfit.id)
		if(!copied_card)
			return

		// If the outfit comes with a special trim override, we'll use that. Otherwise, use the card's default trim. Failing that, no trim at all.
		var/new_trim = initial(job_outfit.id_trim) ? initial(job_outfit.id_trim) : initial(copied_card.trim)

		if(new_trim)
			SSid_access.apply_trim_to_chameleon_card(agent_card, new_trim, FALSE)
		else
			agent_card.assignment = job_datum.title

		agent_card.icon_state = initial(copied_card.icon_state)
		if(ispath(copied_card, /obj/item/card/id/advanced))
			var/obj/item/card/id/advanced/copied_advanced_card = copied_card
			agent_card.assigned_icon_state = initial(copied_advanced_card.assigned_icon_state)

		agent_card.update_label()
		agent_card.update_icon()

/datum/action/item_action/chameleon/change/id_trim/initialize_disguises()
	name = "Change [chameleon_name] Appearance"
	build_all_button_icons()

	chameleon_blacklist |= typecacheof(target.type)
	for(var/trim_path in typesof(chameleon_type))
		if(ispath(trim_path) && ispath(trim_path, /datum/id_trim))
			if(chameleon_blacklist[trim_path])
				continue

			var/datum/id_trim/trim = SSid_access.trim_singletons_by_path[trim_path]

			if(trim && trim.trim_state && trim.assignment)
				var/chameleon_item_name = "[trim.assignment] ([trim.trim_state])"
				chameleon_list[chameleon_item_name] = trim_path

/datum/action/item_action/chameleon/change/id_trim/update_item(picked_trim_path)
	var/obj/item/card/id/advanced/chameleon/agent_card = target

	if(istype(agent_card))
		SSid_access.apply_trim_to_chameleon_card(agent_card, picked_trim_path, TRUE)

	agent_card.update_label()
	agent_card.update_icon()

/datum/action/item_action/chameleon/change/tablet/update_item(obj/item/picked_item)
	..()
	var/obj/item/modular_computer/pda/agent_pda = target
	if(istype(agent_pda))
		agent_pda.update_appearance()

/datum/action/item_action/chameleon/change/tablet/apply_job_data(datum/job/job_datum)
	..()
	var/obj/item/modular_computer/pda/agent_pda = target
	if(istype(agent_pda) && istype(job_datum))
		agent_pda.saved_job = job_datum.title


/obj/item/clothing/under/chameleon
//starts off as black
	name = "black jumpsuit"
	icon_state = "jumpsuit"
	greyscale_colors = "#3f3f3f"
	greyscale_config = /datum/greyscale_config/jumpsuit
	greyscale_config_inhand_left = /datum/greyscale_config/jumpsuit_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/jumpsuit_inhand_right
	greyscale_config_worn = /datum/greyscale_config/jumpsuit_worn
	desc = "It's a plain jumpsuit. It has a small dial on the wrist."
	sensor_mode = SENSOR_OFF //Hey who's this guy on the Syndicate Shuttle??
	random_sensor = FALSE
	resistance_flags = NONE
	can_adjust = FALSE
	armor_type = /datum/armor/under_chameleon

	var/datum/action/item_action/chameleon/change/chameleon_action

/datum/armor/under_chameleon
	melee = 10
	bullet = 10
	laser = 10
	bio = 10
	fire = 50
	acid = 50

/obj/item/clothing/under/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/under
	chameleon_action.chameleon_name = "Jumpsuit"
	chameleon_action.chameleon_blacklist = typecacheof(list(/obj/item/clothing/under, /obj/item/clothing/under/color, /obj/item/clothing/under/rank, /obj/item/clothing/under/changeling), only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/under/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/clothing/under/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/under/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/suit/chameleon
	name = "armor"
	desc = "A slim armored vest that protects against most types of damage."
	icon_state = "armor"
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'
	inhand_icon_state = "armor"
	blood_overlay_type = "armor"
	resistance_flags = NONE
	armor_type = /datum/armor/suit_chameleon
	var/datum/action/item_action/chameleon/change/chameleon_action

/datum/armor/suit_chameleon
	melee = 10
	bullet = 10
	laser = 10
	fire = 50
	acid = 50

/obj/item/clothing/suit/chameleon/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_vest_allowed //should at least act like a vest
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/suit
	chameleon_action.chameleon_name = "Suit"
	chameleon_action.chameleon_blacklist = typecacheof(list(/obj/item/clothing/suit/armor/abductor, /obj/item/clothing/suit/changeling), only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/suit/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/clothing/suit/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/suit/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/glasses/chameleon
	name = "Optical Meson Scanner"
	desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition."
	icon_state = "meson"
	inhand_icon_state = "meson"
	resistance_flags = NONE
	armor_type = /datum/armor/glasses_chameleon

	var/datum/action/item_action/chameleon/change/chameleon_action

/datum/armor/glasses_chameleon
	melee = 10
	bullet = 10
	laser = 10
	fire = 50
	acid = 50

/obj/item/clothing/glasses/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/glasses
	chameleon_action.chameleon_name = "Glasses"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/glasses/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/glasses/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/clothing/glasses/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/glasses/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/gloves/chameleon
	desc = "These gloves provide protection against electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	inhand_icon_state = "ygloves"
	greyscale_colors = null

	resistance_flags = NONE
	armor_type = /datum/armor/gloves_chameleon

	var/datum/action/item_action/chameleon/change/chameleon_action

/datum/armor/gloves_chameleon
	melee = 10
	bullet = 10
	laser = 10
	fire = 50
	acid = 50

/obj/item/clothing/gloves/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/gloves
	chameleon_action.chameleon_name = "Gloves"
	chameleon_action.chameleon_blacklist = typecacheof(list(/obj/item/clothing/gloves, /obj/item/clothing/gloves/color, /obj/item/clothing/gloves/changeling), only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/gloves/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/clothing/gloves/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/gloves/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/head/chameleon
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey colour."
	icon = 'icons/obj/clothing/head/hats.dmi'
	worn_icon = 'icons/mob/clothing/head/hats.dmi'
	icon_state = "greysoft"
	resistance_flags = NONE
	armor_type = /datum/armor/head_chameleon

	var/datum/action/item_action/chameleon/change/chameleon_action

/datum/armor/head_chameleon
	melee = 5
	bullet = 5
	laser = 5
	fire = 50
	acid = 50

/obj/item/clothing/head/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/head
	chameleon_action.chameleon_name = "Hat"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/head/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/head/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/clothing/head/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/head/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/head/chameleon/drone
	// The camohat, I mean, holographic hat projection, is part of the
	// drone itself.
	armor_type = /datum/armor/none
	// which means it offers no protection, it's just air and light

/obj/item/clothing/head/chameleon/drone/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	chameleon_action.random_look()
	var/datum/action/item_action/chameleon/drone/togglehatmask/togglehatmask_action = new(src)
	togglehatmask_action.build_all_button_icons()
	var/datum/action/item_action/chameleon/drone/randomise/randomise_action = new(src)
	randomise_action.build_all_button_icons()

/obj/item/clothing/mask/chameleon
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. While good for concealing your identity, it isn't good for blocking gas flow." //More accurate
	icon_state = "gas_alt"
	inhand_icon_state = "gas_alt"
	resistance_flags = NONE
	armor_type = /datum/armor/mask_chameleon
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL

	var/voice_change = 1 ///This determines if the voice changer is on or off.

	var/datum/action/item_action/chameleon/change/chameleon_action

/datum/armor/mask_chameleon
	melee = 5
	bullet = 5
	laser = 5
	bio = 100
	fire = 50
	acid = 50

/obj/item/clothing/mask/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/mask
	chameleon_action.chameleon_name = "Mask"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/mask/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/mask/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/clothing/mask/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/mask/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/mask/chameleon/attack_self(mob/user)
	voice_change = !voice_change
	to_chat(user, span_notice("The voice changer is now [voice_change ? "on" : "off"]!"))


/obj/item/clothing/mask/chameleon/drone
	//Same as the drone chameleon hat, undroppable and no protection
	armor_type = /datum/armor/none
	// Can drones use the voice changer part? Let's not find out.
	voice_change = 0

/obj/item/clothing/mask/chameleon/drone/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	chameleon_action.random_look()
	var/datum/action/item_action/chameleon/drone/togglehatmask/togglehatmask_action = new(src)
	togglehatmask_action.build_all_button_icons()
	var/datum/action/item_action/chameleon/drone/randomise/randomise_action = new(src)
	randomise_action.build_all_button_icons()

/obj/item/clothing/mask/chameleon/drone/attack_self(mob/user)
	to_chat(user, span_notice("[src] does not have a voice changer."))

/obj/item/clothing/shoes/chameleon
	name = "black shoes"
	icon_state = "sneakers"
	inhand_icon_state = "sneakers_back"
	greyscale_colors = "#545454#ffffff"
	greyscale_config = /datum/greyscale_config/sneakers
	greyscale_config_worn = /datum/greyscale_config/sneakers_worn
	desc = "A pair of black shoes."
	resistance_flags = NONE
	armor_type = /datum/armor/shoes_chameleon

	var/datum/action/item_action/chameleon/change/chameleon_action

/datum/armor/shoes_chameleon
	melee = 10
	bullet = 10
	laser = 10
	bio = 90
	fire = 50
	acid = 50

/obj/item/clothing/shoes/chameleon/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/shoes)

	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/shoes
	chameleon_action.chameleon_name = "Shoes"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/shoes/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/shoes/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/clothing/shoes/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/shoes/chameleon/noslip
	clothing_traits = list(TRAIT_NO_SLIP_WATER)
	can_be_bloody = FALSE

/obj/item/clothing/shoes/chameleon/noslip/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/storage/backpack/chameleon
	name = "backpack"
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/storage/backpack/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/storage/backpack
	chameleon_action.chameleon_name = "Backpack"
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/storage/backpack/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/storage/backpack/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/storage/backpack/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/storage/belt/chameleon
	name = "toolbelt"
	desc = "Holds tools."
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/storage/belt/chameleon/Initialize(mapload)
	. = ..()

	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/storage/belt
	chameleon_action.chameleon_name = "Belt"
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

	atom_storage.silent = TRUE

/obj/item/storage/belt/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/storage/belt/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/storage/belt/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/radio/headset/chameleon
	name = "radio headset"
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/radio/headset/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/radio/headset
	chameleon_action.chameleon_name = "Headset"
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/radio/headset/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/radio/headset/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/radio/headset/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/modular_computer/pda/chameleon
	name = "tablet"
	var/datum/action/item_action/chameleon/change/tablet/chameleon_action

/obj/item/modular_computer/pda/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/modular_computer/pda
	chameleon_action.chameleon_name = "tablet"
	chameleon_action.chameleon_blacklist = typecacheof(list(/obj/item/modular_computer/pda/heads), only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/modular_computer/pda/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/modular_computer/pda/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/modular_computer/pda/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/stamp/chameleon
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/stamp/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/stamp
	chameleon_action.chameleon_name = "Stamp"
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/stamp/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/stamp/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/neck/chameleon
	name = "black tie"
	desc = "A neosilk clip-on tie."
	icon_state = "detective" //we use this icon_state since the other ones are all generated by GAGS.
	resistance_flags = NONE
	armor_type = /datum/armor/neck_chameleon
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/neck/chameleon
	var/datum/action/item_action/chameleon/change/chameleon_action

/datum/armor/neck_chameleon
	fire = 50
	acid = 50

/obj/item/clothing/neck/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/neck
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/neck/cloak/skill_reward)
	chameleon_action.chameleon_name = "Neck Accessory"
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/neck/chameleon/Destroy()
	qdel(chameleon_action)
	return ..()

/obj/item/clothing/neck/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/neck/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/gun/energy/laser/chameleon
	var/datum/action/item_action/chameleon/change/chameleon_action

	ammo_type = list(/obj/item/ammo_casing/energy/chameleon)
	pin = /obj/item/firing_pin
	automatic_charge_overlays = FALSE
	can_select = FALSE

	/// The vars copied over to our projectile on fire.
	var/list/chameleon_projectile_vars

	/// The badmin mode. Makes your projectiles act like the real deal.
	var/real_hits = FALSE

/obj/item/gun/energy/laser/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/gun
	chameleon_action.chameleon_name = "Gun"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/gun/energy/minigun)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

	recharge_newshot()
	set_chameleon_disguise(/obj/item/gun/energy/laser)

/obj/item/gun/energy/laser/chameleon/Destroy()
	chameleon_projectile_vars.Cut()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/gun/energy/laser/chameleon/emp_act(severity)
	return

/**
 * Description: Resets the currently loaded chameleon variables, essentially resetting it to brand new.
 * Arguments: []
 */
/obj/item/gun/energy/laser/chameleon/proc/reset_chameleon_vars()
	chameleon_projectile_vars = list()

	if(chambered)
		chambered.firing_effect_type = initial(chambered.firing_effect_type)

	fire_sound = initial(fire_sound)
	burst_size = initial(burst_size)
	fire_delay = initial(fire_delay)
	inhand_x_dimension = initial(inhand_x_dimension)
	inhand_y_dimension = initial(inhand_y_dimension)

	QDEL_NULL(chambered.loaded_projectile)
	chambered.newshot()

/**
 * Description: Sets what gun we should be mimicking.
 * Arguments: [obj/item/gun/gun_to_set (the gun we're trying to mimic)]
 */
/obj/item/gun/energy/laser/chameleon/proc/set_chameleon_gun(obj/item/gun/gun_to_set)
	if(!istype(gun_to_set))
		stack_trace("[gun_to_set] is not a valid gun.")
		return FALSE

	fire_sound = gun_to_set.fire_sound
	burst_size = gun_to_set.burst_size
	fire_delay = gun_to_set.fire_delay
	inhand_x_dimension = gun_to_set.inhand_x_dimension
	inhand_y_dimension = gun_to_set.inhand_y_dimension

	if(istype(gun_to_set, /obj/item/gun/ballistic))
		var/obj/item/gun/ballistic/ball_gun = gun_to_set
		var/obj/item/ammo_box/ball_ammo = new ball_gun.mag_type(gun_to_set)
		qdel(ball_gun)

		if(!istype(ball_ammo) || !ball_ammo.ammo_type)
			qdel(ball_ammo)
			return FALSE

		var/obj/item/ammo_casing/ball_cartridge = new ball_ammo.ammo_type(gun_to_set)
		set_chameleon_ammo(ball_cartridge)

	else if(istype(gun_to_set, /obj/item/gun/magic))
		var/obj/item/gun/magic/magic_gun = gun_to_set
		var/obj/item/ammo_casing/magic_cartridge = new magic_gun.ammo_type(gun_to_set)
		set_chameleon_ammo(magic_cartridge)

	else if(istype(gun_to_set, /obj/item/gun/energy))
		var/obj/item/gun/energy/energy_gun = gun_to_set
		if(islist(energy_gun.ammo_type) && energy_gun.ammo_type.len)
			var/obj/item/ammo_casing/energy_cartridge = energy_gun.ammo_type[1]
			set_chameleon_ammo(energy_cartridge)

	else if(istype(gun_to_set, /obj/item/gun/syringe))
		var/obj/item/ammo_casing/syringe_cartridge = new /obj/item/ammo_casing/syringegun(src)
		set_chameleon_ammo(syringe_cartridge)

	else
		var/obj/item/ammo_casing/default_cartridge = new /obj/item/ammo_casing(src)
		set_chameleon_ammo(default_cartridge)

/**
 * Description: Sets the ammo type our gun should have.
 * Arguments: [obj/item/ammo_casing/cartridge (the ammo_casing we're trying to copy)]
 */
/obj/item/gun/energy/laser/chameleon/proc/set_chameleon_ammo(obj/item/ammo_casing/cartridge)
	if(!istype(cartridge))
		stack_trace("[cartridge] is not a valid ammo casing.")
		return FALSE

	var/obj/projectile/projectile = cartridge.loaded_projectile
	set_chameleon_projectile(projectile)

/**
 * Description: Sets the current projectile variables for our chameleon gun.
 * Arguments: [obj/projectile/template_projectile (the projectile we're trying to copy)]
 */
/obj/item/gun/energy/laser/chameleon/proc/set_chameleon_projectile(obj/projectile/template_projectile)
	if(!istype(template_projectile))
		stack_trace("[template_projectile] is not a valid projectile.")
		return FALSE

	chameleon_projectile_vars = list("name" = "practice laser", "icon" = 'icons/obj/weapons/guns/projectiles.dmi', "icon_state" = "laser")

	var/default_state = isnull(template_projectile.icon_state) ? "laser" : template_projectile.icon_state

	chameleon_projectile_vars["name"] = template_projectile.name
	chameleon_projectile_vars["icon"] = template_projectile.icon
	chameleon_projectile_vars["icon_state"] = default_state
	chameleon_projectile_vars["speed"] = template_projectile.speed
	chameleon_projectile_vars["color"] = template_projectile.color
	chameleon_projectile_vars["hitsound"] = template_projectile.hitsound
	chameleon_projectile_vars["impact_effect_type"] = template_projectile.impact_effect_type
	chameleon_projectile_vars["range"] = template_projectile.range
	chameleon_projectile_vars["suppressed"] = template_projectile.suppressed
	chameleon_projectile_vars["hitsound_wall"] = template_projectile.hitsound_wall
	chameleon_projectile_vars["pass_flags"] = template_projectile.pass_flags

	if(istype(chambered, /obj/item/ammo_casing/energy/chameleon))
		var/obj/item/ammo_casing/energy/chameleon/cartridge = chambered

		cartridge.loaded_projectile.name = template_projectile.name
		cartridge.loaded_projectile.icon = template_projectile.icon
		cartridge.loaded_projectile.icon_state = default_state
		cartridge.loaded_projectile.speed = template_projectile.speed
		cartridge.loaded_projectile.color = template_projectile.color
		cartridge.loaded_projectile.hitsound = template_projectile.hitsound
		cartridge.loaded_projectile.impact_effect_type = template_projectile.impact_effect_type
		cartridge.loaded_projectile.range = template_projectile.range
		cartridge.loaded_projectile.suppressed = template_projectile.suppressed
		cartridge.loaded_projectile.hitsound_wall =	template_projectile.hitsound_wall
		cartridge.loaded_projectile.pass_flags = template_projectile.pass_flags

		cartridge.projectile_vars = chameleon_projectile_vars.Copy()

	if(real_hits)
		qdel(chambered.loaded_projectile)
		chambered.projectile_type = template_projectile.type

	qdel(template_projectile)


/**
 * Description: Resets our chameleon variables, then resets the entire gun to mimic the given guntype.
 * Arguments: [guntype (the gun we're copying, pathtyped to obj/item/gun)]
 */
/obj/item/gun/energy/laser/chameleon/proc/set_chameleon_disguise(guntype)
	reset_chameleon_vars()
	var/obj/item/gun/new_gun = new guntype(src)
	set_chameleon_gun(new_gun)
	qdel(new_gun)
