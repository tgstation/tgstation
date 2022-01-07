/mob/living/silicon/pai
	name = "pAI"
	icon = 'icons/mob/pai.dmi'
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
	held_lh = 'icons/mob/pai_item_lh.dmi'
	held_rh = 'icons/mob/pai_item_rh.dmi'
	head_icon = 'icons/mob/pai_item_head.dmi'
	radio = /obj/item/radio/headset/silicon/pai
	can_buckle_to = FALSE
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	var/network = "ss13"
	var/obj/machinery/camera/current = null
	/// Used as currency to purchase different abilities
	var/ram = 100
	/// Installed software on the pAI
	var/list/software = list()
	/// current user's DNA
	var/userDNA
	/// The card we inhabit
	var/obj/item/paicard/card
	/// Are we hacking a door?
	var/hacking = FALSE
	/// The progress for hacking
	var/datum/progressbar/hackbar
	/// Changes the display to syndi if true
	var/emagged = FALSE

	var/speakStatement = "states"
	var/speakExclamation = "declares"
	var/speakDoubleExclamation = "alarms"
	var/speakQuery = "queries"
	/// The cable we produce when hacking a door
	var/obj/item/pai_cable/hacking_cable
	/// Name of the one who commands us
	var/master
	/// DNA string for owner verification
	var/master_dna

// Various software-specific vars

	/// Toggles whether the Security HUD is active or not
	var/secHUD = FALSE
	/// Toggles whether the Medical  HUD is active or not
	var/medHUD = FALSE
	/// Toggles whether universal translator has been activated. Cannot be reversed
	var/languages_granted = FALSE
	/// The airlock being hacked
	var/obj/machinery/door/hackdoor
	/// Possible values: 0 - 100, >= 100 means the hack is complete and will be reset upon next check
	var/hackprogress = 0

	// Software
	/// Atmospheric analyzer
	var/obj/item/analyzer/atmos_analyzer
	/// AI's signaler
	var/obj/item/assembly/signaler/internal/signaler
	/// Synthesizer
	var/obj/item/instrument/piano_synth/internal_instrument
	/// pAI Newscaster
	var/obj/machinery/newscaster
	/// pAI healthanalyzer
	var/obj/item/healthanalyzer/hostscan
	/// Internal pAI GPS, enabled if pAI downloads GPS software, and then uses it.
	var/obj/item/gps/pai/internal_gps = null

	var/encryptmod = FALSE
	var/holoform = FALSE
	var/canholo = TRUE
	var/can_transmit = TRUE
	var/can_receive = TRUE
	var/chassis = "repairbot"
	var/list/possible_chassis = list("cat" = TRUE, "mouse" = TRUE, "monkey" = TRUE, "corgi" = FALSE, "fox" = FALSE, "repairbot" = TRUE, "rabbit" = TRUE, "bat" = FALSE, "butterfly" = FALSE, "hawk" = FALSE, "lizard" = FALSE, "duffel" = TRUE) //assoc value is whether it can be picked up.

	var/emitterhealth = 20
	var/emittermaxhealth = 20
	var/emitter_regen_per_second = 1.25
	var/emittercd = 50
	var/emitteroverloadcd = 100
	var/emittersemicd = FALSE

	var/overload_ventcrawl = 0
	var/overload_bulletblock = 0 //Why is this a good idea?
	var/overload_maxhealth = 0
	var/silent = FALSE
	var/brightness_power = 5

/mob/living/silicon/pai/add_sensors() //pAIs have to buy their HUDs
	return

/mob/living/silicon/pai/handle_atom_del(atom/A)
	if(A == hacking_cable)
		hacking_cable = null
		if(!QDELETED(card))
			card.update_appearance()
	if(A == atmos_analyzer)
		atmos_analyzer = null
	if(A == internal_instrument)
		internal_instrument = null
	if(A == newscaster)
		newscaster = null
	if(A == signaler)
		signaler = null
	if(A == hostscan)
		hostscan = null
	if(A == internal_gps)
		internal_gps = null
	return ..()

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

