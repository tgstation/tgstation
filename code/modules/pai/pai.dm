/mob/living/silicon/pai
	name = "pAI"
	icon = 'icons/mob/pai.dmi'
	held_lh = 'icons/mob/pai_item_lh.dmi'
	held_rh = 'icons/mob/pai_item_rh.dmi'
	head_icon = 'icons/mob/pai_item_head.dmi'
	icon_state = "repairbot"
	mouse_opacity = MOUSE_OPACITY_ICON
	density = FALSE
	hud_type = /datum/hud/pai
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	desc = "A generic pAI hard-light holographics emitter."
	health = 500
	maxHealth = 500
	layer = LOW_MOB_LAYER
	can_be_held = TRUE
	move_force = 0
	pull_force = 0
	move_resist = 0
	worn_slot_flags = ITEM_SLOT_HEAD
	radio = /obj/item/radio/headset/silicon/pai
	can_buckle_to = FALSE
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_flags = LIGHT_ATTACHED
	light_color = COLOR_PAI_GREEN
	light_on = FALSE

	/// Whether the pAI can enter holoform or not
	var/can_holo = TRUE
	/// Whether this pAI can recieve radio messages
	var/can_receive = TRUE
	/// Whether this pAI can transmit radio messages
	var/can_transmit = TRUE
	/// The current chasis that will appear when in holoform
	var/chassis = "repairbot"
	/// The card we inhabit
	var/obj/item/pai_card/card
	/// Changes the display to syndi if true
	var/emagged = FALSE
	/// Time between fold out
	var/emitter_cd = 50
	/// The health of the holochassis
	var/emitter_health = 20
	/// The max health of the holochassis
	var/emitter_max_health = 20
	/// Overloaded or emagged foldout cooldown
	var/emitter_overload_cd = 100
	/// Regeneration rate for the holochassis
	var/emitter_regen_per_second = 1.25
	/// Brief pause upon creation, etc
	var/emitter_semi_cd = FALSE
	/// Toggles whether the pAI can hold encryption keys or not
	var/encrypt_mod = FALSE
	/// The cable we produce when hacking a door
	var/obj/item/pai_cable/hacking_cable
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
	var/atom/movable/screen/ai/modpc/interfaceButton
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
		"Newscaster" = 10,
		"Remote Signaler" = 10,
		"Host Scan" = 20,
		"Medical HUD" = 20,
		"Music Synthesizer" = 20,
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
/mob/living/silicon/pai/canUseTopic(atom/movable/movable, be_close = FALSE, no_dexterity = FALSE, no_tk = FALSE, need_hands = FALSE, floor_okay = FALSE)
	// Resting is just an aesthetic feature for them.
	return ..(movable, be_close, no_dexterity, no_tk, need_hands, TRUE)

/mob/living/silicon/pai/Destroy()
	QDEL_NULL(atmos_analyzer)
	QDEL_NULL(camera)
	QDEL_NULL(hacking_cable)
	QDEL_NULL(host_scan)
	QDEL_NULL(instrument)
	QDEL_NULL(internal_gps)
	QDEL_NULL(newscaster)
	QDEL_NULL(signaler)
	if(!QDELETED(card) && loc != card)
		card.forceMove(drop_location())
		// these are otherwise handled by paicard/handle_atom_del()
		card.pai = null
		card.emotion_icon = initial(card.emotion_icon)
		card.update_appearance()
	GLOB.pai_list.Remove(src)
	return ..()

/mob/living/silicon/pai/emag_act(mob/user)
	handle_emag(user)

/mob/living/silicon/pai/examine(mob/user)
	. = ..()
	. += "A personal AI in holochassis mode. Its master ID string seems to be [master_name || "empty"]."

/mob/living/silicon/pai/get_status_tab_items()
	. += ..()
	if(!stat)
		. += text("Emitter Integrity: [emitter_health * (100 / emitter_max_health)].")
	else
		. += text("Systems nonfunctional.")

