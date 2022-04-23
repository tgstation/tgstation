/obj/machinery/computer/cargo/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/armament/cargo_gun, subtypesof(/datum/armament_entry/cargo_gun), 0)
