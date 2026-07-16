/datum/design/integrated_circuit
	name = "Integrated Circuit"
	desc = "The foundation of all circuits. All Circuitry go onto this."
	id = "integrated_circuit"
	build_path = /obj/item/integrated_circuit
	build_type = COMPONENT_PRINTER
	category = list(
		RND_CATEGORY_CIRCUITRY_CORE
	)
	materials = list(/datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/iron =HALF_SHEET_MATERIAL_AMOUNT)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/circuit_multitool
	name = "Circuit Multitool"
	desc = "A circuit multitool to mark entities and load them into."
	id = "circuit_multitool"
	build_path = /obj/item/multitool/circuit
	build_type = COMPONENT_PRINTER
	category = list(
		RND_CATEGORY_CIRCUITRY_CORE
	)
	materials = list(/datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/iron =HALF_SHEET_MATERIAL_AMOUNT)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/usb_cable
	name = "USB Cable"
	desc = "A cable that allows certain shells to connect to nearby computers and machines."
	id = "usb_cable"
	build_path = /obj/item/usb_cable
	build_type = COMPONENT_PRINTER
	category = list(
		RND_CATEGORY_CIRCUITRY_CORE
	)
	// Yes, it would make sense to make them take plastic, but then less people would make them, and I think they're cool
	materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT*2.5)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/component
	name = "Component ( NULL ENTRY )"
	desc = "A component that goes into an integrated circuit."
	build_type = COMPONENT_PRINTER
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE
	category = list(
		RND_CATEGORY_CIRCUITRY_COMPS //Remember to override this when adding new components
	)

/datum/design/component/New()
	. = ..()
	if(build_path)
		var/obj/item/circuit_component/component_path = build_path
		desc = initial(component_path.desc)

/datum/design/component/module
	name = "Module Component"
	id = "comp_module"
	build_path = /obj/item/circuit_component/module
	category = list(
		//This one is just a wrapper to make things a bit tidier so it doesn't belong in any specific subcategory
		RND_CATEGORY_CIRCUITRY_CORE
	)
