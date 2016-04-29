//This file will contain all the intermediary parts used in the crafting of craftable weapons, before they actually become said weapons.

/obj/item/weapon/aluminum_cylinder
	name = "aluminum cylinder"
	desc = "A soda can that has had the top and bottom cut out."
	icon = 'icons/obj/weaponsmithing.dmi'
	icon_state = "cutoutcan"
	w_class = 1

/obj/item/weapon/aluminum_cylinder/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, src))
		to_chat(user, "You press the two [src.name]s together.")
		if(src.loc == user)
			user.drop_item(src, force_drop = 1)
			var/obj/item/weapon/cylinder_assembly/I = new (get_turf(user))
			user.put_in_hands(I)
		else
			new /obj/item/weapon/cylinder_assembly(get_turf(src.loc))
		qdel(src)
		qdel(W)

/obj/item/weapon/cylinder_assembly
	name = "cylinder assembly"
	desc = "Two aluminum cylinders stuck together. Doesn't look very secure."
	icon = 'icons/obj/weaponsmithing.dmi'
	icon_state = "cutoutcan_assembly"

/obj/item/weapon/cylinder_assembly/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			to_chat(user, "You begin welding \the [src] together.")
			playsound(user, 'sound/items/Welder.ogg', 50, 1)
			if(do_after(user, src, 30))
				to_chat(user, "You weld \the [src] together.")
				if(src.loc == user)
					user.drop_item(src, force_drop = 1)
					var/obj/item/weapon/gun_barrel/I = new (get_turf(user))
					user.put_in_hands(I)
				else
					new /obj/item/weapon/gun_barrel(get_turf(src.loc))
				qdel(src)
		else
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return

/obj/item/weapon/cylinder_assembly/attack_self(mob/user as mob)
	..()
	to_chat(user, "You detach the aluminum cylinders from each other.")
	new /obj/item/weapon/aluminum_cylinder(get_turf(user.loc))
	new /obj/item/weapon/aluminum_cylinder(get_turf(user.loc))
	qdel(src)

/obj/item/weapon/gun_barrel
	name = "barrel"
	desc = "A decently-sized strong metal tube."
	icon = 'icons/obj/weaponsmithing.dmi'
	icon_state = "gun_barrel"

/obj/item/weapon/metal_gun_stock
	name = "gun stock"
	desc = "A metal gun stock. Not terribly comfortable."
	icon = 'icons/obj/weaponsmithing.dmi'
	icon_state = "metal_stock"
	w_class = 2

/obj/item/weapon/metal_gun_stock/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/fuel_reservoir))
		to_chat(user, "You loosely affix \the [W] to \the [src].")
		if(src.loc == user)
			user.drop_item(src, force_drop = 1)
			var/obj/item/weapon/gun_assembly/I = new (get_turf(user), "stock_reservoir_assembly")
			user.put_in_hands(I)
		else
			new /obj/item/weapon/gun_assembly(get_turf(src.loc), "stock_reservoir_assembly")
		qdel(src)
		qdel(W)
	if(istype(W, /obj/item/pipe))
		var/obj/item/pipe/P = W
		if(P.pipe_type == 1) //bent pipes only
			to_chat(user, "You loosely affix \the [W] to \the [src].")
			if(src.loc == user)
				user.drop_item(src, force_drop = 1)
				var/obj/item/weapon/gun_assembly/I = new (get_turf(user), "stock_pipe_assembly")
				user.put_in_hands(I)
			else
				new /obj/item/weapon/gun_assembly(get_turf(src.loc), "stock_pipe_assembly")
			qdel(src)
			qdel(W)
	if(istype(W, /obj/item/weapon/stock_parts/subspace/ansible))
		to_chat(user, "You loosely affix \the [W] to \the [src].")
		if(src.loc == user)
			user.drop_item(src, force_drop = 1)
			var/obj/item/weapon/gun_assembly/I = new (get_turf(user), "stock_ansible_assembly")
			user.put_in_hands(I)
		else
			new /obj/item/weapon/gun_assembly(get_turf(src.loc), "stock_ansible_assembly")
		qdel(src)
		qdel(W)

/obj/item/weapon/fuel_reservoir
	name = "fuel reservoir"
	desc = "A grenade casing with a hole poked through, allowing it to hold fuel."
	icon = 'icons/obj/weaponsmithing.dmi'
	icon_state = "reservoir"
	w_class = 2

