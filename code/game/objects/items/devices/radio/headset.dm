// Used for translating channels to tokens on examination
GLOBAL_LIST_INIT(channel_tokens, list(
	RADIO_CHANNEL_COMMON = RADIO_KEY_COMMON,
	RADIO_CHANNEL_SCIENCE = RADIO_TOKEN_SCIENCE,
	RADIO_CHANNEL_COMMAND = RADIO_TOKEN_COMMAND,
	RADIO_CHANNEL_MEDICAL = RADIO_TOKEN_MEDICAL,
	RADIO_CHANNEL_ENGINEERING = RADIO_TOKEN_ENGINEERING,
	RADIO_CHANNEL_SECURITY = RADIO_TOKEN_SECURITY,
	RADIO_CHANNEL_CENTCOM = RADIO_TOKEN_CENTCOM,
	RADIO_CHANNEL_SYNDICATE = RADIO_TOKEN_SYNDICATE,
	RADIO_CHANNEL_SUPPLY = RADIO_TOKEN_SUPPLY,
	RADIO_CHANNEL_SERVICE = RADIO_TOKEN_SERVICE,
	MODE_BINARY = MODE_TOKEN_BINARY,
	RADIO_CHANNEL_AI_PRIVATE = RADIO_TOKEN_AI_PRIVATE
))

/obj/item/radio/headset
	name = "radio headset"
	desc = "An updated, modular intercom that fits over the head. Takes encryption keys."
	icon_state = "headset"
	inhand_icon_state = "headset"
	worn_icon_state = "headset"
	custom_materials = list(/datum/material/iron=75)
	subspace_transmission = TRUE
	canhear_range = 0 // can't hear headsets from very far away

	slot_flags = ITEM_SLOT_EARS
	dog_fashion = null
	var/obj/item/encryptionkey/keyslot2 = null

/obj/item/radio/headset/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins putting \the [src]'s antenna up [user.p_their()] nose! It looks like [user.p_theyre()] trying to give [user.p_them()]self cancer!"))
	return TOXLOSS

/obj/item/radio/headset/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/headset/say_sec_report))
		if(HAS_TRAIT(user, TRAIT_KNOW_SECURITY_REPORTS))
			security_report(user, src)
		else
			to_chat(usr, span_warning("Oh no! To radiate a security report, you need to know its form."))

/obj/item/radio/headset/examine(mob/user)
	. = ..()

	if(item_flags & IN_INVENTORY && loc == user)
		// construction of frequency description
		var/list/avail_chans = list("Use [RADIO_KEY_COMMON] for the currently tuned frequency")
		if(translate_binary)
			avail_chans += "use [MODE_TOKEN_BINARY] for [MODE_BINARY]"
		if(length(channels))
			for(var/i in 1 to length(channels))
				if(i == 1)
					avail_chans += "use [MODE_TOKEN_DEPARTMENT] or [GLOB.channel_tokens[channels[i]]] for [lowertext(channels[i])]"
				else
					avail_chans += "use [GLOB.channel_tokens[channels[i]]] for [lowertext(channels[i])]"
		. += span_notice("A small screen on the headset displays the following available frequencies:\n[english_list(avail_chans)].")

		if(command)
			. += span_info("Alt-click to toggle the high-volume mode.")
	else
		. += span_notice("A small screen on the headset flashes, it's too small to read without holding or wearing the headset.")

/obj/item/radio/headset/Initialize(mapload)
	. = ..()
	set_listening(TRUE)
	recalculateChannels()
	possibly_deactivate_in_loc()

/obj/item/radio/headset/proc/possibly_deactivate_in_loc()
	if(ismob(loc))
		set_listening(should_be_listening)
	else
		set_listening(FALSE, actual_setting = FALSE)

/obj/item/radio/headset/Moved(atom/OldLoc, Dir)
	. = ..()
	possibly_deactivate_in_loc()

/obj/item/radio/headset/Destroy()
	QDEL_NULL(keyslot2)
	return ..()

