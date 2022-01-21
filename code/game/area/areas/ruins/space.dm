//Space Ruin Parents

/area/ruin/space
	has_gravity = FALSE
	area_flags = UNIQUE_AREA

/area/ruin/space/has_grav
	has_gravity = STANDARD_GRAVITY

/area/ruin/space/has_grav/powered
	requires_power = FALSE

/////////////

/area/ruin/space/way_home
	name = "\improper Salvation"
	icon_state = "away"
	always_unpowered = FALSE

// Ruins of "onehalf" ship

/area/ruin/space/has_grav/onehalf/hallway
	name = "\improper Hallway"
	icon_state = "hallC"

/area/ruin/space/has_grav/onehalf/drone_bay
	name = "\improper Mining Drone Bay"
	icon_state = "engine"

/area/ruin/space/has_grav/onehalf/dorms_med
	name = "\improper Crew Quarters"
	icon_state = "Sleep"

/area/ruin/space/has_grav/onehalf/bridge
	name = "\improper Bridge"
	icon_state = "bridge"



/area/ruin/space/has_grav/powered/dinner_for_two
	name = "Dinner for Two"

/area/ruin/space/has_grav/powered/cat_man
	name = "\improper Kitty Den"

/area/ruin/space/has_grav/powered/authorship
	name = "\improper Authorship"

/area/ruin/space/has_grav/powered/aesthetic
	name = "Aesthetic"
	ambientsounds = list('sound/ambience/ambivapor1.ogg')


//Ruin of Hotel

/area/ruin/space/has_grav/hotel
	name = "\improper Hotel"

/area/ruin/space/has_grav/hotel/guestroom
	name = "\improper Hotel Guest Room"
	icon_state = "Sleep"

/area/ruin/space/has_grav/hotel/guestroom/room_1
	name = "\improper Hotel Guest Room 1"

/area/ruin/space/has_grav/hotel/guestroom/room_2
	name = "\improper Hotel Guest Room 2"

/area/ruin/space/has_grav/hotel/guestroom/room_3
	name = "\improper Hotel Guest Room 3"

/area/ruin/space/has_grav/hotel/guestroom/room_4
	name = "\improper Hotel Guest Room 4"

/area/ruin/space/has_grav/hotel/guestroom/room_5
	name = "\improper Hotel Guest Room 5"

/area/ruin/space/has_grav/hotel/guestroom/room_6
	name = "\improper Hotel Guest Room 6"

/area/ruin/space/has_grav/hotel/security
	name = "\improper Hotel Security Post"
	icon_state = "security"

/area/ruin/space/has_grav/hotel/pool
	name = "\improper Hotel Pool Room"
	icon_state = "fitness"

/area/ruin/space/has_grav/hotel/bar
	name = "\improper Hotel Bar"
	icon_state = "cafeteria"

/area/ruin/space/has_grav/hotel/power
	name = "\improper Hotel Power Room"
	icon_state = "engine_smes"

/area/ruin/space/has_grav/hotel/custodial
	name = "\improper Hotel Custodial Closet"
	icon_state = "janitor"

/area/ruin/space/has_grav/hotel/shuttle
	name = "\improper Hotel Shuttle"
	icon_state = "shuttle"
	requires_power = FALSE

/area/ruin/space/has_grav/hotel/dock
	name = "\improper Hotel Shuttle Dock"
	icon_state = "start"

/area/ruin/space/has_grav/hotel/workroom
	name = "\improper Hotel Staff Room"
	icon_state = "crew_quarters"

/area/ruin/space/has_grav/hotel/storeroom
	name = "\improper Hotel Staff Storage"
	icon_state = "crew_quarters"




//Ruin of Derelict Oupost

/area/ruin/space/has_grav/derelictoutpost
	name = "\improper Derelict Outpost"
	icon_state = "green"

/area/ruin/space/has_grav/derelictoutpost/cargostorage
	name = "\improper Derelict Outpost Cargo Storage"
	icon_state = "storage"

/area/ruin/space/has_grav/derelictoutpost/cargobay
	name = "\improper Derelict Outpost Cargo Bay"
	icon_state = "quartstorage"

/area/ruin/space/has_grav/derelictoutpost/powerstorage
	name = "\improper Derelict Outpost Power Storage"
	icon_state = "engine_smes"

