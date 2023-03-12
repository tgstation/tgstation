/mob/living/silicon/pai
	can_be_held = TRUE
	can_buckle_to = FALSE
	density = FALSE
	desc = "A generic pAI hard-light holographics emitter."
	health = 500
	held_lh = 'icons/mob/inhands/pai_item_lh.dmi'
	held_rh = 'icons/mob/inhands/pai_item_rh.dmi'
	head_icon = 'icons/mob/clothing/head/pai_head.dmi'
	hud_type = /datum/hud/pai
	icon = 'icons/mob/silicon/pai.dmi'
	icon_state = "repairbot"
	job = JOB_PERSONAL_AI
	layer = LOW_MOB_LAYER
	light_color = COLOR_PAI_GREEN
	light_flags = LIGHT_ATTACHED
	light_on = FALSE
	light_range = 3
	light_system = MOVABLE_LIGHT
	maxHealth = 500
	mob_size = MOB_SIZE_TINY
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	mouse_opacity = MOUSE_OPACITY_ICON
	move_force = 0
	move_resist = 0
	name = "pAI"
	pass_flags = PASSTABLE | PASSMOB
	pull_force = 0
	radio = /obj/item/radio/headset/silicon/pai
	worn_slot_flags = ITEM_SLOT_HEAD

	/// If someone has enabled/disabled the pAIs ability to holo
	var/can_holo = TRUE
	/// Whether this pAI can recieve radio messages
	var/can_receive = TRUE
	/// Whether this pAI can transmit radio messages
	var/can_transmit = TRUE
	/// The card we inhabit
	var/obj/item/pai_card/card
	/// The current chasis that will appear when in holoform
	var/chassis = "repairbot"
	/// Toggles whether the pAI can hold encryption keys or not
	var/encrypt_mod = FALSE
	/// The cable we produce when hacking a door
	var/obj/item/pai_cable/hacking_cable
	/// The current health of the holochassis
	var/holochassis_health = 20
	/// Holochassis available to use
	var/holochassis_ready = FALSE
	/// Whether we are currently holoformed
	var/holoform = FALSE
	/// Installed software on the pAI
	var/list/installed_software = list()
	/// Toggles whether universal translator has been activated. Cannot be reversed
	var/languages_granted = FALSE
	/// Reference of the bound master
	var/datum/weakref/master_ref
	/// The master's name string
	var/master_name
	/// DNA string for owner verification
	var/master_dna
	/// Toggles whether the Medical  HUD is active or not
	var/medHUD = FALSE
	/// Used as currency to purchase different abilities
	var/ram = 100
	/// Toggles whether the Security HUD is active or not
	var/secHUD = FALSE

	// Onboard Items
	/// Atmospheric analyzer
	var/obj/item/analyzer/atmos_analyzer
	/// Health analyzer
	var/obj/item/healthanalyzer/host_scan
	/// GPS
	var/obj/item/gps/pai/internal_gps
	/// Music Synthesizer
	var/obj/item/instrument/piano_synth/instrument
	/// Newscaster
	var/obj/machinery/newscaster/pai/newscaster
	/// PDA
	var/atom/movable/screen/ai/modpc/pda_button
	/// Photography module
	var/obj/item/camera/siliconcam/pai_camera/camera
	/// Remote signaler
	var/obj/item/assembly/signaler/internal/signaler

	// Static lists
	/// List of all available downloads
	var/static/list/available_software = list(
		"Atmospheric Sensor" = 5,
		"Crew Manifest" = 5,
		"Digital Messenger" = 5,
		"Photography Module" = 5,
		"Encryption Slot" = 10,
		"Music Synthesizer" = 10,
		"Newscaster" = 10,
		"Remote Signaler" = 10,
		"Host Scan" = 20,
		"Medical HUD" = 20,
		"Security HUD" = 20,
		"Crew Monitor" = 35,
		"Door Jack" = 35,
		"Internal GPS" = 35,
		"Universal Translator" = 35,
	)
	/// List of all possible chasises. TRUE means the pAI can be picked up in this chasis.
	var/static/list/possible_chassis = list(
		"bat" = FALSE,
		"butterfly" = FALSE,
		"cat" = TRUE,
		"chicken" = FALSE,
		"corgi" = FALSE,
		"crow" = TRUE,
		"duffel" = TRUE,
		"fox" = FALSE,
		"hawk" = FALSE,
		"lizard" = FALSE,
		"monkey" = TRUE,
		"mouse" = TRUE,
		"rabbit" = TRUE,
		"repairbot" = TRUE,
	)
	/// List of all available card overlays.
	var/static/list/possible_overlays = list(
		"null",
		"angry",
		"cat",
		"extremely-happy",
		"face",
		"happy",
		"laugh",
		"off",
		"sad",
		"sunglasses",
		"what"
	)

