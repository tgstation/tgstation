
//departmental signs

/obj/structure/sign/departments
	icon = 'icons/obj/structures/departmental_signs.dmi'
	is_editable = TRUE
	var/emissive_type

/obj/structure/sign/departments/update_overlays()
	. = ..()
	if (emissive_type)
		. += emissive_appearance(icon, emissive_type, src)

///////MEDBAY

/obj/structure/sign/departments/med
	name = "\improper Medbay sign"
	sign_change_name = "Department - Medbay"
	desc = "A sign labelling an area of the medical department."
	icon_state = "med"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/med)

/obj/structure/sign/departments/med_alt
	name = "\improper Medbay sign"
	sign_change_name = "Department - Medbay Alt"
	icon_state = "medbay"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/med_alt)

/obj/structure/sign/departments/medbay
	name = "\improper Medbay sign"
	sign_change_name = "Generic Medical"
	desc = "The intergalactic symbol of medical institutions. You'll probably get help here."
	icon_state = "bluecross"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/medbay)

/obj/structure/sign/departments/medbay/alt
	name = "\improper Medbay sign"
	sign_change_name = "Generic Medical Alt"
	icon_state = "department_med"
	emissive_type = "department_e"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/medbay/alt)

/obj/structure/sign/departments/exam_room
	name = "\improper Exam Room sign"
	sign_change_name = "Department - Medbay: Exam Room"
	desc = "A guidance sign which reads 'Exam Room'."
	icon_state = "examroom"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/exam_room)

/obj/structure/sign/departments/chemistry
	name = "\improper Chemistry sign"
	sign_change_name = "Department - Medbay: Chemistry"
	desc = "A sign labelling an area containing chemical equipment."
	icon_state = "department_chem"
	emissive_type = "department_e"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/chemistry)

/obj/structure/sign/departments/chemistry/alt
	sign_change_name = "Department - Medbay: Chemistry Alt"
	icon_state = "chemistry2"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/chemistry/alt)

/obj/structure/sign/departments/chemistry/pharmacy
	name = "\improper Pharmacy sign"
	sign_change_name = "Department - Medbay: Pharmacy"
	desc = "A sign labelling an area containing pharmacy equipment."
	icon_state = "department_chem"
	emissive_type = "department_e"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/chemistry/pharmacy)

/obj/structure/sign/departments/psychology
	name = "\improper Psychology sign"
	sign_change_name = "Department - Medbay: Psychology"
	desc = "A sign labelling an area where the Psychologist works, they can probably help you get your head straight."
	icon_state = "department_psych"
	emissive_type = "department_e"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/psychology)

/obj/structure/sign/departments/virology
	name = "\improper Virology sign"
	sign_change_name = "Department - Medbay: Virology"
	desc = "A sign labelling an area where the virologist's laboratory is located."
	icon_state = "pharmacy"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/virology)

/obj/structure/sign/departments/morgue
	name = "\improper Morgue sign"
	sign_change_name = "Department - Medbay: Morgue"
	desc = "A sign labelling an area where the station stores its ever-piling bodies."
	icon_state = "morgue"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/morgue)

///////ENGINEERING

/obj/structure/sign/departments/engineering
	name = "\improper Engineering sign"
	sign_change_name = "Department - Engineering"
	desc = "A sign labelling an area where engineers work."
	icon_state = "department_engi"
	emissive_type = "department_e"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/engineering)

///////SCIENCE

/obj/structure/sign/departments/science
	name = "\improper Science sign"
	sign_change_name = "Department - Science"
	desc = "A sign labelling an area where research and science is performed."
	icon_state = "department_sci"
	emissive_type = "department_e"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/science)

/obj/structure/sign/departments/science/alt
	sign_change_name = "Department - Science Alt"
	icon_state = "science2"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/science/alt)


/obj/structure/sign/departments/xenobio
	name = "\improper Xenobiology sign"
	sign_change_name = "Department - Science: Xenobiology"
	desc = "A sign labelling an area where xenobiological entities are researched."
	icon_state = "department_xeno"
	emissive_type = "department_e"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/xenobio)

// Wallening todo: we need a new sprite for this
/obj/structure/sign/departments/xenobio/alt
	sign_change_name = "Department - Science: Xenobiology Alt"
	icon_state = "xenobio2"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/xenobio/alt)

// Wallening todo: new sprite for htis, clear it out of signs.dmi
/obj/structure/sign/departments/genetics
	name = "\improper Genetics sign"
	sign_change_name = "Department - Science: Genetics"
	desc = "A sign labelling an area where the field of genetics is researched."
	icon_state = "gene"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/genetics)
/obj/structure/sign/departments/rndserver
	name ="\improper R&D Server sign"
	sign_change_name = "Department - Science: R&D Server"
	desc = "A sign labelling an area where scientific data is stored."
	icon_state = "rndserver"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/rndserver)

///////SERVICE

/obj/structure/sign/departments/botany
	name = "\improper Botany sign"
	sign_change_name = "Department - Botany (Flower)"
	desc = "A sign labelling an area as a place where plants are grown."
	icon_state = "department_hydro"
	emissive_type = "department_e"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/botany)

/obj/structure/sign/departments/botany/alt1
	sign_change_name = "Department - Botany (Tray)"
	icon_state = "hydro2"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/botany/alt1)

/obj/structure/sign/departments/botany/alt2
	sign_change_name = "Department - Botany (Watering Can)"
	icon_state = "hydro3"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/botany/alt2)

