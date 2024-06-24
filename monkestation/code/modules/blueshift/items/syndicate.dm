/obj/item/uplink/old_radio
	name = "old radio"
	desc = "A dusty and old looking radio."

/obj/item/uplink/old_radio/Initialize(mapload, owner, tc_amount = 0)
	. = ..()
	var/datum/component/uplink/hidden_uplink = GetComponent(/datum/component/uplink)
	hidden_uplink.name = "old radio"

//Unrestricted MODs
/obj/item/mod/control/pre_equipped/elite/unrestricted
	req_access = null

//Syndie wep charger kit
/obj/item/storage/box/syndie_kit/recharger
	name = "boxed recharger kit"
	desc = "A sleek, sturdy box used to hold all parts to build a weapons recharger."
	icon_state = "syndiebox"

/obj/item/storage/box/syndie_kit/recharger/PopulateContents()
	new /obj/item/circuitboard/machine/recharger(src)
	new /obj/item/stock_parts/capacitor/quadratic(src)
	new /obj/item/stack/sheet/iron/five(src)
	new /obj/item/stack/cable_coil/five(src)
	new /obj/item/screwdriver/nuke(src)
	new /obj/item/wrench(src)

//Back-up space suit
/obj/item/storage/box/syndie_kit/space_suit
	name = "boxed space suit and helmet"
	desc = "A sleek, sturdy box used to hold an emergency spacesuit."
	icon_state = "syndiebox"
	illustration = "syndiesuit"

/obj/item/storage/box/syndie_kit/space_suit/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.max_slots = 2
	atom_storage.set_holdable(list(
		/obj/item/clothing/head/helmet/space/syndicate,
		/obj/item/clothing/suit/space/syndicate,
		))

/obj/item/storage/box/syndie_kit/space_suit/PopulateContents()
	switch(pick(list("red", "green", "dgreen", "blue", "orange", "black")))
		if("green")
			new /obj/item/clothing/head/helmet/space/syndicate/green(src)
			new /obj/item/clothing/suit/space/syndicate/green(src)
		if("dgreen")
			new /obj/item/clothing/head/helmet/space/syndicate/green/dark(src)
			new /obj/item/clothing/suit/space/syndicate/green/dark(src)
		if("blue")
			new /obj/item/clothing/head/helmet/space/syndicate/blue(src)
			new /obj/item/clothing/suit/space/syndicate/blue(src)
		if("red")
			new /obj/item/clothing/head/helmet/space/syndicate(src)
			new /obj/item/clothing/suit/space/syndicate(src)
		if("orange")
			new /obj/item/clothing/head/helmet/space/syndicate/orange(src)
			new /obj/item/clothing/suit/space/syndicate/orange(src)
		if("black")
			new /obj/item/clothing/head/helmet/space/syndicate/black(src)
			new /obj/item/clothing/suit/space/syndicate/black(src)

//Spy
/obj/item/clothing/suit/jacket/det_suit/noir/armoured
	armor_type = /datum/armor/heister

/obj/item/clothing/head/frenchberet/armoured
	armor_type = /datum/armor/cosmetic_sec

/obj/item/clothing/under/suit/black/armoured
	armor_type = /datum/armor/clothing_under/syndicate

/obj/item/clothing/under/suit/black/skirt/armoured
	armor_type = /datum/armor/clothing_under/syndicate

/obj/item/storage/belt/holster/detective/dark
	name = "dark leather holster"
	icon_state = "syndicate_holster"

/obj/item/storage/box/syndie_kit/gunman_outfit
	name = "gunman clothing bundle"
	desc = "A box filled with armored and stylish clothing for the aspiring gunmans."

/obj/item/clothing/suit/jacket/trenchcoat/gunman
	name = "leather overcoat"
	desc = "An armored leather overcoat, intended as the go-to wear for any aspiring gunman."
	body_parts_covered = CHEST|GROIN|ARMS
	armor_type = /datum/armor/leather_gunman

/datum/armor/leather_gunman
	melee = 45
	bullet = 40
	laser = 40
	energy = 50
	bomb = 25
	fire = 50
	acid = 50
	wound = 10

/obj/item/clothing/under/pants/track/robohand
	name = "badass pants"
	desc = "Strangely firm yet soft black pants, these appear to have some armor padding for added protection."
	armor_type = /datum/armor/clothing_under/robohand

/datum/armor/clothing_under/robohand
	melee = 20
	bullet = 20
	laser = 20
	energy = 20
	bomb = 20