/obj/item/weapon/metal_blade
	name = "metal blade"
	desc = "A simple blade made of sturdy metal."
	icon = 'icons/obj/weaponsmithing.dmi'
	icon_state = "metal_blade"
	w_class = 1

/obj/item/weapon/metal_blade/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, src))
		to_chat(user, "You attach \the [W] to \the [src].")
		if(src.loc == user)
			user.drop_item(src, force_drop = 1)
			var/obj/item/weapon/large_metal_blade/I = new (get_turf(user))
			user.put_in_hands(I)
		else
			new /obj/item/weapon/large_metal_blade(get_turf(src.loc))
		qdel(src)
		qdel(W)

/obj/item/weapon/large_metal_blade
	name = "large metal blade"
	desc = "A large blade comprised of two smaller ones. Doesn't appear to be held together very well."
	icon = 'icons/obj/weaponsmithing.dmi'
	icon_state = "large_metal_blade_assembly"
	w_class = 3
	var/complete = 0

/obj/item/weapon/large_metal_blade/attack_self(mob/user as mob)
	if(complete)
		return
	..()
	to_chat(user, "You detach the metal blades from each other.")
	new /obj/item/weapon/metal_blade(get_turf(user.loc))
	new /obj/item/weapon/metal_blade(get_turf(user.loc))
	qdel(src)

/obj/item/weapon/large_metal_blade/attackby(obj/item/weapon/W, mob/user)
	if(complete)
		if(istype(W, /obj/item/stack/cable_coil))
			var/obj/item/stack/cable_coil/C = W
			if(C.amount < 5)
				to_chat(user, "You don't have enough cable to make a grip for \the [src].")
				return
			to_chat(user, "You wrap cable around the base of \the [src], creating a grip.")
			if(src.loc == user)
				user.drop_item(src, force_drop = 1)
				var/obj/item/weapon/sword/I = new (get_turf(user))
				user.put_in_hands(I)
			else
				new /obj/item/weapon/sword(get_turf(src.loc))
			C.use(5)
			qdel(src)
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			to_chat(user, "You begin welding the metal blades together.")
			playsound(user, 'sound/items/Welder.ogg', 50, 1)
			if(do_after(user, src, 30))
				to_chat(user, "You weld the metal blades together.")
				desc = "A large blade made of sturdy metal."
				icon_state = "large_metal_blade"
				w_class = 3
				complete = 1
		else
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return

/obj/item/weapon/rail_assembly
	name = "rail assembly"
	desc = "A set of metal rails."
	icon = 'icons/obj/weaponsmithing.dmi'
	icon_state = "rail_assembly"
	var/durability = 100 //After a certain number of shots, the rails will degrade and will need to be replaced.

/obj/item/weapon/cylinder
	name = "beaker"
	desc = "A beaker. There appear to be six holes drilled through the bottom."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	starting_materials = list(MAT_GLASS = 500)
	origin_tech = "materials=1"
	w_class = 1
	var/has_divider = 0
	var/list/chambers = list(
		null,
		null,
		null,
		null,
		null,
		null,
		)
	var/current_chamber = 1

/obj/item/weapon/cylinder/Destroy()
	for(var/i = 1; i < chambers.len; i++)
		if(chambers[i])
			qdel(chambers[i])
			chambers[i] = null
	..()

/obj/item/weapon/cylinder/proc/cycle()
	if(current_chamber == 6)
		current_chamber = 1
	else
		current_chamber += 1

/obj/item/weapon/cylinder/proc/cycle_back()
	if(current_chamber == 1)
		current_chamber = 6
	else
		current_chamber -= 1

/obj/item/weapon/cylinder/examine(mob/user)
	..()
	var/chambercount = 0
	for(var/i = 1; i<=6; i++)
		if(chambers[i])
			chambercount += 1
	if(chambercount)
		to_chat(user, "<span class='info'>There [chambercount > 1 ? "are" : "is"] [chambercount] vials loaded into \the [src].</span>")

