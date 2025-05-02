//defines the drill hat's yelling setting
#define DRILL_DEFAULT "default"
#define DRILL_SHOUTING "shouting"
#define DRILL_YELLING "yelling"
#define DRILL_CANADIAN "canadian"

//Chef
/obj/item/clothing/head/utility/chefhat
	name = "chef's hat"
	inhand_icon_state = "chefhat"
	icon_state = "chef"
	desc = "The commander in chef's head wear."
	strip_delay = 10
	equip_delay_other = 10
	dog_fashion = /datum/dog_fashion/head/chef
	/// The chance that the movements of a mouse inside of this hat get relayed to the human wearing the hat
	var/mouse_control_probability = 20
	/// Allowed time between movements
	COOLDOWN_DECLARE(move_cooldown)

/// Admin variant of the chef hat where every mouse pilot input will always be transferred to the wearer
/obj/item/clothing/head/utility/chefhat/i_am_assuming_direct_control
	desc = "The commander in chef's head wear. Upon closer inspection, there seem to be dozens of tiny levers, buttons, dials, and screens inside of this hat. What the hell...?"
	mouse_control_probability = 100

/obj/item/clothing/head/utility/chefhat/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/chefhat)

/obj/item/clothing/head/utility/chefhat/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	var/mob/living/basic/new_boss = get_mouse(arrived)
	if(!new_boss)
		return
	RegisterSignal(new_boss, COMSIG_MOB_PRE_EMOTED, PROC_REF(on_mouse_emote))
	RegisterSignal(new_boss, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_mouse_moving))
	RegisterSignal(new_boss, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, PROC_REF(on_mouse_moving))

/obj/item/clothing/head/utility/chefhat/Exited(atom/movable/gone, direction)
	. = ..()
	var/mob/living/basic/old_boss = get_mouse(gone)
	if(!old_boss)
		return
	UnregisterSignal(old_boss, list(COMSIG_MOB_PRE_EMOTED, COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE))

/// Returns a mob stored inside a mob container, if there is one
/obj/item/clothing/head/utility/chefhat/proc/get_mouse(atom/possible_mouse)
	if (!ispickedupmob(possible_mouse))
		return
	var/obj/item/clothing/head/mob_holder/mousey_holder = possible_mouse
	return locate(/mob/living/basic) in mousey_holder.contents

/// Relays emotes emoted by your boss to the hat wearer for full immersion
/obj/item/clothing/head/utility/chefhat/proc/on_mouse_emote(mob/living/source, key, emote_message, type_override)
	SIGNAL_HANDLER
	var/mob/living/carbon/wearer = loc
	if(!wearer || INCAPACITATED_IGNORING(wearer, INCAPABLE_RESTRAINTS))
		return
	if (!prob(mouse_control_probability))
		return COMPONENT_CANT_EMOTE
	INVOKE_ASYNC(wearer, TYPE_PROC_REF(/mob, emote), key, type_override, emote_message, FALSE)
	return COMPONENT_CANT_EMOTE

/// Relays movement made by the mouse in your hat to the wearer of the hat
/obj/item/clothing/head/utility/chefhat/proc/on_mouse_moving(mob/living/source, atom/moved_to)
	SIGNAL_HANDLER
	if (!prob(mouse_control_probability) || !COOLDOWN_FINISHED(src, move_cooldown))
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE // Didn't roll well enough or on cooldown

	var/mob/living/carbon/wearer = loc
	if(!wearer || INCAPACITATED_IGNORING(wearer, INCAPABLE_RESTRAINTS))
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE // Not worn or can't move

	var/move_direction = get_dir(wearer, moved_to)
	if(!wearer.Process_Spacemove(move_direction))
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE // Currently drifting in space
	if(!has_gravity() || !isturf(wearer.loc))
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE // Not in a location where we can move

	step_towards(wearer, moved_to)
	var/move_delay = wearer.cached_multiplicative_slowdown
	if (ISDIAGONALDIR(move_direction))
		move_delay *= sqrt(2)
	COOLDOWN_START(src, move_cooldown, move_delay)
	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/obj/item/clothing/head/utility/chefhat/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is donning [src]! It looks like [user.p_theyre()] trying to become a chef."))
	user.say("Bork Bork Bork!", forced = "chef hat suicide")
	sleep(2 SECONDS)
	user.visible_message(span_suicide("[user] climbs into an imaginary oven!"))
	user.say("BOOORK!", forced = "chef hat suicide")
	playsound(user, 'sound/machines/ding.ogg', 50, TRUE)
	return FIRELOSS

