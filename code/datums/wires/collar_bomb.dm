/datum/wires/collar_bomb
	proper_name = "Collar Bomb"
	randomize = TRUE // Only one wire, no need for blueprints
	holder_type = /obj/item/clothing/neck/collar_bomb
	wires = list(WIRE_ACTIVATE)

/datum/wires/collar_bomb/interactable(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_NECK) == holder)
		return FALSE

/datum/wires/collar_bomb/on_pulse(wire, mob/user)
	var/obj/item/clothing/neck/collar_bomb/collar = holder
	if(collar.active)
		return ..()
	collar.explosive_countdown(ticks_left = 5)
	if(!ishuman(collar.loc))
		return ..()
	var/mob/living/carbon/human/brian = collar.loc
	if(brian.get_item_by_slot(ITEM_SLOT_NECK) != collar)
		return ..()
	var/mob/living/triggerer = user
	var/obj/item/assembly/assembly
	if(isnull(triggerer))
		assembly = assemblies[colors[1]]
		if(assembly)
			triggerer = get_mob_by_key(assembly.fingerprintslast)
	brian.investigate_log("has had their [collar] triggered [triggerer ? "by [user || assembly][assembly ? " last touched by triggerer" : ""]" : ""].", INVESTIGATE_DEATHS)
	return ..()

///I'd rather not get people killed by EMP here.
/datum/wires/collar_bomb/emp_pulse()
	return