/mob/living/silicon/pai/Initialize(mapload)
	var/obj/item/paicard/P = loc
	START_PROCESSING(SSfastprocess, src)
	GLOB.pai_list += src
	make_laws()
	if(!istype(P)) //when manually spawning a pai, we create a card to put it into.
		var/newcardloc = P
		P = new /obj/item/paicard(newcardloc)
		P.setPersonality(src)
	forceMove(P)
	card = P
	job = "Personal AI"
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


/mob/living/silicon/pai/proc/pdaconfig()
	//PDA
	aiPDA = new/obj/item/pda/ai(src)
	aiPDA.owner = real_name
	aiPDA.ownjob = "pAI Messenger"
	aiPDA.name = real_name + " (" + aiPDA.ownjob + ")"

/mob/living/silicon/pai/proc/process_hack(delta_time, times_fired)
	if(hacking_cable?.machine && istype(hacking_cable.machine, /obj/machinery/door) && hacking_cable.machine == hackdoor && get_dist(src, hackdoor) <= 1)
		hackprogress = clamp(hackprogress + (2 * delta_time), 0, HACK_COMPLETE)
		hackbar.update(hackprogress)
	else
		to_chat(src, span_notice("Door Jack: Connection to airlock has been lost. Hack aborted."))
		hackprogress = 0
		hacking = FALSE
		hackdoor = null
		hackbar.end_progress()
		QDEL_NULL(hackbar)
		QDEL_NULL(hacking_cable)
		if(!QDELETED(card))
			card.update_appearance()
		return
	if(hackprogress >= HACK_COMPLETE)
		hackprogress = 0
		hacking = FALSE
		hackbar.end_progress()
		var/obj/machinery/door/door = hacking_cable.machine
		door.open()
		QDEL_NULL(hackbar)
		QDEL_NULL(hacking_cable)

/mob/living/silicon/pai/make_laws()
	laws = new /datum/ai_laws/pai()
	return TRUE

/mob/living/silicon/pai/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	client.perspective = EYE_PERSPECTIVE
	if(holoform)
		client.eye = src
	else
		client.eye = card

/mob/living/silicon/pai/get_status_tab_items()
	. += ..()
	if(!stat)
		. += text("Emitter Integrity: [emitterhealth * (100/emittermaxhealth)]")
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

/datum/action/innate/pai
	name = "PAI Action"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	var/mob/living/silicon/pai/P

/datum/action/innate/pai/Trigger()
	if(!ispAI(owner))
		return 0
	P = owner

/datum/action/innate/pai/software
	name = "Software Interface"
	button_icon_state = "pai"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/software/Trigger()
	..()
	P.ui_act()

/datum/action/innate/pai/shell
	name = "Toggle Holoform"
	button_icon_state = "pai_holoform"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/shell/Trigger()
	..()
	if(P.holoform)
		P.fold_in(0)
	else
		P.fold_out()

/datum/action/innate/pai/chassis
	name = "Holochassis Appearance Composite"
	button_icon_state = "pai_chassis"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/chassis/Trigger()
	..()
	P.choose_chassis()

/datum/action/innate/pai/rest
	name = "Rest"
	button_icon_state = "pai_rest"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/rest/Trigger()
	..()
	P.toggle_resting()

/datum/action/innate/pai/light
	name = "Toggle Integrated Lights"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "emp"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/light/Trigger()
	..()
	P.toggle_integrated_light()

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

/mob/living/silicon/pai/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(QDELETED(src) || stat == DEAD)
		return
	if(hacking_cable)
		if(get_dist(src, hacking_cable) > 1)
			var/turf/T = get_turf(src)
			T.visible_message(span_warning("[hacking_cable] rapidly retracts back into its spool."), span_hear("You hear a click and the sound of wire spooling rapidly."))
			QDEL_NULL(hacking_cable)
			if(!QDELETED(card))
				card.update_appearance()
		else if(hacking)
			process_hack(delta_time, times_fired)
	silent = max(silent - (0.5 * delta_time), 0)

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

/obj/item/paicard/attackby(obj/item/used, mob/user, params)
	if(pai && (istype(used, /obj/item/encryptionkey) || used.tool_behaviour == TOOL_SCREWDRIVER))
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