/obj/item/weapon/cylinder/attack_self(mob/user as mob)
	if(!chambers[current_chamber])
		for(var/i = 1; i<=6; i++)
			if(chambers[i])
				current_chamber = i
	if(!chambers[current_chamber])
		return

	var/obj/item/weapon/reagent_containers/glass/beaker/vial/V = chambers[current_chamber]
	V.forceMove(user.loc)
	user.put_in_hands(V)
	chambers[current_chamber] = null
	to_chat(user, "You remove \the [V] from \the [src].")

/obj/item/weapon/cylinder/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/reagent_containers/food/drinks/sillycup))
		if(has_divider)
			return
		to_chat(user, "You fold \the [W] into a divider and insert it into \the [src].")
		has_divider = 1
		name = "cylinder"
		desc = "A makeshift revolver cylinder. The chambers are just the right size to accomodate some sort of small tube."
		icon = 'icons/obj/weaponsmithing.dmi'
		icon_state = "cylinder"
		qdel(W)

	if(has_divider)
		if(istype(W, /obj/item/weapon/reagent_containers/glass/beaker/vial))
			var/obj/item/weapon/reagent_containers/glass/beaker/vial/V = W
			if(V.flags & OPENCONTAINER)
				if(!V.is_empty())
					to_chat(user, "<span class='warning'>The contents of \the [V] will spill out if there's not a lid on it.</span>")
					return
			if(!user.drop_item(V, src))
				to_chat(user, "<span class='warning'>You can't let go of \the [V]!</span>")
				return 1
			cycle_back() //vials are loaded in "first in, last out" configuration, so that there's no gap between consecutive shots
			chambers[current_chamber] = V
			user.visible_message("[user] inserts \the [V] into \the [src].","You insert \the [V] into \the [src].")

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//GUN ASSEMBLY BEGIN///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/gun_assembly //master gun assembly, handles all intermediary steps between being a thing and being a gun
	name = "gun assembly"
	desc = "It's a thing."
	icon = 'icons/obj/weaponsmithing.dmi'
	icon_state = null
	var/state = null

/obj/item/weapon/gun_assembly/New(atom/T, var/input_state = null)
	..(T)
	state = input_state
	if(!state)
		state = "stock_reservoir_assembly"
	update_assembly()

/obj/item/weapon/gun_assembly/proc/update_assembly()
	switch(state)
		if("stock_reservoir_assembly")
			name = "gun stock"
			desc = "A metal gun stock. There is a fuel reservoir loosely fitted to it."
			icon_state = "stock_reservoir"
		if("stock_reservoir")
			name = "gun stock"
			desc = "A metal gun stock. There is a fuel reservoir securely fastened to it."
			icon_state = "stock_reservoir"
		if("stock_reservoir_barrel_assembly")
			name = "gun stock"
			desc = "It looks like it could be some type of gun. The barrel doesn't seem very well secured to the body."
			icon_state = "stock_reservoir_barrel_assembly"
			w_class = 4
		if("stock_reservoir_barrel")
			name = "gun assembly"
			desc = "It looks like it could be some type of gun. It seems to be missing an ignition source."
			icon_state = "stock_reservoir_barrel"
			w_class = 4
		if("blunderbuss_assembly")
			name = "gun assembly"
			desc = "It looks like it could be some type of gun. The firing mechanism doesn't seem to be securely tightened."
			icon_state = "blunderbuss_assembly"
			w_class = 4

		if("stock_capacitorbank_assembly")
			name = "gun stock"
			desc = "A metal gun stock. There is a capacitor bank securely fastened to it. The capacitor bank's wires seem loose."
			icon_state = "stock_capacitorbank_assembly"
		if("stock_capacitorbank")
			name = "gun stock"
			desc = "A metal gun stock. There is a capacitor bank securely fastened to it."
			icon_state = "stock_capacitorbank"
		if("stock_capacitorbank_barrel_assembly")
			name = "gun assembly"
			desc = "It looks like it could be some type of gun. The barrel doesn't seem very well secured to the body."
			icon_state = "stock_capacitorbank_barrel_assembly"
			w_class = 4
		if("stock_capacitorbank_barrel")
			name = "gun assembly"
			desc = "It looks like it could be some type of gun. It seems to be missing a triggering mechanism."
			icon_state = "stock_capacitorbank_barrel"
			w_class = 4
		if("railgun_assembly")
			name = "gun assembly"
			desc = "It looks like it could be some type of gun. The triggering mechanism is unsecured."
			icon_state = "railgun_assembly"
			w_class = 4

		if("spraybottle_assembly")
			name = "spray bottle"
			desc = "A spray bottle with a metal rod attached to the top. It doesn't appear to be operable."
			icon_state = "spraybottle_assembly"
		if("revialver_assembly")
			name = "revialver"
			desc = "A makeshift single-action revolver. It doesn't seem to have a cylinder loaded into it."
			icon_state = "revialver_assembly"

		if("stock_pipe_assembly")
			name = "gun stock"
			desc = "A metal gun stock. There is a bent pipe loosely fitted to it."
			icon_state = "stock_pipe_assembly"

		if("stock_ansible_assembly")
			name = "gun stock"
			desc = "A metal gun stock. There is a subspace ansible loosely fitted to it."
			icon_state = "stock_ansible_assembly"
		if("stock_ansible")
			name = "gun stock"
			desc = "A metal gun stock. There is a subspace ansible welded onto it."
			icon_state = "stock_ansible"
		if("stock_ansible_amplifier_assembly")
			name = "gun assembly"
			desc = "It looks like it could be some type of gun. The subspace amplifier affixed to the front of it is unsecured."
			icon_state = "stock_ansible_amplifier_assembly"
		if("stock_ansible_amplifier")
			name = "gun assembly"
			desc = "It looks like it could be some type of gun."
			icon_state = "stock_ansible_amplifier"
		if("stock_ansible_amplifier_transmitter_assembly")
			name = "gun assembly"
			desc = "It looks like it could be some type of gun. The subspace transmitter affixed to the front of it is unsecured."
			icon_state = "stock_ansible_amplifier_transmitter_assembly"
		if("subspacetunneler_assembly")
			name = "gun assembly"
			desc = "It looks like it could be some type of gun. Something might fit into the prongs of its subspace ansible."
			icon_state = "subspacetunneler_assembly"

