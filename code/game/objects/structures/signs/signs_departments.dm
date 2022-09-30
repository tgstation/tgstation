
//departmental signs

/obj/structure/sign/departments
	icon = 'icons/obj/departmental_signs.dmi'
	is_editable = TRUE

///////MEDBAY

/obj/structure/sign/departments/medbay
	name = "\improper Medbay sign"
	sign_change_name = "Department - Medbay"
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here."
	icon_state = "bluecross"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/medbay, 32)

/obj/structure/sign/departments/medbay/alt
	name = "\improper Medbay sign"
	sign_change_name = "Department - Medbay Alt"
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here."
	icon_state = "department_med"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/medbay/alt, 32)

/obj/structure/sign/departments/exam_room
	name = "\improper Exam Room sign"
	sign_change_name = "Department - Medbay: Exam Room"
	desc = "A guidance sign which reads 'Exam Room'."
	icon_state = "examroom"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/exam_room, 32)

/obj/structure/sign/departments/chemistry
	name = "\improper Chemistry sign"
	sign_change_name = "Department - Medbay: Chemistry"
	desc = "A sign labelling an area containing chemical equipment."
	icon_state = "department_chem"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/chemistry, 32)

/obj/structure/sign/departments/chemistry/pharmacy
	name = "\improper Pharmacy sign"
	sign_change_name = "Department - Medbay: Pharmacy"
	desc = "A sign labelling an area containing pharmacy equipment."
	icon_state = "department_chem"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/chemistry/pharmacy, 32)

/obj/structure/sign/departments/psychology
	name = "\improper Psychology sign"
	sign_change_name = "Department - Medbay: Psychology"
	desc = "A sign labelling where the Psychologist works, they can probably help you get your head straight."
	icon_state = "department_psych"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/psychology, 32)

///////ENGINEERING

/obj/structure/sign/departments/engineering
	name = "\improper Engineering sign"
	sign_change_name = "Department - Engineering"
	desc = "A sign labelling an area where engineers work."
	icon_state = "department_engi"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/engineering, 32)

///////SCIENCE

/obj/structure/sign/departments/science
	name = "\improper Science sign"
	sign_change_name = "Department - Science"
	desc = "A sign labelling an area where research and science is performed."
	icon_state = "department_sci"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/science, 32)

/obj/structure/sign/departments/science/alt
	name = "\improper Science sign"
	sign_change_name = "Department - Science Alt"
	desc = "A sign labelling an area where research and science is performed."
	icon_state = "science2"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/science/alt, 32)

/obj/structure/sign/departments/xenobio
	name = "\improper Xenobiology sign"
	sign_change_name = "Department - Science: Xenobiology"
	desc = "A sign labelling an area as a place where xenobiological entities are researched."
	icon_state = "department_xeno"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/xenobio, 32)

// Wallening todo: we need a new sprite for this
/obj/structure/sign/departments/rndserver
	name ="\improper R&D Server sign"
	sign_change_name = "Department - Science: R&D Server"
	desc = "A sign labelling an area where scientific data is stored."
	icon_state = "rndserver"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/rndserver, 32)

///////SERVICE

/obj/structure/sign/departments/botany
	name = "\improper Botany sign"
	sign_change_name = "Department - Botany"
	desc = "A sign labelling an area as a place where plants are grown."
	icon_state = "department_hydro"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/botany, 32)

/obj/structure/sign/departments/custodian
	name = "\improper Janitor sign"
	sign_change_name = "Department - Janitor"
	desc = "A sign labelling an area where the janitor works."
	icon_state = "custodian"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/custodian, 32)

/obj/structure/sign/departments/holy
	name = "\improper Chapel sign"
	sign_change_name = "Department - Chapel"
	desc = "A sign labelling a religious area."
	icon_state = "department_chapel"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/holy, 32)

/obj/structure/sign/departments/lawyer
	name = "\improper Legal Department sign"
	sign_change_name = "Department - Legal"
	desc = "A sign labelling an area where the Lawyers work, apply here for arrivals shuttle whiplash settlement."
	icon_state = "department_lawyer"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/lawyer, 32)

///////SUPPLY

/obj/structure/sign/departments/cargo
	name = "\improper Cargo sign"
	sign_change_name = "Department - Cargo"
	desc = "A sign labelling an area where cargo ships dock."
	icon_state = "department_cargo"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/cargo, 32)
///////SECURITY

/obj/structure/sign/departments/security
	name = "\improper Security sign"
	sign_change_name = "Department - Security"
	desc = "A sign labelling an area where the law is law."
	icon_state = "department_sec"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/security, 32)

////MISC LOCATIONS

/obj/structure/sign/departments/restroom
	name = "\improper Restroom sign"
	sign_change_name = "Location - Restroom"
	desc = "A sign labelling a restroom."
	icon_state = "department_wc"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/restroom, 32)

/obj/structure/sign/departments/maint
	name = "\improper Maintenance Tunnel sign"
	sign_change_name = "Location - Maintenance"
	desc = "A sign labelling an area where the departments of the station are linked together."
	icon_state = "mait1"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/maint, 32)

/obj/structure/sign/departments/maint/alt
	name = "\improper Maintenance Tunnel sign"
	sign_change_name = "Location - Maintenance Alt"
	desc = "A sign labelling an area where the departments of the station are linked together."
	icon_state = "mait2"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/maint/alt, 32)

/obj/structure/sign/departments/evac
	name = "\improper Evacuation sign"
	sign_change_name = "Location - Evacuation"
	desc = "A sign labelling an area where evacuation procedures take place."
	icon_state = "department_evac"
	is_editable = TRUE
	///This var detemines which arrow overlay to use.
	var/arrow_direction_state = "evac_overlay_f"

/obj/structure/sign/departments/evac/Initialize()
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

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/evac/fore, 32)
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/evac/aft, 32)
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/evac/starboard, 32)
INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/evac/port, 32)

/obj/structure/sign/departments/drop
	name = "\improper Drop Pods sign"
	sign_change_name = "Location - Drop Pods"
	desc = "A sign labelling an area where drop pod loading procedures take place."
	icon_state = "drop"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/drop, 32)

/obj/structure/sign/departments/court
	name = "\improper Courtroom sign"
	sign_change_name = "Location - Courtroom"
	desc = "A sign labelling the courtroom, where the ever sacred Space Law is upheld."
	icon_state = "department_law"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/court, 32)

// Wallening todo: here down, too
/obj/structure/sign/departments/telecomms
	name = "\improper Telecommunications sign"
	sign_change_name = "Location - Telecommunications"
	desc = "A sign labelling an area where the station's radio and NTnet servers are stored."
	icon_state = "telecomms"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/telecomms, 32)

/obj/structure/sign/departments/telecomms/alt
	icon_state = "telecomms2"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/telecomms/alt, 32)

/obj/structure/sign/departments/aiupload
	name = "\improper AI Upload sign"
	sign_change_name = "Location - AI Upload"
	desc = "A sign labelling an area where laws are uploaded to the station's AI and cyborgs."
	icon_state = "aiupload"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/aiupload, 32)

/obj/structure/sign/departments/aisat
	name = "\improper AI Satellite sign"
	sign_change_name = "Location - AI Satellite"
	desc = "A sign labelling the AI's heavily-fortified satellite."
	icon_state = "aisat"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/aisat, 32)

/obj/structure/sign/departments/vault
	name = "\improper Vault sign"
	sign_change_name = "Location - Vault"
	desc = "A sign labelling a saferoom where the station's resources and self-destruct are secured."
	icon_state = "vault"

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/vault, 32)
