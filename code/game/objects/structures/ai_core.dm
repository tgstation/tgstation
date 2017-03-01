/obj/structure/AIcore
	density = 1
	anchored = TRUE
	name = "\improper AI core"
	icon = 'icons/mob/AI.dmi'
	icon_state = "ai_ready"
	obj_integrity = 500
	max_integrity = 500
	var/datum/ai_laws/laws = new()
	var/obj/item/device/mmi/brain

/obj/structure/AIcore/New()
	..()
	laws.set_laws_config()

/obj/structure/AIcore/Destroy()
	if(circuit)
		qdel(circuit)
		circuit = null
	if(brain)
		qdel(brain)
		brain = null
	return ..()

/obj/structure/AIcore/InitConstruction()
	new /datum/construction_state/first(src, /obj/item/stack/sheet/plasteel, 4)
	new /datum/construction_state(src,
		required_type_to_construct = /obj/item/weapon/wrench,
		required_type_to_deconstruct = /obj/item/weapon/weldingtool,
		construction_delay = 20,\
		deconstruction_delay = 20,\
		construction_message = "securing",\
		deconstruction_message = "slicing apart"\
		examine_message = "Its floor bolts are up.",\
		icon_state = "0",\
		anchored = FALSE,\
	)
	new /datum/construction_state(src,
		required_type_to_construct = /obj/item/weapon/circuitboard/aicore,
		required_type_to_deconstruct = /obj/item/weapon/wrench,
		required_amount_to_construct = 1
		deconstruction_delay = 20,\
		construction_message = "add the circuit to",\
		deconstruction_message = "slicing apart"\
		examine_message = "It's missing a circuit.",\
		icon_state = "0",\
		anchored = TRUE,\
	)
	new /datum/construction_state(src,
		required_type_to_construct = /obj/item/weapon/screwdriver,
		required_type_to_deconstruct = /obj/item/weapon/crowbar,
		construction_message = "screw the circuit board into",\
		deconstruction_message = "remove the circuit from"\
		examine_message = "The circuit is unscrewed.",\
		icon_state = "1",\
	)
	new /datum/construction_state(src,
		required_type_to_construct = /obj/item/stack/cable_coil,
		required_amount_to_construct = 5,
		required_type_to_deconstruct = /obj/item/weapon/screwdriver,
		construction_message = "adding cables to",\
		deconstruction_message = "remove the circuit from",\
		construction_delay = 20,\
		examine_message = "It is unwired.",\
		icon_state = "2",\
	)
	new /datum/construction_state(src,
		required_type_to_construct = /obj/item/stack/sheet/rglass,
		required_amount_to_construct = 2,
		required_type_to_deconstruct = /obj/item/weapon/wirecutters,
		construction_message = "putting the glass panel in",\
		deconstruction_message = "remove the cables from",\
		construction_delay = 20,\
		examine_message = "It is missing a monitor.",\
		icon_state = "3",\
	)
	new /datum/construction_state(src,
		required_type_to_construct = /obj/item/stack/sheet/screwdriver,
		required_type_to_deconstruct = /obj/item/weapon/crowbar,
		construction_message = "connect the monitor to",\
		deconstruction_message = "remove the panel from",\
		construction_delay = 20,\
		examine_message = "The monitor is not screwed in.",\
		icon_state = "4",\
	)
	new /datum/construction_state/last(src,
		required_type_to_deconstruct = /obj/item/stack/sheet/screwdriver,
		deconstruction_message = "disconnect the monitor from",\
		icon_state = "ai_ready",\
	)

/obj/structure/AIcore/ConstructionChecks(state_started_id, constructing, obj/item/I, mob/user, skip)
	. = ..()
	if(!. || skip)
		return
	if(state_started_id == CABLED_CORE && !constructing && brain)
		user << "<span class='warning'>Get that [brain.name] out of there first!</span>"
		return FALSE

/obj/structure/AIcore/OnConstruction(state_id, mob/user)
	..()
	if(state_id != AI_READY_CORE || !brain)
		return
	ticker.mode.remove_antag_for_borging(brain.brainmob.mind)
	if(!istype(brain.laws, /datum/ai_laws/ratvar))
		remove_servant_of_ratvar(brain.brainmob, TRUE)
	var/mob/living/silicon/ai/A = new /mob/living/silicon/ai(loc, laws, brain.brainmob)
	if(brain.force_replace_ai_name)
		A.fully_replace_character_name(A.name, brain.replacement_ai_name())
	feedback_inc("cyborg_ais_created",1)
	qdel(src)

