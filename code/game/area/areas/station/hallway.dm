/area/station/hallway
	icon_state = "hall"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/hallway/primary
	name = "\improper Primary Hallway"
	icon_state = "primaryhall"

/area/station/hallway/primary/aft
	name = "\improper Aft Primary Hallway"
	icon_state = "afthall"

/area/station/hallway/primary/fore
	name = "\improper Fore Primary Hallway"
	icon_state = "forehall"

/area/station/hallway/primary/starboard
	name = "\improper Starboard Primary Hallway"
	icon_state = "starboardhall"

/area/station/hallway/primary/port
	name = "\improper Port Primary Hallway"
	icon_state = "porthall"

/area/station/hallway/primary/central
	name = "\improper Central Primary Hallway"
	icon_state = "centralhall"

/area/station/hallway/primary/central/fore
	name = "\improper Fore Central Primary Hallway"
	icon_state = "hallCF"

/area/station/hallway/primary/central/aft
	name = "\improper Aft Central Primary Hallway"
	icon_state = "hallCA"

/area/station/hallway/primary/upper
	name = "\improper Upper Central Primary Hallway"
	icon_state = "centralhall"

/area/station/hallway/primary/tram
	name = "\improper Primary Tram"

/area/station/hallway/primary/tram/left
	name = "\improper Port Tram Dock"
	icon_state = "halltramL"

/area/station/hallway/primary/tram/center
	name = "\improper Central Tram Dock"
	icon_state = "halltramM"

/area/station/hallway/primary/tram/right
	name = "\improper Starboard Tram Dock"
	icon_state = "halltramR"

// This shouldn't be used, but it gives an icon for the enviornment tree in the map editor
/area/station/hallway/secondary
	icon_state = "secondaryhall"

/area/station/hallway/secondary/command
	name = "\improper Command Hallway"
	icon_state = "bridge_hallway"

/area/station/hallway/secondary/construction
	name = "\improper Construction Area"
	icon_state = "construction"

/area/station/hallway/secondary/construction/engineering
	name = "\improper Engineering Hallway"

/area/station/hallway/secondary/exit
	name = "\improper Escape Shuttle Hallway"
	icon_state = "escape"

/area/station/hallway/secondary/exit/escape_pod
	name = "\improper Escape Pod Bay"
	icon_state = "escape_pods"

/area/station/hallway/secondary/exit/departure_lounge
	name = "\improper Departure Lounge"
	icon_state = "escape_lounge"

/area/station/hallway/secondary/entry
	name = "\improper Arrival Shuttle Hallway"
	icon_state = "entry"
	area_flags = UNIQUE_AREA | EVENT_PROTECTED

/area/station/hallway/secondary/dock
	name = "\improper Secondary Station Dock Hallway"
	icon_state = "hall"

/area/station/hallway/secondary/service
	name = "\improper Service Hallway"
	icon_state = "hall_service"

/area/station/hallway/secondary/spacebridge
	name = "\improper Space Bridge"
	icon_state = "hall"

/area/station/hallway/secondary/recreation
	name = "\improper Recreation Hallway"
	icon_state = "hall"

/*
* Station Specific Areas
* If another station gets added, and you make specific areas for it
* Please make its own section in this file
* The areas below belong to North Star's Hallways
*/

//1
/area/station/hallway/floor1
	name = "\improper First Floor Hallway"

/area/station/hallway/floor1/aft
	name = "\improper First Floor Aft Hallway"
	icon_state = "1_aft"

/area/station/hallway/floor1/fore
	name = "\improper First Floor Fore Hallway"
	icon_state = "1_fore"
//2
/area/station/hallway/floor2
	name = "\improper Second Floor Hallway"

/area/station/hallway/floor2/aft
	name = "\improper Second Floor Aft Hallway"
	icon_state = "2_aft"

/area/station/hallway/floor2/fore
	name = "\improper Second Floor Fore Hallway"
	icon_state = "2_fore"
//3
/area/station/hallway/floor3
	name = "\improper Third Floor Hallway"

/area/station/hallway/floor3/aft
	name = "\improper Third Floor Aft Hallway"
	icon_state = "3_aft"

/area/station/hallway/floor3/fore
	name = "\improper Third Floor Fore Hallway"
	icon_state = "3_fore"
//4
/area/station/hallway/floor4
	name = "\improper Fourth Floor Hallway"

/area/station/hallway/floor4/aft
	name = "\improper Fourth Floor Aft Hallway"
	icon_state = "4_aft"

/area/station/hallway/floor4/fore
	name = "\improper Fourth Floor Fore Hallway"
	icon_state = "4_fore"
