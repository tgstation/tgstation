#define AI_CORE_BRAIN(X) X.braintype == "Android" ? "brain" : "MMI"

/obj/structure/ai_core
	density = TRUE
	anchored = FALSE
	name = "\improper AI core"
	icon = 'icons/mob/silicon/ai.dmi'
	icon_state = "0"
	desc = "The framework for an artificial intelligence core."
	max_integrity = 500
	var/state = CORE_STATE_EMPTY
	var/datum/ai_laws/laws
	var/obj/item/circuitboard/aicore/circuit
	var/obj/item/mmi/core_mmi
	/// only used in cases of AIs piloting mechs or shunted malf AIs, possible later use cases
	var/mob/living/silicon/ai/remote_ai = null

/obj/structure/ai_core/Initialize(mapload)
	. = ..()
	laws = new
	laws.set_laws_config()

/obj/structure/ai_core/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == circuit)
		circuit = null
		if((state != CORE_STATE_GLASSED) && (state != CORE_STATE_FINISHED))
			state = CORE_STATE_EMPTY
			update_appearance()
	if(gone == core_mmi)
		core_mmi = null
		update_appearance()

/obj/structure/ai_core/atom_deconstruct(disassembled = TRUE)
	if(state >= CORE_STATE_GLASSED)
		new /obj/item/stack/sheet/rglass(loc, 2)
	if(state >= CORE_STATE_CABLED)
		new /obj/item/stack/cable_coil(loc, 5)
	if(circuit)
		circuit.forceMove(loc)
		circuit = null
	new /obj/item/stack/sheet/plasteel(loc, 4)

/obj/structure/ai_core/Destroy()
	if(istype(remote_ai))
		remote_ai = null
	QDEL_NULL(circuit)
	QDEL_NULL(core_mmi)
	QDEL_NULL(laws)
	return ..()

/obj/structure/ai_core/update_icon_state()
	switch(state)
		if(CORE_STATE_EMPTY)
			icon_state = "0"
		if(CORE_STATE_CIRCUIT)
			icon_state = "1"
		if(CORE_STATE_SCREWED)
			icon_state = "2"
		if(CORE_STATE_CABLED)
			if(core_mmi)
				icon_state = "3b"
			else
				icon_state = "3"
		if(CORE_STATE_GLASSED)
			icon_state = "4"
		if(CORE_STATE_FINISHED)
			icon_state = "ai-empty"
	return ..()

/obj/structure/ai_core/examine(mob/user)
	. = ..()
	if(!anchored)
		if(state != CORE_STATE_EMPTY)
			. += span_notice("It has some <b>bolts</b> that could be tightened.")
		else
			. += span_notice("It has some <b>bolts</b> that could be tightened. The frame can be <b>melted</b> down.")
	else
		switch(state)
			if(CORE_STATE_EMPTY)
				. += span_notice("There is a <b>slot</b> for a circuit board, its <b>bolts</b> can be loosened.")
			if(CORE_STATE_CIRCUIT)
				. += span_notice("The circuit board can be <b>screwed</b> into place or <b>pried</b> out.")
			if(CORE_STATE_SCREWED)
				. += span_notice("The frame can be <b>wired</b>, the circuit board can be <b>unfastened</b>.")
			if(CORE_STATE_CABLED)
				if(!core_mmi)
					. += span_notice("There are wires which could be hooked up to an <b>MMI or positronic brain</b>, or <b>cut</b>.")
				else
					var/accept_laws = TRUE
					if(core_mmi.laws.id != DEFAULT_AI_LAWID || !core_mmi.brainmob || !core_mmi.brainmob?.mind)
						accept_laws = FALSE
					. += span_notice("There is a <b>slot</b> for a reinforced glass panel, the [AI_CORE_BRAIN(core_mmi)] could be <b>pried</b> out.[accept_laws ? " A law module can be <b>swiped</b> across." : ""]")
			if(CORE_STATE_GLASSED)
				. += span_notice("The monitor [core_mmi?.brainmob?.mind && !suicide_check() ? "and neural interface " : ""]can be <b>screwed</b> in, the panel can be <b>pried</b> out.")
			if(CORE_STATE_FINISHED)
				. += span_notice("The monitor's connection can be <b>cut</b>[core_mmi?.brainmob?.mind && !suicide_check() ? " the neural interface can be <b>screwed</b> in." : "."]")


