// //map and direction signs

/obj/structure/sign/map
	name = "station map"
	desc = "A navigational chart of the station."
	max_integrity = 500

/// Cerestation Map
/obj/structure/sign/map/cerestation
	icon_state = "map-CS"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/map/cerestation)

/// Pubbystation Map
/obj/structure/sign/map/Pubbystation
	icon_state = "map-pubby"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/map/Pubbystation)

/// Boxstation Map
/obj/structure/sign/map/left
	icon_state = "map-left"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/map/left)

/obj/structure/sign/map/right
	icon_state = "map-right"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/map/right)

/// Metastation Map
/obj/structure/sign/map/left/metastation
	icon_state = "map-left-MS"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/map/left/metastation)

/obj/structure/sign/map/right/metastation
	icon_state = "map-right-MS"

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/sign/map/right/metastation)

/obj/structure/sign/directions
	icon = 'icons/obj/structures/directional_signs.dmi'
	/// What direction is the arrow on the sign pointing?
	var/sign_arrow_direction = null
	/// If this sign has a support on the left or right, which side? null if niether
	var/support_side = null

/obj/structure/sign/directions/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/structure/sign/directions/update_icon_state()
	. = ..()
	if(support_side)
		icon_state = "[initial(icon_state)]_[support_side]"
	else
		icon_state = "[initial(icon_state)]"

/obj/structure/sign/directions/update_overlays()
	. = ..()
	if(sign_arrow_direction)
		. += "arrow_[sign_arrow_direction]"

/obj/structure/sign/directions/science
	name = "science department sign"
	desc = "A direction sign, pointing out which way the Science department is."
	icon_state = "direction_sci"

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/science)

/obj/structure/sign/directions/science/right
	support_side = SUPPORT_RIGHT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/science/right)
/obj/structure/sign/directions/science/left
	support_side = SUPPORT_LEFT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/science/left)

/obj/structure/sign/directions/engineering
	name = "engineering department sign"
	desc = "A direction sign, pointing out which way the Engineering department is."
	icon_state = "direction_eng"

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/engineering)

/obj/structure/sign/directions/engineering/right
	support_side = SUPPORT_RIGHT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/engineering/right)
/obj/structure/sign/directions/engineering/left
	support_side = SUPPORT_LEFT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/engineering/left)

/obj/structure/sign/directions/security
	name = "security department sign"
	desc = "A direction sign, pointing out which way the Security department is."
	icon_state = "direction_sec"

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/security)

/obj/structure/sign/directions/security/right
	support_side = SUPPORT_RIGHT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/security/right)
/obj/structure/sign/directions/security/left
	support_side = SUPPORT_LEFT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/security/left)

/obj/structure/sign/directions/medical
	name = "medbay sign"
	desc = "A direction sign, pointing out which way the Medbay is."
	icon_state = "direction_med"

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/medical)

/obj/structure/sign/directions/medical/right
	support_side = SUPPORT_RIGHT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/medical/right)
/obj/structure/sign/directions/medical/left
	support_side = SUPPORT_LEFT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/medical/left)

/obj/structure/sign/directions/evac
	name = "evacuation sign"
	desc = "A direction sign, pointing out which way the escape shuttle dock is."
	icon_state = "direction_evac"

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/evac)

/obj/structure/sign/directions/evac/right
	support_side = SUPPORT_RIGHT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/evac/right)
/obj/structure/sign/directions/evac/left
	support_side = SUPPORT_LEFT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/evac/left)

/obj/structure/sign/directions/supply
	name = "cargo sign"
	desc = "A direction sign, pointing out which way the Cargo Bay is."
	icon_state = "direction_supply"

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/supply)

/obj/structure/sign/directions/supply/right
	support_side = SUPPORT_RIGHT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/supply/right)
/obj/structure/sign/directions/supply/left
	support_side = SUPPORT_LEFT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/supply/left)

/obj/structure/sign/directions/command
	name = "command department sign"
	desc = "A direction sign, pointing out which way the Command department is."
	icon_state = "direction_bridge"

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/command)

/obj/structure/sign/directions/command/right
	support_side = SUPPORT_RIGHT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/command/right)
/obj/structure/sign/directions/command/left
	support_side = SUPPORT_LEFT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/command/left)

/obj/structure/sign/directions/vault
	name = "vault sign"
	desc = "A direction sign, pointing out which way the station's Vault is."
	icon_state = "direction_vault"

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/vault)

/obj/structure/sign/directions/vault/right
	support_side = SUPPORT_RIGHT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/vault/right)
/obj/structure/sign/directions/vault/left
	support_side = SUPPORT_LEFT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/vault/left)

/obj/structure/sign/directions/upload
	name = "upload sign"
	desc = "A direction sign, pointing out which way the station's AI Upload is."
	icon_state = "direction_upload"

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/upload)

/obj/structure/sign/directions/upload/right
	support_side = SUPPORT_RIGHT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/upload/right)
/obj/structure/sign/directions/upload/left
	support_side = SUPPORT_LEFT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/upload/left)

/obj/structure/sign/directions/dorms
	name = "dormitories sign"
	desc = "A direction sign, pointing out which way the dormitories are."
	icon_state = "direction_dorms"

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/dorms)

/obj/structure/sign/directions/dorms/right
	support_side = SUPPORT_RIGHT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/dorms/right)
/obj/structure/sign/directions/dorms/left
	support_side = SUPPORT_LEFT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/dorms/left)

/obj/structure/sign/directions/lavaland
	name = "lava sign"
	desc = "A direction sign, pointing out which way the hot stuff is."
	icon_state = "direction_lavaland"

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/lavaland)

/obj/structure/sign/directions/lavaland/right
	support_side = SUPPORT_RIGHT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/lavaland/right)
/obj/structure/sign/directions/lavaland/left
	support_side = SUPPORT_LEFT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/lavaland/left)

/obj/structure/sign/directions/arrival
	name = "arrivals sign"
	desc = "A direction sign, pointing out which way the arrivals shuttle dock is."
	icon_state = "direction_arrival"

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/arrival)

/obj/structure/sign/directions/arrival/right
	support_side = SUPPORT_RIGHT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/arrival/right)
/obj/structure/sign/directions/arrival/left
	support_side = SUPPORT_LEFT

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/arrival/left)

/obj/structure/sign/directions/doornum
	name = "room number sign"
	desc = "A sign that states the labeled room's number."
	icon_state = "direction_doornum"

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/doornum)

/obj/structure/sign/directions/doornum/right
	icon_state = "direction_doornum_right"

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/doornum/right)
/obj/structure/sign/directions/doornum/left
	icon_state = "direction_doornum_left"

DIRECTIONAL_SIGNS_DIRECTIONAL_HELPERS(/obj/structure/sign/directions/doornum/left)
