/datum/wires/airlock
	proper_name = "Generic Airlock"
	var/wiretype

/datum/wires/airlock/command
	proper_name = "Command Airlock"
	wiretype = "commandairlock"

/datum/wires/airlock/security
	proper_name = "Security Airlock"
	wiretype = "securityairlock"

/datum/wires/airlock/engineering
	proper_name = "Engineering Airlock"
	wiretype = "engineeringairlock"

/datum/wires/airlock/science
	proper_name = "Science Airlock"
	wiretype = "scienceairlock"

/datum/wires/airlock/medical
	proper_name = "Medical Airlock"
	wiretype = "medicalairlock"

/datum/wires/airlock/cargo
	proper_name = "Cargo Airlock"
	wiretype = "cargoairlock"

/datum/wires/airlock/New(atom/holder)
	. = ..()
	if(randomize)
		return
	if(wiretype)
		if(!GLOB.wire_color_directory[wiretype])
			colors = list()
			randomize()
			GLOB.wire_color_directory[wiretype] = colors
			GLOB.wire_name_directory[wiretype] = proper_name
		else
			colors = GLOB.wire_color_directory[wiretype]
