//warning signs


///////DANGEROUS THINGS

/obj/structure/sign/warning
	name = "\improper WARNING sign"
	sign_change_name = "Warning"
	desc = "A warning sign."
	icon_state = "securearea"
	is_editable = TRUE

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning)

/obj/structure/sign/warning/secure_area
	name = "\improper SECURE AREA sign"
	sign_change_name = "Warning - Secure Area"
	desc = "A warning sign which reads 'SECURE AREA'."

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/secure_area)

/obj/structure/sign/warning/docking
	name = "\improper KEEP CLEAR: DOCKING AREA sign"
	sign_change_name = "Warning - Docking Area"
	desc = "A warning sign which reads 'KEEP CLEAR OF DOCKING AREA'."

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/docking)

/obj/structure/sign/warning/biohazard
	name = "\improper BIOHAZARD sign"
	sign_change_name = "Warning - Biohazard"
	desc = "A warning sign which reads 'BIOHAZARD'."
	icon_state = "bio"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/biohazard)

/obj/structure/sign/warning/electric_shock
	name = "\improper HIGH VOLTAGE sign"
	sign_change_name = "Warning - High Voltage"
	desc = "A warning sign which reads 'HIGH VOLTAGE'."
	icon_state = "shock"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/electric_shock)

/obj/structure/sign/warning/vacuum
	name = "\improper HARD VACUUM AHEAD sign"
	sign_change_name = "Warning - Hard Vacuum"
	desc = "A warning sign which reads 'HARD VACUUM AHEAD'."
	icon_state = "space"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/vacuum)

/obj/structure/sign/warning/vacuum/external
	name = "\improper EXTERNAL AIRLOCK sign"
	sign_change_name = "Warning - External Airlock"
	desc = "A warning sign which reads 'EXTERNAL AIRLOCK'."
	layer = MOB_LAYER

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/vacuum/external)

/obj/structure/sign/warning/deathsposal
	name = "\improper DISPOSAL: LEADS TO SPACE sign"
	sign_change_name = "Warning - Disposals: Leads to Space"
	desc = "A warning sign which reads 'DISPOSAL: LEADS TO SPACE'."
	icon_state = "deathsposal"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/deathsposal)

/obj/structure/sign/warning/bodysposal
	name = "\improper DISPOSAL: LEADS TO MORGUE sign"
	sign_change_name = "Warning - Disposals: Leads to Morgue"
	desc = "A warning sign which reads 'DISPOSAL: LEADS TO MORGUE'."
	icon_state = "bodysposal"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/bodysposal)

/obj/structure/sign/warning/fire
	name = "\improper DANGER: FIRE sign"
	sign_change_name = "Warning - Fire Hazard"
	desc = "A warning sign which reads 'DANGER: FIRE'."
	icon_state = "fire"
	resistance_flags = FIRE_PROOF

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/fire)

/obj/structure/sign/warning/no_smoking
	name = "\improper NO SMOKING sign"
	sign_change_name = "Warning - No Smoking"
	desc = "A warning sign which reads 'NO SMOKING'."
	icon_state = "nosmoking2"
	resistance_flags = FLAMMABLE

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/no_smoking)

/obj/structure/sign/warning/no_smoking/circle
	name = "\improper NO SMOKING sign"
	sign_change_name = "Warning - No Smoking Alt"
	desc = "A warning sign which reads 'NO SMOKING'."
	icon_state = "nosmoking"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/no_smoking/circle)

/obj/structure/sign/warning/yes_smoking/circle
	name = "\improper YES SMOKING sign"
	sign_change_name = "Warning - Yes Smoking"
	desc = "A warning sign which reads 'YES SMOKING'."
	icon_state = "yessmoking"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/yes_smoking/circle)

/obj/structure/sign/warning/radiation
	name = "\improper HAZARDOUS RADIATION sign"
	sign_change_name = "Warning - Radiation"
	desc = "A warning sign alerting the user of potential radiation hazards."
	icon_state = "radiation"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/radiation)