/obj/structure/AIcore/OnDeconstruction(state_id, mob/user, forced)
	..()
	update_icon()

/obj/structure/AIcore/update_icon()
	if(current_construction_state.id == CABLED_CORE)
		icon_state = "3[brain ? "b" : ""]"

/obj/structure/AIcore/examine(mob/user)
	..()
	if(current_construction_state.id == CABLED_CORE && brain)
		user << "There is a brain inside."

/obj/structure/AIcore/attackby(obj/item/P, mob/user, params)
	if(current_construction_state.id == CABLED_CORE)
		if(istype(P, /obj/item/weapon/aiModule))
			if(brain && brain.laws.id != DEFAULT_AI_LAWID)
				user << "<span class='warning'>The installed [brain.name] already has set laws!</span>"
				return
			var/obj/item/weapon/aiModule/module = P
			module.install(laws, user)
			return

		if(istype(P, /obj/item/device/mmi) && !brain)
			var/obj/item/device/mmi/M = P
			if(!M.brainmob)
				user << "<span class='warning'>Sticking an empty [M.name] into the frame would sort of defeat the purpose!</span>"
				return
			if(M.brainmob.stat == DEAD)
				user << "<span class='warning'>Sticking a dead [M.name] into the frame would sort of defeat the purpose!</span>"
				return

			if(!M.brainmob.client)
				user << "<span class='warning'>Sticking an inactive [M.name] into the frame would sort of defeat the purpose.</span>"
				return

			if((config) && (!config.allow_ai) || jobban_isbanned(M.brainmob, "AI"))
				user << "<span class='warning'>This [M.name] does not seem to fit!</span>"
				return

			if(!M.brainmob.mind)
				user << "<span class='warning'>This [M.name] is mindless!</span>"
				return

			if(!user.drop_item())
				return

			M.forceMove(src)
			brain = M
			user << "<span class='notice'>You add [M.name] to the frame.</span>"
			update_icon()
			return

		if(istype(P, /obj/item/weapon/crowbar) && brain)
			playsound(loc, P.usesound, 50, 1)
			user << "<span class='notice'>You remove the brain.</span>"
			brain.forceMove(loc)
			brain = null
			update_icon()
			return
	

	else if(current_construction_state.id == AI_READY_CORE && istype(P, /obj/item/device/aicard))
		P.transfer_ai("INACTIVE", "AICARD", src, user)
		return

	return ..()

/obj/structure/AIcore/deconstruct(disassembled = TRUE)
	if(state == GLASS_CORE)
		new /obj/item/stack/sheet/rglass(loc, 2)
	if(state >= CABLED_CORE)
		new /obj/item/stack/cable_coil(loc, 5)
	if(circuit)
		circuit.forceMove(loc)
		circuit = null
	new /obj/item/stack/sheet/plasteel(loc, 4)
	qdel(src)

/*
This is a good place for AI-related object verbs so I'm sticking it here.
If adding stuff to this, don't forget that an AI need to cancel_camera() whenever it physically moves to a different location.
That prevents a few funky behaviors.
*/
//The type of interaction, the player performing the operation, the AI itself, and the card object, if any.


/atom/proc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/device/aicard/card)
	if(istype(card))
		if(card.flush)
			user << "<span class='boldannounce'>ERROR</span>: AI flush is in progress, cannot execute transfer protocol."
			return 0
	return 1


/obj/structure/AIcore/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/device/aicard/card)
	if(state != AI_READY_CORE || !..())
		return
 //Transferring a carded AI to a core.
	if(interaction == AI_TRANS_FROM_CARD)
		AI.control_disabled = 0
		AI.radio_enabled = 1
		AI.forceMove(loc) // to replace the terminal.
		AI << "You have been uploaded to a stationary terminal. Remote device connection restored."
		user << "<span class='boldnotice'>Transfer successful</span>: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed."
		card.AI = null
		qdel(src)
	else //If for some reason you use an empty card on an empty AI terminal.
		user << "There is no AI loaded on this terminal!"


/obj/item/weapon/circuitboard/aicore
	name = "AI core (AI Core Board)" //Well, duh, but best to be consistent
	origin_tech = "programming=3"
