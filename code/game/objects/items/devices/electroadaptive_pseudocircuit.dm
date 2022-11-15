//Used by engineering cyborgs in place of generic circuits.
/obj/item/electroadaptive_pseudocircuit
	name = "electroadaptive pseudocircuit"
	desc = "An all-in-one circuit imprinter, designer, synthesizer, outfitter, creator, and chef. It can be used in place of any generic circuit board during construction."
	icon = 'icons/obj/module.dmi'
	icon_state = "boris"
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron = 50, /datum/material/glass = 300)
	var/circuits = 5 //How many circuits the pseudocircuit has left
	var/static/recycleable_circuits = typecacheof(list(
		/obj/item/electronics/firelock,
		/obj/item/electronics/airalarm,
		/obj/item/electronics/firealarm,
		/obj/item/electronics/apc,
		/obj/item/electronics/airlock,
	)) //A typecache of circuits consumable for material
	var/obj/item/electronics/airlock/airlock_electronics //An internal set of airlock electronics used for copying access over to newly created ones

/obj/item/electroadaptive_pseudocircuit/Initialize(mapload)
	. = ..()
	maptext = MAPTEXT(circuits)
	add_item_action(/datum/action/item_action/pseudocircuit_access)
	airlock_electronics = new(src)
	airlock_electronics.name = "Access Control"
	airlock_electronics.holder = src

/obj/item/electroadaptive_pseudocircuit/Destroy()
	. = ..()
	QDEL_NULL(airlock_electronics)

/obj/item/electroadaptive_pseudocircuit/examine(mob/user)
	. = ..()
	if(iscyborg(user))
		. += "[span_notice("It has material for <b>[circuits]</b> circuit[circuits == 1 ? "" : "s"]. Use the pseudocircuit on existing circuits to gain material.")]\n"+\
		"[span_notice("Serves as a substitute for <b>fire/air alarm</b>, <b>firelock</b>, <b>airlock</b>, and <b>APC</b> electronics.")]\n"+\
		span_notice("It can also be used on an APC or light fixture with no power cell to <b>fabricate a low-capacity cell</b> at a high power cost.")

/obj/item/electroadaptive_pseudocircuit/proc/adapt_circuit(mob/living/silicon/robot/R, circuit_cost = 0)
	if(QDELETED(R) || !istype(R))
		return
	if(!R.cell)
		to_chat(R, span_warning("You need a power cell installed for that."))
		return
	if(!R.cell.use(circuit_cost))
		to_chat(R, span_warning("You don't have the energy for that (you need [display_energy(circuit_cost)].)"))
		return
	if(!circuits)
		to_chat(R, span_warning("You need more material. Use [src] on existing simple circuits to break them down."))
		return
	playsound(R, 'sound/items/rped.ogg', 50, TRUE)
	circuits--
	maptext = MAPTEXT(circuits)
	return TRUE //The actual circuit magic itself is done on a per-object basis

/obj/item/electroadaptive_pseudocircuit/afterattack(atom/target, mob/living/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!is_type_in_typecache(target, recycleable_circuits))
		return
	circuits++
	maptext = MAPTEXT(circuits)
	user.visible_message(span_notice("User breaks down [target] with [src]."), \
	span_notice("You recycle [target] into [src]. It now has material for <b>[circuits]</b> circuits."))
	playsound(user, 'sound/items/deconstruct.ogg', 50, TRUE)
	qdel(target)

/obj/item/electroadaptive_pseudocircuit/ui_action_click(mob/user, actiontype)
	airlock_electronics.ui_interact(user)

/datum/action/item_action/pseudocircuit_access
	name = "Change Airlock Access"
	icon_icon = 'icons/hud/radial.dmi'
	button_icon_state = "access"