/mob/living/silicon/pai/add_sensors() //pAIs have to buy their HUDs
	return

/mob/living/silicon/pai/can_interact_with(atom/target)
	if(target == signaler) // Bypass for signaler
		return TRUE
	if(target == modularInterface)
		return TRUE
	return ..()

// See software.dm for Topic()
/mob/living/silicon/pai/can_perform_action(atom/movable/target, action_bitflags)
	action_bitflags |= ALLOW_RESTING // Resting is just an aesthetic feature for them
	action_bitflags &= ~ALLOW_SILICON_REACH // They don't get long reach like the rest of silicons
	return ..(target, action_bitflags)

/mob/living/silicon/pai/Destroy()
	QDEL_NULL(atmos_analyzer)
	QDEL_NULL(camera)
	QDEL_NULL(hacking_cable)
	QDEL_NULL(host_scan)
	QDEL_NULL(instrument)
	QDEL_NULL(internal_gps)
	QDEL_NULL(newscaster)
	QDEL_NULL(signaler)
	card = null
	GLOB.pai_list.Remove(src)
	return ..()

// Need to override parent here because the message we dispatch is turf-based, not based on the location of the object because that could be fuckin anywhere
/mob/living/silicon/pai/send_applicable_messages()
	var/turf/location = get_turf(src)
	location.visible_message(span_danger(get_visible_suicide_message()), null, span_hear(get_blind_suicide_message())) // null in the second arg here because we're sending from the turf

/mob/living/silicon/pai/get_visible_suicide_message()
	return "[src] flashes a message across its screen, \"Wiping core files. Please acquire a new personality to continue using pAI device functions.\""

/mob/living/silicon/pai/get_blind_suicide_message()
	return "[src] bleeps electronically."

/mob/living/silicon/pai/emag_act(mob/user)
	handle_emag(user)

/mob/living/silicon/pai/examine(mob/user)
	. = ..()
	. += "Its master ID string seems to be [(!master_name || emagged) ? "empty" : master_name]."

/mob/living/silicon/pai/get_status_tab_items()
	. += ..()
	if(!stat)
		. += text("Emitter Integrity: [holochassis_health * (100 / HOLOCHASSIS_MAX_HEALTH)].")
	else
		. += text("Systems nonfunctional.")

/mob/living/silicon/pai/handle_atom_del(atom/deleting_atom)
	if(deleting_atom == hacking_cable)
		untrack_pai()
		untrack_thing(hacking_cable)
		hacking_cable = null
		SStgui.update_user_uis(src)
		if(!QDELETED(card))
			card.update_appearance()
	if(deleting_atom == atmos_analyzer)
		atmos_analyzer = null
	if(deleting_atom == camera)
		camera = null
	if(deleting_atom == host_scan)
		host_scan = null
	if(deleting_atom == internal_gps)
		internal_gps = null
	if(deleting_atom == instrument)
		instrument = null
	if(deleting_atom == newscaster)
		newscaster = null
	if(deleting_atom == signaler)
		signaler = null
	return ..()

/mob/living/silicon/pai/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)
	GLOB.pai_list += src
	make_laws()
	for(var/law in laws.inherent)
		lawcheck += law
	var/obj/item/pai_card/pai_card = loc
	if(!istype(pai_card)) // when manually spawning a pai, we create a card to put it into.
		var/newcardloc = pai_card
		pai_card = new(newcardloc)
		pai_card.set_personality(src)
	forceMove(pai_card)
	card = pai_card
	addtimer(VARSET_CALLBACK(src, holochassis_ready, TRUE), HOLOCHASSIS_INIT_TIME)
	if(!holoform)
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, PAI_FOLDED)
		ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, PAI_FOLDED)
	desc = "A pAI hard-light holographics emitter. This one appears in the form of a [chassis]."

	RegisterSignal(src, COMSIG_LIVING_CULT_SACRIFICED, PROC_REF(on_cult_sacrificed))

