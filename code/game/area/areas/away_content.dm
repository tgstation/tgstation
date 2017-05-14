
// Away Missions
/area/awaymission
	name = "Strange Location"
	icon_state = "away"
	has_gravity = 1

/area/awaymission/example
	name = "Strange Station"
	icon_state = "away"

/area/awaymission/desert
	name = "Mars"
	icon_state = "away"

/area/awaymission/listeningpost
	name = "Listening Post"
	icon_state = "away"
	requires_power = 0

/area/awaymission/beach
	name = "Beach"
	icon_state = "away"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	requires_power = 0
	has_gravity = 1
	ambientsounds = list('sound/ambience/shore.ogg', 'sound/ambience/seag1.ogg','sound/ambience/seag2.ogg','sound/ambience/seag2.ogg')

/area/awaymission/errorroom
	name = "Super Secret Room"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	has_gravity = 1


//Research Base Areas//--

/area/awaymission/research
	name = "Research Outpost"
	icon_state = "away"
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED

/area/awaymission/research/interior
	name = "Research Inside"
	requires_power = 1
	icon_state = "away2"

/area/awaymission/research/interior/cryo
	name = "Research Cryostasis Room"
	icon_state = "medbay"

/area/awaymission/research/interior/clonestorage
	name = "Research Clone Storage"
	icon_state = "cloning"

/area/awaymission/research/interior/genetics
	name = "Research Genetics Research"
	icon_state = "genetics"

/area/awaymission/research/interior/engineering
	name = "Research Engineering"
	icon_state = "engine"

/area/awaymission/research/interior/security
	name = "Research Security"
	icon_state = "security"

/area/awaymission/research/interior/secure
	name = "Research Secure Vault"

/area/awaymission/research/interior/maint
	name = "Research Maintenance"
	icon_state = "maintcentral"

/area/awaymission/research/interior/dorm
	name = "Research Dorms"
	icon_state = "Sleep"

/area/awaymission/research/interior/escapepods
	name = "Research Escape Wing"
	icon_state = "exit"

/area/awaymission/research/interior/gateway
	name = "Research Gateway"
	icon_state = "start"

/area/awaymission/research/interior/bathroom
	name = "Research Bathrooms"
	icon_state = "restrooms"

/area/awaymission/research/interior/medbay
	name = "Research Medbay"
	icon_state = "medbay"

/area/awaymission/research/exterior
	name = "Research Exterior"
	icon_state = "unknown"



//Challenge Areas

/area/awaymission/challenge/start
	name = "Where Am I?"
	icon_state = "away"

/area/awaymission/challenge/main
	name = "Danger Room"
	icon_state = "away1"
	requires_power = 0

/area/awaymission/challenge/end
	name = "Administration"
	icon_state = "away2"
	requires_power = 0


//centcomAway areas

/area/awaymission/centcomAway
	name = "XCC-P5831"
	icon_state = "away"
	requires_power = 0

/area/awaymission/centcomAway/general
	name = "XCC-P5831"
	music = 'sound/ambience/ambigen3.ogg'

/area/awaymission/centcomAway/maint
	name = "XCC-P5831 Maintenance"
	icon_state = "away1"
	music = 'sound/ambience/ambisin1.ogg'

/area/awaymission/centcomAway/thunderdome
	name = "XCC-P5831 Thunderdome"
	icon_state = "away2"
	music = 'sound/ambience/ambisin2.ogg'

/area/awaymission/centcomAway/cafe
	name = "XCC-P5831 Kitchen Arena"
	icon_state = "away3"
	music = 'sound/ambience/ambisin3.ogg'

/area/awaymission/centcomAway/courtroom
	name = "XCC-P5831 Courtroom"
	icon_state = "away4"
	music = 'sound/ambience/ambisin4.ogg'

/area/awaymission/centcomAway/hangar
	name = "XCC-P5831 Hangars"
	icon_state = "away4"
	music = 'sound/ambience/ambigen5.ogg'


/*Cabin areas*/
/area/awaymission/snowforest
	name = "Snow Forest"
	icon_state = "away"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED

/area/awaymission/cabin
	name = "Cabin"
	icon_state = "away2"
	requires_power = 1
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED

/area/awaymission/snowforest/lumbermill
	name = "Lumbermill"
	icon_state = "away3"

//Packer Ship Areas

/area/awaymission/BMPship
	name = "BMP Asteroids"
	icon_state = "away"


/area/awaymission/BMPship/Aft
	name = "Aft Block"
	icon_state = "away1"
	requires_power = 1

/area/awaymission/BMPship/Midship
	name = "Midship Block"
	icon_state = "away2"
	requires_power = 1

/area/awaymission/BMPship/Fore
	name = "Fore Block"
	icon_state = "away3"
	requires_power = 1


//Academy Areas

/area/awaymission/academy
	name = "Academy Asteroids"
	icon_state = "away"

/area/awaymission/academy/headmaster
	name = "Academy Fore Block"
	icon_state = "away1"

/area/awaymission/academy/classrooms
	name = "Academy Classroom Block"
	icon_state = "away2"

/area/awaymission/academy/academyaft
	name = "Academy Ship Aft Block"
	icon_state = "away3"

/area/awaymission/academy/academygate
	name = "Academy Gateway"
	icon_state = "away4"

/area/awaymission/academy/academycellar
	name = "Academy Cellar"
	icon_state = "away4"

