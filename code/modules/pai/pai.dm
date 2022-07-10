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
	desc = "A generic pAI mobile hard-light holographics emitter. It seems to be deactivated."
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

	/// The strength of the internal flashlight
	var/brightness_power = 5
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
	/// Modular pc interface button
	var/atom/movable/screen/ai/modpc/interfaceButton
	/// Toggles whether universal translator has been activated. Cannot be reversed
	var/languages_granted = FALSE
	/// Name of the one who commands us
	var/master
	/// DNA string for owner verification
	var/master_dna
	/// Toggles whether the Medical  HUD is active or not
	var/medHUD = FALSE
	/// Cached list for medical records to send as static data
	var/list/medical_records = list()
	/// Used as currency to purchase different abilities
	var/ram = 100
	/// Cached list for security records to send as static data
	var/list/security_records = list()

	/// Toggles whether the Security HUD is active or not
	var/secHUD = FALSE
	// Onboard Items
	/// Atmospheric analyzer
	var/obj/item/analyzer/atmos_analyzer
	/// Health analyzer
	var/obj/item/healthanalyzer/host_scan
	/// GPS
	var/obj/item/gps/pai/gps
	/// Music Synthesizer
	var/obj/item/instrument/piano_synth/instrument
	/// Newscaster
	var/obj/machinery/newscaster
	/// Remote signaler
	var/obj/item/assembly/signaler/internal/signaler
	// Static lists
	/// List of all available downloads
	var/static/list/available_software = list(
		"atmosphere sensor" = 5,
		"crew manifest" = 5,
		"digital messenger" = 5,
		"photography module" = 5,
		"camera zoom" = 10,
		"host scan" = 10,
		"medical records" = 10,
		"printer module" = 10,
		"remote signaler" = 10,
		"security records" = 10,
		"loudness booster" = 20,
		"medical HUD" = 20,
		"newscaster" = 20,
		"security HUD" = 20,
		"door jack" = 25,
		"encryption keys" = 25,
		"internal gps" = 35,
		"universal translator" = 35,
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

/obj/item/pai_card/attackby(obj/item/used, mob/user, params)
	if(pai && istype(used, /obj/item/encryptionkey))
		if(!pai.encrypt_mod)
			to_chat(user, span_alert("Encryption Key ports not configured."))
			return
		user.set_machine(src)
		pai.radio.attackby(used, user, params)
		to_chat(user, span_notice("You insert [used] into the [src]."))
		return
	return ..()

/mob/living/silicon/pai/can_interact_with(atom/A)
	if(A == signaler) // Bypass for signaler
		return TRUE
	if(A == modularInterface)
		return TRUE
	return ..()

// See software.dm for Topic()
/mob/living/silicon/pai/canUseTopic(atom/movable/M, be_close=FALSE, o_dexterity=FALSE, no_tk=FALSE, need_hands = FALSE, floor_okay=FALSE)
	// Resting is just an aesthetic feature for them.
	return ..(M, be_close, no_dexterity, no_tk, need_hands, TRUE)

/mob/living/silicon/pai/Destroy()
	QDEL_NULL(atmos_analyzer)
	QDEL_NULL(instrument)
	QDEL_NULL(hacking_cable)
	QDEL_NULL(newscaster)
	QDEL_NULL(signaler)
	QDEL_NULL(host_scan)
	QDEL_NULL(gps)
	if(!QDELETED(card) && loc != card)
		card.forceMove(drop_location())
		// these are otherwise handled by paicard/handle_atom_del()
		card.pai = null
		card.emotion_icon = initial(card.emotion_icon)
		card.update_appearance()
	GLOB.pai_list -= src
	return ..()

/obj/item/pai_card/emag_act(mob/user)
	if(!pai)
		return
	to_chat(user, span_notice("You override [pai]'s directive system, clearing its master string and supplied directive."))
	to_chat(pai, span_userdanger("Warning: System override detected, check directive sub-system for any changes."))
	log_game("[key_name(user)] emagged [key_name(pai)], wiping their master DNA and supplemental directive.")
	pai.emagged = TRUE
	pai.master = null
	pai.master_dna = null
	// Sets supplemental directive to this
	pai.laws.supplied[1] = "None."

/mob/living/silicon/pai/examine(mob/user)
	. = ..()
	. += "A personal AI in holochassis mode. Its master ID string seems to be [master]."

/mob/living/silicon/pai/get_status_tab_items()
	. += ..()
	if(!stat)
		. += text("Emitter Integrity: [emitter_health * (100 / emitter_max_health)]")
	else
		. += text("Systems nonfunctional")

/mob/living/silicon/pai/handle_atom_del(atom/deleting_atom)
	if(deleting_atom == hacking_cable)
		hacking_cable = null
		if(!QDELETED(card))
			card.update_appearance()
	if(deleting_atom == atmos_analyzer)
		atmos_analyzer = null
	if(deleting_atom == instrument)
		instrument = null
	if(deleting_atom == newscaster)
		newscaster = null
	if(deleting_atom == signaler)
		signaler = null
	if(deleting_atom == host_scan)
		host_scan = null
	if(deleting_atom == gps)
		gps = null
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
		pai_card = new /obj/item/pai_card(newcardloc)
		pai_card.set_personality(src)
	forceMove(pai_card)
	card = pai_card
	job = JOB_PERSONAL_AI
	atmos_analyzer = new /obj/item/analyzer(src)
	signaler = new /obj/item/assembly/signaler/internal(src)
	host_scan = new /obj/item/healthanalyzer(src)
	newscaster = new /obj/machinery/newscaster/pai(src)
	if(!aicamera)
		aicamera = new /obj/item/camera/siliconcam/ai_camera(src)
		aicamera.flash_enabled = TRUE
	. = ..()
	create_modularInterface()
	emitter_semi_cd = TRUE
	addtimer(CALLBACK(src, .proc/emitter_cool), 600)
	if(!holoform)
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, PAI_FOLDED)
		ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, PAI_FOLDED)
	return INITIALIZE_HINT_LATELOAD

/mob/living/silicon/pai/LateInitialize()
	. = ..()
	modularInterface.saved_identification = name

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

/obj/item/pai_card/screwdriver_act(mob/living/user, obj/item/tool)
	return pai.radio.screwdriver_act(user, tool)

/mob/living/silicon/pai/updatehealth()
	if(status_flags & GODMODE)
		return
	set_health(maxHealth - getBruteLoss() - getFireLoss())
	update_stat()

/**
 * Creates a new pAI.
 *
 * @param delete_old {boolean} If TRUE, deletes the old pAI if one exists.
 */
/mob/proc/make_pai(delete_old)
	var/obj/item/pai_card/card = new /obj/item/pai_card(get_turf(src))
	var/mob/living/silicon/pai/pai = new /mob/living/silicon/pai(card)
	pai.key = key
	pai.name = name
	card.set_personality(pai)
	if(delete_old)
		qdel(src)
