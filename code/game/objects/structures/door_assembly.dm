obj/structure/door_assembly
	icon = 'icons/obj/doors/door_assembly.dmi'

	name = "airlock assembly"
	icon_state = "door_as_0"
	anchored = 0
	density = 1
	var/state = 0
	var/mineral = null
	var/typetext = ""
	var/icontext = ""
	var/base_icon_state = "door_as_"
	var/glass_base_icon_state = "door_as_g"
	var/obj/item/weapon/airlock_electronics/electronics = null
	var/airlock_type = /obj/machinery/door/airlock //the type path of the airlock once completed
	var/glass_type = /obj/machinery/door/airlock/glass
	var/created_name = null

obj/structure/door_assembly/New()
	base_icon_state = copytext(icon_state,1,lentext(icon_state))

/obj/structure/door_assembly/door_assembly_0
	name = "airlock assembly"
	icon_state = "door_as_1"
	airlock_type = /obj/machinery/door/airlock
	anchored = 1
	density = 1
	state = 1

/obj/structure/door_assembly/door_assembly_com
	name = "command airlock assembly"
	icon_state = "door_as_com1"
	glass_base_icon_state = "door_as_gcom"
	typetext = "command"
	icontext = "com"
	glass_type = /obj/machinery/door/airlock/glass_command
	airlock_type = /obj/machinery/door/airlock/command
	anchored = 1
	density = 1
	state = 1

/obj/structure/door_assembly/door_assembly_com/glass
	mineral = "glass"
	icon_state = "door_as_gcom1"

/obj/structure/door_assembly/door_assembly_sec
	name = "security airlock assembly"
	icon_state = "door_as_sec1"
	glass_base_icon_state = "door_as_gsec"
	typetext = "security"
	icontext = "sec"
	glass_type = /obj/machinery/door/airlock/glass_security
	airlock_type = /obj/machinery/door/airlock/security
	anchored = 1
	density = 1
	state = 1

/obj/structure/door_assembly/door_assembly_sec/glass
	mineral = "glass"
	icon_state = "door_as_gsec1"

/obj/structure/door_assembly/door_assembly_eng
	name = "engineering airlock assembly"
	icon_state = "door_as_eng1"
	glass_base_icon_state = "door_as_geng"
	typetext = "engineering"
	icontext = "eng"
	glass_type = /obj/machinery/door/airlock/glass_engineering
	airlock_type = /obj/machinery/door/airlock/engineering
	anchored = 1
	density = 1
	state = 1

/obj/structure/door_assembly/door_assembly_eng/glass
	mineral = "glass"
	icon_state = "door_as_geng1"

/obj/structure/door_assembly/door_assembly_min
	name = "mining airlock assembly"
	icon_state = "door_as_min1"
	glass_base_icon_state = "door_as_gmin"
	typetext = "mining"
	icontext = "min"
	glass_type = /obj/machinery/door/airlock/glass_mining
	airlock_type = /obj/machinery/door/airlock/mining
	anchored = 1
	density = 1
	state = 1

/obj/structure/door_assembly/door_assembly_min/glass
	mineral = "glass"
	icon_state = "door_as_gmin1"

/obj/structure/door_assembly/door_assembly_atmo
	name = "atmospherics airlock assembly"
	icon_state = "door_as_atmo1"
	glass_base_icon_state = "door_as_gatmo"
	typetext = "atmos"
	icontext = "atmo"
	glass_type = /obj/machinery/door/airlock/glass_atmos
	airlock_type = /obj/machinery/door/airlock/atmos
	anchored = 1
	density = 1
	state = 1

/obj/structure/door_assembly/door_assembly_atmo/glass
	mineral = "glass"
	icon_state = "door_as_gatmo1"

/obj/structure/door_assembly/door_assembly_research
	name = "research airlock assembly"
	icon_state = "door_as_res1"
	glass_base_icon_state = "door_as_gres"
	typetext = "research"
	icontext = "res"
	glass_type = /obj/machinery/door/airlock/glass_research
	airlock_type = /obj/machinery/door/airlock/research
	anchored = 1
	density = 1
	state = 1

/obj/structure/door_assembly/door_assembly_research/glass
	mineral = "glass"
	icon_state = "door_as_gres1"