/obj/item/radio/headset/ui_data(mob/user)
	. = ..()
	.["headset"] = TRUE

/obj/item/radio/headset/MouseDrop(mob/over, src_location, over_location)
	var/mob/headset_user = usr
	if((headset_user == over) && headset_user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return attack_self(headset_user)
	return ..()

/obj/item/radio/headset/syndicate //disguised to look like a normal headset for stealth ops

/obj/item/radio/headset/syndicate/alt //undisguised bowman with flash protection
	name = "syndicate headset"
	desc = "A syndicate headset that can be used to hear all radio frequencies. Protects ears from flashbangs."
	icon_state = "syndie_headset"
	inhand_icon_state = "syndie_headset"

/obj/item/radio/headset/syndicate/alt/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_EARS))

/obj/item/radio/headset/syndicate/alt/leader
	name = "team leader headset"
	command = TRUE

/obj/item/radio/headset/syndicate/Initialize(mapload)
	. = ..()
	make_syndie()

/obj/item/radio/headset/binary
/obj/item/radio/headset/binary/Initialize(mapload)
	. = ..()
	qdel(keyslot)
	keyslot = new /obj/item/encryptionkey/binary
	recalculateChannels()

/obj/item/radio/headset/headset_sec
	name = "security radio headset"
	actions_types = list(/datum/action/item_action/headset/say_sec_report)
	desc = "This is used by your elite security force."
	icon_state = "sec_headset"
	keyslot = new /obj/item/encryptionkey/headset_sec

/obj/item/radio/headset/headset_sec/alt
	name = "security bowman headset"
	actions_types = list(/datum/action/item_action/headset/say_sec_report)
	desc = "This is used by your elite security force. Protects ears from flashbangs."
	icon_state = "sec_headset_alt"
	inhand_icon_state = "sec_headset_alt"

/obj/item/radio/headset/headset_sec/alt/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_EARS))

/obj/item/radio/headset/headset_eng
	name = "engineering radio headset"
	desc = "When the engineers wish to chat like girls."
	icon_state = "eng_headset"
	keyslot = new /obj/item/encryptionkey/headset_eng

/obj/item/radio/headset/headset_rob
	name = "robotics radio headset"
	desc = "Made specifically for the roboticists, who cannot decide between departments."
	icon_state = "rob_headset"
	keyslot = new /obj/item/encryptionkey/headset_rob

/obj/item/radio/headset/headset_med
	name = "medical radio headset"
	desc = "A headset for the trained staff of the medbay."
	icon_state = "med_headset"
	keyslot = new /obj/item/encryptionkey/headset_med

/obj/item/radio/headset/headset_sci
	name = "science radio headset"
	desc = "A sciency headset. Like usual."
	icon_state = "sci_headset"
	keyslot = new /obj/item/encryptionkey/headset_sci

/obj/item/radio/headset/headset_medsci
	name = "medical research radio headset"
	desc = "A headset that is a result of the mating between medical and science."
	icon_state = "medsci_headset"
	keyslot = new /obj/item/encryptionkey/headset_medsci

/obj/item/radio/headset/headset_srvsec
	name = "law and order headset"
	desc = "In the criminal justice headset, the encryption key represents two separate but equally important groups. Sec, who investigate crime, and Service, who provide services. These are their comms."
	icon_state = "srvsec_headset"
	keyslot = new /obj/item/encryptionkey/headset_srvsec

/obj/item/radio/headset/headset_srvmed
	name = "psychology headset"
	desc = "A headset allowing the wearer to communicate with medbay and service."
	icon_state = "med_headset"
	keyslot = new /obj/item/encryptionkey/headset_srvmed

/obj/item/radio/headset/headset_com
	name = "command radio headset"
	desc = "A headset with a commanding channel."
	icon_state = "com_headset"
	keyslot = new /obj/item/encryptionkey/headset_com

/obj/item/radio/headset/heads
	command = TRUE

/obj/item/radio/headset/heads/captain
	name = "\proper the captain's headset"
	desc = "The headset of the king."
	icon_state = "com_headset"
	keyslot = new /obj/item/encryptionkey/heads/captain

