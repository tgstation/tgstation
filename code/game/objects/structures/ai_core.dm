#define EMPTY_CORE 0
#define CIRCUIT_CORE 1
#define SCREWED_CORE 2
#define CABLED_CORE 3
#define GLASS_CORE 4

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
		brain.forceMove(loc)
		brain = null
	return ..()

/obj/structure/AIcore/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/weapon/wrench))
		playsound(loc, P.usesound, 50, 1)
		user.visible_message("[user] [anchored ? "fastens" : "unfastens"] [src].", \
					 "<span class='notice'>You start to [anchored ? "unfasten [src] from" : "fasten [src] to"] the floor...</span>")
		if(do_after(user, 20*P.toolspeed, target = src))
			user << "<span class='notice'>You [anchored ? "unfasten [src] from" : "fasten [src] to"] the floor.</span>"
			anchored = !anchored
		return
	if(!anchored)
		if(istype(P, /obj/item/weapon/weldingtool))
			if(state != EMPTY_CORE)
				user << "<span class='warning'>The core must be empty to deconstruct it!</span>"
				return
			var/obj/item/weapon/weldingtool/WT = P
			if(!WT.isOn())
				user << "<span class='warning'>The welder must be on for this task!</span>"
				return
			playsound(loc, 'sound/items/Welder.ogg', 50, 1)
			user << "<span class='notice'>You start to deconstruct the frame...</span>"
			if(do_after(user, 20*P.toolspeed, target = src) && src && state == EMPTY_CORE && WT && WT.remove_fuel(0, user))
				user << "<span class='notice'>You deconstruct the frame.</span>"
				deconstruct(TRUE)
			return
	else
		switch(state)
			if(EMPTY_CORE)
				if(istype(P, /obj/item/weapon/circuitboard/aicore))
					if(!user.drop_item())
						return
					playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
					user << "<span class='notice'>You place the circuit board inside the frame.</span>"
					icon_state = "1"
					state = CIRCUIT_CORE
					circuit = P
					P.forceMove(src)
					return
			if(CIRCUIT_CORE)
				if(istype(P, /obj/item/weapon/screwdriver))
					playsound(loc, P.usesound, 50, 1)
					user << "<span class='notice'>You screw the circuit board into place.</span>"
					state = SCREWED_CORE
					icon_state = "2"
					return
				if(istype(P, /obj/item/weapon/crowbar))
					playsound(loc, P.usesound, 50, 1)
					user << "<span class='notice'>You remove the circuit board.</span>"
					state = EMPTY_CORE
					icon_state = "0"
					circuit.forceMove(loc)
					circuit = null
					return
			if(SCREWED_CORE)
				if(istype(P, /obj/item/weapon/screwdriver) && circuit)
					playsound(loc, P.usesound, 50, 1)
					user << "<span class='notice'>You unfasten the circuit board.</span>"
					state = CIRCUIT_CORE
					icon_state = "1"
					return
				if(istype(P, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/C = P
					if(C.get_amount() >= 5)
						playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
						user << "<span class='notice'>You start to add cables to the frame...</span>"
						if(do_after(user, 20, target = src) && state == SCREWED_CORE && C.use(5))
							user << "<span class='notice'>You add cables to the frame.</span>"
							state = CABLED_CORE
							icon_state = "3"
					else
						user << "<span class='warning'>You need five lengths of cable to wire the AI core!</span>"
					return
			if(CABLED_CORE)
				if(istype(P, /obj/item/weapon/wirecutters))
					if (brain)
						user << "<span class='warning'>Get that brain out of there first!</span>"
					else
						playsound(loc, P.usesound, 50, 1)
						user << "<span class='notice'>You remove the cables.</span>"
						state = SCREWED_CORE
						icon_state = "2"
						var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( loc )
						A.amount = 5
					return

				if(istype(P, /obj/item/stack/sheet/rglass))
					var/obj/item/stack/sheet/rglass/G = P
					if(G.get_amount() >= 2)
						playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
						user << "<span class='notice'>You start to put in the glass panel...</span>"
						if(do_after(user, 20, target = src) && state == CABLED_CORE && G.use(2))
							user << "<span class='notice'>You put in the glass panel.</span>"
							state = GLASS_CORE
							icon_state = "4"
					else
						user << "<span class='warning'>You need two sheets of reinforced glass to insert them into the AI core!</span>"
					return

				if(istype(P, /obj/item/weapon/aiModule))
					var/obj/item/weapon/aiModule/module = P
					module.install(laws, user)
					return

				if(istype(P, /obj/item/device/mmi) && !brain)
					var/obj/item/device/mmi/M = P
					if(!M.brainmob)
						user << "<span class='warning'>Sticking an empty MMI into the frame would sort of defeat the purpose!</span>"
						return
					if(M.brainmob.stat == DEAD)
						user << "<span class='warning'>Sticking a dead brain into the frame would sort of defeat the purpose!</span>"
						return

					if(!M.brainmob.client)
						user << "<span class='warning'>Sticking an inactive brain into the frame would sort of defeat the purpose.</span>"
						return

					if((config) && (!config.allow_ai) || jobban_isbanned(M.brainmob, "AI") || M.hacked || M.clockwork)
						user << "<span class='warning'>This MMI does not seem to fit!</span>"
						return

					if(!M.brainmob.mind)
						user << "<span class='warning'>This MMI is mindless!</span>"
						return

					if(!user.drop_item())
						return

					ticker.mode.remove_antag_for_borging(M.brainmob.mind)
					remove_servant_of_ratvar(M, TRUE)
					M.forceMove(src)
					brain = M
					user << "<span class='notice'>Added a brain.</span>"
					icon_state = "3b"
					return

				if(istype(P, /obj/item/weapon/crowbar) && brain)
					playsound(loc, P.usesound, 50, 1)
					user << "<span class='notice'>You remove the brain.</span>"
					brain.forceMove(loc)
					brain = null
					icon_state = "3"
					return

			if(GLASS_CORE)
				if(istype(P, /obj/item/weapon/crowbar))
					playsound(loc, P.usesound, 50, 1)
					user << "<span class='notice'>You remove the glass panel.</span>"
					state = CABLED_CORE
					if(brain)
						icon_state = "3b"
					else
						icon_state = "3"
					new /obj/item/stack/sheet/rglass(loc, 2)
					return

				if(istype(P, /obj/item/weapon/screwdriver))
					playsound(loc, P.usesound, 50, 1)
					user << "<span class='notice'>You connect the monitor.</span>"
					new /mob/living/silicon/ai (loc, laws, brain)
					feedback_inc("cyborg_ais_created",1)
					qdel(src)
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

/obj/structure/AIcore/deactivated
	name = "inactive AI"
	icon = 'icons/mob/AI.dmi'
	icon_state = "ai-empty"
	anchored = 1
	state = GLASS_CORE

/obj/structure/AIcore/deactivated/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/device/aicard) && state == GLASS_CORE)
		A.transfer_ai("INACTIVE","AICARD",src,user)
	else
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
			user << "<span class='boldannounce'>ERROR</span>: AI flush is in progress, cannot execute transfer protocol."
			return 0
	return 1


/obj/structure/AIcore/deactivated/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/device/aicard/card)
	if(!..())
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
	name = "circuit board (AI core)"
	origin_tech = "programming=3"