//Captain
/obj/item/clothing/head/hats/caphat
	name = "captain's hat"
	desc = "It's good being the king."
	icon_state = "captain"
	inhand_icon_state = "that"
	flags_inv = 0
	armor_type = /datum/armor/hats_caphat
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/captain

//Captain: This is no longer space-worthy
/datum/armor/hats_caphat
	melee = 25
	bullet = 15
	laser = 25
	energy = 35
	bomb = 25
	fire = 50
	acid = 50
	wound = 5

/obj/item/clothing/head/hats/caphat/parade
	name = "captain's parade cap"
	desc = "Worn only by Captains with an abundance of class."
	icon_state = "capcap"
	dog_fashion = null

/obj/item/clothing/head/caphat/beret
	name = "captain's beret"
	desc = "For the Captains known for their sense of fashion."
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#0070B7#FFCE5B"
	hair_mask = HAIR_MASK_HIDE_ABOVE_45_DEG_MEDIUM

//Head of Personnel
/obj/item/clothing/head/hats/hopcap
	name = "head of personnel's cap"
	icon_state = "hopcap"
	desc = "The symbol of true bureaucratic micromanagement."
	armor_type = /datum/armor/hats_hopcap
	dog_fashion = /datum/dog_fashion/head/hop

//Chaplain
/datum/armor/hats_hopcap
	melee = 25
	bullet = 15
	laser = 25
	energy = 35
	bomb = 25
	fire = 50
	acid = 50

/obj/item/clothing/head/chaplain/nun_hood
	name = "nun hood"
	desc = "Maximum piety in this star system."
	icon_state = "nun_hood"
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/chaplain/habit_veil
	name = "nun veil"
	desc = "No nunsene clothing."
	icon_state = "nun_hood_alt"
	flags_inv = HIDEHAIR | HIDEEARS
	clothing_flags = SNUG_FIT // can't be knocked off by throwing a paper hat.

/obj/item/clothing/head/chaplain/bishopmitre
	name = "bishop mitre"
	desc = "An opulent hat that functions as a radio to God. Or as a lightning rod, depending on who you ask."
	icon_state = "bishopmitre"

#define CANDY_CD_TIME 2 MINUTES

//Detective
/obj/item/clothing/head/fedora/det_hat
	name = "detective's fedora"
	desc = "There's only one man who can sniff out the dirty stench of crime, and he's likely wearing this hat."
	armor_type = /datum/armor/fedora_det_hat
	icon_state = "detective"
	interaction_flags_click = NEED_DEXTERITY|NEED_HANDS|ALLOW_RESTING
	dog_fashion = /datum/dog_fashion/head/detective
	/// Path for the flask that spawns inside their hat roundstart
	var/flask_path = /obj/item/reagent_containers/cup/glass/flask/det
	/// Cooldown for retrieving precious candy corn with rmb
	COOLDOWN_DECLARE(candy_cooldown)


/datum/armor/fedora_det_hat
	melee = 25
	bullet = 5
	laser = 25
	energy = 35
	fire = 30
	acid = 50
	wound = 5


/obj/item/clothing/head/fedora/det_hat/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/small/fedora/detective)

	register_context()

	new flask_path(src)


/obj/item/clothing/head/fedora/det_hat/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to take a candy corn.")


