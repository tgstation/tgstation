//map and direction signs

/obj/structure/sign/map
	name = "station map"
	desc = "A navigational chart of the station."
	max_integrity = 500

/obj/structure/sign/map/left
	icon_state = "map-left"

/obj/structure/sign/map/right
	icon_state = "map-right"

/obj/structure/sign/directions/science
	name = "science department sign"
	desc = "A direction sign, pointing out which way the Science department is."
	icon_state = "direction_sci"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/directions/science, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/directions/science, 32)
#endif

/obj/structure/sign/directions/engineering
	name = "engineering department sign"
	desc = "A direction sign, pointing out which way the Engineering department is."
	icon_state = "direction_eng"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/directions/engineering, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/directions/engineering, 32)
#endif

/obj/structure/sign/directions/security
	name = "security department sign"
	desc = "A direction sign, pointing out which way the Security department is."
	icon_state = "direction_sec"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/directions/security, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/directions/security, 32)
#endif

/obj/structure/sign/directions/medical
	name = "medbay sign"
	desc = "A direction sign, pointing out which way the Medbay is."
	icon_state = "direction_med"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/directions/medical, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/directions/medical, 32)
#endif

/obj/structure/sign/directions/evac
	name = "evacuation sign"
	desc = "A direction sign, pointing out which way the escape shuttle dock is."
	icon_state = "direction_evac"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/directions/evac, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/directions/evac, 32)
#endif

/obj/structure/sign/directions/supply
	name = "cargo sign"
	desc = "A direction sign, pointing out which way the Cargo Bay is."
	icon_state = "direction_supply"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/directions/supply, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/directions/supply, 32)
#endif

/obj/structure/sign/directions/command
	name = "command department sign"
	desc = "A direction sign, pointing out which way the Command department is."
	icon_state = "direction_bridge"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/directions/command, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/directions/command, 32)
#endif

/obj/structure/sign/directions/vault
	name = "vault sign"
	desc = "A direction sign, pointing out which way the station's Vault is."
	icon_state = "direction_vault"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/directions/vault, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/directions/vault, 32)
#endif

/obj/structure/sign/directions/upload
	name = "upload sign"
	desc = "A direction sign, pointing out which way the station's AI Upload is."
	icon_state = "direction_upload"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/directions/upload, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/directions/upload, 32)
#endif

/obj/structure/sign/directions/dorms
	name = "dormitories sign"
	desc = "A direction sign, pointing out which way the dormitories are."
	icon_state = "direction_dorms"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/directions/dorms, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/directions/dorms, 32)
#endif

/obj/structure/sign/directions/lavaland
	name = "lava sign"
	desc = "A direction sign, pointing out which way the hot stuff is."
	icon_state = "direction_lavaland"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/directions/lavaland, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/directions/lavaland, 32)
#endif

/obj/structure/sign/directions/arrival
	name = "arrivals sign"
	desc = "A direction sign, pointing out which way the arrivals shuttle dock is."
	icon_state = "direction_arrival"

#ifdef EXPERIMENT_WALLENING
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/directions/arrival, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/directions/arrival, 32)
#endif