/area/ruin/space/has_grav/derelictoutpost/dockedship
	name = "\improper Derelict Outpost Docked Ship"
	icon_state = "red"

//Ruin of turretedoutpost

/area/ruin/space/has_grav/turretedoutpost
	name = "\improper Turreted Outpost"
	icon_state = "red"


//Ruin of old teleporter

/area/ruin/space/oldteleporter
	name = "\improper Old Teleporter"
	icon_state = "teleporter"


//Ruin of mech transport

/area/ruin/space/has_grav/powered/mechtransport
	name = "\improper Mech Transport"
	icon_state = "green"


//Ruin of The Lizard's Gas

/area/ruin/space/has_grav/thelizardsgas
	name = "\improper The Lizard's Gas"


//Ruin of Deep Storage

/area/ruin/space/has_grav/deepstorage
	name = "Deep Storage"
	icon_state = "storage"

/area/ruin/space/has_grav/deepstorage/airlock
	name = "\improper Deep Storage Airlock"
	icon_state = "quart"

/area/ruin/space/has_grav/deepstorage/power
	name = "\improper Deep Storage Power and Atmospherics Room"
	icon_state = "engi_storage"

/area/ruin/space/has_grav/deepstorage/hydroponics
	name = "Deep Storage Hydroponics"
	icon_state = "garden"

/area/ruin/space/has_grav/deepstorage/armory
	name = "\improper Deep Storage Secure Storage"
	icon_state = "armory"

/area/ruin/space/has_grav/deepstorage/storage
	name = "\improper Deep Storage Storage"
	icon_state = "storage_wing"

/area/ruin/space/has_grav/deepstorage/dorm
	name = "\improper Deep Storage Dormitory"
	icon_state = "crew_quarters"

/area/ruin/space/has_grav/deepstorage/kitchen
	name = "\improper Deep Storage Kitchen"
	icon_state = "kitchen"

/area/ruin/space/has_grav/deepstorage/crusher
	name = "\improper Deep Storage Recycler"
	icon_state = "storage"


//Ruin of Abandoned Zoo

/area/ruin/space/has_grav/abandonedzoo
	name = "\improper Abandoned Zoo"
	icon_state = "green"


//Ruin of ancient Space Station

/area/ruin/space/has_grav/ancientstation
	name = "Charlie Station Main Corridor"
	icon_state = "green"

/area/ruin/space/has_grav/ancientstation/powered
	name = "Powered Tile"
	icon_state = "teleporter"
	requires_power = FALSE

/area/ruin/space/has_grav/ancientstation/space
	name = "Exposed To Space"
	icon_state = "teleporter"
	has_gravity = FALSE

/area/ruin/space/has_grav/ancientstation/atmo
	name = "Beta Station Atmospherics"
	icon_state = "red"
	ambience_index = AMBIENCE_ENGI
	has_gravity = TRUE

/area/ruin/space/has_grav/ancientstation/betacorridor
	name = "Beta Station Main Corridor"
	icon_state = "bluenew"

/area/ruin/space/has_grav/ancientstation/engi
	name = "Charlie Station Engineering"
	icon_state = "engine"
	ambience_index = AMBIENCE_ENGI

/area/ruin/space/has_grav/ancientstation/comm
	name = "Charlie Station Command"
	icon_state = "captain"

/area/ruin/space/has_grav/ancientstation/hydroponics
	name = "Charlie Station Hydroponics"
	icon_state = "garden"

/area/ruin/space/has_grav/ancientstation/kitchen
	name = "\improper Charlie Station Kitchen"
	icon_state = "kitchen"

/area/ruin/space/has_grav/ancientstation/sec
	name = "Charlie Station Security"
	icon_state = "red"

/area/ruin/space/has_grav/ancientstation/deltacorridor
	name = "Delta Station Main Corridor"
	icon_state = "green"

/area/ruin/space/has_grav/ancientstation/proto
	name = "\improper Delta Station Prototype Lab"
	icon_state = "ordlab"

/area/ruin/space/has_grav/ancientstation/rnd
	name = "Delta Station Research and Development"
	icon_state = "ordlab"

/area/ruin/space/has_grav/ancientstation/deltaai
	name = "\improper Delta Station AI Core"
	icon_state = "ai"
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')