/obj/item/weapon/gun_assembly/attack_self(mob/user as mob)
	switch(state)
		if("stock_reservoir_assembly")
			to_chat(user, "You detach the fuel reservoir from \the [src].")
			user.drop_item(src, force_drop = 1)
			var/obj/item/weapon/metal_gun_stock/I = new (get_turf(src.loc))
			var/obj/item/weapon/fuel_reservoir/Q = new (get_turf(src.loc))
			user.put_in_hands(I)
			user.put_in_hands(Q)
			qdel(src)
		if("stock_reservoir_barrel_assembly")
			to_chat(user, "You detach the barrel from \the [src].")
			var/obj/item/weapon/gun_barrel/I = new (get_turf(user.loc))
			user.put_in_hands(I)
			state = "stock_reservoir"
			update_assembly()
		if("blunderbuss_assembly")
			to_chat(user, "You detach the igniter from \the [src].")
			var/obj/item/device/assembly/igniter/I = new (get_turf(src.loc))
			user.put_in_hands(I)
			state = "stock_reservoir_barrel"
			update_assembly()
		if("stock_capacitorbank_barrel_assembly")
			to_chat(user, "You detach the barrel from \the [src].")
			var/obj/item/weapon/gun_barrel/I = new (get_turf(user.loc))
			user.put_in_hands(I)
			state = "stock_capacitorbank"
			update_assembly()

/obj/item/weapon/gun_assembly/attackby(obj/item/weapon/W, mob/user)
	switch(state)
		if("stock_reservoir_assembly")
			if(iswrench(W))
				to_chat(user, "You securely fasten the fuel reservoir to \the [src].")
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
				state = "stock_reservoir"
				update_assembly()
		if("stock_reservoir")
			if(istype(W, /obj/item/weapon/gun_barrel))
				to_chat(user, "You attach \the [W] to \the [src].")
				state = "stock_reservoir_barrel_assembly"
				update_assembly()
				qdel(W)
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = W
				if(C.amount < 5)
					to_chat(user, "You don't have enough cable to make a capacitor bank.")
					return
				to_chat(user, "You add the coil to the fuel reservoir, creating a capacitor bank.")
				state = "stock_capacitorbank_assembly"
				update_assembly()
				C.use(5)
			if(iswrench(W))
				to_chat(user, "You loosen the fuel reservoir on \the [src].")
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
				state = "stock_reservoir_assembly"
				update_assembly()