/obj/item/clothing/head/fedora/det_hat/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	context[SCREENTIP_CONTEXT_ALT_LMB] = "Candy Time"

	return CONTEXTUAL_SCREENTIP_SET


/// Now to solve where all these keep coming from
/obj/item/clothing/head/fedora/det_hat/click_alt(mob/user)
	if(!COOLDOWN_FINISHED(src, candy_cooldown))
		to_chat(user, span_warning("You just took a candy corn! You should wait a couple minutes, lest you burn through your stash."))
		return CLICK_ACTION_BLOCKING

	var/obj/item/food/candy_corn/sweets = new /obj/item/food/candy_corn(src)
	user.put_in_hands(sweets)
	to_chat(user, span_notice("You slip a candy corn from your hat."))
	COOLDOWN_START(src, candy_cooldown, CANDY_CD_TIME)

	return CLICK_ACTION_SUCCESS


#undef CANDY_CD_TIME

/obj/item/clothing/head/fedora/det_hat/minor
	flask_path = /obj/item/reagent_containers/cup/glass/flask/det/minor

///Detectives Fedora, but like Inspector Gadget. Not a subtype to not inherit candy corn stuff
/obj/item/clothing/head/fedora/inspector_hat
	name = "inspector's fedora"
	desc = "There's only one man can try to stop an evil villain."
	armor_type = /datum/armor/fedora_det_hat
	icon_state = "detective"
	dog_fashion = /datum/dog_fashion/head/detective
	interaction_flags_click = FORBID_TELEKINESIS_REACH|ALLOW_RESTING
	///prefix our phrases must begin with
	var/prefix = "go go gadget"
	///an assoc list of regex = item (like regex datum = revolver item)
	var/list/items_by_regex = list()
	///A an assoc list of regex = phrase (like regex datum = gun text)
	var/list/phrases_by_regex = list()
	///how many gadgets can we hold
	var/max_items = 4
	///items above this weight cannot be put in the hat
	var/max_weight = WEIGHT_CLASS_NORMAL

/obj/item/clothing/head/fedora/inspector_hat/Initialize(mapload)
	. = ..()
	become_hearing_sensitive(ROUNDSTART_TRAIT)
	QDEL_NULL(atom_storage)

/obj/item/clothing/head/fedora/inspector_hat/proc/set_prefix(desired_prefix)

	prefix = desired_prefix

	// Regenerated the phrases here.
	for(var/old_regex in phrases_by_regex)
		var/old_phrase = phrases_by_regex[old_regex]
		var/obj/item/old_item = items_by_regex[old_regex]
		items_by_regex -= old_regex
		phrases_by_regex -= old_regex
		set_phrase(old_phrase,old_item)

	return TRUE

/obj/item/clothing/head/fedora/inspector_hat/proc/set_phrase(desired_phrase,obj/item/associated_item)

	var/regex/phrase_regex = regex("[prefix]\[\\s\\W\]+[desired_phrase]","i")

	phrases_by_regex[phrase_regex] = desired_phrase
	items_by_regex[phrase_regex] = associated_item

	return TRUE

/obj/item/clothing/head/fedora/inspector_hat/examine(mob/user)
	. = ..()
	. += span_notice("You can put items inside, and get them out by saying a phrase, or using it in-hand!")
	. += span_notice("The prefix is <b>[prefix]</b>, and you can change it with alt-click!\n")
	for(var/found_regex in phrases_by_regex)
		var/found_phrase = phrases_by_regex[found_regex]
		var/obj/item/found_item = items_by_regex[found_regex]
		. += span_notice("[icon2html(found_item, user)] You can remove [found_item] by saying <b>\"[prefix] [found_phrase]\"</b>!")