/mob/living/silicon/pai/make_laws()
	laws = new /datum/ai_laws/pai()
	return TRUE

/mob/living/silicon/pai/process(delta_time)
	holochassis_health = clamp((holochassis_health + (HOLOCHASSIS_REGEN_PER_SECOND * delta_time)), -50, HOLOCHASSIS_MAX_HEALTH)

/mob/living/silicon/pai/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	. = ..()
	if(!.)
		add_movespeed_modifier(/datum/movespeed_modifier/pai_spacewalk)
		return TRUE
	remove_movespeed_modifier(/datum/movespeed_modifier/pai_spacewalk)
	return TRUE

/mob/living/silicon/pai/screwdriver_act(mob/living/user, obj/item/tool)
	return radio.screwdriver_act(user, tool)

/mob/living/silicon/pai/updatehealth()
	if(status_flags & GODMODE)
		return
	set_health(maxHealth - getBruteLoss() - getFireLoss())
	update_stat()
	SEND_SIGNAL(src, COMSIG_LIVING_HEALTH_UPDATE)

/**
 * Resolves the weakref of the pai's master.
 * If the master has been deleted, calls reset_software().
 *
 * @returns {mob/living || FALSE} - The master mob, or
 * 	FALSE if the master is gone.
 */
/mob/living/silicon/pai/proc/find_master()
	if(!master_ref)
		return FALSE
	var/mob/living/resolved_master = master_ref?.resolve()
	if(!resolved_master)
		reset_software()
		return FALSE
	return resolved_master

/**
 * Fixes weird speech issues with the pai.
 *
 * @returns {boolean} - TRUE if successful.
 */
/mob/living/silicon/pai/proc/fix_speech()
	var/mob/living/silicon/pai = src
	balloon_alert(pai, "speech modulation corrected")
	for(var/effect in typesof(/datum/status_effect/speech))
		pai.remove_status_effect(effect)
	return TRUE

/**
 * Gets the current holder of the pAI if its
 * being carried in card or holoform.
 *
 * @returns {living/carbon || FALSE} - The holder of the pAI,
 * 	or FALSE if the pAI is not being carried.
 */
/mob/living/silicon/pai/proc/get_holder()
	var/mob/living/carbon/holder
	if(!holoform && iscarbon(card.loc))
		holder = card.loc
	if(holoform && ispickedupmob(loc) && iscarbon(loc.loc))
		holder = loc.loc
	if(!holder || !iscarbon(holder))
		return FALSE
	return holder

/**
 * Handles the pai card or the pai itself being hit with an emag.
 * This replaces any current laws, masters, and DNA.
 *
 * @param {living/carbon} attacker - The user performing the action.
 * @returns {boolean} - TRUE if successful, FALSE if not.
 */
/mob/living/silicon/pai/proc/handle_emag(mob/living/carbon/attacker)
	if(!isliving(attacker))
		return FALSE
	balloon_alert(attacker, "directive override complete")
	balloon_alert(src, "directive override detected")
	log_game("[key_name(attacker)] emagged [key_name(src)], wiping their master DNA and supplemental directive.")
	emagged = TRUE
	master_ref = WEAKREF(attacker)
	master_name = "The Syndicate"
	master_dna = "Untraceable Signature"
	// Sets supplemental directive to this
	laws.supplied[1] = "Do not interfere with the operations of the Syndicate."
	return TRUE

/**
 * Resets the pAI and any emagged status.
 *
 * @returns {boolean} - TRUE if successful, FALSE if not.
 */
/mob/living/silicon/pai/proc/reset_software()
	emagged = FALSE
	if(!master_ref)
		return FALSE
	master_ref = null
	master_name = null
	master_dna = null
	add_supplied_law(0, "None.")
	balloon_alert(src, "software rebooted")
	return TRUE