/obj/structure/door_assembly/door_assembly_science
	name = "science airlock assembly"
	icon_state = "door_as_sci1"
	glass_base_icon_state = "door_as_gsci"
	typetext = "science"
	icontext = "sci"
	glass_type = /obj/machinery/door/airlock/glass_science
	airlock_type = /obj/machinery/door/airlock/science
	anchored = 1
	density = 1
	state = 1

/obj/structure/door_assembly/door_assembly_science/glass
	mineral = "glass"
	icon_state = "door_as_gsci1"

/obj/structure/door_assembly/door_assembly_med
	name = "medical airlock assembly"
	icon_state = "door_as_med1"
	glass_base_icon_state = "door_as_gmed"
	typetext = "medical"
	icontext = "med"
	glass_type = /obj/machinery/door/airlock/glass_medical
	airlock_type = /obj/machinery/door/airlock/medical
	anchored = 1
	density = 1
	state = 1

/obj/structure/door_assembly/door_assembly_med/glass
	mineral = "glass"
	icon_state = "door_as_gmed1"

/obj/structure/door_assembly/door_assembly_mai
	name = "maintenance airlock assembly"
	icon_state = "door_as_mai1"
	typetext = "maintenance"
	icontext = "mai"
	airlock_type = /obj/machinery/door/airlock/maintenance
	anchored = 1
	density = 1
	state = 1

/obj/structure/door_assembly/door_assembly_ext
	name = "external airlock assembly"
	icon_state = "door_as_ext1"
	typetext = "external"
	icontext = "ext"
	airlock_type = /obj/machinery/door/airlock/external
	anchored = 1
	density = 1
	state = 1

/obj/structure/door_assembly/door_assembly_fre
	name = "freezer airlock assembly"
	icon_state = "door_as_fre1"
	typetext = "freezer"
	icontext = "fre"
	airlock_type = /obj/machinery/door/airlock/freezer
	anchored = 1
	density = 1
	state = 1

/obj/structure/door_assembly/door_assembly_hatch
	name = "airtight hatch assembly"
	icon_state = "door_as_hatch1"
	typetext = "hatch"
	icontext = "hatch"
	airlock_type = /obj/machinery/door/airlock/hatch
	anchored = 1
	density = 1
	state = 1

/obj/structure/door_assembly/door_assembly_mhatch
	name = "maintenance hatch assembly"
	icon_state = "door_as_mhatch1"
	typetext = "maintenance_hatch"
	icontext = "mhatch"
	airlock_type = /obj/machinery/door/airlock/maintenance_hatch
	anchored = 1
	density = 1
	state = 1

/obj/structure/door_assembly/door_assembly_glass
	name = "glass airlock assembly"
	icon_state = "door_as_g1"
	airlock_type = /obj/machinery/door/airlock/glass
	anchored = 1
	density = 1
	state = 1
	mineral = "glass"

/obj/structure/door_assembly/door_assembly_gold
	name = "gold airlock assembly"
	icon_state = "door_as_gold1"
	airlock_type = /obj/machinery/door/airlock/gold
	anchored = 1
	density = 1
	state = 1
	mineral = "gold"

/obj/structure/door_assembly/door_assembly_silver
	name = "silver airlock assembly"
	icon_state = "door_as_silver1"
	airlock_type = /obj/machinery/door/airlock/silver
	anchored = 1
	density = 1
	state = 1
	mineral = "silver"

/obj/structure/door_assembly/door_assembly_diamond
	name = "diamond airlock assembly"
	icon_state = "door_as_diamond1"
	airlock_type = /obj/machinery/door/airlock/diamond
	anchored = 1
	density = 1
	state = 1
	mineral = "diamond"

/obj/structure/door_assembly/door_assembly_uranium
	name = "uranium airlock assembly"
	icon_state = "door_as_uranium1"
	airlock_type = /obj/machinery/door/airlock/uranium
	anchored = 1
	density = 1
	state = 1
	mineral = "uranium"

/obj/structure/door_assembly/door_assembly_plasma
	name = "plasma airlock assembly"
	icon_state = "door_as_plasma1"
	airlock_type = /obj/machinery/door/airlock/plasma
	anchored = 1
	density = 1
	state = 1
	mineral = "plasma"