/obj/item/radio/headset/heads/captain/alt
	name = "\proper the captain's bowman headset"
	desc = "The headset of the boss. Protects ears from flashbangs."
	icon_state = "com_headset_alt"
	inhand_icon_state = "com_headset_alt"

/obj/item/radio/headset/heads/captain/alt/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_EARS))

/obj/item/radio/headset/heads/rd
	name = "\proper the research director's headset"
	desc = "Headset of the fellow who keeps society marching towards technological singularity."
	icon_state = "com_headset"
	keyslot = new /obj/item/encryptionkey/heads/rd

/obj/item/radio/headset/heads/hos
	name = "\proper the head of security's headset"
	actions_types = list(/datum/action/item_action/headset/say_sec_report)
	desc = "The headset of the man in charge of keeping order and protecting the station."
	icon_state = "com_headset"
	keyslot = new /obj/item/encryptionkey/heads/hos

/obj/item/radio/headset/heads/hos/alt
	name = "\proper the head of security's bowman headset"
	actions_types = list(/datum/action/item_action/headset/say_sec_report)
	desc = "The headset of the man in charge of keeping order and protecting the station. Protects ears from flashbangs."
	icon_state = "com_headset_alt"
	inhand_icon_state = "com_headset_alt"

/obj/item/radio/headset/heads/hos/alt/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_EARS))

/obj/item/radio/headset/heads/ce
	name = "\proper the chief engineer's headset"
	desc = "The headset of the guy in charge of keeping the station powered and undamaged."
	icon_state = "com_headset"
	keyslot = new /obj/item/encryptionkey/heads/ce

/obj/item/radio/headset/heads/cmo
	name = "\proper the chief medical officer's headset"
	desc = "The headset of the highly trained medical chief."
	icon_state = "com_headset"
	keyslot = new /obj/item/encryptionkey/heads/cmo

/obj/item/radio/headset/heads/hop
	name = "\proper the head of personnel's headset"
	desc = "The headset of the guy who will one day be captain."
	icon_state = "com_headset"
	keyslot = new /obj/item/encryptionkey/heads/hop

/obj/item/radio/headset/headset_cargo
	name = "supply radio headset"
	desc = "A headset used by the QM and his slaves."
	icon_state = "cargo_headset"
	keyslot = new /obj/item/encryptionkey/headset_cargo

/obj/item/radio/headset/headset_cargo/mining
	name = "mining radio headset"
	desc = "Headset used by shaft miners."
	icon_state = "mine_headset"
	keyslot = new /obj/item/encryptionkey/headset_mining

/obj/item/radio/headset/headset_srv
	name = "service radio headset"
	desc = "Headset used by the service staff, tasked with keeping the station full, happy and clean."
	icon_state = "srv_headset"
	keyslot = new /obj/item/encryptionkey/headset_service

/obj/item/radio/headset/headset_cent
	name = "\improper CentCom headset"
	desc = "A headset used by the upper echelons of Nanotrasen."
	icon_state = "cent_headset"
	keyslot = new /obj/item/encryptionkey/headset_com
	keyslot2 = new /obj/item/encryptionkey/headset_cent

/obj/item/radio/headset/headset_cent/empty
	keyslot = null
	keyslot2 = null

/obj/item/radio/headset/headset_cent/commander
	keyslot = new /obj/item/encryptionkey/heads/captain

/obj/item/radio/headset/headset_cent/alt
	name = "\improper CentCom bowman headset"
	desc = "A headset especially for emergency response personnel. Protects ears from flashbangs."
	icon_state = "cent_headset_alt"
	inhand_icon_state = "cent_headset_alt"
	keyslot = null

/obj/item/radio/headset/headset_cent/alt/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_EARS))

/obj/item/radio/headset/silicon/pai
	name = "\proper mini Integrated Subspace Transceiver "
	subspace_transmission = FALSE


/obj/item/radio/headset/silicon/ai
	name = "\proper Integrated Subspace Transceiver "
	keyslot2 = new /obj/item/encryptionkey/ai
	command = TRUE