/obj/item/clothing/glasses/sunglasses/robohand
	name = "badass sunglasses"
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks flashes. These ones seem to be bulletproof?"
	body_parts_covered = HEAD //What do you mean glasses don't protect your head? Of course they do. Cyberpunk has flying cars(mostly intentional)!
	armor_type = /datum/armor/sunglasses_robohand

/datum/armor/sunglasses_robohand
	melee = 20
	bullet = 60
	laser = 20
	energy = 20
	bomb = 20
	wound = 5

//More items
/obj/item/guardian_creator/tech/choose/traitor/opfor
	allow_changeling = TRUE

/obj/item/codeword_granter
	name = "codeword manual"
	desc = "A black manual with a red S lovingly inscribed on the cover by only the finest of presses from a factory."
	icon = 'monkestation/code/modules/blueshift/opfor/icons/items.dmi'
	icon_state = "codeword_book"
	/// Number of charges the book has, limits the number of times it can be used.
	var/charges = 1


/obj/item/codeword_granter/attack_self(mob/living/user)
	if(!isliving(user))
		return

	to_chat(user, span_boldannounce("You start skimming through [src], and feel suddenly imparted with the knowledge of the following code words:"))

	user.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_phrase_regex, "blue", src)
	user.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_response_regex, "red", src)
	to_chat(user, "<b>Code Phrases</b>: [jointext(GLOB.syndicate_code_phrase, ", ")]")
	to_chat(user, "<b>Code Responses</b>: [span_red("[jointext(GLOB.syndicate_code_response, ", ")]")]")

	use_charge(user)


/obj/item/codeword_granter/attack(mob/living/attacked_mob, mob/living/user)
	if(!istype(attacked_mob) || !istype(user))
		return

	if(attacked_mob == user)
		attack_self(user)
		return

	playsound(loc, SFX_PUNCH, 25, TRUE, -1)

	if(attacked_mob.stat == DEAD)
		attacked_mob.visible_message(span_danger("[user] smacks [attacked_mob]'s lifeless corpse with [src]."), span_userdanger("[user] smacks your lifeless corpse with [src]."), span_hear("You hear smacking."))
	else
		attacked_mob.visible_message(span_notice("[user] teaches [attacked_mob] by beating [attacked_mob.p_them()] over the head with [src]!"), span_boldnotice("As [user] hits you with [src], you feel suddenly imparted with the knowledge of some [span_red("specific words")]."), span_hear("You hear smacking."))
		attacked_mob.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_phrase_regex, "blue", src)
		attacked_mob.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_response_regex, "red", src)
		to_chat(attacked_mob, span_boldnotice("You feel suddenly imparted with the knowledge of the following code words:"))
		to_chat(attacked_mob, "<b>Code Phrases</b>: [span_blue("[jointext(GLOB.syndicate_code_phrase, ", ")]")]")
		to_chat(attacked_mob, "<b>Code Responses</b>: [span_red("[jointext(GLOB.syndicate_code_response, ", ")]")]")
		use_charge(user)


/obj/item/codeword_granter/proc/use_charge(mob/user)
	charges--

	if(!charges)
		var/turf/src_turf = get_turf(src)
		src_turf.visible_message(span_warning("The cover and contents of [src] start shifting and changing! It slips out of your hands!"))
		new /obj/item/book/manual/random(src_turf)
		qdel(src)


/obj/item/antag_granter
	icon = 'monkestation/code/modules/blueshift/opfor/icons/items.dmi'
	/// What antag datum to give
	var/antag_datum = /datum/antagonist/traitor
	/// What to tell the user when they use the granter
	var/user_message = ""


/obj/item/antag_granter/attack(mob/living/target_mob, mob/living/user, params)
	. = ..()

	if(target_mob != user) // As long as you're attacking yourself it counts.
		return
	attack_self(user)


/obj/item/antag_granter/attack_self(mob/user, modifiers)
	. = ..()
	if(!isliving(user) || !user.mind)
		return FALSE

	to_chat(user, span_notice(user_message))
	user.mind.add_antag_datum(antag_datum)
	qdel(src)
	return TRUE

/obj/item/antag_granter/changeling
	name = "viral injector"
	desc = "A blue injector filled with some viscous, red substance. It has no markings apart from an orange warning stripe near the large needle."
	icon_state = "changeling_injector"
	antag_datum = /datum/antagonist/changeling
	user_message = "As you inject the substance into yourself, you start to feel... <span class='red'><b>better</b></span>."