//BLUNDERBUSS BEGIN////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		if("stock_reservoir_barrel_assembly")
			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0, user))
					to_chat(user, "You begin welding the barrel to \the [src].")
					playsound(user, 'sound/items/Welder.ogg', 50, 1)
					if(do_after(user, src, 30))
						to_chat(user, "You weld the barrel to \the [src].")
						state = "stock_reservoir_barrel"
						update_assembly()
				else
					to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
					return
		if("stock_reservoir_barrel")
			if(istype(W, /obj/item/device/assembly/igniter))
				to_chat(user, "You attach \the [W] to \the [src].")
				state = "blunderbuss_assembly"
				update_assembly()
				qdel(W)
		if("blunderbuss_assembly")
			if(isscrewdriver(W))
				to_chat(user, "You tighten the igniter to \the [src].")
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				if(src.loc == user)
					user.drop_item(src, force_drop = 1)
					var/obj/item/weapon/blunderbuss/I = new (get_turf(user))
					user.put_in_hands(I)
				else
					new /obj/item/weapon/blunderbuss(get_turf(src.loc))
				qdel(src)
//BLUNDERBUSS END//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//RAILGUN BEGIN////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		if("stock_capacitorbank_assembly")
			if(isscrewdriver(W))
				to_chat(user, "You tighten the wires in \the [src]'s capacitor bank.")
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				state = "stock_capacitorbank"
				update_assembly()
			if(iswirecutter(W))
				to_chat(user, "You cut the wires out of the capacitor bank.")
				playsound(user, 'sound/items/Wirecutter.ogg', 50, 1)
				state = "stock_reservoir"
				update_assembly()
				var/obj/item/stack/cable_coil/C = new (get_turf(user))
				C.amount = 5
		if("stock_capacitorbank")
			if(istype(W, /obj/item/weapon/gun_barrel))
				to_chat(user, "You attach \the [W] to \the [src].")
				state = "stock_capacitorbank_barrel_assembly"
				update_assembly()
				qdel(W)
			if(isscrewdriver(W))
				to_chat(user, "You loosen the wires in \the [src]'s capacitor bank.")
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				state = "stock_capacitorbank_assembly"
				update_assembly()
		if("stock_capacitorbank_barrel_assembly")
			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0, user))
					to_chat(user, "You begin welding the barrel to \the [src].")
					playsound(user, 'sound/items/Welder.ogg', 50, 1)
					if(do_after(user, src, 30))
						to_chat(user, "You weld the barrel to \the [src].")
						state = "stock_capacitorbank_barrel"
						update_assembly()
				else
					to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
					return
		if("stock_capacitorbank_barrel")
			if(istype(W, /obj/item/mounted/frame/light_switch) || istype(W, /obj/item/mounted/frame/access_button) || istype(W, /obj/item/mounted/frame/driver_button))
				to_chat(user, "You attach \the [W] to \the [src].")
				state = "railgun_assembly"
				update_assembly()
				qdel(W)
		if("railgun_assembly")
			if(isscrewdriver(W))
				to_chat(user, "You secure \the [src]'s triggering mechanism.")
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				if(src.loc == user)
					user.drop_item(src, force_drop = 1)
					var/obj/item/weapon/gun/projectile/railgun/I = new (get_turf(user))
					user.put_in_hands(I)
				else
					new /obj/item/weapon/gun/projectile/railgun(get_turf(src.loc))
				qdel(src)
//RAILGUN END//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//REVIALVER BEGIN//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		if("spraybottle_assembly")
			if(istype(W, /obj/item/weapon/storage/pill_bottle))
				var/obj/item/weapon/storage/pill_bottle/P = W
				if(!P.melted)
					return
				to_chat(user, "You press the melted part of \the [W] onto the end of the metal rod, creating a plastic barrel.")
				state = "revialver_assembly"
				update_assembly()
				qdel(W)
		if("revialver_assembly")
			if(istype(W, /obj/item/weapon/cylinder))
				to_chat(user, "<span class='warning'>\The [W] will fall off if there's nothing on \the [src] to hold it.</span>")
				return
			if(istype(W, /obj/item/device/label_roll))
				to_chat(user, "You wrap \the [W] around the middle of the metal rod on \the [src].")
				if(src.loc == user)
					user.drop_item(src, force_drop = 1)
					var/obj/item/weapon/gun/projectile/revialver/I = new (get_turf(user))
					user.put_in_hands(I)
				else
					new /obj/item/weapon/gun/projectile/revialver(get_turf(src.loc))
				qdel(W)
				qdel(src)
