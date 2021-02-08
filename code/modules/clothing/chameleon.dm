#define EMP_RANDOMISE_TIME 300

/datum/action/item_action/chameleon/drone/randomise
	name = "Randomise Headgear"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "random"

/datum/action/item_action/chameleon/drone/randomise/Trigger()
	if(!IsAvailable())
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
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'

/datum/action/item_action/chameleon/drone/togglehatmask/New()
	..()

	if (istype(target, /obj/item/clothing/head/chameleon/drone))
		button_icon_state = "drone_camogear_helm"
	if (istype(target, /obj/item/clothing/mask/chameleon/drone))
		button_icon_state = "drone_camogear_mask"

/datum/action/item_action/chameleon/drone/togglehatmask/Trigger()
	if(!IsAvailable())
		return

	// No point making the code more complicated if no non-drone
	// is ever going to use one of these

	var/mob/living/simple_animal/drone/D

	if(istype(owner, /mob/living/simple_animal/drone))
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
		to_chat(owner, "<span class='warning'>You shouldn't be able to toggle a camogear helmetmask if you're not wearing it.</span>")
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
			if(initial(O.can_be_admin_equipped))
				standard_outfit_options[initial(O.name)] = path
		sortTim(standard_outfit_options, /proc/cmp_text_asc)
	outfit_options = standard_outfit_options

/datum/action/chameleon_outfit/Trigger()
	return select_outfit(owner)

/datum/action/chameleon_outfit/proc/select_outfit(mob/user)
	if(!user || !IsAvailable())
		return FALSE
	var/selected = input("Select outfit to change into", "Chameleon Outfit") as null|anything in outfit_options
	if(!IsAvailable() || QDELETED(src) || QDELETED(user))
		return FALSE
	var/outfit_type = outfit_options[selected]
	if(!outfit_type)
		return FALSE
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

	//hardsuit helmets/suit hoods
	if(O.toggle_helmet && (ispath(O.suit, /obj/item/clothing/suit/space/hardsuit) || ispath(O.suit, /obj/item/clothing/suit/hooded)) && ishuman(user))
		var/mob/living/carbon/human/H = user
		//make sure they are actually wearing the suit, not just holding it, and that they have a chameleon hat
		if(istype(H.wear_suit, /obj/item/clothing/suit/chameleon) && istype(H.head, /obj/item/clothing/head/chameleon))
			var/helmet_type
			if(ispath(O.suit, /obj/item/clothing/suit/space/hardsuit))
				var/obj/item/clothing/suit/space/hardsuit/hardsuit = O.suit
				helmet_type = initial(hardsuit.helmettype)
			else
				var/obj/item/clothing/suit/hooded/hooded = O.suit
				helmet_type = initial(hooded.hoodtype)

			if(helmet_type)
				var/obj/item/clothing/head/chameleon/hat = H.head
				hat.chameleon_action.update_look(user, helmet_type)
	qdel(O)
	return TRUE


/datum/action/item_action/chameleon/change
	name = "Chameleon Change"
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
	if(button)
		button.name = "Change [chameleon_name] Appearance"

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
	var/picked_name
	picked_name = input("Select [chameleon_name] to change into", "Chameleon [chameleon_name]", picked_name) as null|anything in sortList(chameleon_list, /proc/cmp_typepaths_asc)
	if(!picked_name)
		return
	picked_item = chameleon_list[picked_name]
	if(!picked_item)
		return
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
	if(isliving(user))
		var/mob/living/C = user
		if(C.stat != CONSCIOUS)
			return

		update_item(picked_item)
		var/obj/item/thing = target
		thing.update_slot_icon()
	UpdateButtonIcon()