/obj/item/clothing/head/fedora/inspector_hat/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range)
	. = ..()
	var/mob/living/carbon/wearer = loc
	if(!istype(wearer) || speaker != wearer) //if we are worn
		return

	raw_message = htmlrendertext(raw_message)

	for(var/regex/found_regex as anything in phrases_by_regex)
		if(!found_regex.Find(raw_message))
			continue
		var/obj/item/found_item = items_by_regex[found_regex]
		if(wearer.put_in_hands(found_item))
			wearer.visible_message(span_warning("[src] drops [found_item] into the hands of [wearer]!"))
			. = TRUE
		else
			balloon_alert(wearer, "can't put in hands!")
			break

	return .

/obj/item/clothing/head/fedora/inspector_hat/attackby(obj/item/item, mob/user, params)
	. = ..()

	if(LAZYLEN(contents) >= max_items)
		balloon_alert(user, "full!")
		return
	if(item.w_class > max_weight)
		balloon_alert(user, "too big!")
		return

	var/desired_phrase = tgui_input_text(user, "What is the activation phrase?", "Activation phrase", "gadget", max_length = 26)
	if(!desired_phrase || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return

	if(item.loc != user || !user.transferItemToLoc(item, src))
		return

	to_chat(user, span_notice("You install [item] into the [thtotext(contents.len)] slot of [src]."))
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	set_phrase(desired_phrase,item)

	return TRUE

/obj/item/clothing/head/fedora/inspector_hat/attack_self(mob/user)
	. = ..()
	if(!length(items_by_regex))
		return CLICK_ACTION_BLOCKING
	var/list/found_items = list()
	for(var/found_regex in items_by_regex)
		found_items += items_by_regex[found_regex]
	var/obj/found_item = tgui_input_list(user, "What item do you want to remove?", "Item Removal", found_items)
	if(!found_item || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return CLICK_ACTION_BLOCKING
	user.put_in_inactive_hand(found_item)

/obj/item/clothing/head/fedora/inspector_hat/click_alt(mob/user)
	var/new_prefix = tgui_input_text(user, "What should be the new prefix?", "Activation prefix", prefix, max_length = 24)
	if(!new_prefix || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return CLICK_ACTION_BLOCKING
	set_prefix(new_prefix)
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/head/fedora/inspector_hat/Exited(atom/movable/gone, direction)
	. = ..()
	for(var/found_regex in items_by_regex)
		var/obj/item/found_item = items_by_regex[found_regex]
		if(gone != found_item)
			continue
		items_by_regex -= found_regex
		phrases_by_regex -= found_regex
		break

/obj/item/clothing/head/fedora/inspector_hat/atom_destruction(damage_flag)

	var/atom/atom_location = drop_location()
	for(var/found_regex in items_by_regex)
		var/obj/item/result = items_by_regex[found_regex]
		result.forceMove(atom_location)
		items_by_regex -= found_regex
		phrases_by_regex -= found_regex

	return ..()

/obj/item/clothing/head/fedora/inspector_hat/Destroy()
	QDEL_LIST_ASSOC(items_by_regex) //Anything that failed to drop gets deleted.
	return ..()

//Mime
/obj/item/clothing/head/beret
	name = "beret"
	desc = "A beret, a mime's favorite headwear."
	icon_state = "beret"
	icon_preview = 'icons/obj/clothing/head/beret.dmi'
	icon_state_preview = "beret"
	dog_fashion = /datum/dog_fashion/head/beret
	greyscale_config = /datum/greyscale_config/beret
	greyscale_config_worn = /datum/greyscale_config/beret/worn
	greyscale_colors = "#972A2A"
	flags_1 = IS_PLAYER_COLORABLE_1
	hair_mask = HAIR_MASK_HIDE_ABOVE_45_DEG_MEDIUM

//Security
/obj/item/clothing/head/hats/hos
	name = "generic head of security hat"
	desc = "Please contact the Nanotrasen Costuming Department if found."
	armor_type = /datum/armor/hats_hos
	strip_delay = 8 SECONDS

/obj/item/clothing/head/hats/hos/cap
	name = "head of security cap"
	desc = "The robust standard-issue cap of the Head of Security. For showing the officers who's in charge. Looks a bit stout."
	icon_state = "hoscap"

/obj/item/clothing/head/hats/hos/cap/Initialize(mapload)
	. = ..()
	// Give it a little publicity
	var/static/list/slapcraft_recipe_list = list(\
		/datum/crafting_recipe/sturdy_shako,\
		)

	AddElement(
		/datum/element/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

/datum/armor/hats_hos
	melee = 40
	bullet = 30
	laser = 25
	energy = 35
	bomb = 25
	bio = 10
	fire = 50
	acid = 60
	wound = 10

/obj/item/clothing/head/hats/hos/cap/syndicate
	name = "syndicate cap"
	desc = "A black cap fit for a high ranking syndicate officer."

/obj/item/clothing/head/hats/hos/shako
	name = "sturdy shako"
	desc = "Wearing this makes you want to shout \"Down and give me twenty!\" at someone."
	icon_state = "hosshako"
	worn_icon = 'icons/mob/large-worn-icons/64x64/head.dmi'
	worn_x_dimension = 64
	worn_y_dimension = 64

/obj/item/clothing/head/hats/hos/beret
	name = "head of security's beret"
	desc = "A robust beret for the Head of Security, for looking stylish while not sacrificing protection."
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#39393f#f0cc8f"
	hair_mask = HAIR_MASK_HIDE_ABOVE_45_DEG_MEDIUM

/obj/item/clothing/head/hats/hos/beret/navyhos
	name = "head of security's formal beret"
	desc = "A special beret with the Head of Security's insignia emblazoned on it. A symbol of excellence, a badge of courage, a mark of distinction."
	greyscale_colors = "#638799#f0cc8f"

/obj/item/clothing/head/hats/hos/beret/syndicate
	name = "syndicate beret"
	desc = "A black beret with thick armor padding inside. Stylish and robust."

/obj/item/clothing/head/hats/warden
	name = "warden's police hat"
	desc = "It's a special armored hat issued to the Warden of a security force. Protects the head from impacts."
	icon_state = "policehelm"
	armor_type = /datum/armor/hats_warden
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/warden

/datum/armor/hats_warden
	melee = 40
	bullet = 30
	laser = 30
	energy = 40
	bomb = 25
	fire = 30
	acid = 60
	wound = 6

/obj/item/clothing/head/hats/warden/police
	name = "police officer's hat"
	desc = "A police officer's hat. This hat emphasizes that you are THE LAW."

/obj/item/clothing/head/hats/warden/red
	name = "warden's hat"
	desc = "A warden's red hat. Looking at it gives you the feeling of wanting to keep people in cells for as long as possible."
	icon_state = "wardenhat"
	dog_fashion = /datum/dog_fashion/head/warden_red

/obj/item/clothing/head/hats/warden/drill
	name = "warden's campaign hat"
	desc = "A special armored campaign hat with the security insignia emblazoned on it. Uses reinforced fabric to offer sufficient protection."
	icon_state = "wardendrill"
	inhand_icon_state = null
	dog_fashion = null
	var/mode = DRILL_DEFAULT

/obj/item/clothing/head/hats/warden/drill/screwdriver_act(mob/living/carbon/human/user, obj/item/I)
	if(..())
		return TRUE
	switch(mode)
		if(DRILL_DEFAULT)
			to_chat(user, span_notice("You set the voice circuit to the middle position."))
			mode = DRILL_SHOUTING
		if(DRILL_SHOUTING)
			to_chat(user, span_notice("You set the voice circuit to the last position."))
			mode = DRILL_YELLING
		if(DRILL_YELLING)
			to_chat(user, span_notice("You set the voice circuit to the first position."))
			mode = DRILL_DEFAULT
		if(DRILL_CANADIAN)
			to_chat(user, span_danger("You adjust voice circuit but nothing happens, probably because it's broken."))
	return TRUE

/obj/item/clothing/head/hats/warden/drill/wirecutter_act(mob/living/user, obj/item/I)
	..()
	if(mode != DRILL_CANADIAN)
		to_chat(user, span_danger("You broke the voice circuit!"))
		mode = DRILL_CANADIAN
	return TRUE

/obj/item/clothing/head/hats/warden/drill/equipped(mob/M, slot)
	. = ..()
	if (slot & ITEM_SLOT_HEAD)
		RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/head/hats/warden/drill/dropped(mob/M)
	. = ..()
	UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/head/hats/warden/drill/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		switch (mode)
			if(DRILL_SHOUTING)
				message += "!"
			if(DRILL_YELLING)
				message += "!!"
			if(DRILL_CANADIAN)
				message = "[message]"
				var/list/canadian_words = strings("canadian_replacement.json", "canadian")

				for(var/key in canadian_words)
					var/value = canadian_words[key]
					if(islist(value))
						value = pick(value)

					message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
					message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
					message = replacetextEx(message, " [key]", " [value]")

				if(prob(30))
					message += pick(", eh?", ", EH?")
		speech_args[SPEECH_MESSAGE] = message

/obj/item/clothing/head/beret/sec
	name = "security beret"
	desc = "A robust beret with the security insignia emblazoned on it. Uses reinforced fabric to offer sufficient protection."
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#a52f29#F2F2F2"
	armor_type = /datum/armor/cosmetic_sec
	strip_delay = 60
	dog_fashion = null
	flags_1 = NONE

/datum/armor/cosmetic_sec
	melee = 30
	bullet = 25
	laser = 25
	energy = 35
	bomb = 25
	fire = 20
	acid = 50
	wound = 4

/obj/item/clothing/head/beret/sec/navywarden
	name = "warden's beret"
	desc = "A special beret with the Warden's insignia emblazoned on it. For wardens with class."
	greyscale_colors = "#638799#ebebeb"
	strip_delay = 60

/obj/item/clothing/head/beret/sec/navyofficer
	desc = "A special beret with the security insignia emblazoned on it. For officers with class."
	greyscale_colors = "#638799#a52f29"

//Science
/obj/item/clothing/head/beret/science
	name = "science beret"
	desc = "A science-themed beret for our hardworking scientists."
	greyscale_colors = "#8D008F"
	flags_1 = NONE

/obj/item/clothing/head/beret/science/rd
	desc = "A purple badge with the insignia of the Research Director attached. For the paper-shuffler in you!"
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#7e1980#c9cbcb"

//Medical
/obj/item/clothing/head/beret/medical
	name = "medical beret"
	desc = "A medical-flavored beret for the doctor in you!"
	greyscale_colors = COLOR_WHITE
	flags_1 = NONE

/obj/item/clothing/head/beret/medical/paramedic
	name = "paramedic beret"
	desc = "For finding corpses in style!"
	greyscale_colors = "#16313D"

/obj/item/clothing/head/beret/medical/cmo
	name = "chief medical officer beret"
	desc = "A beret in a distinct surgical turquoise!"
	greyscale_colors = "#5EB8B8"

/obj/item/clothing/head/utility/surgerycap
	name = "blue surgery cap"
	icon_state = "surgicalcap"
	desc = "A blue medical surgery cap to prevent the surgeon's hair from entering the insides of the patient!"
	flags_inv = HIDEHAIR //Cover your head doctor!
	w_class = WEIGHT_CLASS_SMALL //surgery cap can be easily crumpled

/obj/item/clothing/head/utility/surgerycap/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, -3) //FISH DOCTOR?!

/obj/item/clothing/head/utility/surgerycap/attack_self(mob/user)
	. = ..()
	if(.)
		return
	balloon_alert(user, "[flags_inv & HIDEHAIR ? "loosening" : "tightening"] strings...")
	if(!do_after(user, 3 SECONDS, src))
		return
	flags_inv ^= HIDEHAIR
	balloon_alert(user, "[flags_inv & HIDEHAIR ? "tightened" : "loosened "] strings")
	return TRUE

/obj/item/clothing/head/utility/surgerycap/examine(mob/user)
	. = ..()
	. += span_notice("Use in hand to [flags_inv & HIDEHAIR ? "loosen" : "tighten"] the strings.")

/obj/item/clothing/head/utility/surgerycap/purple
	name = "burgundy surgery cap"
	icon_state = "surgicalcapwine"
	desc = "A burgundy medical surgery cap to prevent the surgeon's hair from entering the insides of the patient!"

/obj/item/clothing/head/utility/surgerycap/green
	name = "green surgery cap"
	icon_state = "surgicalcapgreen"
	desc = "A green medical surgery cap to prevent the surgeon's hair from entering the insides of the patient!"

/obj/item/clothing/head/utility/surgerycap/cmo
	name = "turquoise surgery cap"
	icon_state = "surgicalcapcmo"
	desc = "The CMO's medical surgery cap to prevent their hair from entering the insides of the patient!"

/obj/item/clothing/head/utility/surgerycap/black
	name = "black surgery cap"
	icon_state = "surgicalcapblack"
	desc = "A black medical surgery cap to prevent the surgeon's hair from entering the insides of the patient!"

/obj/item/clothing/head/utility/head_mirror
	name = "head mirror"
	desc = "Used by doctors to look into a patient's eyes, ears, and mouth. \
		A little useless now, given the technology available, but it certainly completes the look."
	icon_state = "headmirror"
	body_parts_covered = NONE

/obj/item/clothing/head/utility/head_mirror/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, -3) //FISH DOCTOR?!

/obj/item/clothing/head/utility/head_mirror/examine(mob/user)
	. = ..()
	. += span_notice("In a properly lit room, you can use this to examine people's eyes, ears, and mouth <i>closer</i>.")

/obj/item/clothing/head/utility/head_mirror/equipped(mob/living/user, slot)
	. = ..()
	if(slot & slot_flags)
		RegisterSignal(user, COMSIG_MOB_EXAMINING_MORE, PROC_REF(examining))
	else
		UnregisterSignal(user, COMSIG_MOB_EXAMINING_MORE)

/obj/item/clothing/head/utility/head_mirror/dropped(mob/living/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_EXAMINING_MORE)

/obj/item/clothing/head/utility/head_mirror/proc/examining(mob/living/examiner, atom/examining, list/examine_list)
	SIGNAL_HANDLER
	if(!ishuman(examining) || examining == examiner || examiner.is_blind() || !examiner.Adjacent(examining))
		return
	var/mob/living/carbon/human/human_examined = examining
	if(!human_examined.get_bodypart(BODY_ZONE_HEAD))
		return
	if(!examiner.has_light_nearby())
		examine_list += span_warning("You attempt to use your [name] to examine [examining]'s head better... but it's too dark. Should've invested in a head lamp.")
		return
	if(examiner.dir == examining.dir) // disallow examine from behind - every other dir is OK
		examine_list += span_warning("You attempt to use your [name] to examine [examining]'s head better... but [examining.p_theyre()] facing the wrong way.")
		return

	var/list/final_message = list("You examine [examining]'s head closer with your [name], you notice [examining.p_they()] [examining.p_have()]...")
	if(human_examined.is_mouth_covered())
		final_message += "\tYou can't see [examining.p_their()] mouth."
	else
		var/obj/item/organ/tongue/has_tongue = human_examined.get_organ_slot(ORGAN_SLOT_TONGUE)
		var/pill_count = 0
		for(var/datum/action/item_action/activate_pill/pill in human_examined.actions)
			pill_count++

		if(pill_count >= 1 && has_tongue)
			final_message += "\t[pill_count] pill\s in [examining.p_their()] mouth, and \a [has_tongue]."
		else if(pill_count >= 1)
			final_message += "\t[pill_count] pill\s in [examining.p_their()] mouth, but oddly no tongue."
		else if(has_tongue)
			final_message += "\t\A [has_tongue] in [examining.p_their()] mouth - go figure."
		else
			final_message += "\tNo tongue in [examining.p_their()] mouth, oddly enough."

	if(human_examined.is_ears_covered())
		final_message += "\tYou can't see [examining.p_their()] ears."
	else
		var/obj/item/organ/ears/has_ears = human_examined.get_organ_slot(ORGAN_SLOT_EARS)
		if(has_ears)
			if(has_ears.deaf)
				final_message += "\tDamaged eardrums in [examining.p_their()] ear canals."
			else
				final_message += "\tA set of [has_ears.damage ? "" : "healthy "][has_ears.name]."
		else
			final_message += "\tNo eardrums and empty ear canals... how peculiar."

	if(human_examined.is_eyes_covered())
		final_message += "\tYou can't see [examining.p_their()] eyes."
	else
		var/obj/item/organ/eyes/has_eyes = human_examined.get_organ_slot(ORGAN_SLOT_EYES)
		if(has_eyes)
			final_message += "\tA pair of [has_eyes.damage ? "" : "healthy "][has_eyes.name]."
		else
			final_message += "\tEmpty eye sockets."

	examine_list += span_notice("<i>[jointext(final_message, "\n")]</i>")

//Engineering
/obj/item/clothing/head/beret/engi
	name = "engineering beret"
	desc = "Might not protect you from radiation, but definitely will protect you from looking unfashionable!"
	greyscale_colors = "#FFBC30"
	flags_1 = NONE

//Cargo
/obj/item/clothing/head/beret/cargo
	name = "cargo beret"
	desc = "No need to compensate when you can wear this beret!"
	greyscale_colors = "#b7723d"
	flags_1 = NONE

//Curator
/obj/item/clothing/head/fedora/curator
	name = "treasure hunter's fedora"
	desc = "You got red text today kid, but it doesn't mean you have to like it."
	icon_state = "curator"

/obj/item/clothing/head/beret/durathread
	name = "durathread beret"
	desc = "A beret made from durathread, its resilient fibers provide some protection to the wearer."
	icon_state = "beret_badge"
	icon_preview = 'icons/obj/fluff/previews.dmi'
	icon_state_preview = "beret_durathread"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#C5D4F3#ECF1F8"
	armor_type = /datum/armor/beret_durathread

/datum/armor/beret_durathread
	melee = 15
	bullet = 5
	laser = 15
	energy = 25
	bomb = 10
	fire = 30
	acid = 5
	wound = 4

/obj/item/clothing/head/beret/highlander
	desc = "That was white fabric. <i>Was.</i>"
	dog_fashion = null //THIS IS FOR SLAUGHTER, NOT PUPPIES

/obj/item/clothing/head/beret/highlander/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HIGHLANDER_TRAIT)

//CentCom
/obj/item/clothing/head/beret/centcom_formal
	name = "\improper CentCom Formal Beret"
	desc = "Sometimes, a compromise between fashion and defense needs to be made. Thanks to Nanotrasen's most recent nano-fabric durability enhancements, this time, it's not the case."
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#46b946#f2c42e"
	armor_type = /datum/armor/beret_centcom_formal
	strip_delay = 10 SECONDS


#undef DRILL_DEFAULT
#undef DRILL_SHOUTING
#undef DRILL_YELLING
#undef DRILL_CANADIAN

/datum/armor/beret_centcom_formal
	melee = 80
	bullet = 80
	laser = 50
	energy = 50
	bomb = 100
	bio = 100
	fire = 100
	acid = 90
	wound = 10

//Independant Militia
/obj/item/clothing/head/beret/militia
	name = "\improper Militia General's Beret"
	desc = "A rallying cry for the inhabitants of the Spinward Sector, the heroes that wear this keep the horrors of the galaxy at bay. Call them, and they'll be there in a minute!"
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#43523d#a2abb0"
	armor_type = /datum/armor/cosmetic_sec