//REVIALVER END////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//BLAST CANNON BEGIN///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		if("stock_pipe_assembly")
			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0, user))
					to_chat(user, "You begin welding the bent pipe to \the [src].")
					playsound(user, 'sound/items/Welder.ogg', 50, 1)
					if(do_after(user, src, 30))
						to_chat(user, "You weld the bent pipe to \the [src].")
						if(src.loc == user)
							user.drop_item(src, force_drop = 1)
							var/obj/item/weapon/gun/projectile/blastcannon/I = new (get_turf(user))
							user.put_in_hands(I)
						else
							new /obj/item/weapon/gun/projectile/blastcannon(get_turf(src.loc))
						qdel(src)
				else
					to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
					return
//BLAST CANNON END/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//SUBSPACE TUNNELER BEGIN//////////////////////////////////////////////////////////////////////////////////////////////////////////////
		if("stock_ansible_assembly")
			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0, user))
					to_chat(user, "You begin welding the subspace ansible onto \the [src].")
					playsound(user, 'sound/items/Welder.ogg', 50, 1)
					if(do_after(user, src, 30))
						to_chat(user, "You weld the subspace ansible onto \the [src].")
						state = "stock_ansible"
						update_assembly()
				else
					to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
					return
		if("stock_ansible")
			if(istype(W, /obj/item/weapon/stock_parts/subspace/amplifier))
				to_chat(user, "You attach \the [W] to \the [src].")
				state = "stock_ansible_amplifier_assembly"
				update_assembly()
				qdel(W)
		if("stock_ansible_amplifier_assembly")
			if(isscrewdriver(W))
				to_chat(user, "You secure \the [src]'s subspace amplifier.")
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				state = "stock_ansible_amplifier"
				update_assembly()
		if("stock_ansible_amplifier")
			if(istype(W, /obj/item/weapon/stock_parts/subspace/transmitter))
				to_chat(user, "You attach \the [W] to \the [src].")
				state = "stock_ansible_amplifier_transmitter_assembly"
				update_assembly()
				qdel(W)
		if("stock_ansible_amplifier_transmitter_assembly")
			if(isscrewdriver(W))
				to_chat(user, "You secure \the [src]'s subspace transmitter.")
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				state = "subspacetunneler_assembly"
				update_assembly()
		if("subspacetunneler_assembly")
			if(istype(W, /obj/item/weapon/stock_parts/subspace/crystal))
				to_chat(user, "You place \the [W] into the prongs of the subspace ansible on \the [src].")
				if(src.loc == user)
					user.drop_item(src, force_drop = 1)
					var/obj/item/weapon/subspacetunneler/I = new (get_turf(user))
					user.put_in_hands(I)
				else
					new /obj/item/weapon/subspacetunneler(get_turf(src.loc))
				qdel(W)
				qdel(src)
//SUBSPACE TUNNELER END////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//GUN ASSEMBLY END/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////





//TOMAHAWK BEGIN///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/wrench_wired
	name = "wired wrench"
	desc = "A wrench with some wire wrapped around the top. It'd be easy to attach something to the top bit."
	icon = 'icons/obj/weaponsmithing.dmi'
	icon_state = "wrench"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/items_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/items_righthand.dmi')
	hitsound = "sound/weapons/smash.ogg"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	force = 5.0
	throwforce = 7.0
	w_class = 2.0
	starting_materials = list(MAT_IRON = 150)
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("bashes", "batters", "bludgeons", "whacks")
	var/metal_assembly = 0

/obj/item/weapon/wrench_wired/proc/update_wired_wrench_assembly()
	if(metal_assembly)
		name = "tomahawk assembly"
		desc = "A makeshift handaxe with a fine blade of strong metal. The blade doesn't look very secure."
		icon_state = "tomahawk_metal_assembly"
	else
		name = "wired wrench"
		desc = "A wrench with some wire wrapped around the top. It'd be easy to attach something to the top bit."
		icon_state = "wrench"

