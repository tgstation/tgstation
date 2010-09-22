/obj/AIcore
	density = 1
	anchored = 0
	name = "AI core"
	icon = 'AIcore.dmi'
	icon_state = "0"
	var/state = 0
	var/datum/ai_laws/laws = new /datum/ai_laws
	var/obj/item/weapon/circuitboard/circuit = null
	var/obj/item/brain/brain = null


/obj/AIcore/attackby(obj/item/weapon/P as obj, mob/user as mob)
	switch(state)
		if(0)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(src.loc, 'Ratchet.ogg', 50, 1)
				if(do_after(user, 20))
					user << "\blue You wrench the frame into place."
					src.anchored = 1
					src.state = 1
			if(istype(P, /obj/item/weapon/weldingtool))
				playsound(src.loc, 'Welder.ogg', 50, 1)
				if(do_after(user, 20))
					user << "\blue You deconstruct the frame."
					var/obj/item/weapon/sheet/r_metal/A = new /obj/item/weapon/sheet/r_metal( src.loc )
					A.amount = 4
					del(src)
		if(1)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(src.loc, 'Ratchet.ogg', 50, 1)
				if(do_after(user, 20))
					user << "\blue You unfasten the frame."
					src.anchored = 0
					src.state = 0
			if(istype(P, /obj/item/weapon/circuitboard/aicore) && !circuit)
				playsound(src.loc, 'Deconstruct.ogg', 50, 1)
				user << "\blue You place the circuit board inside the frame."
				src.icon_state = "1"
				src.circuit = P
				user.drop_item()
				P.loc = src
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(src.loc, 'Screwdriver.ogg', 50, 1)
				user << "\blue You screw the circuit board into place."
				src.state = 2
				src.icon_state = "2"
			if(istype(P, /obj/item/weapon/crowbar) && circuit)
				playsound(src.loc, 'Crowbar.ogg', 50, 1)
				user << "\blue You remove the circuit board."
				src.state = 1
				src.icon_state = "0"
				circuit.loc = src.loc
				src.circuit = null
		if(2)
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(src.loc, 'Screwdriver.ogg', 50, 1)
				user << "\blue You unfasten the circuit board."
				src.state = 1
				src.icon_state = "1"
			if(istype(P, /obj/item/weapon/cable_coil))
				if(P:amount >= 5)
					playsound(src.loc, 'Deconstruct.ogg', 50, 1)
					if(do_after(user, 20))
						P:amount -= 5
						if(!P:amount) del(P)
						user << "\blue You add cables to the frame."
						src.state = 3
						src.icon_state = "3"
		if(3)
			if(istype(P, /obj/item/weapon/wirecutters))
				if (src.brain)
					user << "Get that brain out of there first"
				else
					playsound(src.loc, 'wirecutter.ogg', 50, 1)
					user << "\blue You remove the cables."
					src.state = 2
					src.icon_state = "2"
					var/obj/item/weapon/cable_coil/A = new /obj/item/weapon/cable_coil( src.loc )
					A.amount = 5
					src.laws.clear_inherent_laws()

			if(istype(P, /obj/item/weapon/sheet/rglass))
				if(P:amount >= 2)
					playsound(src.loc, 'Deconstruct.ogg', 50, 1)
					if(do_after(user, 20))
						P:amount -= 2
						if(!P:amount) del(P)
						user << "\blue You put in the glass panel."
						src.state = 4
						src.icon_state = "4"

			if(istype(P, /obj/item/weapon/aiModule/asimov))
				src.laws.add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
				src.laws.add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
				src.laws.add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
				usr << "Law module applied."

			if(istype(P, /obj/item/weapon/aiModule/purge))
				src.laws.clear_inherent_laws()
				usr << "Law module applied."


			if(istype(P, /obj/item/weapon/aiModule/freeform))
				var/obj/item/weapon/aiModule/freeform/M = P
				src.laws.add_inherent_law(M.newFreeFormLaw)
				usr << "Added a freeform law."

			if(istype(P, /obj/item/brain))
				user.drop_item()
				P.loc = src
				src.brain = P
				usr << "Added a brain."
				src.icon_state = "3b"

			if(istype(P, /obj/item/weapon/crowbar) && src.brain)
				playsound(src.loc, 'Crowbar.ogg', 50, 1)
				user << "\blue You remove the brain."
				src.brain.loc = src.loc
				src.brain = null
				src.icon_state = "3"

		if(4)
			if(istype(P, /obj/item/weapon/crowbar))
				playsound(src.loc, 'Crowbar.ogg', 50, 1)
				user << "\blue You remove the glass panel."
				src.state = 3
				src.icon_state = "3"
				var/obj/item/weapon/sheet/rglass/A = new /obj/item/weapon/sheet/rglass( src.loc )
				A.amount = 2
			if(istype(P, /obj/item/weapon/screwdriver))
				playsound(src.loc, 'Screwdriver.ogg', 50, 1)
				user << "\blue You connect the monitor."

				new /mob/living/silicon/ai ( src.loc, laws, brain )
				del(src)