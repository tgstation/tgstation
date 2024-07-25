/// Datum holding information about pod type visuals, VFX, name and description
/// These are not created anywhere and thus should not be assigned procs, only being used as data storage
/datum/pod_style
	/// Name that pods of this style will be named by default
	var/name = "supply pod"
	/// Name that is displayed to admins in pod config panel
	var/ui_name = "Standard"
	/// Description assigned to droppods of this style
	var/desc = "A Nanotrasen supply drop pod."
	/// Determines if this pod can use animations/masking/overlays
	var/shape = POD_SHAPE_NORMAL
	/// Base icon state assigned to this pod
	var/icon_state = "pod"
	/// Whenever this pod should have a door overlay added to it. Uses [icon_state]_door sprite
	var/has_door = TRUE
	/// Decals added to this pod, if any
	var/decal_icon = "default"
	/// Color that this pod glows when landing
	var/glow_color = "yellow"
	/// Type of rubble that this pod creates upon landing
	var/rubble_type = RUBBLE_NORMAL
	/// ID for TGUI data
	var/id = "standard"

/datum/pod_style/advanced
	name = "bluespace supply pod"
	ui_name = "Advanced"
	desc = "A Nanotrasen Bluespace supply pod. Teleports back to CentCom after delivery."
	decal_icon = "bluespace"
	glow_color = "blue"
	id = "bluespace"

/datum/pod_style/centcom
	name = "\improper CentCom supply pod"
	ui_name = "Nanotrasen"
	desc = "A Nanotrasen supply pod, this one has been marked with Central Command's designations. Teleports back to CentCom after delivery."
	decal_icon = "centcom"
	glow_color = "blue"
	id = "centcom"

/datum/pod_style/syndicate
	name = "blood-red supply pod"
	ui_name = "Syndicate"
	desc = "An intimidating supply pod, covered in the blood-red markings of the Syndicate. It's probably best to stand back from this."
	icon_state = "darkpod"
	decal_icon = "syndicate"
	glow_color = "red"
	id = "syndicate"

/datum/pod_style/deathsquad
	name = "\improper Deathsquad drop pod"
	ui_name = "Deathsquad"
	desc = "A Nanotrasen drop pod. This one has been marked the markings of Nanotrasen's elite strike team."
	icon_state = "darkpod"
	decal_icon = "deathsquad"
	glow_color = "blue"
	id = "deathsquad"

/datum/pod_style/advanced
	name = "bloody supply pod"
	ui_name = "Cultist"
	desc = "A Nanotrasen supply pod covered in scratch-marks, blood, and strange runes."
	decal_icon = "cultist"
	glow_color = "red"
	id = "cultist"

/datum/pod_style/missile
	name = "cruise missile"
	ui_name = "Missile"
	desc = "A big ass missile that didn't seem to fully detonate. It was likely launched from some far-off deep space missile silo. There appears to be an auxillery payload hatch on the side, though manually opening it is likely impossible."
	shape = POD_SHAPE_OTHER
	icon_state = "missile"
	has_door = FALSE
	decal_icon = null
	glow_color = null
	rubble_type = RUBBLE_THIN
	id = "missile"

/datum/pod_style/missile/syndicate
	name = "\improper Syndicate cruise missile"
	ui_name = "Syndie Missile"
	desc = "A big ass, blood-red missile that didn't seem to fully detonate. It was likely launched from some deep space Syndicate missile silo. There appears to be an auxillery payload hatch on the side, though manually opening it is likely impossible."
	icon_state = "smissile"
	id = "syndie_missile"

/datum/pod_style/box
	name = "\improper Aussec supply crate"
	ui_name = "Supply Box"
	desc = "An incredibly sturdy supply crate, designed to withstand orbital re-entry. Has 'Aussec Armory - 2532' engraved on the side."
	shape = POD_SHAPE_OTHER
	icon_state = "box"
	decal_icon = null
	glow_color = null
	rubble_type = RUBBLE_WIDE
	id = "supply_box"

/datum/pod_style/clown
	name = "\improper HONK pod"
	ui_name = "Clown Pod"
	desc = "A brightly-colored supply pod. It likely originated from the Clown Federation."
	icon_state = "clownpod"
	decal_icon = "clown"
	glow_color = "green"
	id = "clown"

/datum/pod_style/orange
	name = "\improper Orange"
	ui_name = "Fruit"
	desc = "An angry orange."
	shape = POD_SHAPE_OTHER
	icon_state = "orange"
	decal_icon = null
	glow_color = null
	rubble_type = RUBBLE_WIDE
	id = "orange"

/datum/pod_style/invisible
	name =  "\improper S.T.E.A.L.T.H. pod MKVII"
	ui_name = "Invisible"
	desc = "A supply pod that, under normal circumstances, is completely invisible to conventional methods of detection. How are you even seeing this?"
	shape = POD_SHAPE_OTHER
	has_door = FALSE
	icon_state = null
	decal_icon = null
	glow_color = null
	rubble_type = RUBBLE_NONE
	id = "invisible"

/datum/pod_style/gondola
	name = "gondola"
	ui_name = "Gondola"
	desc = "The silent walker. This one seems to be part of a delivery agency."
	shape = POD_SHAPE_OTHER
	icon_state = "gondola"
	has_door = FALSE
	decal_icon = null
	glow_color = null
	rubble_type = RUBBLE_NONE
	id = "gondola"

/datum/pod_style/seethrough
	name = null
	ui_name = "Seethrough"
	desc = null
	shape = POD_SHAPE_OTHER
	has_door = FALSE
	icon_state = null
	decal_icon = null
	glow_color = null
	rubble_type = RUBBLE_NONE
	id = "seethrough"
