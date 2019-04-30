// Hose

/obj/item/mecha_parts/mecha_equipment/botanic

/obj/item/mecha_parts/mecha_equipment/botanic/can_attach(obj/mecha/working/tree/M)
	if(..() && istype(M))
		return 1

/obj/item/mecha_parts/mecha_equipment/botanic/hose
	name = "Giant Hose"
	desc = "Used for watering plants, the mechanics of this tool allow for the perfect amount of water to be dispensed on the plant to fully hydrate it."
	icon_state = "mecha_exting"

/obj/item/mecha_parts/mecha_equipment/botanic/hose/action(atom/target)
	if(!action_checks(target) || get_dist(chassis, target)>3)
		return FALSE
	if(istype(target, /obj/structure/reagent_dispensers/watertank) && get_dist(chassis,target) <= 1)
		occupant_message("<span class='warning'>Use the internal menu to siphon the water instead!</span>")
		return FALSE
	if(!chassis.reagents.total_volume > 0)
		occupant_message("<span class='warning'>You are out of water!</span>")
		return FALSE
	if(istype(target, /obj/machinery/hydroponics) && get_dist(chassis,target) <= 1)
		var/obj/machinery/hydroponics/H = target
		playsound(chassis, 'sound/effects/extinguish.ogg', 75, 1, -3)
		occupant_message("<span class='warning'>You hose down [H].</span>")
		chassis.reagents.trans_to(target, H.maxwater - H.waterlevel)
	//else
	//extinguisher is gone for the moment, there were some abominations in it. see working_tools.dm
	if(!chassis.reagents.total_volume)
		occupant_message("<span class='warning'>You are out of water!</span>")

/obj/item/mecha_parts/mecha_equipment/botanic/cultivator
	name = "Touch of Gaia"
	desc = "A very useful multipurpose tool that allows the user to remove weeds and turn them into an improved fertilizer."
	icon_state = "mecha_exting"
	var/cultivating = TRUE

/obj/item/mecha_parts/mecha_equipment/botanic/cultivator/Initialize()
	. = ..()
	create_reagents(100)
	update_icon()

/obj/item/mecha_parts/mecha_equipment/botanic/cultivator/action(atom/target)
	var/obj/machinery/hydroponics/H = target
	if(!(istype(H) && get_dist(chassis,H) <= 1))
		return 0
	if(cultivating)
		if(!H.weedlevel > 0)
			occupant_message("<span class='warning'>This plot is completely devoid of weeds! It doesn't need uprooting.</span>")
			return 0
		reagents.add_reagent("water", H.weedlevel*2)
		chassis.visible_message("[chassis] uproots the weeds.")
		occupant_message("<span class='notice'>Created [H.weedlevel*2] units of fertilizer!</span>")
		H.weedlevel = 0
		update_icon()
	else
		if(!reagents.total_volume)
			occupant_message("<span class='warning'>You are out of fertilizer! Uproot some weeds first!</span>")
			return 0
