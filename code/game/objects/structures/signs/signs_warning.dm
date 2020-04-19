//warning signs
//sign_change_name is an alternate name for a sign that only shows up in the list you see when you use a pen on a sign backing.


///////DANGEROUS THINGS

/obj/structure/sign/warning
	name = "\improper WARNING"
	sign_change_name = "Warning"
	desc = "A warning sign."
	icon_state = "securearea"
	is_buildable = TRUE

/obj/structure/sign/warning/securearea
	name = "\improper SECURE AREA"
	sign_change_name = "Warning - Secure Area"
	desc = "A warning sign which reads 'SECURE AREA'."
	is_buildable = TRUE

/obj/structure/sign/warning/docking
	name = "\improper KEEP CLEAR: DOCKING AREA"
	sign_change_name = "Warning - Docking Area"
	desc = "A warning sign which reads 'KEEP CLEAR OF DOCKING AREA'."
	is_buildable = TRUE

/obj/structure/sign/warning/biohazard
	name = "\improper BIOHAZARD"
	sign_change_name = "Warning - Biohazard"
	desc = "A warning sign which reads 'BIOHAZARD'."
	icon_state = "bio"
	is_buildable = TRUE

/obj/structure/sign/warning/electricshock
	name = "\improper HIGH VOLTAGE"
	sign_change_name = "Warning - High Voltage"
	desc = "A warning sign which reads 'HIGH VOLTAGE'."
	icon_state = "shock"
	is_buildable = TRUE

/obj/structure/sign/warning/vacuum
	name = "\improper HARD VACUUM AHEAD"
	sign_change_name = "Warning - Hard Vacuum"
	desc = "A warning sign which reads 'HARD VACUUM AHEAD'."
	icon_state = "space"
	is_buildable = TRUE

/obj/structure/sign/warning/vacuum/external
	name = "\improper EXTERNAL AIRLOCK"
	sign_change_name = "Warning - External Airlock"
	desc = "A warning sign which reads 'EXTERNAL AIRLOCK'."
	layer = MOB_LAYER
	is_buildable = TRUE

/obj/structure/sign/warning/deathsposal
	name = "\improper DISPOSAL: LEADS TO SPACE"
	sign_change_name = "Warning - Disposals: Leads to Space"
	desc = "A warning sign which reads 'DISPOSAL: LEADS TO SPACE'."
	icon_state = "deathsposal"
	is_buildable = TRUE

/obj/structure/sign/warning/bodysposal
	name = "\improper DISPOSAL: LEADS TO MORGUE"
	sign_change_name = "Warning - Disposals: Leads to Morgue"
	desc = "A warning sign which reads 'DISPOSAL: LEADS TO MORGUE'."
	icon_state = "bodysposal"
	is_buildable = TRUE

/obj/structure/sign/warning/fire
	name = "\improper DANGER: FIRE"
	sign_change_name = "Warning - Fire Hazard"
	desc = "A warning sign which reads 'DANGER: FIRE'."
	icon_state = "fire"
	resistance_flags = FIRE_PROOF
	is_buildable = TRUE

/obj/structure/sign/warning/nosmoking
	name = "\improper NO SMOKING"
	sign_change_name = "Warning - No Smoking"
	desc = "A warning sign which reads 'NO SMOKING'."
	icon_state = "nosmoking2"
	resistance_flags = FLAMMABLE
	is_buildable = TRUE

/obj/structure/sign/warning/nosmoking/circle
	name = "\improper NO SMOKING"
	sign_change_name = "Warning - No Smoking (Alt. Design)"
	icon_state = "nosmoking"
	is_buildable = TRUE

/obj/structure/sign/warning/radiation
	name = "\improper HAZARDOUS RADIATION"
	sign_change_name = "Warning - Radiation"
	desc = "A warning sign alerting the user of potential radiation hazards."
	icon_state = "radiation"
	is_buildable = TRUE

/obj/structure/sign/warning/radiation/rad_area
	name = "\improper RADIOACTIVE AREA"
	sign_change_name = "Warning - Radioactive Area"
	desc = "A warning sign which reads 'RADIOACTIVE AREA'."
	is_buildable = TRUE

/obj/structure/sign/warning/xeno_mining
	name = "\improper DANGEROUS ALIEN LIFE"
	sign_change_name = "Warning - Xenos"
	desc = "A sign that warns would-be travellers of hostile alien life in the vicinity."
	icon = 'icons/obj/mining.dmi'
	icon_state = "xeno_warning"
	is_buildable = TRUE

/obj/structure/sign/warning/enginesafety
	name = "\improper ENGINEERING SAFETY"
	sign_change_name = "Warning - Engineering Safety Poster"
	desc = "A sign detailing the various safety protocols when working on-site to ensure a safe shift."
	icon_state = "safety"
	is_buildable = TRUE

/obj/structure/sign/warning/explosives
	name = "\improper HIGH EXPLOSIVES"
	sign_change_name = "Warning - Explosives"
	desc = "A warning sign which reads 'HIGH EXPLOSIVES'."
	icon_state = "explosives"
	is_buildable = TRUE

/obj/structure/sign/warning/explosives/alt
	name = "\improper HIGH EXPLOSIVES"
	sign_change_name = "Warning - Explosives (Alt. Design)"
	desc = "A warning sign which reads 'HIGH EXPLOSIVES'."
	icon_state = "explosives2"
	is_buildable = TRUE

/obj/structure/sign/warning/testchamber
	name = "\improper TESTING AREA"
	sign_change_name = "Warning - Testing Area"
	desc = "A sign that warns of high-power testing equipment in the area. That's either a really powerful laser... or a satellite landing on some person's head."
	icon_state = "testchamber"
	is_buildable = TRUE

/obj/structure/sign/warning/firingrange
	name = "\improper FIRING RANGE"
	sign_change_name = "Warning - Firing Range"
	desc = "A sign reminding you to remain behind the firing line, and to wear ear protection."
	icon_state = "firingrange"
	is_buildable = TRUE

/obj/structure/sign/warning/coldtemp
	name = "\improper FREEZING AIR"
	sign_change_name = "Warning - Temp: Cold"
	desc = "A sign that warns of extremely cold air in the vicinity."
	icon_state = "cold"
	is_buildable = TRUE

/obj/structure/sign/warning/hottemp
	name = "\improper SUPERHEATED AIR"
	sign_change_name = "Warning - Temp: Hot"
	desc = "A sign that warns of extremely hot air in the vicinity."
	icon_state = "heat"
	is_buildable = TRUE

/obj/structure/sign/warning/gasmask
	name = "\improper CONTAMINATED AIR"
	sign_change_name = "Warning - Contaminated Air"
	desc = "A sign that warns of dangerous particulates in the air, instructing you to wear a filtration device."
	icon_state = "gasmask"
	is_buildable = TRUE

/obj/structure/sign/warning/chemdiamond
	name = "\improper REACTIVE CHEMICALS"
	sign_change_name = "Warning - Hazardous Chemicals"
	desc = "A sign that warns of potentially reactive chemicals nearby, be they explosive, flamable, or acidic."
	icon_state = "chemdiamond"
	is_buildable = TRUE

////MISC LOCATIONS

/obj/structure/sign/warning/pods
	name = "\improper ESCAPE PODS"
	sign_change_name = "Location - Escape Pods"
	desc = "A warning sign which reads 'ESCAPE PODS'."
	icon_state = "pods"
	is_buildable = TRUE