/mob/living/silicon/pai/handle_atom_del(atom/deleting_atom)
	if(deleting_atom == hacking_cable)
		hacking_cable = null
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
	var/obj/item/pai_card/pai_card = loc
	START_PROCESSING(SSfastprocess, src)
	GLOB.pai_list += src
	make_laws()
	for (var/law in laws.inherent)
		lawcheck += law
	if(!istype(pai_card)) //when manually spawning a pai, we create a card to put it into.
		var/newcardloc = pai_card
		pai_card = new(newcardloc)
		pai_card.set_personality(src)
	forceMove(pai_card)
	card = pai_card
	job = JOB_PERSONAL_AI
	. = ..()
	emitter_semi_cd = TRUE
	addtimer(CALLBACK(src, .proc/emitter_cool), 600)
	if(!holoform)
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, PAI_FOLDED)
		ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, PAI_FOLDED)
	desc = "A pAI mobile hard-light holographics emitter. This one appears in the form of a [chassis]."
	return INITIALIZE_HINT_LATELOAD

/mob/living/silicon/pai/make_laws()
	laws = new /datum/ai_laws/pai()
	return TRUE

/mob/living/silicon/pai/process(delta_time)
	emitter_health = clamp((emitter_health + (emitter_regen_per_second * delta_time)), -50, emitter_max_health)

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

/**
 * Resolves the weakref of the pai's master.
 * If the master has been deleted, calls reset_software().
 *
 * @return {mob/living} the master mob, or FALSE if the master is gone.
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
 * @param {mob} user - The user performing the action.
 * @return {boolean} - TRUE if successful.
 */
/mob/living/silicon/pai/proc/fix_speech(mob/user)
	var/mob/living/silicon/pai/pai = src
	to_chat(pai, span_notice("Your owner has corrected your speech modulation!"))
	to_chat(user, span_notice("You fix the pAI's speech modulator."))
	for(var/effect in typesof(/datum/status_effect/speech))
		pai.remove_status_effect(effect)
	return TRUE

/**
 * Gets the current holder of the pAI if its
 * being carried in card or holoform.
 *
 * @return {living/carbon || FALSE} - The holder of the pAI,
 * 	or FALSE if the pAI is not being carried.
 */
/mob/living/silicon/pai/proc/get_holder()
	var/mob/living/carbon/holder
	if(!holoform && iscarbon(card.loc))
		holder = card.loc
	if(holoform && istype(loc, /obj/item/clothing/head/mob_holder) && iscarbon(loc.loc))
		holder = loc.loc
	if(!holder || !iscarbon(holder))
		return FALSE
	return holder

/**
 * Handles the pai card or the pai itself being hit with an emag.
 * This replaces any current laws, masters, and DNA.
 *
 * @param {living/carbon} attacker - The user performing the action.
 * @return {boolean} - TRUE if successful, FALSE if not.
 */
/mob/living/silicon/pai/proc/handle_emag(mob/living/carbon/attacker)
	var/mob/living/silicon/pai/pai = src
	if(!isliving(attacker))
		return FALSE
	to_chat(attacker, span_notice("You override [pai]'s directive system, clearing its master string and supplied directive."))
	to_chat(pai, span_boldannounce("Warning: System override detected, check directive sub-system for any changes."))
	log_game("[key_name(attacker)] emagged [key_name(pai)], wiping their master DNA and supplemental directive.")
	emagged = TRUE
	master_ref = WEAKREF(attacker)
	master_name = attacker.real_name
	master_dna = "Untraceable Signature"
	// Sets supplemental directive to this
	laws.supplied[1] = "Do not interfere with the operations of the Syndicate."
	return TRUE

/**
 * Creates a new pAI.
 *
 * @param {boolean} delete_old - If TRUE, deletes the old pAI.
 */
/mob/proc/make_pai(delete_old)
	var/obj/item/pai_card/card = new(src)
	var/mob/living/silicon/pai/pai = new(card)
	pai.key = key
	pai.name = name
	card.set_personality(pai)
	if(delete_old)
		qdel(src)

/**
 * Resets the pAI and any emagged status.
 *
 * @param {mob} user - The user performing the action.
 * @return {boolean} - TRUE if successful, FALSE if not.
 */
/mob/living/silicon/pai/proc/reset_software(mob/user)
	var/mob/living/silicon/pai/pai = src
	emagged = FALSE
	if(!master_ref)
		return FALSE
	master_ref = null
	master_name = null
	master_dna = null
	add_supplied_law(0, "None.")
	to_chat(user, span_notice("You reset the software on the pAI."))
	to_chat(pai, span_notice("Your software has been reset."))
	return TRUE

