obj/structure/door_assembly
	icon = 'icons/obj/doors/door_assembly.dmi'

	name = "Airlock Assembly"
	icon_state = "door_as_0"
	anchored = 0
	density = 1
	var/state = 0
	var/mineral = null
	var/base_icon_state = "door_as_0"
	var/glass_base_icon_state = "door_as_g0"
	var/obj/item/weapon/airlock_electronics/electronics = null
	var/airlock_type = /obj/machinery/door/airlock //the type path of the airlock once completed
	var/glass_type = /obj/machinery/door/airlock/glass
	var/glass = null

	New()
		base_icon_state = copytext(icon_state,1,lentext(icon_state))

	door_assembly_0
		name = "Airlock Assembly"
		icon_state = "door_as_1"
		airlock_type = /obj/machinery/door/airlock
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_com
		name = "Command Airlock Assembly"
		icon_state = "door_as_com1"
		glass_base_icon_state = "door_as_gcom"
		glass_type = /obj/machinery/door/airlock/glass_command
		airlock_type = /obj/machinery/door/airlock/command
		anchored = 1
		density = 1
		state = 1
		glass = 0

		glass
			glass = 1
			icon_state = "door_as_gcom1"

	door_assembly_sec
		name = "Security Airlock Assembly"
		icon_state = "door_as_sec1"
		glass_base_icon_state = "door_as_gsec"
		glass_type = /obj/machinery/door/airlock/glass_security
		airlock_type = /obj/machinery/door/airlock/security
		anchored = 1
		density = 1
		state = 1
		glass = 0

		glass
			glass = 1
			icon_state = "door_as_gsec1"

	door_assembly_eng
		name = "Engineering Airlock Assembly"
		icon_state = "door_as_eng1"
		glass_base_icon_state = "door_as_geng"
		glass_type = /obj/machinery/door/airlock/glass_engineering
		airlock_type = /obj/machinery/door/airlock/engineering
		anchored = 1
		density = 1
		state = 1
		glass = 0

		glass
			glass = 1
			icon_state = "door_as_geng1"

	door_assembly_min
		name = "Mining Airlock Assembly"
		icon_state = "door_as_min1"
		glass_base_icon_state = "door_as_gmin"
		glass_type = /obj/machinery/door/airlock/glass_mining
		airlock_type = /obj/machinery/door/airlock/mining
		anchored = 1
		density = 1
		state = 1
		glass = 0

		glass
			glass = 1
			icon_state = "door_as_gmin1"

	door_assembly_atmo
		name = "Atmospherics Airlock Assembly"
		icon_state = "door_as_atmo1"
		glass_base_icon_state = "door_as_gatmo"
		glass_type = /obj/machinery/door/airlock/glass_atmos
		airlock_type = /obj/machinery/door/airlock/atmos
		anchored = 1
		density = 1
		state = 1
		glass = 0

		glass
			glass = 1
			icon_state = "door_as_gatmo1"

	door_assembly_research
		name = "Research Airlock Assembly"
		icon_state = "door_as_res1"
		glass_base_icon_state = "door_as_gres"
		glass_type = /obj/machinery/door/airlock/glass_research
		airlock_type = /obj/machinery/door/airlock/research
		anchored = 1
		density = 1
		state = 1
		glass = 0

		glass
			glass = 1
			icon_state = "door_as_gres1"

	door_assembly_med
		name = "Medical Airlock Assembly"
		icon_state = "door_as_med1"
		airlock_type = /obj/machinery/door/airlock/medical
		anchored = 1
		density = 1
		state = 1

		glass
			mineral = "glass"
			icon_state = "door_as_gmed1"

	door_assembly_mai
		name = "Maintenance Airlock Assembly"
		icon_state = "door_as_mai1"
		airlock_type = /obj/machinery/door/airlock/maintenance
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_ext
		name = "External Airlock Assembly"
		icon_state = "door_as_ext1"
		airlock_type = /obj/machinery/door/airlock/external
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_fre
		name = "Freezer Airlock Assembly"
		icon_state = "door_as_fre1"
		airlock_type = /obj/machinery/door/airlock/freezer
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_hatch
		name = "Airtight Hatch Assembly"
		icon_state = "door_as_hatch1"
		airlock_type = /obj/machinery/door/airlock/hatch
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_mhatch
		name = "Maintenance Hatch Assembly"
		icon_state = "door_as_mhatch1"
		airlock_type = /obj/machinery/door/airlock/maintenance_hatch
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_glass
		name = "Glass Airlock Assembly"
		icon_state = "door_as_g1"
		airlock_type = /obj/machinery/door/airlock/glass
		anchored = 1
		density = 1
		state = 1
		mineral = "glass"

	door_assembly_gold
		name = "Gold Airlock Assembly"
		icon_state = "door_as_gold1"
		airlock_type = /obj/machinery/door/airlock/gold
		anchored = 1
		density = 1
		state = 1
		mineral = "gold"

	door_assembly_silver
		name = "Silver Airlock Assembly"
		icon_state = "door_as_silver1"
		airlock_type = /obj/machinery/door/airlock/silver
		anchored = 1
		density = 1
		state = 1
		mineral = "silver"

	door_assembly_diamond
		name = "Diamond Airlock Assembly"
		icon_state = "door_as_diamond1"
		airlock_type = /obj/machinery/door/airlock/diamond
		anchored = 1
		density = 1
		state = 1
		mineral = "diamond"

	door_assembly_uranium
		name = "Uranium Airlock Assembly"
		icon_state = "door_as_uranium1"
		airlock_type = /obj/machinery/door/airlock/uranium
		anchored = 1
		density = 1
		state = 1
		mineral = "uranium"

	door_assembly_plasma
		name = "Plasma Airlock Assembly"
		icon_state = "door_as_plasma1"
		airlock_type = /obj/machinery/door/airlock/plasma
		anchored = 1
		density = 1
		state = 1
		mineral = "plasma"

	door_assembly_clown
		name = "Bananium Airlock Assembly"
		desc = "Honk"
		icon_state = "door_as_clown1"
		airlock_type = /obj/machinery/door/airlock/clown
		anchored = 1
		density = 1
		state = 1
		mineral = "clown"

	door_assembly_sandstone
		name = "Sandstone Airlock Assembly"
		icon_state = "door_as_sandstone1"
		airlock_type = /obj/machinery/door/airlock/sandstone
		anchored = 1
		density = 1
		state = 1
		mineral = "sandstone"

	door_assembly_sandstone
		name = "Sandstone Airlock Assembly"
		icon_state = "door_as_sandstone1"
		airlock_type = /obj/machinery/door/airlock/sandstone
		anchored = 1
		density = 1
		state = 1
		mineral = "sandstone"

	door_assembly_highsecurity // Borrowing this until WJohnston makes sprites for the assembly
		name = "High Tech Security Assembly"
		icon_state = "door_as_hatch1"
		airlock_type = /obj/machinery/door/airlock/highsecurity
		anchored = 1
		density = 1
		state = 1
		glass = 0