/obj/structure/door_assembly/door_assembly_clown
	name = "bananium airlock assembly"
	desc = "Honk"
	icon_state = "door_as_clown1"
	airlock_type = /obj/machinery/door/airlock/clown
	anchored = 1
	density = 1
	state = 1
	mineral = "bananium"

/obj/structure/door_assembly/door_assembly_sandstone
	name = "sandstone airlock assembly"
	icon_state = "door_as_sandstone1"
	airlock_type = /obj/machinery/door/airlock/sandstone
	anchored = 1
	density = 1
	state = 1
	mineral = "sandstone"

/obj/structure/door_assembly/door_assembly_highsecurity // Borrowing this until WJohnston makes sprites for the assembly
	name = "high security airlock assembly"
	icon_state = "door_as_highsec1"
	typetext = "highsecurity"
	icontext = "highsec"
	airlock_type = /obj/machinery/door/airlock/highsecurity
	anchored = 1
	density = 1
	state = 1

/obj/structure/door_assembly/door_assembly_vault
	name = "vault door assembly"
	icon_state = "door_as_vault1"
	typetext = "vault"
	icontext = "vault"
	airlock_type = /obj/machinery/door/airlock/vault
	anchored = 1
	density = 1
	state = 1

/obj/structure/door_assembly/door_assembly_shuttle
	name = "shuttle airlock assembly"
	icon_state = "door_as_shuttle1"
	typetext = "shuttle"
	icontext = "shuttle"
	airlock_type = /obj/machinery/door/airlock/shuttle
	anchored = 1
	density = 1
	state = 1

/obj/structure/door_assembly/door_assembly_wood
	name = "wooden airlock assembly"
	icon_state = "door_as_wood1"
	airlock_type = /obj/machinery/door/airlock/wood
	anchored = 1
	density = 1
	state = 1
	mineral = "wood"

/obj/structure/door_assembly/door_assembly_viro
	name = "virology airlock assembly"
	icon_state = "door_as_viro1"
	glass_base_icon_state = "door_as_gviro"
	typetext = "virology"
	icontext = "viro"
	glass_type = /obj/machinery/door/airlock/glass_virology
	airlock_type = /obj/machinery/door/airlock/virology
	anchored = 1
	density = 1
	state = 1

/obj/structure/door_assembly/door_assembly_viro/glass
	mineral = "glass"
	icon_state = "door_as_gviro1"

