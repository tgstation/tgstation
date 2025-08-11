/datum/component/boris_circuit_container
	dupe_mode = COMPONENT_DUPE_SOURCES
	var/list/obj/item/circuit_component/mmi/mmi_components
	var/datum/weakref/indicator_weakref

/datum/component/boris_circuit_container/Initialize()
	. = ..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/boris_circuit_container/Destroy(force)
	mmi_components = null
	return ..()

/datum/component/boris_circuit_container/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_AI, PROC_REF(on_ai_click))
	var/atom/parent_atom = parent
	var/image/indicator_image = image('icons/mob/huds/hud.dmi', parent_atom, "hudtracking", pixel_x = 8)
	SET_PLANE_EXPLICIT(indicator_image, ABOVE_LIGHTING_PLANE, parent_atom)
	indicator_weakref = WEAKREF(parent_atom.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/ais,
		"boris_circuit_container_[REF(src)]",
		indicator_image,
		NONE
	))

/datum/component/boris_circuit_container/UnregisterFromParent()
	QDEL_NULL(indicator_weakref)
	return ..()

/datum/component/boris_circuit_container/on_source_add(source)
	. = ..()
	var/obj/item/circuit_component/mmi/source_comp = locate(source)
	if(!istype(source_comp))
		return COMPONENT_INCOMPATIBLE
	LAZYADD(mmi_components, source)

/datum/component/boris_circuit_container/on_source_remove(source)
	var/obj/item/circuit_component/mmi/source_comp = locate(source)
	if(source_comp)
		LAZYREMOVE(mmi_components, source_comp)
	return ..()

/datum/component/boris_circuit_container/proc/on_ai_click(atom/movable/source, mob/user)
	SIGNAL_HANDLER
	if(!length(mmi_components))
		return
	if(HAS_TRAIT(user, TRAIT_CONNECTED_TO_CIRCUIT))
		return
	if(length(mmi_components) == 1)
		var/obj/item/circuit_component/mmi/mmi_comp = mmi_components[1]
		if(mmi_comp.parent.shell == source)
			INVOKE_ASYNC(mmi_comp, TYPE_PROC_REF(/obj/item/circuit_component/mmi, confirm_ai_connect), user, source)
			return COMPONENT_CANCEL_ATTACK_CHAIN
	INVOKE_ASYNC(src, PROC_REF(select_circuit), source, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/boris_circuit_container/proc/select_circuit(atom/movable/source, mob/user)
	var/list/choices = list()
	var/list/choice_map = list()
	var/source_in_choices = FALSE
	for(var/obj/item/circuit_component/mmi/mmi_component as anything in mmi_components)
		if(mmi_component.occupant)
			continue
		var/atom/movable/shell = mmi_component.parent.shell
		choices[shell] = shell
		choice_map[shell] = mmi_component
		if(shell == source)
			source_in_choices = TRUE
	if(!source_in_choices)
		choices[source] = source
	var/atom/movable/choice = show_radial_menu(user, source, choices, user_space = TRUE)
	if(QDELETED(choice) || QDELETED(user) || !user.can_interact_with(choice))
		return
	if(choice == source && !source_in_choices)
		choice.attack_ai(user)
		return
	var/obj/item/circuit_component/mmi/choice_comp = choice_map[choice]
	if(QDELETED(choice_comp) || choice_comp.parent?.shell != choice || !choice_comp.boris)
		return
	choice_comp.do_ai_connect(user, choice)
