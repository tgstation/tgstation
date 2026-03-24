/// The master datum that handles every bit of gizmo code
/// Just so you will understand the full insanity of this:
/// object > gizmo_controller > gizmo_puzzle + gizmo_interface > gizmode > gizpulse > callbacks

/datum/gizmo_controller
	/// Can hold different interacting modes (wires, voice) and connected interfaces
	var/list/interfaces = list(GIZMO_INTERFACE_WIRES = /datum/gizmo_interface)
	/// Instanted interfaces. really just here so I can check this shit in vv
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

/// Wired with an interface that moves
/datum/gizmo_controller/beyblade
	interfaces = list(GIZMO_INTERFACE_WIRES = /datum/gizmo_interface/beyblade)

/// Wired with an interface that toggles the icon_state and/or glows
/datum/gizmo_controller/toggle
	interfaces = list(GIZMO_INTERFACE_WIRES = /datum/gizmo_interface/toggle)

/// Voice controller with a voice puzzle and interface. Comes with a wire interface that gives you the hint to use the voice interface
/datum/gizmo_controller/voice
	interfaces = list(GIZMO_INTERFACE_WIRES = /datum/gizmo_interface/voice_unlock, GIZMO_INTERFACE_VOICE = /datum/gizmo_interface)

/// For held gizmo's
/datum/gizmo_controller/item