/obj/item/weapon/wrench_wired/attack_self(mob/user as mob)
	if(metal_assembly)
		to_chat(user, "You remove the metal blade from \the [src].")
		new /obj/item/weapon/wrench_wired(get_turf(src.loc))
		new /obj/item/weapon/metal_blade(get_turf(src.loc))
		qdel(src)
	else
		to_chat(user, "You unwrap the cable cuffs from around \the [src].")
		new /obj/item/weapon/wrench(get_turf(src.loc))
		new /obj/item/weapon/handcuffs/cable(get_turf(src.loc))
		qdel(src)

/obj/item/weapon/wrench_wired/attackby(obj/item/weapon/W, mob/user)
	..()
	if(metal_assembly)
		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(0, user))
				to_chat(user, "You begin welding the blade to \the [src].")
				playsound(user, 'sound/items/Welder.ogg', 50, 1)
				if(do_after(user, src, 30))
					to_chat(user, "You weld the blade to \the [src].")
					if(src.loc == user)
						user.drop_item(src, force_drop = 1)
						var/obj/item/weapon/hatchet/tomahawk/metal/I = new (get_turf(user))
						user.put_in_hands(I)
					else
						new /obj/item/weapon/hatchet/tomahawk/metal(get_turf(src.loc))
					qdel(src)
			else
				to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
				return
	else if(istype(W, /obj/item/weapon/shard))
		to_chat(user, "You fasten \the [W] to \the [src].")
		if(src.loc == user)
			user.drop_item(src, force_drop = 1)
			var/obj/item/weapon/hatchet/tomahawk/I = new (get_turf(user))
			user.put_in_hands(I)
		else
			new /obj/item/weapon/hatchet/tomahawk(get_turf(src.loc))
		qdel(src)
		qdel(W)
	if(istype(W, /obj/item/weapon/metal_blade))
		to_chat(user, "You loosely fasten \the [W] to \the [src].")
		metal_assembly = 1
		update_wired_wrench_assembly()
		qdel(W)
//TOMAHAWK END/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//CANNON BEGIN/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly
	name = "wheelchair assembly"
	desc = "A wheelchair with an unsecured barrel on it."
	icon = 'icons/obj/weaponsmithing.dmi'
	icon_state = "wheelchair_assembly"
	var/cannon_assembly = 0

/obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/proc/update_wheelchair_assembly()
	if(cannon_assembly)
		name = "cannon assembly"
		desc = "A makeshift cannon, created by welding a barrel onto a wheelchair. It lacks an ignition source."
		icon_state = "cannon_assembly"
	else
		name = "wheelchair assembly"
		desc = "A wheelchair with an unsecured barrel on it."
		icon_state = "wheelchair_assembly"

/obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/buckle_mob(mob/M as mob, mob/user as mob)
	return	//This isn't actually a vehicle, it's just the child of one.

/obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/attack_hand()
	if(cannon_assembly)
		return
	to_chat(usr, "You remove the barrel from \the [src].")
	var/obj/item/weapon/gun_barrel/I = new (get_turf(usr))
	usr.put_in_hands(I)
	var/obj/structure/bed/chair/vehicle/wheelchair/Q = new (get_turf(src.loc))
	Q.dir = dir
	qdel(src)

/obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/attackby(obj/item/weapon/W, mob/user)
	if(cannon_assembly)
		if(istype(W, /obj/item/device/assembly/igniter))
			to_chat(user, "You attach \the [W] to \the [src].")
			var/obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/cannon/I = new (get_turf(src.loc))
			I.dir = dir
			qdel(src)
			qdel(W)
	else if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			to_chat(user, "You begin welding the barrel onto \the [src].")
			playsound(user, 'sound/items/Welder.ogg', 50, 1)
			if(do_after(user, src, 80))
				to_chat(user, "You weld the barrel onto \the [src].")
				cannon_assembly = 1
				update_wheelchair_assembly()
		else
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return
//CANNON END///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/power/secured_capacitor
	name = "capacitor"
	desc = "A basic capacitor used in the construction of a variety of devices."
	icon = 'icons/obj/weaponsmithing.dmi'
	icon_state = "secured_capacitor"
	density = 0
	state = 1
	var/charge = 0
	var/charging = 0
	var/list/power_states = list()
	var/maxcharge = 30000000
	var/fully_charged = 0