/datum/action/item_action/chameleon/change/proc/update_item(obj/item/picked_item)
	target.name = initial(picked_item.name)
	target.desc = initial(picked_item.desc)
	target.icon_state = initial(picked_item.icon_state)
	if(isitem(target))
		var/obj/item/clothing/I = target
		I.lefthand_file = initial(picked_item.lefthand_file)
		I.righthand_file = initial(picked_item.righthand_file)
		I.inhand_icon_state = initial(picked_item.inhand_icon_state)
		I.worn_icon = initial(picked_item.worn_icon)
		I.worn_icon_state = initial(picked_item.worn_icon_state)
		if(istype(I, /obj/item/clothing) && istype(initial(picked_item), /obj/item/clothing))
			var/obj/item/clothing/CL = I
			var/obj/item/clothing/PCL = picked_item
			CL.flags_cover = initial(PCL.flags_cover)
	target.icon = initial(picked_item.icon)

/datum/action/item_action/chameleon/change/Trigger()
	if(!IsAvailable())
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
	var/obj/item/card/id/syndicate/agent_card = target
	if(istype(agent_card))
		var/obj/item/card/id/copied_card = picked_item
		agent_card.uses_overlays = initial(copied_card.uses_overlays)
		agent_card.id_type_name = initial(copied_card.id_type_name)
		if(!agent_card.forged)
			agent_card.registered_name = initial(copied_card.registered_name)
			agent_card.assignment = initial(copied_card.assignment)
		agent_card.update_label()
		if(!agent_card.forged)
			agent_card.name = initial(copied_card.name) //e.g. captain's spare ID, not Captain's ID Card (Captain)

/datum/action/item_action/chameleon/change/id/apply_job_data(datum/job/job_datum)
	..()
	var/obj/item/card/id/syndicate/agent_card = target
	if(istype(agent_card) && istype(job_datum))
		agent_card.forged = TRUE
		agent_card.assignment = job_datum.title

/datum/action/item_action/chameleon/change/pda/update_item(obj/item/picked_item)
	..()
	var/obj/item/pda/agent_pda = target
	if(istype(agent_pda))
		agent_pda.update_label()
		agent_pda.update_icon()

/datum/action/item_action/chameleon/change/pda/apply_job_data(datum/job/job_datum)
	..()
	var/obj/item/pda/agent_pda = target
	if(istype(agent_pda) && istype(job_datum))
		agent_pda.ownjob = job_datum.title


