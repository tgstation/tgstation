/datum/gizmo_controller
	var/list/interfaces = list(GIZMO_INTERFACE_WIRES = /datum/gizmo_interface)
	var/list/instances = list()

/datum/gizmo_controller/New()
	. = ..()

/datum/gizmo_controller/proc/generate_interfaces(atom/movable/holder)
	for(var/interface_define in interfaces)
		var/interface_type = interfaces[interface_define]

		var/list/callbacks = list()
		var/datum/gizmo_interface/interface_instance = new interface_type (holder)
		interface_instance.generate_interface(holder, callbacks)
		instances += interface_instance

		switch(interface_define)
			if(GIZMO_INTERFACE_WIRES)
				holder.set_wires(new /datum/wires/gizmo(holder, interface_instance.puzzle))
			if(GIZMO_INTERFACE_VOICE)
				holder.AddComponent(/datum/component/gizmo_voice, interface_instance.puzzle)

/datum/gizmo_controller/beyblade
	interfaces = list(GIZMO_INTERFACE_WIRES = /datum/gizmo_interface/beyblade)

/datum/gizmo_controller/toggle
	interfaces = list(GIZMO_INTERFACE_WIRES = /datum/gizmo_interface/toggle)

/datum/gizmo_controller/voice
	interfaces = list(GIZMO_INTERFACE_WIRES = /datum/gizmo_interface/voice_unlock, GIZMO_INTERFACE_VOICE = /datum/gizmo_interface)
