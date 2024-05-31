//departmental signs

/obj/structure/sign/departments
	is_editable = TRUE

///////MEDBAY

/obj/structure/sign/departments/med
	name = "\improper Medbay sign"
	sign_change_name = "Department - Medbay"
	desc = "A sign labelling an area of the medical department."
	icon_state = "med"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/med, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/med, 32)
#endif

/obj/structure/sign/departments/med_alt
	name = "\improper Medbay sign"
	sign_change_name = "Department - Medbay Alt"
	icon_state = "medbay"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/med_alt, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/med_alt, 32)
#endif

/obj/structure/sign/departments/medbay
	name = "\improper Medbay sign"
	sign_change_name = "Generic Medical"
	desc = "The intergalactic symbol of medical institutions. You'll probably get help here."
	icon_state = "bluecross"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/medbay, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/medbay, 32)
#endif

/obj/structure/sign/departments/medbay/alt
	name = "\improper Medbay sign"
	sign_change_name = "Generic Medical Alt"
	icon_state = "bluecross2"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/medbay/alt, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/medbay/alt, 32)
#endif

/obj/structure/sign/departments/exam_room
	name = "\improper Exam Room sign"
	sign_change_name = "Department - Medbay: Exam Room"
	desc = "A guidance sign which reads 'Exam Room'."
	icon_state = "examroom"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/exam_room, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/exam_room, 32)
#endif

/obj/structure/sign/departments/chemistry
	name = "\improper Chemistry sign"
	sign_change_name = "Department - Medbay: Chemistry"
	desc = "A sign labelling an area containing chemical equipment."
	icon_state = "chemistry1"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/chemistry, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/chemistry, 32)
#endif

/obj/structure/sign/departments/chemistry/alt
	sign_change_name = "Department - Medbay: Chemistry Alt"
	icon_state = "chemistry2"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/chemistry/alt, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/chemistry/alt, 32)
#endif

/obj/structure/sign/departments/chemistry/pharmacy
	name = "\improper Pharmacy sign"
	sign_change_name = "Department - Medbay: Pharmacy"
	desc = "A sign labelling an area containing pharmacy equipment."
	icon_state = "pharmacy"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/chemistry/pharmacy, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/chemistry/pharmacy, 32)
#endif

/obj/structure/sign/departments/psychology
	name = "\improper Psychology sign"
	sign_change_name = "Department - Medbay: Psychology"
	desc = "A sign labelling an area where the Psychologist works, they can probably help you get your head straight."
	icon_state = "psychology"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/psychology, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/psychology, 32)
#endif

/obj/structure/sign/departments/virology
	name = "\improper Virology sign"
	sign_change_name = "Department - Medbay: Virology"
	desc = "A sign labelling an area where the virologist's laboratory is located."
	icon_state = "pharmacy"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/virology, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/virology, 32)
#endif

/obj/structure/sign/departments/morgue
	name = "\improper Morgue sign"
	sign_change_name = "Department - Medbay: Morgue"
	desc = "A sign labelling an area where the station stores its ever-piling bodies."
	icon_state = "morgue"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/morgue, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/morgue, 32)
#endif

///////ENGINEERING

/obj/structure/sign/departments/engineering
	name = "\improper Engineering sign"
	sign_change_name = "Department - Engineering"
	desc = "A sign labelling an area where engineers work."
	icon_state = "engine"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/engineering, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/engineering, 32)
#endif

///////SCIENCE

/obj/structure/sign/departments/science
	name = "\improper Science sign"
	sign_change_name = "Department - Science"
	desc = "A sign labelling an area where research and science is performed."
	icon_state = "science1"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/science, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/science, 32)
#endif

/obj/structure/sign/departments/science/alt
	sign_change_name = "Department - Science Alt"
	icon_state = "science2"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/science/alt, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/science/alt, 32)
#endif

/obj/structure/sign/departments/xenobio
	name = "\improper Xenobiology sign"
	sign_change_name = "Department - Science: Xenobiology"
	desc = "A sign labelling an area where xenobiological entities are researched."
	icon_state = "xenobio1"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/xenobio, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/xenobio, 32)
#endif

/obj/structure/sign/departments/xenobio/alt
	sign_change_name = "Department - Science: Xenobiology Alt"
	icon_state = "xenobio2"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/xenobio/alt, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/xenobio/alt, 32)
#endif

/obj/structure/sign/departments/genetics
	name = "\improper Genetics sign"
	sign_change_name = "Department - Science: Genetics"
	desc = "A sign labelling an area where the field of genetics is researched."
	icon_state = "gene"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/genetics, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/genetics, 32)
#endif

/obj/structure/sign/departments/rndserver
	name ="\improper R&D Server sign"
	sign_change_name = "Department - Science: R&D Server"
	desc = "A sign labelling an area where scientific data is stored."
	icon_state = "rndserver"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/rndserver, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/rndserver, 32)
#endif

///////SERVICE

/obj/structure/sign/departments/botany
	name = "\improper Botany sign"
	sign_change_name = "Department - Botany (Flower)"
	desc = "A sign labelling an area as a place where plants are grown."
	icon_state = "hydro1"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/botany, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/botany, 32)
#endif