/obj/item/clothing/under/chameleon
//starts off as black
	name = "black jumpsuit"
	icon = 'icons/obj/clothing/under/color.dmi'
	icon_state = "black"
	inhand_icon_state = "bl_suit"
	worn_icon = 'icons/mob/clothing/under/color.dmi'
	desc = "It's a plain jumpsuit. It has a small dial on the wrist."
	sensor_mode = SENSOR_OFF //Hey who's this guy on the Syndicate Shuttle??
	random_sensor = FALSE
	resistance_flags = NONE
	can_adjust = FALSE
	armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/under/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/under
	chameleon_action.chameleon_name = "Jumpsuit"
	chameleon_action.chameleon_blacklist = typecacheof(list(/obj/item/clothing/under, /obj/item/clothing/under/color, /obj/item/clothing/under/rank, /obj/item/clothing/under/changeling), only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/clothing/under/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/under/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/suit/chameleon
	name = "armor"
	desc = "A slim armored vest that protects against most types of damage."
	icon_state = "armor"
	inhand_icon_state = "armor"
	blood_overlay_type = "armor"
	resistance_flags = NONE
	armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/suit/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/suit
	chameleon_action.chameleon_name = "Suit"
	chameleon_action.chameleon_blacklist = typecacheof(list(/obj/item/clothing/suit/armor/abductor, /obj/item/clothing/suit/changeling), only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/clothing/suit/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/suit/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/glasses/chameleon
	name = "Optical Meson Scanner"
	desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition."
	icon_state = "meson"
	inhand_icon_state = "meson"
	resistance_flags = NONE
	armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/glasses/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/glasses
	chameleon_action.chameleon_name = "Glasses"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/glasses/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/clothing/glasses/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/glasses/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/gloves/chameleon
	desc = "These gloves provide protection against electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	inhand_icon_state = "ygloves"

	resistance_flags = NONE
	armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/gloves/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/gloves
	chameleon_action.chameleon_name = "Gloves"
	chameleon_action.chameleon_blacklist = typecacheof(list(/obj/item/clothing/gloves, /obj/item/clothing/gloves/color, /obj/item/clothing/gloves/changeling), only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/clothing/gloves/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/gloves/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/head/chameleon
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey colour."
	icon_state = "greysoft"

	resistance_flags = NONE
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/head/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/head
	chameleon_action.chameleon_name = "Hat"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/head/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/clothing/head/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/head/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/head/chameleon/drone
	// The camohat, I mean, holographic hat projection, is part of the
	// drone itself.
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	// which means it offers no protection, it's just air and light

/obj/item/clothing/head/chameleon/drone/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	chameleon_action.random_look()
	var/datum/action/item_action/chameleon/drone/togglehatmask/togglehatmask_action = new(src)
	togglehatmask_action.UpdateButtonIcon()
	var/datum/action/item_action/chameleon/drone/randomise/randomise_action = new(src)
	randomise_action.UpdateButtonIcon()

/obj/item/clothing/mask/chameleon
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. While good for concealing your identity, it isn't good for blocking gas flow." //More accurate
	icon_state = "gas_alt"
	inhand_icon_state = "gas_alt"
	resistance_flags = NONE
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL

	var/voice_change = 1 ///This determines if the voice changer is on or off.

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/mask/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/mask
	chameleon_action.chameleon_name = "Mask"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/mask/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/clothing/mask/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/mask/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/mask/chameleon/attack_self(mob/user)
	voice_change = !voice_change
	to_chat(user, "<span class='notice'>The voice changer is now [voice_change ? "on" : "off"]!</span>")


/obj/item/clothing/mask/chameleon/drone
	//Same as the drone chameleon hat, undroppable and no protection
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	// Can drones use the voice changer part? Let's not find out.
	voice_change = 0

/obj/item/clothing/mask/chameleon/drone/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	chameleon_action.random_look()
	var/datum/action/item_action/chameleon/drone/togglehatmask/togglehatmask_action = new(src)
	togglehatmask_action.UpdateButtonIcon()
	var/datum/action/item_action/chameleon/drone/randomise/randomise_action = new(src)
	randomise_action.UpdateButtonIcon()

/obj/item/clothing/mask/chameleon/drone/attack_self(mob/user)
	to_chat(user, "<span class='notice'>[src] does not have a voice changer.</span>")

/obj/item/clothing/shoes/chameleon
	name = "black shoes"
	icon_state = "black"
	desc = "A pair of black shoes."
	permeability_coefficient = 0.05
	resistance_flags = NONE
	armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/shoes/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/shoes
	chameleon_action.chameleon_name = "Shoes"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/shoes/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/clothing/shoes/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/shoes/chameleon/noslip
	name = "black shoes"
	icon_state = "black"
	desc = "A pair of black shoes."
	clothing_flags = NOSLIP
	can_be_bloody = FALSE

/obj/item/clothing/shoes/chameleon/noslip/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/storage/backpack/chameleon
	name = "backpack"
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/storage/backpack/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/storage/backpack
	chameleon_action.chameleon_name = "Backpack"
	chameleon_action.initialize_disguises()

/obj/item/storage/backpack/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/storage/backpack/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/storage/belt/chameleon
	name = "toolbelt"
	desc = "Holds tools."
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/storage/belt/chameleon/Initialize()
	. = ..()

	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/storage/belt
	chameleon_action.chameleon_name = "Belt"
	chameleon_action.initialize_disguises()

/obj/item/storage/belt/chameleon/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.silent = TRUE

/obj/item/storage/belt/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/storage/belt/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/radio/headset/chameleon
	name = "radio headset"
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/radio/headset/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/radio/headset
	chameleon_action.chameleon_name = "Headset"
	chameleon_action.initialize_disguises()

/obj/item/radio/headset/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/radio/headset/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/pda/chameleon
	name = "PDA"
	var/datum/action/item_action/chameleon/change/pda/chameleon_action

/obj/item/pda/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/pda
	chameleon_action.chameleon_name = "PDA"
	chameleon_action.chameleon_blacklist = typecacheof(list(/obj/item/pda/heads, /obj/item/pda/ai, /obj/item/pda/ai/pai), only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/pda/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/pda/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/stamp/chameleon
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/stamp/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/stamp
	chameleon_action.chameleon_name = "Stamp"
	chameleon_action.initialize_disguises()

/obj/item/stamp/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/neck/chameleon
	name = "black tie"
	desc = "A neosilk clip-on tie."
	icon_state = "blacktie"
	resistance_flags = NONE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/neck/chameleon
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/neck/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/neck
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/neck/cloak/skill_reward)
	chameleon_action.chameleon_name = "Neck Accessory"
	chameleon_action.initialize_disguises()

/obj/item/clothing/neck/chameleon/Destroy()
	qdel(chameleon_action)
	return ..()

/obj/item/clothing/neck/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/neck/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/datum/action/item_action/chameleon/change/skillchip
	/// Skillchip that this chameleon action is imitating.
	var/obj/item/skillchip/skillchip_mimic
	/// When we can next modify this skillchip
	COOLDOWN_DECLARE(usable_cooldown)
	var/cooldown = 5 MINUTES
	var/is_active = TRUE

/datum/action/item_action/chameleon/change/skillchip/Destroy()
	if(skillchip_mimic)
		skillchip_mimic.on_removal(FALSE)
	QDEL_NULL(skillchip_mimic)
	return ..()

/datum/action/item_action/chameleon/change/skillchip/proc/set_active(active = TRUE)
	is_active = active
	UpdateButtonIcon()

/datum/action/item_action/chameleon/change/skillchip/Grant(mob/M)
	. = ..()

	if(!COOLDOWN_FINISHED(src, usable_cooldown))
		START_PROCESSING(SSfastprocess, src)

/datum/action/item_action/chameleon/change/skillchip/Remove(mob/M)
	STOP_PROCESSING(SSfastprocess, src)

	return ..()

/// Completely override the functionality of the initialize_disguises() proc. No longer uses chameleon_blacklist and uses skillchip flags and vars instead.
/datum/action/item_action/chameleon/change/skillchip/initialize_disguises()
	if(button)
		button.name = "Change [chameleon_name] Function"

	if(!ispath(chameleon_type, /obj/item/skillchip))
		CRASH("Attempted to initialise [src] disguise list with incompatible item path [chameleon_type].")

	var/obj/item/skillchip/target_chip = target

	if(!istype(target_chip))
		CRASH("Attempted to initialise [src] disguise list, but it is attached to incorrect item type [target_chip].")

	for(var/chip_type in typesof(chameleon_type))
		var/obj/item/skillchip/skillchip = chip_type
		if((chip_type == initial(skillchip.abstract_parent_type)) \
			|| (target_chip.slot_use < initial(skillchip.slot_use)) \
			|| (initial(skillchip.skillchip_flags) & SKILLCHIP_CHAMELEON_INCOMPATIBLE) \
			|| (initial(skillchip.item_flags) & ABSTRACT) \
			|| !initial(skillchip.icon_state))
			continue
		var/chameleon_item_name = "[initial(skillchip.name)] ([initial(skillchip.icon_state)])"
		chameleon_list[chameleon_item_name] = skillchip

/datum/action/item_action/chameleon/change/skillchip/update_item(obj/item/skillchip/picked_item)
	if(istype(picked_item))
		target.name = initial(picked_item.skill_name)
		target.desc = initial(picked_item.skill_description)
		target.icon_state = initial(picked_item.skill_icon)

/datum/action/item_action/chameleon/change/skillchip/update_look(mob/user, picked_item)
	if(!COOLDOWN_FINISHED(src, usable_cooldown))
		to_chat(user, "<span class='notice'>Chameleon skillchip is still recharging for another [COOLDOWN_TIMELEFT(src, usable_cooldown) * 0.1] seconds!</span>")
		return ..()

	var/obj/item/skillchip/new_chip = new picked_item(target, FALSE)

	// Do a bit of a sanity check.
	if(!istype(new_chip))
		stack_trace("Chameleon skillchip [src] attempted to change into non-skillchip item [picked_item].")
		QDEL_NULL(new_chip)
		return ..()

	// Remove the existing chip first, if it exists.
	if(skillchip_mimic)
		skillchip_mimic.on_removal(FALSE)
		QDEL_NULL(skillchip_mimic)

	// This chip should technically have 0 slot use before doing these checks. With skillchip_mimic removed, any checks
	// will probably end up using the 2-slot chameleon chip that is holding new_chip.
	new_chip.slot_use = 0

	var/incompatibility_msg = new_chip.has_mob_incompatibility(user)
	if(incompatibility_msg)
		to_chat(user, "<span class='notice'>The chameleon skillchip fails to load the new skillchip's data. The following thought fills your mind: [incompatibility_msg]</span>")
		QDEL_NULL(new_chip)
		return ..()

	var/mob/living/carbon/target_mob = user

	// Should never happen. Our target isn't the right mob type.
	if(!istype(target_mob))
		stack_trace("Chameleon skillchip [src] attempted to mimic [new_chip], but target [target_mob] is not of the correct type.")
		QDEL_NULL(new_chip)
		return ..()

	// Should doubly never happen, would imply the chameleon chip is in a qdel'd or null brain.
	var/obj/item/organ/brain/brain = target_mob.getorganslot(ORGAN_SLOT_BRAIN)
	if(QDELETED(brain))
		stack_trace("Chameleon skillchip [src] attempted to mimic [new_chip], but it appears this chip is in non-existent brain: [brain]")
		QDEL_NULL(new_chip)
		return ..()

	// Bypass the usual channels and directly call on_implant.
	skillchip_mimic = new_chip
	skillchip_mimic.on_implant(brain)

	// Let's update the slot size we deleted earlier. We're going to make it match the parent chip, as it'll end up
	// feeding calls through itself to this chip.

	var/obj/item/skillchip/target_chip = target

	if(!istype(target_chip))
		CRASH("Attempted to initialise [src] disguise list, but it is attached to incorrect item type [target_chip].")

	skillchip_mimic.slot_use = target_chip.slot_use

	var/activate_msg = skillchip_mimic.try_activate_skillchip(FALSE, FALSE)

	// Couldn't activate the chip for some reason.
	// Can still be activated later on, or a new chip type selected. So let's not start processing or cooldowns.
	if(activate_msg)
		to_chat(user, "<span class='notice'>Your skillchip can't activate! Your mind fills with the following thought: [activate_msg]</span>")
		return ..()

	// All set, start processing and cooldowns and inform the user of the recharge time.
	COOLDOWN_START(src, usable_cooldown, cooldown)
	START_PROCESSING(SSfastprocess, src)

	to_chat(user, "<span class='notice'>The chameleon skillchip is recharging. It will be unable to change for another [cooldown * 0.1] seconds.</span>")

	return ..()

/datum/action/item_action/chameleon/change/skillchip/IsAvailable()
	if(!is_active)
		return FALSE

	if(!COOLDOWN_FINISHED(src, usable_cooldown))
		return FALSE

	return ..()

/datum/action/item_action/chameleon/change/skillchip/process()
	if(!owner)
		button.maptext = ""
		STOP_PROCESSING(SSfastprocess, src)
		return

	if(COOLDOWN_FINISHED(src, usable_cooldown))
		button.maptext = ""
		UpdateButtonIcon()
		STOP_PROCESSING(SSfastprocess, src)
		return

	button.maptext = MAPTEXT("<b>[COOLDOWN_TIMELEFT(src, usable_cooldown) * 0.1]</b>")

/**
 * Clears the currently mimic'd skillchip, if any exists.
 */
/datum/action/item_action/chameleon/change/skillchip/proc/clear_mimic_chip()
	if(skillchip_mimic)
		skillchip_mimic.on_removal(FALSE)
		QDEL_NULL(skillchip_mimic)