/obj/structure/door_assembly/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/weldingtool) && !anchored )
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			user.visible_message("[user] dissassembles the airlock assembly.", "You start to dissassemble the airlock assembly.")
			playsound(src.loc, 'Welder2.ogg', 50, 1)

			if(do_after(user, 40))
				if(!src || !WT.isOn()) return
				user << "\blue You dissasembled the airlock assembly!"
				new /obj/item/stack/sheet/metal(get_turf(src), 4)
				switch(mineral)
					if("glass")
						new /obj/item/stack/sheet/rglass(get_turf(src))
					if("gold")
						new /obj/item/stack/sheet/gold(get_turf(src))
						new /obj/item/stack/sheet/gold(get_turf(src))
					if("silver")
						new /obj/item/stack/sheet/silver(get_turf(src))
						new /obj/item/stack/sheet/silver(get_turf(src))
					if("diamond")
						new /obj/item/stack/sheet/diamond(get_turf(src))
						new /obj/item/stack/sheet/diamond(get_turf(src))
					if("uranium")
						new /obj/item/stack/sheet/uranium(get_turf(src))
						new /obj/item/stack/sheet/uranium(get_turf(src))
					if("plasma")
						new /obj/item/stack/sheet/plasma(get_turf(src))
						new /obj/item/stack/sheet/plasma(get_turf(src))
					if("clown")
						new /obj/item/stack/sheet/clown(get_turf(src))
						new /obj/item/stack/sheet/clown(get_turf(src))
					if("sandstone")
						new /obj/item/stack/sheet/sandstone(get_turf(src))
						new /obj/item/stack/sheet/sandstone(get_turf(src))
				del(src)
		else
			user << "\blue You need more welding fuel to dissassemble the airlock assembly."
			return

	else if(istype(W, /obj/item/weapon/wrench) && !anchored )
		playsound(src.loc, 'Ratchet.ogg', 100, 1)
		user.visible_message("[user] secures the airlock assembly to the floor.", "You start to secure the airlock assembly to the floor.")

		if(do_after(user, 40))
			if(!src) return
			user << "\blue You secured the airlock assembly!"
			src.name = "Secured Airlock Assembly"
			src.anchored = 1

	else if(istype(W, /obj/item/weapon/wrench) && anchored )
		playsound(src.loc, 'Ratchet.ogg', 100, 1)
		user.visible_message("[user] unsecures the airlock assembly from the floor.", "You start to unsecure the airlock assembly from the floor.")
		if(do_after(user, 40))
			if(!src) return
			user << "\blue You unsecured the airlock assembly!"
			src.name = "Airlock Assembly"
			src.anchored = 0

	else if(istype(W, /obj/item/weapon/cable_coil) && state == 0 && anchored )
		var/obj/item/weapon/cable_coil/coil = W
		user.visible_message("[user] wires the airlock assembly.", "You start to wire the airlock assembly.")
		if(do_after(user, 40))
			if(!src) return
			coil.use(1)
			src.state = 1
			user << "\blue You wire the Airlock!"
			src.name = "Wired Airlock Assembly"

	else if(istype(W, /obj/item/weapon/wirecutters) && state == 1 )
		playsound(src.loc, 'Wirecutter.ogg', 100, 1)
		user.visible_message("[user] cuts the wires from the airlock assembly.", "You start to cut the wires from airlock assembly.")

		if(do_after(user, 40))
			if(!src) return
			user << "\blue You cut the airlock wires.!"
			new/obj/item/weapon/cable_coil(get_turf(user), 1)
			src.state = 0
			src.name = "Secured Airlock Assembly"

	else if(istype(W, /obj/item/weapon/airlock_electronics) && state == 1 )
		playsound(src.loc, 'Screwdriver.ogg', 100, 1)
		user.visible_message("[user] installs the electronics into the airlock assembly.", "You start to install electronics into the airlock assembly.")
		user.drop_item()
		W.loc = src

		if(do_after(user, 40))
			if(!src) return
			user << "\blue You installed the airlock electronics!"
			src.state = 2
			src.name = "Near finished Airlock Assembly"
			src.electronics = W
		else
			W.loc = src.loc

			//del(W)

	else if(istype(W, /obj/item/weapon/crowbar) && state == 2 )
		playsound(src.loc, 'Crowbar.ogg', 100, 1)
		user.visible_message("[user] removes the electronics from the airlock assembly.", "You start to install electronics into the airlock assembly.")

		if(do_after(user, 40))
			if(!src) return
			user << "\blue You removed the airlock electronics!"
			src.state = 1
			src.name = "Wired Airlock Assembly"
			var/obj/item/weapon/airlock_electronics/ae
			if (!electronics)
				ae = new/obj/item/weapon/airlock_electronics( src.loc )
			else
				ae = electronics
				electronics = null
				ae.loc = src.loc
	else if(istype(W, /obj/item/stack/sheet) && !mineral)
		var/obj/item/stack/sheet/G = W
		if(G)
			if(G.amount>=1)
				switch(G.type)
					if(/obj/item/stack/sheet/rglass)
						playsound(src.loc, 'Crowbar.ogg', 100, 1)
						user.visible_message("[user] adds [G.name] to the airlock assembly.", "You start to install [G.name] into the airlock assembly.")
						if(do_after(user, 40))
							user << "\blue You installed reinforced glass windows into the airlock assembly!"
							G.use(1)
							src.mineral = "glass"
							src.name = "Near finished Window Airlock Assembly"
							src.airlock_type = /obj/machinery/door/airlock/glass
							src.base_icon_state = "door_as_g" //this will be applied to the icon_state with the correct state number at the proc's end.
					if(/obj/item/stack/sheet/gold)
						if(G.amount>=2)
							playsound(src.loc, 'Crowbar.ogg', 100, 1)
							user.visible_message("[user] adds [G.name] to the airlock assembly.", "You start to install [G.name] into the airlock assembly.")
							if(do_after(user, 40))
								user << "\blue You installed gold plating into the airlock assembly!"
								G.use(2)
								src.mineral = "gold"
								src.name = "Near finished Gold Airlock Assembly"
								src.airlock_type = /obj/machinery/door/airlock/gold
								src.base_icon_state = "door_as_gold"
					if(/obj/item/stack/sheet/silver)
						if(G.amount>=2)
							playsound(src.loc, 'Crowbar.ogg', 100, 1)
							user.visible_message("[user] adds [G.name] to the airlock assembly.", "You start to install [G.name] into the airlock assembly.")
							if(do_after(user, 40))
								user << "\blue You installed silver plating into the airlock assembly!"
								G.use(2)
								src.mineral = "silver"
								src.name = "Near finished Silver Airlock Assembly"
								src.airlock_type = /obj/machinery/door/airlock/silver
								src.base_icon_state = "door_as_silver"
					if(/obj/item/stack/sheet/diamond)
						if(G.amount>=2)
							playsound(src.loc, 'Crowbar.ogg', 100, 1)
							user.visible_message("[user] adds [G.name] to the airlock assembly.", "You start to install [G.name] into the airlock assembly.")
							if(do_after(user, 40))
								user << "\blue You installed diamond plating into the airlock assembly!"
								G.use(2)
								src.mineral = "diamond"
								src.name = "Near finished Diamond Airlock Assembly"
								src.airlock_type = /obj/machinery/door/airlock/diamond
								src.base_icon_state = "door_as_diamond"
					if(/obj/item/stack/sheet/uranium)
						if(G.amount>=2)
							playsound(src.loc, 'Crowbar.ogg', 100, 1)
							user.visible_message("[user] adds [G.name] to the airlock assembly.", "You start to install [G.name] into the airlock assembly.")
							if(do_after(user, 40))
								user << "\blue You installed uranium plating into the airlock assembly!"
								G.use(2)
								src.mineral = "uranium"
								src.name = "Near finished Uranium Airlock Assembly"
								src.airlock_type = /obj/machinery/door/airlock/uranium
								src.base_icon_state = "door_as_uranium"
					if(/obj/item/stack/sheet/plasma)
						if(G.amount>=2)
							playsound(src.loc, 'Crowbar.ogg', 100, 1)
							user.visible_message("[user] adds [G.name] to the airlock assembly.", "You start to install [G.name] into the airlock assembly.")
							if(do_after(user, 40))
								user << "\blue You installed plasma plating into the airlock assembly!"
								G.use(2)
								src.mineral = "plasma"
								src.name = "Near finished Plasma Airlock Assembly"
								src.airlock_type = /obj/machinery/door/airlock/plasma
								src.base_icon_state = "door_as_plasma"
					if(/obj/item/stack/sheet/clown)
						if(G.amount>=2)
							playsound(src.loc, 'Crowbar.ogg', 100, 1)
							user.visible_message("[user] adds [G.name] to the airlock assembly.", "You start to install [G.name] into the airlock assembly.")
							if(do_after(user, 40))
								user << "\blue You installed bananium plating into the airlock assembly!HONK"
								G.use(2)
								playsound(src.loc, 'bikehorn.ogg', 15, 1, -3)
								src.mineral = "clown"
								src.name = "Near finished Bananium Airlock Assembly"
								src.airlock_type = /obj/machinery/door/airlock/clown
								src.base_icon_state = "door_as_clown"
					if(/obj/item/stack/sheet/sandstone)
						if(G.amount>=2)
							playsound(src.loc, 'Crowbar.ogg', 100, 1)
							user.visible_message("[user] adds [G.name] to the airlock assembly.", "You start to install [G.name] into the airlock assembly.")
							if(do_after(user, 40))
								user << "\blue You installed sandstone plating into the airlock assembly!"
								G.use(2)
								src.mineral = "sandstone"
								src.name = "Near finished Sandstone Airlock Assembly"
								src.airlock_type = /obj/machinery/door/airlock/sandstone
								src.base_icon_state = "door_as_sandstone"

	else if(istype(W, /obj/item/weapon/screwdriver) && state == 2 )
		playsound(src.loc, 'Screwdriver.ogg', 100, 1)
		user << "\blue Now finishing the airlock."

		if(do_after(user, 40))
			if(!src) return
			user << "\blue You finish the airlock!"
			var/obj/machinery/door/airlock/door
			switch(mineral)
				if("glass")
					airlock_type = /obj/machinery/door/airlock/glass
					door = new src.airlock_type( src.loc )
				if("gold")
					airlock_type = /obj/machinery/door/airlock/gold
					door = new src.airlock_type( src.loc )
				if("silver")
					airlock_type = /obj/machinery/door/airlock/silver
					door = new src.airlock_type( src.loc )
				if("diamond")
					airlock_type = /obj/machinery/door/airlock/diamond
					door = new src.airlock_type( src.loc )
				if("uranium")
					airlock_type = /obj/machinery/door/airlock/uranium
					door = new src.airlock_type( src.loc )
				if("plasma")
					airlock_type = /obj/machinery/door/airlock/plasma
					door = new src.airlock_type( src.loc )
				if("clown")
					airlock_type = /obj/machinery/door/airlock/clown
					door = new src.airlock_type( src.loc )
				if("sandstone")
					airlock_type = /obj/machinery/door/airlock/sandstone
					door = new src.airlock_type( src.loc )
				else
					door = new src.airlock_type( src.loc )
			//door.req_access = src.req_access
			door.electronics = src.electronics
			door.req_access = src.electronics.conf_access
			src.electronics.loc = door
			del(src)
	else
		..()
	icon_state = "[base_icon_state][state]"
	//This updates the icon_state. They are named as "door_as1_eng" where the 1 in that example
	//represents what state it's in. So the most generic algorithm for the correct updating of
	//this is simply to change the number.