/obj/structure/ai_core/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()
	if(. > 0 && istype(remote_ai))
		to_chat(remote_ai, span_danger("Your core is under attack!"))

/obj/structure/ai_core/deactivated
	icon_state = "ai-empty"
	anchored = TRUE
	state = CORE_STATE_FINISHED
	var/mob/living/silicon/ai/attached_ai

/obj/structure/ai_core/deactivated/Initialize(mapload, skip_mmi_creation = FALSE, posibrain = FALSE, linked_ai)
	. = ..()
	circuit = new(src)
	if(linked_ai)
		attached_ai = linked_ai
	if(skip_mmi_creation)
		return
	if(posibrain)
		core_mmi = new/obj/item/mmi/posibrain(src, /* autoping = */ FALSE)
	else
		core_mmi = new(src)
		core_mmi.brain = new(core_mmi)
		core_mmi.update_appearance()

/obj/structure/ai_core/deactivated/Destroy()
	if(attached_ai)
		attached_ai.linked_core = null
		attached_ai = null
	. = ..()

/obj/structure/ai_core/deactivated/proc/disable_doomsday(datum/source)
	SIGNAL_HANDLER
	attached_ai.ShutOffDoomsdayDevice()

/obj/structure/ai_core/latejoin_inactive
	name = "networked AI core"
	desc = "This AI core is connected by bluespace transmitters to NTNet, allowing for an AI personality to be downloaded to it on the fly mid-shift."
	icon_state = "ai-empty"
	anchored = TRUE
	state = CORE_STATE_FINISHED
	var/available = TRUE
	var/safety_checks = TRUE
	var/active = TRUE

/obj/structure/ai_core/latejoin_inactive/Initialize(mapload)
	. = ..()
	circuit = new(src)
	core_mmi = new(src)
	core_mmi.brain = new(core_mmi)
	core_mmi.update_appearance()
	GLOB.latejoin_ai_cores += src

/obj/structure/ai_core/latejoin_inactive/Destroy()
	GLOB.latejoin_ai_cores -= src
	return ..()

/obj/structure/ai_core/latejoin_inactive/examine(mob/user)
	. = ..()
	. += "Its transmitter seems to be <b>[active? "on" : "off"]</b>."
	. += span_notice("You could [active? "deactivate" : "activate"] it with a multitool.")

/obj/structure/ai_core/latejoin_inactive/proc/is_available() //If people still manage to use this feature to spawn-kill AI latejoins ahelp them.
	if(!available)
		return FALSE
	if(!safety_checks)
		return TRUE
	if(!active)
		return FALSE
	var/turf/T = get_turf(src)
	var/area/A = get_area(src)
	if(!(A.area_flags & BLOBS_ALLOWED))
		return FALSE
	if(!A.power_equip)
		return FALSE
	if(!SSmapping.level_trait(T.z,ZTRAIT_STATION))
		return FALSE
	if(!isfloorturf(T))
		return FALSE
	return TRUE

/obj/structure/ai_core/latejoin_inactive/attackby(obj/item/tool, mob/user, list/modifiers, list/attack_modifiers)
	if(tool.tool_behaviour == TOOL_MULTITOOL)
		active = !active
		to_chat(user, span_notice("You [active? "activate" : "deactivate"] \the [src]'s transmitters."))
		return
	return ..()