/area/ruin/space/has_grav/ancientstation/mining
	name = "Beta Station Mining Equipment"
	icon_state = "mining"

/area/ruin/space/has_grav/ancientstation/medbay
	name = "Beta Station Medbay"
	icon_state = "medbay"

/area/ruin/space/has_grav/ancientstation/betastorage
	name = "\improper Beta Station Storage"
	icon_state = "storage"

/area/solars/ancientstation
	name = "\improper Charlie Station Solar Array"
	icon_state = "panelsP"

//DERELICT

/area/ruin/space/derelict
	name = "\improper Derelict Station"
	icon_state = "storage"

/area/ruin/space/derelict/hallway/primary
	name = "\improper Derelict Primary Hallway"
	icon_state = "hallP"

/area/ruin/space/derelict/hallway/secondary
	name = "\improper Derelict Secondary Hallway"
	icon_state = "hallS"

/area/ruin/space/derelict/hallway/primary/port
	name = "\improper Derelict Port Hallway"
	icon_state = "hallFP"

/area/ruin/space/derelict/arrival
	name = "\improper Derelict Arrival Centre"
	icon_state = "yellow"

/area/ruin/space/derelict/storage/equipment
	name = "\improper Derelict Equipment Storage"

/area/ruin/space/derelict/bridge
	name = "\improper Derelict Control Room"
	icon_state = "bridge"

/area/ruin/space/derelict/bridge/access
	name = "\improper Derelict Control Room Access"
	icon_state = "auxstorage"

/area/ruin/space/derelict/bridge/ai_upload
	name = "\improper Derelict Computer Core"
	icon_state = "ai"

/area/ruin/space/derelict/solar_control
	name = "\improper Derelict Solar Control"
	icon_state = "engine"

/area/ruin/space/derelict/se_solar
	name = "\improper South East Solars"
	icon_state = "engine"

/area/ruin/space/derelict/medical
	name = "\improper Derelict Medbay"
	icon_state = "medbay"

/area/ruin/space/derelict/medical/chapel
	name = "\improper Derelict Chapel"
	icon_state = "chapel"

/area/solars/derelict_starboard
	name = "\improper Derelict Starboard Solar Array"
	icon_state = "panelsS"

/area/solars/derelict_aft
	name = "\improper Derelict Aft Solar Array"
	icon_state = "yellow"

/area/ruin/space/derelict/singularity_engine
	name = "\improper Derelict Singularity Engine"
	icon_state = "engine"

/area/ruin/space/derelict/gravity_generator
	name = "\improper Derelict Gravity Generator Room"
	icon_state = "red"

/area/ruin/space/derelict/atmospherics
	name = "Derelict Atmospherics"
	icon_state = "red"

//DJSTATION

/area/ruin/space/djstation
	name = "\improper Ruskie DJ Station"
	icon_state = "DJ"
	has_gravity = STANDARD_GRAVITY

/area/ruin/space/djstation/solars
	name = "\improper DJ Station Solars"
	icon_state = "DJ"
	has_gravity = STANDARD_GRAVITY

//ABANDONED TELEPORTER

/area/ruin/space/abandoned_tele
	name = "\improper Abandoned Teleporter"
	icon_state = "teleporter"
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/signal.ogg')

//OLD AI SAT

/area/tcommsat/oldaisat
	name = "\improper Abandoned Satellite"
	icon_state = "tcomsatcham"

//ABANDONED BOX WHITESHIP

/area/ruin/space/has_grav/whiteship/box

	name = "\improper Abandoned Ship"
	icon_state = "red"


//SYNDICATE LISTENING POST STATION

/area/ruin/space/has_grav/listeningstation
	name = "\improper Listening Post"
	icon_state = "yellow"

/area/ruin/space/has_grav/powered/ancient_shuttle
	name = "\improper Ancient Shuttle"
	icon_state = "yellow"

//HELL'S FACTORY OPERATING FACILITY
/area/ruin/space/has_grav/hellfactory
	name = "\improper Hell Factory"
	icon_state = "yellow"

/area/ruin/space/has_grav/hellfactoryoffice
	name = "\improper Hell Factory Office"
	icon_state = "red"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | NOTELEPORT
