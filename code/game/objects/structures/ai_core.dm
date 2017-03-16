/obj/structure/AIcore
	density = 1
	anchored = TRUE
	name = "\improper AI core"
	icon = 'icons/mob/AI.dmi'
	icon_state = "ai-empty"
	obj_integrity = 500
	max_integrity = 500
	var/datum/ai_laws/laws = new()
	var/obj/item/device/mmi/brain

/obj/structure/AIcore/New()
	..()
	laws.set_laws_config()

/obj/structure/AIcore/Destroy()
	if(brain)
		qdel(brain)
		brain = null
	return ..()

CONSTRUCTION_BLUEPRINT(/obj/structure/AIcore, TRUE, TRUE)
	. = newlist(
		/datum/construction_state/first{
		//	required_type_to_construct = /obj/item/stack/sheet/plasteel
			required_amount_to_construct = 4
			construction_delay = 50
			one_per_turf = 1
			on_floor = 1
		},
		/datum/construction_state{
			required_type_to_construct = /obj/item/weapon/wrench
			required_type_to_deconstruct = /obj/item/weapon/weldingtool
			construction_delay = 20
			deconstruction_delay = 20
			construction_message = "securing"
			deconstruction_message = "slicing apart"
			examine_message = "It is welded together and the floor bolts are up."
			icon_state = "0"
			anchored = 0
		},
		/datum/construction_state{
			required_type_to_construct = /obj/item/weapon/circuitboard/aicore
			required_type_to_deconstruct = /obj/item/weapon/wrench
			required_amount_to_construct = 1
			deconstruction_delay = 20
			construction_message = "add the circuit to"
			deconstruction_message = "unsecuring"
			examine_message = "The floor bolts are down and it's missing a circuit."
			icon_state = "0"
			anchored = 1
		},
		/datum/construction_state{
			required_type_to_construct = /obj/item/weapon/screwdriver
			required_type_to_deconstruct = /obj/item/weapon/crowbar
			construction_message = "screw the circuit board into"
			deconstruction_message = "remove the circuit from"
			examine_message = "The circuit is unscrewed."
			icon_state = "1"
		},
		/datum/construction_state{
			required_type_to_construct = /obj/item/stack/cable_coil
			required_amount_to_construct = 5
			required_type_to_deconstruct = /obj/item/weapon/screwdriver
			construction_message = "adding cables to"
			deconstruction_message = "unscrew the circuit from"
			construction_delay = 20
			examine_message = "The circuit is screwed in and it is unwired"
			icon_state = "2"
		},
		/datum/construction_state{
			required_type_to_construct = /obj/item/stack/sheet/rglass
			required_amount_to_construct = 2
			required_type_to_deconstruct = /obj/item/weapon/wirecutters
			construction_message = "putting the monitor in"
			deconstruction_message = "remove the cables from"
			construction_delay = 20
			examine_message = "It is wired up and missing a monitor."
			icon_state = "3"
		},
		/datum/construction_state{
			required_type_to_construct = /obj/item/weapon/screwdriver
			required_type_to_deconstruct = /obj/item/weapon/crowbar
			construction_message = "connect the monitor to"
			deconstruction_message = "remove the monitor from"
			construction_delay = 20
			examine_message = "The monitor is not screwed in."
			icon_state = "4"
		},
		/datum/construction_state/last{
			required_type_to_deconstruct = /obj/item/weapon/screwdriver
			deconstruction_message = "disconnect the monitor from"
		}
	)
	
	//This is here to work around a byond bug
	//http://www.byond.com/forum/?post=2220240
	//When its fixed clean up this copypasta across the codebase OBJ_CONS_BAD_CONST

	var/datum/construction_state/first/X = .[1]
	X.required_type_to_construct = /obj/item/stack/sheet/plasteel

/obj/structure/AIcore/ConstructionChecks(state_started_id, constructing, obj/item/I, mob/user, skip)
	. = ..()
	if(!. || skip)
		return
	if(state_started_id == CABLED_CORE && !constructing && brain)
		to_chat(user, "<span class='warning'>Get that [brain.name] out of there first!</span>")
		return FALSE

