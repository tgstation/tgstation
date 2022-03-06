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

	/// The card we inhabit
	var/obj/item/paicard/card

	/// Used as currency to purchase different abilities
	var/ram = 100
	/// Installed software on the pAI
	var/list/software = list()
	/// The strength of the internal flashlight
	var/brightness_power = 5
	/// Changes the display to syndi if true
	var/emagged = FALSE

	/// Name of the one who commands us
	var/master
	/// DNA string for owner verification
	var/master_dna
	/// Whether we are currently holoformed
	var/holoform = FALSE
	/// Whether the pAI can enter holoform or not
	var/canholo = TRUE
	/// Whether this pAI can transmit radio messages
	var/can_transmit = TRUE
	/// Whether this pAI can recieve radio messages
	var/can_receive = TRUE


	// Various software-specific vars

	/// Toggles whether the Security HUD is active or not
	var/secHUD = FALSE
	/// Toggles whether the Medical  HUD is active or not
	var/medHUD = FALSE
	/// Toggles whether the pAI can hold encryption keys or not
	var/encryptmod = FALSE
	/// Toggles whether universal translator has been activated. Cannot be reversed
	var/languages_granted = FALSE
	/// Atmospheric analyzer
	var/obj/item/analyzer/atmos_analyzer
	/// AI's signaler
	var/obj/item/assembly/signaler/internal/signaler
	/// pAI Synthesizer
	var/obj/item/instrument/piano_synth/internal_instrument
	/// pAI Newscaster
	var/obj/machinery/newscaster
	/// pAI healthanalyzer
	var/obj/item/healthanalyzer/hostscan
	/// Internal pAI GPS, enabled if pAI downloads GPS software, and then uses it.
	var/obj/item/gps/pai/internal_gps
	/// The cable we produce when hacking a door
	var/obj/item/pai_cable/hacking_cable

	/// The current chasis that will appear when in holoform
	var/chassis = "repairbot"
	/// List of all possible chasises. TRUE means the pAI can be picked up in this chasis.
	var/list/possible_chassis = list(
		"cat" = TRUE,
		"mouse" = TRUE,
		"monkey" = TRUE,
		"corgi" = FALSE,
		"fox" = FALSE,
		"repairbot" = TRUE,
		"rabbit" = TRUE,
		"bat" = FALSE,
		"butterfly" = FALSE,
		"hawk" = FALSE,
		"lizard" = FALSE,
		"duffel" = TRUE,
	)

	var/emitterhealth = 20
	var/emittermaxhealth = 20
	var/emitter_regen_per_second = 1.25
	var/emittercd = 50
	var/emitteroverloadcd = 100
	var/emittersemicd = FALSE

	/// Bool that determines if the pAI can refresh medical/security records.
	var/refresh_spam = FALSE
	/// Cached list for medical records to send as static data
	var/list/medical_records = list()
	/// Cached list for security records to send as static data
	var/list/security_records = list()

	var/list/available_software = list(
		"crew manifest" = 5,
		"digital messenger" = 5,
		"atmosphere sensor" = 5,
		"photography module" = 5,
		"camera zoom" = 10,
		"printer module" = 10,
		"remote signaler" = 10,
		"medical records" = 10,
		"security records" = 10,
		"host scan" = 10,
		"medical HUD" = 20,
		"security HUD" = 20,
		"loudness booster" = 20,
		"newscaster" = 20,
		"door jack" = 25,
		"encryption keys" = 25,
		"internal gps" = 35,
		"universal translator" = 35,
	)

/mob/living/silicon/pai/add_sensors() //pAIs have to buy their HUDs
	return

/mob/living/silicon/pai/handle_atom_del(atom/deleting_atom)
	if(deleting_atom == hacking_cable)
		hacking_cable = null
		if(!QDELETED(card))
			card.update_appearance()
	if(deleting_atom == atmos_analyzer)
		atmos_analyzer = null
	if(deleting_atom == internal_instrument)
		internal_instrument = null
	if(deleting_atom == newscaster)
		newscaster = null
	if(deleting_atom == signaler)
		signaler = null
	if(deleting_atom == hostscan)
		hostscan = null
	if(deleting_atom == internal_gps)
		internal_gps = null
	return ..()