/obj/structure/sign/departments/botany/alt1
	sign_change_name = "Department - Botany (Tray)"
	icon_state = "hydro2"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/botany/alt1, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/botany/alt1, 32)
#endif

/obj/structure/sign/departments/botany/alt2
	sign_change_name = "Department - Botany (Watering Can)"
	icon_state = "hydro3"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/botany/alt2, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/botany/alt2, 32)
#endif

/obj/structure/sign/departments/botany/botany/alt3
	sign_change_name = "Department - Botany (Tray) Alt"
	icon_state = "botany"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/botany/alt3, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/botany/alt3, 32)
#endif

/obj/structure/sign/departments/custodian
	name = "\improper Janitor sign"
	sign_change_name = "Department - Janitor"
	desc = "A sign labelling an area where the janitor works."
	icon_state = "custodian"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/custodian, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/custodian, 32)
#endif

/obj/structure/sign/departments/holy
	name = "\improper Chapel sign"
	sign_change_name = "Department - Chapel"
	desc = "A sign labelling a religious area."
	icon_state = "holy"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/holy, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/holy, 32)
#endif

/obj/structure/sign/departments/holy_alt
	name = "\improper Chapel sign"
	sign_change_name = "Department - Chapel"
	desc = "A sign labelling a religious area."
	icon_state = "chapel"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/holy, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/holy, 32)
#endif

/obj/structure/sign/departments/lawyer
	name = "\improper Legal Department sign"
	sign_change_name = "Department - Legal"
	desc = "A sign labelling an area where the Lawyers work, apply here for arrivals shuttle whiplash settlement."
	icon_state = "lawyer"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/lawyer, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/lawyer, 32)
#endif

///////SUPPLY

/obj/structure/sign/departments/cargo
	name = "\improper Cargo sign"
	sign_change_name = "Department - Cargo"
	desc = "A sign labelling an area where cargo ships dock."
	icon_state = "cargo"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/cargo, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/cargo, 32)
#endif

///////SECURITY

/obj/structure/sign/departments/security
	name = "\improper Security sign"
	sign_change_name = "Department - Security"
	desc = "A sign labelling an area where the law is law."
	icon_state = "security"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/security, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/security, 32)
#endif

////MISC LOCATIONS

/obj/structure/sign/departments/restroom
	name = "\improper Restroom sign"
	sign_change_name = "Location - Restroom"
	desc = "A sign labelling a restroom."
	icon_state = "restroom"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/restroom, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/restroom, 32)
#endif

/obj/structure/sign/departments/maint
	name = "\improper Maintenance Tunnel sign"
	sign_change_name = "Location - Maintenance"
	desc = "A sign labelling an area where the departments of the station are linked together."
	icon_state = "mait1"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/maint, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/maint, 32)
#endif

/obj/structure/sign/departments/maint/alt
	name = "\improper Maintenance Tunnel sign"
	sign_change_name = "Location - Maintenance Alt"
	desc = "A sign labelling an area where the departments of the station are linked together."
	icon_state = "mait2"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/maint/alt, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/maint/alt, 32)
#endif

/obj/structure/sign/departments/evac
	name = "\improper Evacuation sign"
	sign_change_name = "Location - Evacuation"
	desc = "A sign labelling an area where evacuation procedures take place."
	icon_state = "evac"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/evac, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/evac, 32)
#endif

/obj/structure/sign/departments/drop
	name = "\improper Drop Pods sign"
	sign_change_name = "Location - Drop Pods"
	desc = "A sign labelling an area where drop pod loading procedures take place."
	icon_state = "drop"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/drop, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/drop, 32)
#endif

/obj/structure/sign/departments/court
	name = "\improper Courtroom sign"
	sign_change_name = "Location - Courtroom"
	desc = "A sign labelling the courtroom, where the ever sacred Space Law is upheld."
	icon_state = "court"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/court, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/court, 32)
#endif

/obj/structure/sign/departments/telecomms
	name = "\improper Telecommunications sign"
	sign_change_name = "Location - Telecommunications"
	desc = "A sign labelling an area where the station's radio and NTnet servers are stored."
	icon_state = "telecomms"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/telecomms, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/telecomms, 32)
#endif

/obj/structure/sign/departments/telecomms/alt
	icon_state = "telecomms2"
	sign_change_name = "Location - Telecommunications Alt"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/telecomms/alt, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/telecomms/alt, 32)
#endif

/obj/structure/sign/departments/aiupload
	name = "\improper AI Upload sign"
	sign_change_name = "Location - AI Upload"
	desc = "A sign labelling an area where laws are uploaded to the station's AI and cyborgs."
	icon_state = "aiupload"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/aiupload, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/aiupload, 32)
#endif

/obj/structure/sign/departments/aisat
	name = "\improper AI Satellite sign"
	sign_change_name = "Location - AI Satellite"
	desc = "A sign labelling the AI's heavily-fortified satellite."
	icon_state = "aisat"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/aisat, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/aisat, 32)
#endif

/obj/structure/sign/departments/vault
	name = "\improper Vault sign"
	sign_change_name = "Location - Vault"
	desc = "A sign labelling a saferoom where the station's resources and self-destruct are secured."
	icon_state = "vault"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/departments/vault, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/departments/vault, 32)
#endif