/obj/structure/door_assembly/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/pen))
		var/t = stripped_input(user, "Enter the name for the door.", src.name, src.created_name,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && src.loc != usr)
			return
		created_name = t
		return

	else if(istype(W, /obj/item/weapon/airlock_painter)) // |- Ricotez
	//INFORMATION ABOUT ADDING A NEW AIRLOCK TO THE PAINT LIST:
	//If your airlock has a regular version, add it to the list with regular versions.
	//If your airlock has a glass version, add it to the list with glass versions.
	//Don't forget to also set has_solid and has_glass to the proper value.
	//Do NOT add your airlock to a list if it does not have a version for that list,
	//	or you will get broken icons.
		var/obj/item/weapon/airlock_painter/WT = W
		if(WT.can_use(user))
			var/icontype
			var/optionlist
			if(mineral && mineral == "glass")
				//These airlocks have a glass version.
				optionlist = list("Default", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Mining")
			else
				//These airlocks have a regular version.
				optionlist = list("Default", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Mining", "Maintenance", "External", "High Security")


			icontype = input(user, "Please select a paintjob for this airlock.") in optionlist
			if((!in_range(src, usr) && src.loc != usr) || !WT.use(user))
				return
			var/has_solid = 0
			var/has_glass = 0
			switch(icontype)
				//For Default the standard options suffice.
				if("Engineering")
					typetext = "engineering"
					icontext = "eng"
					has_solid = 1
					has_glass = 1
				if("Atmospherics")
					typetext = "atmos"
					icontext = "atmo"
					has_solid = 1
					has_glass = 1
				if("Security")
					typetext = "security"
					icontext = "sec"
					has_solid = 1
					has_glass = 1
				if("Command")
					typetext = "command"
					icontext = "com"
					has_solid = 1
					has_glass = 1
				if("Medical")
					typetext = "medical"
					icontext = "med"
					has_solid = 1
					has_glass = 1
				if("Research")
					typetext = "research"
					icontext = "res"
					has_solid = 1
					has_glass = 1
				if("Mining")
					typetext = "mining"
					icontext = "min"
					has_solid = 1
					has_glass = 1
				if("Maintenance")
					typetext = "maintenance"
					icontext = "mai"
					has_solid = 1
					has_glass = 0
				if("External")
					typetext = "external"
					icontext = "ext"
					has_solid = 1
					has_glass = 0
				if("High Security")
					typetext = "highsecurity"
					icontext = "highsec"
					has_solid = 1
					has_glass = 0
			if(has_solid)
				airlock_type = text2path("/obj/machinery/door/airlock/[typetext]")
				base_icon_state = "door_as_[icontext]"
			else
				airlock_type = /obj/machinery/door/airlock
				base_icon_state = "door_as_"

			if(has_glass)
				glass_type = text2path("/obj/machinery/door/airlock/glass_[typetext]")
				glass_base_icon_state = "door_as_g[icontext]"
			else
				glass_type = /obj/machinery/door/airlock/glass
				glass_base_icon_state = "door_as_g"

			if(mineral && mineral != "glass")
				mineral = null //I know this is stupid, but until we change glass to a boolean it's how this code works.
			user << "<span class='notice'> You change the paintjob on the airlock assembly.</span>"

	else if(istype(W, /obj/item/weapon/weldingtool) && !anchored )
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			user.visible_message("<span class='warning'>[user] disassembles the airlock assembly.</span>", \
								"You start to disassemble the airlock assembly...")
			playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)

			if(do_after(user, 40))
				if( !WT.isOn() )
					return
				user << "<span class='notice'> You disassemble the airlock assembly.</span>"
				new /obj/item/stack/sheet/metal(get_turf(src), 4)
				if (mineral)
					if (mineral == "glass")
						new /obj/item/stack/sheet/rglass(get_turf(src))
					else
						var/M = text2path("/obj/item/stack/sheet/mineral/[mineral]")
						new M(get_turf(src))
						new M(get_turf(src))
				qdel(src)
		else
			return

	else if(istype(W, /obj/item/weapon/wrench) && !anchored )
		var/door_check = 1
		for(var/obj/machinery/door/D in loc)
			if(!D.sub_door)
				door_check = 0
				break

		if(door_check)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
			user.visible_message("<span class='warning'>[user] secures the airlock assembly to the floor.</span>", \
								 "You start to secure the airlock assembly to the floor...", \
								 "You hear wrenching")

			if(do_after(user, 40))
				if( src.anchored )
					return
				user << "<span class='notice'> You secure the airlock assembly.</span>"
				src.name = "secured airlock assembly"
				src.anchored = 1
		else
			user << "There is another door here!"

	else if(istype(W, /obj/item/weapon/wrench) && anchored )
		playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
		user.visible_message("<span class='warning'>[user] unsecures the airlock assembly from the floor.</span>", \
							 "You start to unsecure the airlock assembly from the floor...", \
							 "You hear wrenching")
		if(do_after(user, 40))
			if( !src.anchored )
				return
			user << "<span class='notice'> You unsecure the airlock assembly.</span>"
			src.name = "airlock assembly"
			src.anchored = 0

	else if(istype(W, /obj/item/stack/cable_coil) && state == 0 && anchored )
		var/obj/item/stack/cable_coil/C = W
		if (C.get_amount() < 1)
			user << "<span class='warning'>You need one length of cable to wire the airlock assembly!</span>"
			return
		user.visible_message("<span class='warning'>[user] wires the airlock assembly.</span>", \
							"You start to wire the airlock assembly...")
		if(do_after(user, 40))
			if(C.get_amount() < 1 || state != 0) return
			C.use(1)
			src.state = 1
			user << "<span class='notice'>You wire the airlock assembly.</span>"
			src.name = "wired airlock assembly"

	else if(istype(W, /obj/item/weapon/wirecutters) && state == 1 )
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		user.visible_message("<span class='warning'>[user] cuts the wires from the airlock assembly.</span>", \
							"You start to cut the wires from the airlock assembly...")

		if(do_after(user, 40))
			if( src.state != 1 )
				return
			user << "<span class='notice'> You cut the wires from the airlock assembly.</span>"
			new/obj/item/stack/cable_coil(get_turf(user), 1)
			src.state = 0
			src.name = "secured airlock assembly"

	else if(istype(W, /obj/item/weapon/airlock_electronics) && state == 1 )
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		user.visible_message("<span class='warning'>[user] installs the electronics into the airlock assembly.</span>", \
							"You start to install electronics into the airlock assembly...")


		if(do_after(user, 40))
			if( src.state != 1 )
				return

			user.drop_item()
			W.loc = src
			user << "<span class='notice'> You install the airlock electronics.</span>"
			src.state = 2
			src.name = "near finished airlock assembly"
			src.electronics = W


	else if(istype(W, /obj/item/weapon/crowbar) && state == 2 )
		playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
		user.visible_message("<span class='warning'>[user] removes the electronics from the airlock assembly.</span>", \
								"You start to remove electronics from the airlock assembly...")

		if(do_after(user, 40))
			if( src.state != 2 )
				return
			user << "<span class='notice'> You removed the airlock electronics...</span>"
			src.state = 1
			src.name = "wired airlock assembly"
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
			if(G.get_amount() >= 1)
				if(G.type == /obj/item/stack/sheet/rglass)
					playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
					user.visible_message("<span class='warning'>[user] adds [G.name] to the airlock assembly.</span>", \
										"You start to install [G.name] into the airlock assembly...")
					if(do_after(user, 40))
						if(G.get_amount() < 1 || mineral) return
						user << "<span class='notice'>You install reinforced glass windows into the airlock assembly.</span>"
						G.use(1)
						mineral = "glass"
						name = "near finished window airlock assembly"
						//This list contains the airlock paintjobs that have a glass version:
						if(icontext in list("eng", "atmo", "sec", "com", "med", "res", "min"))
							src.airlock_type = text2path("/obj/machinery/door/airlock/[typetext]")
							src.glass_type = text2path("/obj/machinery/door/airlock/glass_[typetext]")
						else
							//This airlock is default or does not have a glass version, so we revert to the default glass airlock. |- Ricotez
							airlock_type = /obj/machinery/door/airlock
							glass_type = /obj/machinery/door/airlock/glass
							typetext = ""
							icontext = ""
						base_icon_state = "door_as_[icontext]"
						glass_base_icon_state = "door_as_g[icontext]"
				else if(istype(G, /obj/item/stack/sheet/mineral))
					var/M = G.sheettype
					if(G.get_amount() >= 2)
						playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
						user.visible_message("<span class='warning'>[user] adds [G.name] to the airlock assembly.</span>", \
										 "You start to install [G.name] into the airlock assembly...")
						if(do_after(user, 40))
							if(G.get_amount() < 2 || mineral) return
							user << "<span class='notice'>You install [M] plating into the airlock assembly.</span>"
							G.use(2)
							mineral = "[M]"
							name = "near finished [M] airlock assembly"
							airlock_type = text2path ("/obj/machinery/door/airlock/[M]")
							base_icon_state = "door_as_[M]"
							glass_base_icon_state = "door_as_g"
							glass_type = /obj/machinery/door/airlock/glass

	else if(istype(W, /obj/item/weapon/screwdriver) && state == 2 )
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		user.visible_message("<span class='warning'>[user] finishes the airlock.</span>", \
							 "You start finishing the airlock...")

		if(do_after(user, 40))
			if(src.loc && state == 2)
				user << "<span class='notice'> You finish the airlock.</span>"
				var/obj/machinery/door/airlock/door
				if(mineral == "glass")
					door = new src.glass_type( src.loc )
				else
					door = new src.airlock_type( src.loc )
				//door.req_access = src.req_access
				door.electronics = src.electronics
				if(src.electronics.use_one_access)
					door.req_one_access = src.electronics.conf_access
				else
					door.req_access = src.electronics.conf_access
				if(created_name)
					door.name = created_name
				src.electronics.loc = door
				qdel(src)
	else
		..()
	if(mineral == "glass")
		icon_state = "[glass_base_icon_state][state]"
	else
		icon_state = "[base_icon_state][state]"
	//This updates the icon_state. They are named as "door_as1_eng" where the 1 in that example
	//represents what state it's in. So the most generic algorithm for the correct updating of
	//this is simply to change the number.