/obj/machinery/power/secured_capacitor/New()
	..()
	power_machines.Remove(src)

/obj/machinery/power/secured_capacitor/adv
	name = "advanced capacitor"
	icon_state = "secured_capacitor_adv"
	maxcharge = 200000000

/obj/machinery/power/secured_capacitor/adv/super
	name = "super capacitor"
	icon_state = "secured_capacitor_adv_super"
	maxcharge = 1000000000

/obj/machinery/power/secured_capacitor/attack_hand(mob/user as mob)
	if(!charging)
		attempt_connect(user)
	else
		disconnect_capacitor()
		to_chat(user, "<span class='notice'>You halt \the [src.name]'s charging process.</span>")

/obj/machinery/power/secured_capacitor/examine(mob/user)
	..()
	if(charge)
		to_chat(user, "<span class='notice'>\The [src.name] is charged to [charge]W.</span>")
		if(charge == maxcharge)
			to_chat(user, "<span class='info'>\The [src.name] has maximum charge!</span>")
		else if(power_states.len >= 10)
			to_chat(user, "<span class='info'>\The [src.name] is full.</span>")
	else
		to_chat(user, "<span class='notice'>\The [src.name] is uncharged.</span>")

/obj/machinery/power/secured_capacitor/attackby(obj/item/weapon/W, mob/user)
	if(iswrench(W))
		if(charging)
			to_chat(user, "<span class='warning'>\The [src.name] needs to be turned off first.</span>")
			return
		to_chat(user, "You unsecure \the [src.name] from the floor.")
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		power_machines.Remove(src)
		switch(name)
			if("capacitor")
				var/obj/item/weapon/stock_parts/capacitor/I = new (get_turf(src.loc))
				I.stored_charge = charge
				I.maximum_charge = maxcharge
			if("advanced capacitor")
				var/obj/item/weapon/stock_parts/capacitor/adv/I = new (get_turf(src.loc))
				I.stored_charge = charge
				I.maximum_charge = maxcharge
			if("super capacitor")
				var/obj/item/weapon/stock_parts/capacitor/adv/super/I = new (get_turf(src.loc))
				I.stored_charge = charge
				I.maximum_charge = maxcharge
		qdel(src)

/obj/machinery/power/secured_capacitor/verb/flush_charge()
	set name = "Discharge capacitor"
	set category = "Object"
	set src in range(1)

	if(usr.isUnconscious())
		to_chat(usr, "You can't do that while unconscious.")
		return

	charge = 0
	power_states.len = 0
	to_chat(usr, "<span class='notice'>You discharge \the [src.name]'s stored energy.</span>")

/obj/machinery/power/secured_capacitor/proc/attempt_connect(mob/user)
	if(connect_to_network())
		if(fully_charged)
			to_chat(user, "<span class='notice'>\The [src.name] is full.</span>")
			disconnect_capacitor()
			return
		if(avail() > 0)
			power_machines.Add(src)
			charging = 1
			src.visible_message("<span class='notice'>\The [src.name] hums quietly.</span>")
			return 1
		else
			src.visible_message("<span class='warning'>\The [src.name] buzzes. There doesn't seem to be any power in the wire.</span>","<span class='warning'>You hear a buzz.</span>")
			disconnect_capacitor()
			return 0
	else
		src.visible_message("<span class='warning'>\The [src.name] buzzes. It won't charge if it's not secured to a wire knot.</span>","<span class='warning'>You hear a buzz.</span>")
		disconnect_capacitor()
		return 0

/obj/machinery/power/secured_capacitor/process()
	if(avail() <= 0)
		power_machines.Remove(src)
		charging = 0
		return attempt_connect()

	if(power_states.len < 10)
		power_states += avail()

	var/total = 0
	for(var/i = 1; i <= power_states.len; i++)
		total += power_states[i]

	charge = round((total/power_states.len) * (power_states.len/10))
	if(charge > maxcharge)
		charge = maxcharge
		fully_charged = 1

	if(power_states.len >= 10)
		fully_charged = 1

	if(fully_charged)
		disconnect_capacitor()

/obj/machinery/power/secured_capacitor/proc/disconnect_capacitor()
	power_machines.Remove(src)
	disconnect_from_network()
	charging = 0
	if(fully_charged)
		alert_noise("ping")