/mob/living/silicon/pai/Initialize(mapload)
	var/obj/item/paicard/pai_card = loc
	START_PROCESSING(SSfastprocess, src)
	GLOB.pai_list += src
	make_laws()
	for (var/law in laws.inherent)
		lawcheck += law
	if(!istype(pai_card)) //when manually spawning a pai, we create a card to put it into.
		var/newcardloc = pai_card
		pai_card = new /obj/item/paicard(newcardloc)
		pai_card.setPersonality(src)
	forceMove(pai_card)
	card = pai_card
	job = JOB_PERSONAL_AI
	atmos_analyzer = new /obj/item/analyzer(src)
	signaler = new /obj/item/assembly/signaler/internal(src)
	hostscan = new /obj/item/healthanalyzer(src)
	newscaster = new /obj/machinery/newscaster(src)
	if(!aicamera)
		aicamera = new /obj/item/camera/siliconcam/ai_camera(src)
		aicamera.flash_enabled = TRUE

	addtimer(CALLBACK(src, .proc/pdaconfig), 5)

	. = ..()

	emittersemicd = TRUE
	addtimer(CALLBACK(src, .proc/emittercool), 600)

	if(!holoform)
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, PAI_FOLDED)
		ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, PAI_FOLDED)

/mob/living/silicon/pai/Destroy()
	QDEL_NULL(atmos_analyzer)
	QDEL_NULL(internal_instrument)
	QDEL_NULL(hacking_cable)
	QDEL_NULL(newscaster)
	QDEL_NULL(signaler)
	QDEL_NULL(hostscan)
	QDEL_NULL(internal_gps)
	if(!QDELETED(card) && loc != card)
		card.forceMove(drop_location())
		card.pai = null //these are otherwise handled by paicard/handle_atom_del()
		card.emotion_icon = initial(card.emotion_icon)
		card.update_appearance()
	GLOB.pai_list -= src
	return ..()

/mob/living/silicon/pai/proc/pdaconfig()
	//PDA
	aiPDA = new /obj/item/pda/ai(src)
	aiPDA.owner = real_name
	aiPDA.ownjob = "pAI Messenger"
	aiPDA.name = "[real_name] ([aiPDA.ownjob])"

/mob/living/silicon/pai/make_laws()
	laws = new /datum/ai_laws/pai()
	return TRUE

/mob/living/silicon/pai/get_status_tab_items()
	. += ..()
	if(!stat)
		. += text("Emitter Integrity: [emitterhealth * (100 / emittermaxhealth)]")
	else
		. += text("Systems nonfunctional")


// See software.dm for Topic()

/mob/living/silicon/pai/canUseTopic(atom/movable/M, be_close=FALSE, no_dexterity=FALSE, no_tk=FALSE, need_hands = FALSE, floor_okay=FALSE)
	return ..(M, be_close, no_dexterity, no_tk, need_hands, TRUE) //Resting is just an aesthetic feature for them.

/mob/proc/makePAI(delold)
	var/obj/item/paicard/card = new /obj/item/paicard(get_turf(src))
	var/mob/living/silicon/pai/pai = new /mob/living/silicon/pai(card)
	pai.key = key
	pai.name = name
	card.setPersonality(pai)
	if(delold)
		qdel(src)

/mob/living/silicon/pai/Process_Spacemove(movement_dir = 0)
	. = ..()
	if(!.)
		add_movespeed_modifier(/datum/movespeed_modifier/pai_spacewalk)
		return TRUE
	remove_movespeed_modifier(/datum/movespeed_modifier/pai_spacewalk)
	return TRUE

/mob/living/silicon/pai/examine(mob/user)
	. = ..()
	. += "A personal AI in holochassis mode. Its master ID string seems to be [master]."

/mob/living/silicon/pai/updatehealth()
	if(status_flags & GODMODE)
		return
	set_health(maxHealth - getBruteLoss() - getFireLoss())
	update_stat()

/mob/living/silicon/pai/process(delta_time)
	emitterhealth = clamp((emitterhealth + (emitter_regen_per_second * delta_time)), -50, emittermaxhealth)

/mob/living/silicon/pai/can_interact_with(atom/A)
	if(A == signaler) // Bypass for signaler
		return TRUE

	return ..()

/obj/item/paicard/screwdriver_act(mob/living/user, obj/item/tool)
	return pai.radio.screwdriver_act(user, tool)

/obj/item/paicard/attackby(obj/item/used, mob/user, params)
	if(pai && istype(used, /obj/item/encryptionkey))
		if(!pai.encryptmod)
			to_chat(user, span_alert("Encryption Key ports not configured."))
			return
		user.set_machine(src)
		pai.radio.attackby(used, user, params)
		to_chat(user, span_notice("You insert [used] into the [src]."))
		return

	return ..()

/obj/item/paicard/emag_act(mob/user) // Emag to wipe the master DNA and supplemental directive
	if(!pai)
		return
	to_chat(user, span_notice("You override [pai]'s directive system, clearing its master string and supplied directive."))
	to_chat(pai, span_userdanger("Warning: System override detected, check directive sub-system for any changes."))
	log_game("[key_name(user)] emagged [key_name(pai)], wiping their master DNA and supplemental directive.")
	pai.emagged = TRUE
	pai.master = null
	pai.master_dna = null
	pai.laws.supplied[1] = "None." // Sets supplemental directive to this
