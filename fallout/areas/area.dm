//FALLOUT
/area/f13
	name = "wasteland"
	icon = 'fallout/icons/turf/f13areas.dmi'
	icon_state = "desert"
	requires_power = FALSE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	outdoors = TRUE
	has_gravity = STANDARD_GRAVITY
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	lightswitch = FALSE //no. just no
	ambientsounds = list('fallout/sound/f13ambience/wasteland.ogg', 'fallout/sound/f13ambience/sewer.ogg')
	flags_1 = NONE //>desert >>has destroyed robo dirt on it

/area/f13/admeme
	icon_state = "secret"
	requires_power = FALSE

/area/f13/underground

/area/f13/underground/bos
	name = "BoS"
	flags_1 = NONE
	requires_power = TRUE
	icon_state = "nuke_storage"

/area/f13/underground/mountain
	name = "mountain"
	icon_state = "cave"
	requires_power = TRUE

/area/f13/tcoms
	name = "tcom"
	icon_state = "tcomsatcham"
	requires_power = FALSE

/area/f13/desert
	name = "Desert"
	icon_state = "desert"
	requires_power = FALSE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	outdoors = TRUE
	lightswitch = FALSE //no. just no
	flags_1 = NONE //>desert >>has destroyed robo dirt on it

/area/f13/sunny_dale
	name = "Sunny Dale"
	icon_state = "sunny_dale"
	requires_power = TRUE

/area/f13/ncr_main
	name = "NCR Mainbase"
	icon_state = "ncr_main"
	requires_power = TRUE

/area/f13/raider_mall
	name = "Raider Mall"
	icon_state = "raider_mall"
	requires_power = TRUE

/area/f13/mountain_bunker
	name = "Mountain Bunker"
	icon_state = "mountain_bunker"
	requires_power = TRUE

/area/f13/prison
	name = "prison"
	icon_state = "sunny_dale"
	requires_power = TRUE

/area/f13/klamat
	name = "Klamat"
	icon_state = "klamat"
	requires_power = TRUE

/area/f13/klamat/mine
	name = "Klamat mine"
	icon_state = "klamat_mine"
	requires_power = TRUE

/area/f13/deepmine
	name = "Klamat deep mine"
	icon_state = "klamat_mine"
	requires_power = TRUE

/area/f13/farmhouse
	name = "Farmhouse"
	icon_state = "farmhouse"
	requires_power = TRUE

/area/f13/farmhousesouth
	name = "FarmhouseS"
	icon_state = "farmhouse"
	requires_power = TRUE

/area/f13/legioncamp
	name = "Legion Camp"
	icon_state = "legioncamp"

/area/f13/powerplant
	name = "Power Plant"
	icon_state = "powerplant"
	requires_power = TRUE
	ambientsounds = ENGINEERING

/area/f13/underground/enclave_base
	name = "Enclave Base"
	icon_state = "enclave_base"

/area/f13/den
	name = "Den"
	icon_state = "den"

/area/f13/underground/overseer_office
	name = "Overseer's Office"
	icon_state = "overseer_office"
	requires_power = TRUE

/area/f13/underground/vault_atrium_upper
	name = "Vault Atrium Upper"
	icon_state = "vault_atrium_upper"
	requires_power = TRUE

/area/f13/underground/vault_atrium_Lower
	name = "Vault Atrium Lower"
	icon_state = "vault_atrium_upper"
	requires_power = TRUE

/area/shuttle/vault_elevator
	name = "Vault Elevator"

/area/shuttle/enclavefort_elevator
	name = "Enclave Fort Elevator"

/area/shuttle/bos_elevator
	name = "BOS Elevator"

/area/shuttle/bunker_elevator
	name = "Bunker Elevator"

/area/shuttle/northbunker_elevator
	name = "North Bunker Elevator"

/area/shuttle/mining_elevator
	name = "Mining Elevator"

/area/f13/underground/cave/vault
	name = "Vault Mine"
	icon_state = "caves"
	outdoors = TRUE

/area/f13/underground/cave
	name = "Cave"
	icon_state = "cave"
	outdoors = TRUE