/obj/item/antag_granter/heretic
	name = "strange book"
	desc = "A purple book with a green eye on the cover. You swear it's looking at you...."
	icon_state = "heretic_granter"
	antag_datum = /datum/antagonist/heretic
	user_message = "As you open the book, you see a great flash as <span class='hypnophrase'>the world becomes all the clearer for you</span>."

/obj/item/antag_granter/clock_cultist
	name = "brass contraption"
	desc = "A cogwheel-shaped device of brass, with a glass lens floating, suspended in the center."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_objects.dmi'
	icon_state = "vanguard_cogwheel"
	antag_datum = /datum/antagonist/clock_cultist/solo
	user_message = "A whirring fills your ears as <span class='brass'>knowledge of His Eminence fills your mind</span>."

/obj/item/antag_granter/clock_cultist/attack_self(mob/user, modifiers)
	. = ..()
	if(!.)
		return FALSE

	var/obj/item/clockwork/clockwork_slab/slab = new
	user.put_in_hands(slab, FALSE)

#define INFINITE_CHARGES -1

/obj/item/device/traitor_announcer
	name = "odd device"
	desc = "Hmm... what is this for?"
	special_desc_requirement = EXAMINE_CHECK_SYNDICATE
	special_desc = "A remote that can be used to transmit a fake announcement of your own design."
	icon = 'icons/obj/device.dmi'
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	icon_state = "inspector"
	worn_icon_state = "salestagger"
	inhand_icon_state = "electronic"
	///How many uses does it have? -1 for infinite
	var/uses = 1

/obj/item/device/traitor_announcer/attack_self(mob/living/user, modifiers)
	. = ..()

	//can we use this?
	if(!isliving(user) || (uses == 0))
		balloon_alert(user, "no uses left!")
		return

	//build our announcement
	var/origin = sanitize_text(reject_bad_text(tgui_input_text(user, "Who is announcing, or where is the announcement coming from?", "Announcement Origin", get_area_name(user), max_length = 56), ascii_only = FALSE))
	if(!origin)
		balloon_alert(user, "bad origin!")
		return

	var/audio_key = tgui_input_list(user, "Which announcement audio key should play? ('Intercept' is default)", "Announcement Audio", GLOB.announcer_keys, ANNOUNCER_INTERCEPT)
	if(!audio_key)
		balloon_alert(user, "bad audio!")
		return

	var/color = tgui_input_list(user, "Which color should the announcement be?", "Announcement Hue", ANNOUNCEMENT_COLORS, "default")
	if(!color)
		balloon_alert(user, "bad color!")
		return

	var/title = sanitize_text(reject_bad_text(tgui_input_text(user, "Choose the title of the announcement.", "Announcement Title", max_length = 84), ascii_only = FALSE))
	if(!title)
		balloon_alert(user, "bad title!")
		return

	var/input = sanitize_text(reject_bad_text(tgui_input_text(user, "Choose the bodytext of the announcement.", "Announcement Text", multiline = TRUE), ascii_only = FALSE))
	if(!input)
		balloon_alert(user, "bad text!")
		return

	//treat voice
	var/list/message_data = user.treat_message(input)

	//send
	priority_announce(
		text = message_data["message"],
		title = title,
		sound = audio_key,
		sender_override = origin,
		color_override = color,
		has_important_message = TRUE,
		encode_title = FALSE,
		encode_text = FALSE,
	)

	if(uses != INFINITE_CHARGES)
		uses--

	deadchat_broadcast(" made a fake priority announcement from [span_name("[get_area_name(usr, TRUE)]")].", span_name("[user.real_name]"), user, message_type=DEADCHAT_ANNOUNCEMENT)
	user.log_talk("\[Message title\]: [title], \[Message\]: [input], \[Audio key\]: [audio_key]", LOG_TELECOMMS, tag = "priority announcement")
	message_admins("[ADMIN_LOOKUPFLW(user)] has used [src] to make a fake announcement of [input].")

// Adminbus
/obj/item/device/traitor_announcer/infinite
	uses = -1

#undef INFINITE_CHARGES

/obj/item/reagent_containers/cup/glass/drinkingglass/shotglass/syndicate
	name = "shot glass"
	desc = "A shot glass - the universal symbol for terrible decisions."
	icon_state = "shotglass"
	base_icon_state = "shotglass"
	gulp_size = 50
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = list(50)
	volume = 50
	reagent_flags = REFILLABLE | DRAINABLE

/obj/item/storage/box/syndieshotglasses
	name = "box of shot glasses"
	desc = "It has a picture of shot glasses on it."
	illustration = "drinkglass"

/obj/item/storage/box/syndieshotglasses/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/cup/glass/drinkingglass/shotglass/syndicate(src)