/obj/structure/sign/departments/botany/botany/alt3
	sign_change_name = "Department - Botany (Tray) Alt"
	icon_state = "botany"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/botany/alt3)

/obj/structure/sign/departments/custodian
	name = "\improper Janitor sign"
	sign_change_name = "Department - Janitor"
	desc = "A sign labelling an area where the janitor works."
	icon_state = "custodian"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/custodian)

/obj/structure/sign/departments/holy
	name = "\improper Chapel sign"
	sign_change_name = "Department - Chapel"
	desc = "A sign labelling a religious area."
	icon_state = "department_chapel"
	emissive_type = "department_e"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/holy)

/obj/structure/sign/departments/holy_alt
	name = "\improper Chapel sign"
	sign_change_name = "Department - Chapel"
	desc = "A sign labelling a religious area."
	icon_state = "chapel"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/holy)

/obj/structure/sign/departments/lawyer
	name = "\improper Legal Department sign"
	sign_change_name = "Department - Legal"
	desc = "A sign labelling an area where the Lawyers work, apply here for arrivals shuttle whiplash settlement."
	icon_state = "department_lawyer"
	emissive_type = "department_e"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/lawyer)

///////SUPPLY

/obj/structure/sign/departments/cargo
	name = "\improper Cargo sign"
	sign_change_name = "Department - Cargo"
	desc = "A sign labelling an area where cargo ships dock."
	icon_state = "department_cargo"
	emissive_type = "department_e"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/cargo)

/obj/structure/sign/departments/exodrone
	name = "\improper Exodrone sign"
	sign_change_name = "Department - Cargo: exodrone"
	desc = "A sign labelling an area where exodrones are used."
	icon_state = "exodrone"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/exodrone)

///////SECURITY

/obj/structure/sign/departments/security
	name = "\improper Security sign"
	sign_change_name = "Department - Security"
	desc = "A sign labelling an area where the law is law."
	icon_state = "department_sec"
	emissive_type = "department_e"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/security)

////MISC LOCATIONS

/obj/structure/sign/departments/restroom
	name = "\improper Restroom sign"
	sign_change_name = "Location - Restroom"
	desc = "A sign labelling a restroom."
	icon_state = "department_wc"
	emissive_type = "department_e"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/restroom)

/obj/structure/sign/departments/maint
	name = "\improper Maintenance Tunnel sign"
	sign_change_name = "Location - Maintenance"
	desc = "A sign labelling an area where the departments of the station are linked together."
	icon_state = "mait1"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/maint)

/obj/structure/sign/departments/maint/alt
	name = "\improper Maintenance Tunnel sign"
	sign_change_name = "Location - Maintenance Alt"
	desc = "A sign labelling an area where the departments of the station are linked together."
	icon_state = "mait2"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/maint/alt)

/obj/structure/sign/departments/evac
	name = "\improper Evacuation sign"
	sign_change_name = "Location - Evacuation"
	desc = "A sign labelling an area where evacuation procedures take place."
	icon_state = "department_evac"
	emissive_type = "department_evac_e"
	is_editable = TRUE
	///This var detemines which arrow overlay to use.
	var/arrow_direction_state = "evac_overlay_f"

/obj/structure/sign/departments/evac/Initialize(mapload)
	. = ..()
	add_overlay(arrow_direction_state)

/obj/structure/sign/departments/evac/fore
	arrow_direction_state = "evac_overlay_f"

/obj/structure/sign/departments/evac/aft
	arrow_direction_state = "evac_overlay_a"

/obj/structure/sign/departments/evac/starboard
	arrow_direction_state = "evac_overlay_s"

/obj/structure/sign/departments/evac/port
	arrow_direction_state = "evac_overlay_p"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/evac/fore)
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/evac/aft)
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/evac/starboard)
WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/evac/port)

/obj/structure/sign/departments/drop
	name = "\improper Drop Pods sign"
	sign_change_name = "Location - Drop Pods"
	desc = "A sign labelling an area where drop pod loading procedures take place."
	icon_state = "drop"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/drop)

/obj/structure/sign/departments/court
	name = "\improper Courtroom sign"
	sign_change_name = "Location - Courtroom"
	desc = "A sign labelling the courtroom, where the ever sacred Space Law is upheld."
	icon_state = "department_law"
	emissive_type = "department_e"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/court)

// Wallening todo: here down, too
/obj/structure/sign/departments/telecomms
	name = "\improper Telecommunications sign"
	sign_change_name = "Location - Telecommunications"
	desc = "A sign labelling an area where the station's radio and NTnet servers are stored."
	icon_state = "telecomms"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/telecomms)

/obj/structure/sign/departments/telecomms/alt
	icon_state = "telecomms2"
	sign_change_name = "Location - Telecommunications Alt"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/telecomms/alt)

/obj/structure/sign/departments/aiupload
	name = "\improper AI Upload sign"
	sign_change_name = "Location - AI Upload"
	desc = "A sign labelling an area where laws are uploaded to the station's AI and cyborgs."
	icon_state = "aiupload"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/aiupload)

/obj/structure/sign/departments/aisat
	name = "\improper AI Satellite sign"
	sign_change_name = "Location - AI Satellite"
	desc = "A sign labelling the AI's heavily-fortified satellite."
	icon_state = "aisat"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/aisat)

/obj/structure/sign/departments/vault
	name = "\improper Vault sign"
	sign_change_name = "Location - Vault"
	desc = "A sign labelling a saferoom where the station's resources and self-destruct are secured."
	icon_state = "vault"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/vault)
