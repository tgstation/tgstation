/obj/vehicle/sealed/mecha/working/ripley/firefighter
	desc = "Autonomous Power Loader Unit. This model is the F-type, for firefighter. It's much better!"
	name = "\improper APLU \"Firefighter\""
	icon = 'modular_skyrat/modules/firefighter/icons/firefighter.dmi'
	icon_state = "firefighter"
	base_icon_state = "firefighter"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	lights_power = 7
	armor = list(MELEE = 40, BULLET = 30, LASER = 60, ENERGY = 30, BOMB = 60, BIO = 0, RAD = 70, FIRE = 100, ACID = 100)
	max_integrity = 400
	max_temperature = 80000
	enclosed = TRUE
	wreckage = /obj/structure/mecha_wreckage/ripley/firefighter
	max_occupants = 2 //COME ON FRIEND, LETS GO ON A JOURNEY!

/obj/vehicle/sealed/mecha/working/ripley/firefighter/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_eject)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_internals)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_cycle_equip)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_lights)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_view_stats)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/strafe)

/obj/structure/mecha_wreckage/ripley/firefighter
	name = "\improper Ripley MK-F wreckage"
	icon = 'modular_skyrat/modules/firefighter/icons/firefighter.dmi'
	icon_state = "firefighter-broken"

//Conversion kit

/datum/design/ripleyupgradef
	name = "Ripley MK-I to MK-Firefighter conversion kit"
	id = "ripleyupgradef"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/ripleyupgradef
	materials = list(/datum/material/iron=15000,/datum/material/plasma=10000,/datum/material/silver=10000,/datum/material/gold=5000)
	construction_time = 150
	category = list("Exosuit Equipment")

/obj/item/mecha_parts/mecha_equipment/ripleyupgradef
	name = "Ripley MK-Firefighter Conversion Kit"
	desc = "A specialised firefighter upgrade kit which can upgrade an MK-I ripley to an MK-F ripley which has incredible heat resistance, mining will want this. This kit cannot be removed, once applied."
	icon = 'modular_skyrat/modules/firefighter/icons/firefighter_equipment.dmi'
	icon_state = "ripleyupgradef"
	mech_flags = EXOSUIT_MODULE_RIPLEY

/obj/item/mecha_parts/mecha_equipment/ripleyupgradef/can_attach(obj/vehicle/sealed/mecha/working/ripley/M)
	if(M.type != /obj/vehicle/sealed/mecha/working/ripley)
		to_chat(loc, "<span class='warning'>This conversion kit can only be applied to APLU MK-I models.</span>")
		return FALSE
	if(LAZYLEN(M.cargo))
		to_chat(loc, "<span class='warning'>[M]'s cargo hold must be empty before this conversion kit can be applied.</span>")
		return FALSE
	if(!(M.mecha_flags & ADDING_MAINT_ACCESS_POSSIBLE)) //non-removable upgrade, so lets make sure the pilot or owner has their say.
		to_chat(loc, "<span class='warning'>[M] must have maintenance protocols active in order to allow this conversion kit.</span>")
		return FALSE
	if(LAZYLEN(M.occupants)) //We're actualy making a new mech and swapping things over, it might get weird if players are involved
		to_chat(loc, "<span class='warning'>[M] must be unoccupied before this conversion kit can be applied.</span>")
		return FALSE
	if(!M.cell) //Turns out things break if the cell is missing
		to_chat(loc, "<span class='warning'>The conversion process requires a cell installed.</span>")
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/ripleyupgradef/attach(obj/vehicle/sealed/mecha/markone)
	var/obj/vehicle/sealed/mecha/working/ripley/firefighter/mkf = new (get_turf(markone),1)
	if(!mkf)
		return
	QDEL_NULL(mkf.cell)
	if (markone.cell)
		mkf.cell = markone.cell
		markone.cell.forceMove(mkf)
		markone.cell = null
	QDEL_NULL(mkf.scanmod)
	if (markone.scanmod)
		mkf.scanmod = markone.scanmod
		markone.scanmod.forceMove(mkf)
		markone.scanmod = null
	QDEL_NULL(mkf.capacitor)
	if (markone.capacitor)
		mkf.capacitor = markone.capacitor
		markone.capacitor.forceMove(mkf)
		markone.capacitor = null
	mkf.update_part_values()
	for(var/obj/item/mecha_parts/equipment in markone.contents)
		if(istype(equipment, /obj/item/mecha_parts/concealed_weapon_bay)) //why is the bay not just a variable change who did this
			equipment.forceMove(mkf)
	for(var/obj/item/mecha_parts/mecha_equipment/equipment in markone.equipment) //Move the equipment over...
		equipment.detach(mkf)
		equipment.attach(mkf)
	mkf.dna_lock = markone.dna_lock
	mkf.mecha_flags = markone.mecha_flags
	mkf.strafe = markone.strafe
	mkf.update_integrity(round((markone.get_integrity() / markone.max_integrity) * mkf.get_integrity())) //Integ set to the same percentage integ as the old mecha, rounded to be whole number
	if(markone.name != initial(markone.name))
		mkf.name = markone.name
	markone.wreckage = FALSE
	qdel(markone)
	playsound(get_turf(mkf),'sound/items/ratchet.ogg',50,TRUE)
	return
