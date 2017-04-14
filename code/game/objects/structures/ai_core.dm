/obj/structure/AIcore
	density = 1
	anchored = 0
	name = "\improper AI core"
	icon = 'icons/mob/AI.dmi'
	icon_state = "0"
	obj_integrity = 500
	max_integrity = 500
	var/state = 0
	var/datum/ai_laws/laws = new()
	var/obj/item/weapon/circuitboard/circuit = null
	var/obj/item/device/mmi/brain = null

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

/obj/structure/AIcore/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/weapon/wrench))
		return default_unfasten_wrench(user, P, 20)
	if(!anchored)
		if(istype(P, /obj/item/weapon/weldingtool))
			if(state != EMPTY_CORE)
				to_chat(user, "<span class='warning'>The core must be empty to deconstruct it!</span>")
				return
			var/obj/item/weapon/weldingtool/WT = P
			if(!WT.isOn())
				to_chat(user, "<span class='warning'>The welder must be on for this task!</span>")
				return
			playsound(loc, WT.usesound, 50, 1)
			to_chat(user, "<span class='notice'>You start to deconstruct the frame...</span>")
			if(do_after(user, 20*P.toolspeed, target = src) && src && state == EMPTY_CORE && WT && WT.remove_fuel(0, user))
				to_chat(user, "<span class='notice'>You deconstruct the frame.</span>")
				deconstruct(TRUE)
			return
	else
		switch(state)
			if(EMPTY_CORE)
				if(istype(P, /obj/item/weapon/circuitboard/aicore))
					if(!user.drop_item())
						return
					playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You place the circuit board inside the frame.</span>")
					update_icon()
					state = CIRCUIT_CORE
					circuit = P
					P.forceMove(src)
					return
			if(CIRCUIT_CORE)
				if(istype(P, /obj/item/weapon/screwdriver))
					playsound(loc, P.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You screw the circuit board into place.</span>")
					state = SCREWED_CORE
					update_icon()
					return
				if(istype(P, /obj/item/weapon/crowbar))
					playsound(loc, P.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
					state = EMPTY_CORE
					update_icon()
					circuit.forceMove(loc)
					circuit = null
					return
			if(SCREWED_CORE)
				if(istype(P, /obj/item/weapon/screwdriver) && circuit)
					playsound(loc, P.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You unfasten the circuit board.</span>")
					state = CIRCUIT_CORE
					update_icon()
					return
				if(istype(P, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/C = P
					if(C.get_amount() >= 5)
						playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
						to_chat(user, "<span class='notice'>You start to add cables to the frame...</span>")
						if(do_after(user, 20, target = src) && state == SCREWED_CORE && C.use(5))
							to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
							state = CABLED_CORE
							update_icon()
					else
						to_chat(user, "<span class='warning'>You need five lengths of cable to wire the AI core!</span>")
					return
			if(CABLED_CORE)
				if(istype(P, /obj/item/weapon/wirecutters))
					if(brain)
						to_chat(user, "<span class='warning'>Get that [brain.name] out of there first!</span>")
					else
						playsound(loc, P.usesound, 50, 1)
						to_chat(user, "<span class='notice'>You remove the cables.</span>")
						state = SCREWED_CORE
						update_icon()
						var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( loc )
						A.amount = 5
					return

				if(istype(P, /obj/item/stack/sheet/rglass))
					var/obj/item/stack/sheet/rglass/G = P
					if(G.get_amount() >= 2)
						playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
						to_chat(user, "<span class='notice'>You start to put in the glass panel...</span>")
						if(do_after(user, 20, target = src) && state == CABLED_CORE && G.use(2))
							to_chat(user, "<span class='notice'>You put in the glass panel.</span>")
							state = GLASS_CORE
							update_icon()
					else
						to_chat(user, "<span class='warning'>You need two sheets of reinforced glass to insert them into the AI core!</span>")
					return

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

			if(GLASS_CORE)
				if(istype(P, /obj/item/weapon/crowbar))
					playsound(loc, P.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You remove the glass panel.</span>")
					state = CABLED_CORE
					update_icon()
					new /obj/item/stack/sheet/rglass(loc, 2)
					return

				if(istype(P, /obj/item/weapon/screwdriver))
					playsound(loc, P.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You connect the monitor.</span>")
					if(brain)
						SSticker.mode.remove_antag_for_borging(brain.brainmob.mind)
						if(!istype(brain.laws, /datum/ai_laws/ratvar))
							remove_servant_of_ratvar(brain.brainmob, TRUE)
						var/mob/living/silicon/ai/A = new /mob/living/silicon/ai(loc, laws, brain.brainmob)
						if(brain.force_replace_ai_name)
							A.fully_replace_character_name(A.name, brain.replacement_ai_name())
						feedback_inc("cyborg_ais_created",1)
						qdel(src)
					else
						state = AI_READY_CORE
						update_icon()
					return

			if(AI_READY_CORE)
				if(istype(P, /obj/item/device/aicard))
					P.transfer_ai("INACTIVE", "AICARD", src, user)
					return

				if(istype(P, /obj/item/weapon/screwdriver))
					playsound(loc, P.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
					state = GLASS_CORE
					update_icon()
					return
	return ..()

/obj/structure/AIcore/update_icon()
	switch(state)
		if(EMPTY_CORE)
			icon_state = "0"
		if(CIRCUIT_CORE)
			icon_state = "1"
		if(SCREWED_CORE)
			icon_state = "2"
		if(CABLED_CORE)
			if(brain)
				icon_state = "3b"
			else
				icon_state = "3"
		if(GLASS_CORE)
			icon_state = "4"
		if(AI_READY_CORE)
			icon_state = "ai-empty"

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

/obj/structure/AIcore/deactivated
	name = "inactive AI"
	icon_state = "ai-empty"
	anchored = 1
	state = AI_READY_CORE

/obj/structure/AIcore/deactivated/New()
	..()
	circuit = new(src)


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
	if(state != AI_READY_CORE || !..())
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