/obj/structure/ai_core/proc/ai_structure_to_mob()
	var/mob/living/brain/the_brainmob = core_mmi.brainmob
	if(!the_brainmob.mind || suicide_check())
		return FALSE
	the_brainmob.mind.remove_antags_for_borging()
	if(!the_brainmob.mind.has_ever_been_ai)
		SSblackbox.record_feedback("amount", "ais_created", 1)
	var/mob/living/silicon/ai/ai_mob = null

	if(core_mmi.overrides_aicore_laws)
		ai_mob = new /mob/living/silicon/ai(loc, core_mmi.laws, the_brainmob)
		core_mmi.laws = null //MMI's law datum is being donated, so we need the MMI to let it go or the GC will eat it
	else
		ai_mob = new /mob/living/silicon/ai(loc, laws, the_brainmob)
		laws = null //we're giving the new AI this datum, so let's not delete it when we qdel(src) 5 lines from now

	var/datum/antagonist/malf_ai/malf_datum = IS_MALF_AI(ai_mob)
	if(malf_datum)
		malf_datum.add_law_zero()

	if(!isnull(the_brainmob.client))
		ai_mob.set_gender(the_brainmob.client)
	if(core_mmi.force_replace_ai_name)
		ai_mob.fully_replace_character_name(ai_mob.name, core_mmi.replacement_ai_name())
	ai_mob.posibrain_inside = core_mmi.braintype == "Android"
	deadchat_broadcast(" has been brought online at <b>[get_area_name(ai_mob, format_text = TRUE)]</b>.", span_name("[ai_mob]"), follow_target = ai_mob, message_type = DEADCHAT_ANNOUNCEMENT)
	qdel(src)
	return ai_mob

/// Quick proc to call to see if the brainmob inside of us has suicided. Returns TRUE if we have, FALSE in any other scenario.
/obj/structure/ai_core/proc/suicide_check()
	if(isnull(core_mmi) || isnull(core_mmi.brainmob))
		return FALSE
	return HAS_TRAIT(core_mmi.brainmob, TRAIT_SUICIDED)

/*
This is a good place for AI-related object verbs so I'm sticking it here.
If adding stuff to this, don't forget that an AI need to cancel_camera() whenever it physically moves to a different location.
That prevents a few funky behaviors.
*/
//The type of interaction, the player performing the operation, the AI itself, and the card object, if any.


/atom/proc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	SHOULD_CALL_PARENT(TRUE)
	if(istype(card))
		if(card.flush)
			to_chat(user, span_alert("ERROR: AI flush is in progress, cannot execute transfer protocol."))
			return FALSE
	return TRUE

/obj/structure/ai_core/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(state != CORE_STATE_FINISHED || !..())
		return
	if(core_mmi && core_mmi.brainmob)
		if(core_mmi.brainmob.mind)
			to_chat(user, span_warning("[src] already contains an active mind!"))
			return
		else if(suicide_check())
			to_chat(user, span_warning("[AI_CORE_BRAIN(core_mmi)] installed in [src] is completely useless!"))
			return
	//Transferring a carded AI to a core.
	if(interaction == AI_TRANS_FROM_CARD)
		AI.set_control_disabled(FALSE)
		AI.radio_enabled = TRUE
		AI.forceMove(loc) // to replace the terminal.
		to_chat(AI, span_notice("You have been uploaded to a stationary terminal. Remote device connection restored."))
		to_chat(user, "[span_boldnotice("Transfer successful")]: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
		card.AI = null
		AI.battery = circuit.battery
		AI.posibrain_inside = isnull(core_mmi) || core_mmi.braintype == "Android"
		qdel(src)
	else //If for some reason you use an empty card on an empty AI terminal.
		to_chat(user, span_alert("There is no AI loaded on this terminal."))

/obj/item/circuitboard/aicore
	name = "AI core (AI Core Board)" //Well, duh, but best to be consistent
	var/battery = 200 //backup battery for when the AI loses power. Copied to/from AI mobs when carding, and placed here to avoid recharge via deconning the core

/obj/item/circuitboard/aicore/Initialize(mapload)
	. = ..()
	if(mapload && HAS_TRAIT(SSstation, STATION_TRAIT_HUMAN_AI))
		return INITIALIZE_HINT_QDEL

#undef AI_CORE_BRAIN