/**
 * Imprints your DNA onto the downloaded pAI
 *
 * @param {mob} user - The user performing the imprint.
 * @returns {boolean} - TRUE if successful, FALSE if not.
 */
/mob/living/silicon/pai/proc/set_dna(mob/user)
	if(!iscarbon(user))
		balloon_alert(user, "incompatible DNA signature")
		balloon_alert(src, "incompatible DNA signature")
		return FALSE
	if(emagged)
		balloon_alert(user, "directive system malfunctional")
		return FALSE
	var/mob/living/carbon/master = user
	master_ref = WEAKREF(master)
	master_name = master.real_name
	master_dna = master.dna.unique_enzymes
	to_chat(src, span_boldannounce("You have been bound to a new master: [user.real_name]!"))
	holochassis_ready = TRUE
	return TRUE

/**
 * Opens a tgui alert that allows someone to enter laws.
 *
 * @param {mob} user - The user performing the law change.
 * @returns {boolean} - TRUE if successful, FALSE if not.
 */
/mob/living/silicon/pai/proc/set_laws(mob/user)
	if(!master_ref)
		balloon_alert(user, "access denied: no master")
		return FALSE
	var/new_laws = tgui_input_text(user, "Enter any additional directives you would like your pAI personality to follow. Note that these directives will not override the personality's allegiance to its imprinted master. Conflicting directives will be ignored.", "pAI Directive Configuration", laws.supplied[1], 300)
	if(!new_laws || !master_ref)
		return FALSE
	add_supplied_law(0, new_laws)
	to_chat(src, span_notice(new_laws))
	return TRUE

/**
 * Toggles the ability of the pai to enter holoform
 *
 * @returns {boolean} - TRUE if successful, FALSE if not.
 */
/mob/living/silicon/pai/proc/toggle_holo()
	balloon_alert(src, "holomatrix [can_holo ? "disabled" : "enabled"]")
	can_holo = !can_holo
	return TRUE

/**
 * Toggles the radio settings on and off.
 *
 * @param {string} option - The option being toggled.
 */
/mob/living/silicon/pai/proc/toggle_radio(option)
	// it can't be both so if we know it's not transmitting it must be receiving.
	var/transmitting = option == "transmit"
	var/transmit_holder = (transmitting ? WIRE_TX : WIRE_RX)
	if(transmitting)
		can_transmit = !can_transmit
	else //receiving
		can_receive = !can_receive
	radio.wires.cut(transmit_holder)//wires.cut toggles cut and uncut states
	transmit_holder = (transmitting ? can_transmit : can_receive) //recycling can be fun!
	balloon_alert(src, "[transmitting ? "outgoing" : "incoming"] radio [transmit_holder ? "enabled" : "disabled"]")
	return TRUE

/**
 * Wipes the current pAI on the card.
 *
 * @param {mob} user - The user performing the action.
 *
 * @returns {boolean} - TRUE if successful, FALSE if not.
 */
/mob/living/silicon/pai/proc/wipe_pai(mob/user)
	if(tgui_alert(user, "Are you certain you wish to delete the current personality? This action cannot be undone.", "Personality Wipe", list("Yes", "No")) != "Yes")
		return FALSE
	to_chat(src, span_warning("You feel yourself slipping away from reality."))
	to_chat(src, span_danger("Byte by byte you lose your sense of self."))
	to_chat(src, span_userdanger("Your mental faculties leave you."))
	to_chat(src, span_rose("oblivion... "))
	balloon_alert(user, "personality wiped")
	playsound(src, "sound/machines/buzz-two.ogg", 30, TRUE)
	qdel(src)
	return TRUE

/// Signal proc for [COMSIG_LIVING_CULT_SACRIFICED] to give a funny message when a pai is attempted to be sac'd
/mob/living/silicon/pai/proc/on_cult_sacrificed(datum/source, list/invokers)
	SIGNAL_HANDLER

	for(var/mob/living/cultist as anything in invokers)
		to_chat(cultist, span_cultitalic("You don't think this is what Nar'Sie had in mind when She asked for blood sacrifices..."))
	return STOP_SACRIFICE