/**
 * Imprints your DNA onto the downloaded pAI
 *
 * @param {mob} user - The user performing the imprint.
 * @return {boolean} - TRUE if successful, FALSE if not.
 */
/mob/living/silicon/pai/proc/set_dna(mob/user)
	var/mob/living/silicon/pai/pai = src
	if(!iscarbon(user))
		to_chat(user, span_warning("You don't have any DNA, or your DNA is incompatible with this device!"))
		return FALSE
	var/mob/living/carbon/master = user
	master_ref = WEAKREF(master)
	master_name = master.real_name
	master_dna = master.dna.unique_enzymes
	to_chat(pai, span_notice("You have been bound to a new master: [user.real_name]!"))
	emitter_semi_cd = FALSE
	return TRUE

/**
 * Opens a tgui alert that allows someone to enter laws.
 *
 * @param {mob} user - The user performing the law change.
 * @return {boolean} - TRUE if successful, FALSE if not.
 */
/mob/living/silicon/pai/proc/set_laws(mob/user)
	var/mob/living/silicon/pai/pai = src
	if(!master_ref)
		to_chat(user, span_warning("The pAI is not bound to a master! It doesn't have to listen to anyone."))
		return FALSE
	var/new_laws = tgui_input_text(user, "Enter any additional directives you would like your pAI personality to follow. Note that these directives will not override the personality's allegiance to its imprinted master. Conflicting directives will be ignored.", "pAI Directive Configuration", laws.supplied[1], 300)
	if(!new_laws || !pai || !master_ref)
		return FALSE
	add_supplied_law(0, new_laws)
	to_chat(pai, span_notice("They are as follows:"))
	to_chat(pai, span_notice(new_laws))
	return TRUE

/**
 * Toggles the ability of the pai to enter holoform
 *
 * @param {mob} user - The user performing the toggle.
 * @return {boolean} - TRUE if successful, FALSE if not.
 */
/mob/living/silicon/pai/proc/toggle_holo(mob/user)
	var/mob/living/silicon/pai/pai = src
	to_chat(user, span_notice("You [can_holo ? "disabled" : "enabled"] your pAI's holomatrix."))
	to_chat(pai, span_warning("Your owner has [can_holo ? "disabled" : "enabled"] your holomatrix projectors!"))
	can_holo = !can_holo
	return TRUE

/**
 * Toggles the radio settings on and off.
 *
 * @param {mob} user - The user performing the radio change.
 * @param {string} option - The option being toggled.
 */
/mob/living/silicon/pai/proc/toggle_radio(mob/user, option)
	var/mob/living/silicon/pai/pai = src
	// it can't be both so if we know it's not transmitting it must be receiving.
	var/transmitting = option == "transmit"
	var/transmit_holder = (transmitting ? WIRE_TX : WIRE_RX)
	if(transmitting)
		can_transmit = !can_transmit
	else //receiving
		can_receive = !can_receive
	radio.wires.cut(transmit_holder)//wires.cut toggles cut and uncut states
	transmit_holder = (transmitting ? can_transmit : can_receive) //recycling can be fun!
	to_chat(user, span_notice("You [transmit_holder ? "enable" : "disable"] your pAI's [transmitting ? "outgoing" : "incoming"] radio transmissions!"))
	to_chat(pai, span_warning("Your owner has [transmit_holder ? "enabled" : "disabled"] your [transmitting ? "outgoing" : "incoming"] radio transmissions!"))
	return TRUE

/**
 * Wipes the current pAI on the card.
 *
 * @param {mob} user - The user performing the action.
 * @return {boolean} - TRUE if successful, FALSE if not.
 */
/mob/living/silicon/pai/proc/wipe_pai(mob/user)
	var/mob/living/silicon/pai/pai = src
	if(tgui_alert(user, "Are you certain you wish to delete the current personality? This action cannot be undone.", "Personality Wipe", list("Yes", "No")) != "Yes")
		return FALSE
	to_chat(pai, span_warning("You feel yourself slipping away from reality."))
	to_chat(pai, span_danger("Byte by byte you lose your sense of self."))
	to_chat(pai, span_userdanger("Your mental faculties leave you."))
	to_chat(pai, span_rose("oblivion... "))
	qdel(pai)
	return TRUE
