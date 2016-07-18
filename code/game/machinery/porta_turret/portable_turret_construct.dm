#define PTURRET_UNSECURED  0
#define PTURRET_BOLTED  1
#define PTURRET_START_INTERNAL_ARMOUR  2
#define PTURRET_INTERNAL_ARMOUR_ON  3
#define PTURRET_GUN_EQUIPPED  4
#define PTURRET_SENSORS_ON  5
#define PTURRET_CLOSED  6
#define PTURRET_START_EXTERNAL_ARMOUR  7
#define PTURRET_EXTERNAL_ARMOUR_ON  8
/obj/machinery/porta_turret_construct
	name = "turret frame"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turret_frame"
	density = 1
	var/build_step = PTURRET_UNSECURED //the current step in the building process
	var/finish_name = "turret"	//the name applied to the product turret
	var/installation = null		//the gun type installed
	var/gun_charge = 0			//the gun charge of the gun type installed


/obj/machinery/porta_turret_construct/attackby(obj/item/I, mob/user, params)
	//this is a bit unwieldy but self-explanatory
	switch(build_step)
		if(PTURRET_UNSECURED)	//first step
			if(istype(I, /obj/item/weapon/wrench) && !anchored)
				playsound(loc, 'sound/items/Ratchet.ogg', 100, 1)
				user << "<span class='notice'>You secure the external bolts.</span>"
				anchored = 1
				build_step = PTURRET_BOLTED
				return

			else if(istype(I, /obj/item/weapon/crowbar) && !anchored)
				playsound(loc, 'sound/items/Crowbar.ogg', 75, 1)
				user << "<span class='notice'>You dismantle the turret construction.</span>"
				new /obj/item/stack/sheet/metal( loc, 5)
				qdel(src)
				return

		if(PTURRET_BOLTED)
			if(istype(I, /obj/item/stack/sheet/metal))
				var/obj/item/stack/sheet/metal/M = I
				if(M.use(2))
					user << "<span class='notice'>You add some metal armor to the interior frame.</span>"
					build_step = PTURRET_START_INTERNAL_ARMOUR
					icon_state = "turret_frame2"
				else
					user << "<span class='warning'>You need two sheets of metal to continue construction!</span>"
				return

			else if(istype(I, /obj/item/weapon/wrench))
				playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
				user << "<span class='notice'>You unfasten the external bolts.</span>"
				anchored = 0
				build_step = PTURRET_UNSECURED
				return


		if(PTURRET_START_INTERNAL_ARMOUR)
			if(istype(I, /obj/item/weapon/wrench))
				playsound(loc, 'sound/items/Ratchet.ogg', 100, 1)
				user << "<span class='notice'>You bolt the metal armor into place.</span>"
				build_step = PTURRET_INTERNAL_ARMOUR_ON
				return

			else if(istype(I, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = I
				if(!WT.isOn())
					return
				if(WT.get_fuel() < 5) //uses up 5 fuel.
					user << "<span class='warning'>You need more fuel to complete this task!</span>"
					return

				playsound(loc, pick('sound/items/Welder.ogg', 'sound/items/Welder2.ogg'), 50, 1)
				user << "<span class='notice'>You start to remove the turret's interior metal armor...</span>"
				if(do_after(user, 20/I.toolspeed, target = src))
					if(!WT.isOn() || !WT.remove_fuel(5, user))
						return
					build_step = PTURRET_BOLTED
					user << "<span class='notice'>You remove the turret's interior metal armor.</span>"
					new /obj/item/stack/sheet/metal( loc, 2)
					return


		if(PTURRET_INTERNAL_ARMOUR_ON)
			if(istype(I, /obj/item/weapon/gun/energy)) //the gun installation part
				var/obj/item/weapon/gun/energy/E = I
				if(!user.drop_item())
					return
				installation = I.type
				gun_charge = E.power_supply.charge //the gun's charge is stored in gun_charge
				user << "<span class='notice'>You add [I] to the turret.</span>"
				build_step = PTURRET_GUN_EQUIPPED
				qdel(I)
				return

			else if(istype(I, /obj/item/weapon/wrench))
				playsound(loc, 'sound/items/Ratchet.ogg', 100, 1)
				user << "<span class='notice'>You remove the turret's metal armor bolts.</span>"
				build_step = PTURRET_START_INTERNAL_ARMOUR
				return

		if(PTURRET_GUN_EQUIPPED)
			if(isprox(I))
				build_step = PTURRET_SENSORS_ON
				if(!user.drop_item())
					return
				user << "<span class='notice'>You add the proximity sensor to the turret.</span>"
				qdel(I)
				return


		if(PTURRET_SENSORS_ON)
			if(istype(I, /obj/item/weapon/screwdriver))
				playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
				build_step = PTURRET_CLOSED
				user << "<span class='notice'>You close the internal access hatch.</span>"
				return


		if(PTURRET_CLOSED)
			if(istype(I, /obj/item/stack/sheet/metal))
				var/obj/item/stack/sheet/metal/M = I
				if(M.use(2))
					user << "<span class='notice'>You add some metal armor to the exterior frame.</span>"
					build_step = PTURRET_START_EXTERNAL_ARMOUR
				else
					user << "<span class='warning'>You need two sheets of metal to continue construction!</span>"
				return

			else if(istype(I, /obj/item/weapon/screwdriver))
				playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
				build_step = PTURRET_SENSORS_ON
				user << "<span class='notice'>You open the internal access hatch.</span>"
				return

		if(PTURRET_START_EXTERNAL_ARMOUR)
			if(istype(I, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = I
				if(!WT.isOn())
					return
				if(WT.get_fuel() < 5)
					user << "<span class='warning'>You need more fuel to complete this task!</span>"

				playsound(loc, pick('sound/items/Welder.ogg', 'sound/items/Welder2.ogg'), 50, 1)
				user << "<span class='notice'>You begin to weld the turret's armor down...</span>"
				if(do_after(user, 30/I.toolspeed, target = src))
					if(!WT.isOn() || !WT.remove_fuel(5, user))
						return
					build_step = PTURRET_EXTERNAL_ARMOUR_ON
					user << "<span class='notice'>You weld the turret's armor down.</span>"

					//The final step: create a full turret
					var/obj/machinery/porta_turret/turret = new/obj/machinery/porta_turret(loc)
					turret.name = finish_name
					turret.installation = installation
					turret.gun_charge = gun_charge
					turret.setup()

					qdel(src)

			else if(istype(I, /obj/item/weapon/crowbar))
				playsound(loc, 'sound/items/Crowbar.ogg', 75, 1)
				user << "<span class='notice'>You pry off the turret's exterior armor.</span>"
				new /obj/item/stack/sheet/metal(loc, 2)
				build_step = PTURRET_CLOSED
				return

	if(istype(I, /obj/item/weapon/pen))	//you can rename turrets like bots!
		var/t = stripped_input(user, "Enter new turret name", name, finish_name)
		if(!t)
			return
		if(!Adjacent(user))
			return

		finish_name = t
		return
	return ..()


/obj/machinery/porta_turret_construct/attack_hand(mob/user)
	switch(build_step)
		if(PTURRET_GUN_EQUIPPED)
			build_step = PTURRET_INTERNAL_ARMOUR_ON

			var/obj/item/weapon/gun/energy/Gun = new installation(loc)
			Gun.power_supply.charge = gun_charge
			Gun.update_icon()
			installation = null
			gun_charge = 0
			user << "<span class='notice'>You remove [Gun] from the turret frame.</span>"

		if(PTURRET_SENSORS_ON)
			user << "<span class='notice'>You remove the prox sensor from the turret frame.</span>"
			new /obj/item/device/assembly/prox_sensor(loc)
			build_step = PTURRET_GUN_EQUIPPED

/obj/machinery/porta_turret_construct/attack_ai()
	return