/obj/structure/sign/warning/radiation/rad_area
	name = "\improper RADIOACTIVE AREA sign"
	sign_change_name = "Warning - Radioactive Area"
	desc = "A warning sign which reads 'RADIOACTIVE AREA'."

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/radiation/rad_area)

/obj/structure/sign/warning/xeno_mining
	name = "\improper DANGEROUS ALIEN LIFE sign"
	sign_change_name = "Warning - Xenos"
	desc = "A sign that warns would-be travellers of hostile alien life in the vicinity."
	icon = 'icons/obj/signs.dmi'
	icon_state = "xeno_warning"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/xeno_mining)

/obj/structure/sign/warning/engine_safety
	name = "\improper ENGINEERING SAFETY sign"
	sign_change_name = "Warning - Engineering Safety Protocols"
	desc = "A sign detailing the various safety protocols when working on-site to ensure a safe shift."
	icon_state = "safety"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/engine_safety)

/obj/structure/sign/warning/explosives
	name = "\improper HIGH EXPLOSIVES sign"
	sign_change_name = "Warning - Explosives"
	desc = "A warning sign which reads 'HIGH EXPLOSIVES'."
	icon_state = "explosives"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/explosives)

/obj/structure/sign/warning/explosives/alt
	name = "\improper HIGH EXPLOSIVES sign"
	sign_change_name = "Warning - Explosives Alt"
	desc = "A warning sign which reads 'HIGH EXPLOSIVES'."
	icon_state = "explosives2"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/explosives/alt)

/obj/structure/sign/warning/test_chamber
	name = "\improper TESTING AREA sign"
	sign_change_name = "Warning - Testing Area"
	desc = "A sign that warns of high-power testing equipment in the area."
	icon_state = "testchamber"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/test_chamber)

/obj/structure/sign/warning/firing_range
	name = "\improper FIRING RANGE sign"
	sign_change_name = "Warning - Firing Range"
	desc = "A sign reminding you to remain behind the firing line, and to wear ear protection."
	icon_state = "firingrange"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/firing_range)

/obj/structure/sign/warning/cold_temp
	name = "\improper FREEZING AIR sign"
	sign_change_name = "Warning - Temp: Cold"
	desc = "A sign that warns of extremely cold air in the vicinity."
	icon_state = "cold"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/cold_temp)

/obj/structure/sign/warning/hot_temp
	name = "\improper SUPERHEATED AIR sign"
	sign_change_name = "Warning - Temp: Hot"
	desc = "A sign that warns of extremely hot air in the vicinity."
	icon_state = "heat"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/hot_temp)

/obj/structure/sign/warning/gas_mask
	name = "\improper CONTAMINATED AIR sign"
	sign_change_name = "Warning - Contaminated Air"
	desc = "A sign that warns of dangerous particulates or gasses in the air, instructing you to wear internals."
	icon_state = "gasmask"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/gas_mask)

/obj/structure/sign/warning/chem_diamond
	name = "\improper REACTIVE CHEMICALS sign"
	sign_change_name = "Warning - Hazardous Chemicals sign"
	desc = "A sign that warns of potentially reactive chemicals nearby, be they explosive, flammable, or acidic."
	icon_state = "chemdiamond"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/chem_diamond)

/obj/structure/sign/warning/doors
	name = "\improper BLAST DOORS sign"
	sign_change_name = "Warning - Blast Doors"
	desc = "A sign that shows there are doors here. There are doors everywhere!"
	icon_state = "doors"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/doors, 32)

////MISC LOCATIONS

/obj/structure/sign/warning/pods
	name = "\improper ESCAPE PODS sign"
	sign_change_name = "Location - Escape Pods"
	desc = "A warning sign which reads 'ESCAPE PODS'."
	icon_state = "pods"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/pods)

/obj/structure/sign/warning/rad_shelter
	name = "\improper RADSTORM SHELTER sign"
	sign_change_name = "Location - Radstorm Shelter"
	desc = "A warning sign which reads 'RADSTORM SHELTER'."
	icon_state = "radshelter"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/warning/rad_shelter)