/obj/item/radio/headset/screwdriver_act(mob/living/user, obj/item/tool)
	user.set_machine(src)
	if(keyslot || keyslot2)
		for(var/ch_name in channels)
			SSradio.remove_object(src, GLOB.radiochannels[ch_name])
			secure_radio_connections[ch_name] = null

		if(keyslot)
			user.put_in_hands(keyslot)
			keyslot = null
		if(keyslot2)
			user.put_in_hands(keyslot2)
			keyslot2 = null

		recalculateChannels()
		to_chat(user, span_notice("You pop out the encryption keys in the headset."))

	else
		to_chat(user, span_warning("This headset doesn't have any unique encryption keys! How useless..."))
	tool.play_tool_sound(src, 10)
	return TRUE

/obj/item/radio/headset/attackby(obj/item/W, mob/user, params)
	user.set_machine(src)

	if(istype(W, /obj/item/encryptionkey))
		if(keyslot && keyslot2)
			to_chat(user, span_warning("The headset can't hold another key!"))
			return

		if(!keyslot)
			if(!user.transferItemToLoc(W, src))
				return
			keyslot = W

		else
			if(!user.transferItemToLoc(W, src))
				return
			keyslot2 = W


		recalculateChannels()
	else
		return ..()


/obj/item/radio/headset/recalculateChannels()
	. = ..()
	if(keyslot2)
		for(var/ch_name in keyslot2.channels)
			if(!(ch_name in src.channels))
				LAZYSET(channels, ch_name, keyslot2.channels[ch_name])

		if(keyslot2.translate_binary)
			translate_binary = TRUE
		if(keyslot2.syndie)
			syndie = TRUE
		if (keyslot2.independent)
			independent = TRUE

		for(var/ch_name in channels)
			secure_radio_connections[ch_name] = add_radio(src, GLOB.radiochannels[ch_name])

/obj/item/radio/headset/AltClick(mob/living/user)
	if(!istype(user) || !Adjacent(user) || user.incapacitated())
		return
	if (command)
		use_command = !use_command
		to_chat(user, span_notice("You toggle high-volume mode [use_command ? "on" : "off"]."))

/obj/item/radio/headset/proc/security_report(mob/user, obj/item/radio/headset/radio)
	//I don't know how to make the presentation more convenient. Let it be like this for now.
	var/list/options = sort_list(list(
			"Combat Actions" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "combat"),
			"Detecting" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "detecting"),
			"Status" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "status"),
			"Support Request" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "request")
		))
	var/option = show_radial_menu(user, user, options)
	if(!option)
		return FALSE
	switch(option)
		if("Combat Actions")
			options = list(
				"Pursuing the perpetrator" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "pursuing"),
				"I'm fighting" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "fighting"),
				"I'm hurt" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "hurt"),
				"Taking combat losses" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "losses"),
				"Retreat" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "retreat")
			)
		if("Detecting")
			options = list(
				"Station damage" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "station_damage"),
				"Fire" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "fire"),
				"Depressurization" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "depressurization"),
				"Criminal trail" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "criminal_trail"),
				"Corpse" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "corpse"),
				"Perpetrator" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "perpetrator"),
				"Dangerous perpetrator" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "dangerous_perpetrator")
			)
		if("Status")
			options = list(
				"Positive" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "positive"),
				"Negative" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "negative"),
				"My location" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "my_loc"),
				"Busy" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "busy"),
				"Available" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "available")
			)
		if("Support Request")
			options = list(
				"Requesting a detective" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "detective_support"),
				"Requesting combat support" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "combat_support"),
				"Requesting Engineering assistance" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "engineering_assistance"),
				"Requesting Medical assistance" = image(icon = 'icons/mob/actions/action_security.dmi', icon_state = "medical_assistance")
			)
	var/message = show_radial_menu(user, user, options)
	if(!message)
		return FALSE
	message = "[message]. [get_area(user)]."
	radio.talk_into(user, "[message]", "Security")
	user.say(message)