/area/awaymission/academy/academyengine
	name = "Academy Engine"
	icon_state = "away4"



//Wild West Areas

/area/awaymission/wwmines
	name = "Wild West Mines"
	icon_state = "away1"
	requires_power = 0

/area/awaymission/wwgov
	name = "Wild West Mansion"
	icon_state = "away2"
	requires_power = 0

/area/awaymission/wwrefine
	name = "Wild West Refinery"
	icon_state = "away3"
	requires_power = 0

/area/awaymission/wwvault
	name = "Wild West Vault"
	icon_state = "away3"

/area/awaymission/wwvaultdoors
	name = "Wild West Vault Doors"  // this is to keep the vault area being entirely lit because of requires_power
	icon_state = "away2"
	requires_power = 0


/*
 * Areas
 */
 //Gateroom gets its own APC specifically for the gate
 /area/awaymission/gateroom

 //Library, medbay, storage room
 /area/awaymission/southblock

 //Arrivals, security, hydroponics, shuttles (since they dont move, they dont need specific areas)
 /area/awaymission/arrivalblock

 //Crew quarters, cafeteria, chapel
 /area/awaymission/midblock

 //engineering, bridge (not really north but it doesnt really need its own APC)
 /area/awaymission/northblock

 //That massive research room
 /area/awaymission/research

//Syndicate shuttle
/area/awaymission/syndishuttle


//Spacebattle Areas

/area/awaymission/spacebattle
	name = "Space Battle"
	icon_state = "away"
	requires_power = 0

/area/awaymission/spacebattle/cruiser
	name = "Nanotrasen Cruiser"

/area/awaymission/spacebattle/syndicate1
	name = "Syndicate Assault Ship 1"

/area/awaymission/spacebattle/syndicate2
	name = "Syndicate Assault Ship 2"

/area/awaymission/spacebattle/syndicate3
	name = "Syndicate Assault Ship 3"

/area/awaymission/spacebattle/syndicate4
	name = "Syndicate War Sphere 1"

/area/awaymission/spacebattle/syndicate5
	name = "Syndicate War Sphere 2"

/area/awaymission/spacebattle/syndicate6
	name = "Syndicate War Sphere 3"

/area/awaymission/spacebattle/syndicate7
	name = "Syndicate Fighter"

/area/awaymission/spacebattle/secret
	name = "Hidden Chamber"


//Snow Valley Areas//--

/area/awaymission/snowdin
	name = "Snowdin Tundra Plains"
	icon_state = "away"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED

/area/awaymission/snowdin/post
	name = "Snowdin Outpost"
	requires_power = 1

/area/awaymission/snowdin/igloo
	name = "Snowdin Igloos"
	icon_state = "away2"

/area/awaymission/snowdin/cave
	name = "Snowdin Caves"
	icon_state = "away2"

/area/awaymission/snowdin/base
	name = "Snowdin Main Base"
	icon_state = "away3"
	requires_power = 1

/area/awaymission/snowdin/dungeon1
	name = "Snowdin Depths"
	icon_state = "away2"

/area/awaymission/snowdin/sekret
	name = "Snowdin Operations"
	icon_state = "away3"
	requires_power = 1



/area/awaycontent
	name = "space"

/area/awaycontent/a1
	icon_state = "awaycontent1"

/area/awaycontent/a2
	icon_state = "awaycontent2"

/area/awaycontent/a3
	icon_state = "awaycontent3"

/area/awaycontent/a4
	icon_state = "awaycontent4"

/area/awaycontent/a5
	icon_state = "awaycontent5"

/area/awaycontent/a6
	icon_state = "awaycontent6"

/area/awaycontent/a7
	icon_state = "awaycontent7"

/area/awaycontent/a8
	icon_state = "awaycontent8"

/area/awaycontent/a9
	icon_state = "awaycontent9"

/area/awaycontent/a10
	icon_state = "awaycontent10"

/area/awaycontent/a11
	icon_state = "awaycontent11"

/area/awaycontent/a11
	icon_state = "awaycontent12"

/area/awaycontent/a12
	icon_state = "awaycontent13"

/area/awaycontent/a13
	icon_state = "awaycontent14"

/area/awaycontent/a14
	icon_state = "awaycontent14"

/area/awaycontent/a15
	icon_state = "awaycontent15"

/area/awaycontent/a16
	icon_state = "awaycontent16"

/area/awaycontent/a17
	icon_state = "awaycontent17"

/area/awaycontent/a18
	icon_state = "awaycontent18"

/area/awaycontent/a19
	icon_state = "awaycontent19"

/area/awaycontent/a20
	icon_state = "awaycontent20"

/area/awaycontent/a21
	icon_state = "awaycontent21"

/area/awaycontent/a22
	icon_state = "awaycontent22"

/area/awaycontent/a23
	icon_state = "awaycontent23"

/area/awaycontent/a24
	icon_state = "awaycontent24"

/area/awaycontent/a25
	icon_state = "awaycontent25"

/area/awaycontent/a26
	icon_state = "awaycontent26"

/area/awaycontent/a27
	icon_state = "awaycontent27"

/area/awaycontent/a28
	icon_state = "awaycontent28"

/area/awaycontent/a29
	icon_state = "awaycontent29"

/area/awaycontent/a30
	icon_state = "awaycontent30"