/obj/structure/AIcore/OnConstruction(state_id, mob/user, obj/item/used)
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

/obj/structure/AIcore/OnDeconstruction(state_id, mob/user, obj/item/created, forced)
	..()
	update_icon()

/obj/structure/AIcore/update_icon()
	if(current_construction_state.id == CABLED_CORE)
		icon_state = "3[brain ? "b" : ""]"

/obj/structure/AIcore/examine(mob/user)
	..()
	if(current_construction_state.id == CABLED_CORE && brain)
		to_chat(user, "There is a brain inside.")

/obj/structure/AIcore/attackby(obj/item/P, mob/user, params)
	if(current_construction_state.id == CABLED_CORE)
		if(istype(P, /obj/item/weapon/aiModule))
			if(brain && brain.laws.id != DEFAULT_AI_LAWID)
				to_chat(user, "<span class='warning'>The installed [brain.name] already has set laws!</span>")
				return
			var/obj/item/weapon/aiModule/module = P
			module.install(laws, user)
			return

		if(istype(P, /obj/item/device/mmi) && !brain)
			var/obj/item/device/mmi/M = P
			if(!M.brainmob)
				to_chat(user, "<span class='warning'>Sticking an empty [M.name] into the frame would sort of defeat the purpose!</span>")
				return
			if(M.brainmob.stat == DEAD)
				to_chat(user, "<span class='warning'>Sticking a dead [M.name] into the frame would sort of defeat the purpose!</span>")
				return

			if(!M.brainmob.client)
				to_chat(user, "<span class='warning'>Sticking an inactive [M.name] into the frame would sort of defeat the purpose.</span>")
				return

			if((config) && (!config.allow_ai) || jobban_isbanned(M.brainmob, "AI"))
				to_chat(user, "<span class='warning'>This [M.name] does not seem to fit!</span>")
				return

			if(!M.brainmob.mind)
				to_chat(user, "<span class='warning'>This [M.name] is mindless!</span>")
				return

			if(!user.drop_item())
				return

			M.forceMove(src)
			brain = M
			to_chat(user, "<span class='notice'>You add [M.name] to the frame.</span>")
			update_icon()
			return

		if(istype(P, /obj/item/weapon/crowbar) && brain)
			playsound(loc, P.usesound, 50, 1)
			to_chat(user, "<span class='notice'>You remove the brain.</span>")
			brain.forceMove(loc)
			brain = null
			update_icon()
			return
	

	else if(current_construction_state.id == AI_READY_CORE && istype(P, /obj/item/device/aicard))
		P.transfer_ai("INACTIVE", "AICARD", src, user)
		return

	return ..()

/*
This is a good place for AI-related object verbs so I'm sticking it here.
If adding stuff to this, don't forget that an AI need to cancel_camera() whenever it physically moves to a different location.
That prevents a few funky behaviors.
*/
//The type of interaction, the player performing the operation, the AI itself, and the card object, if any.


/atom/proc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/device/aicard/card)
	if(istype(card))
		if(card.flush)
			to_chat(user, "<span class='boldannounce'>ERROR</span>: AI flush is in progress, cannot execute transfer protocol.")
			return 0
	return 1


/obj/structure/AIcore/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/device/aicard/card)
	if(current_construction_state.id != AI_READY_CORE || !..())
		return
 //Transferring a carded AI to a core.
	if(interaction == AI_TRANS_FROM_CARD)
		AI.control_disabled = 0
		AI.radio_enabled = 1
		AI.forceMove(loc) // to replace the terminal.
		to_chat(AI, "You have been uploaded to a stationary terminal. Remote device connection restored.")
		to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
		card.AI = null
		qdel(src)
	else //If for some reason you use an empty card on an empty AI terminal.
		to_chat(user, "There is no AI loaded on this terminal!")


/obj/item/weapon/circuitboard/aicore
	name = "AI core (AI Core Board)" //Well, duh, but best to be consistent
	origin_tech = "programming=3"
