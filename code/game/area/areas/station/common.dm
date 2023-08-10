/area/station/commons
	name = "\improper Crew Facilities"
	icon_state = "commons"
	sound_environment = SOUND_AREA_STANDARD_STATION
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/*
* Dorm Areas
*/

/area/station/commons/dorms
	name = "\improper Dormitories"
	icon_state = "dorms"

/area/station/commons/dorms/room1
	name = "\improper Dorms Room 1"
	icon_state = "room1"

/area/station/commons/dorms/room2
	name = "\improper Dorms Room 2"
	icon_state = "room2"

/area/station/commons/dorms/room3
	name = "\improper Dorms Room 3"
	icon_state = "room3"

/area/station/commons/dorms/room4
	name = "\improper Dorms Room 4"
	icon_state = "room4"

/area/station/commons/dorms/apartment1
	name = "\improper Dorms Apartment 1"
	icon_state = "apartment1"

/area/station/commons/dorms/apartment2
	name = "\improper Dorms Apartment 2"
	icon_state = "apartment2"

/area/station/commons/dorms/barracks
	name = "\improper Sleep Barracks"

/area/station/commons/dorms/barracks/male
	name = "\improper Male Sleep Barracks"
	icon_state = "dorms_male"

/area/station/commons/dorms/barracks/female
	name = "\improper Female Sleep Barracks"
	icon_state = "dorms_female"

/area/station/commons/dorms/laundry
	name = "\improper Laundry Room"
	icon_state = "laundry_room"

/area/station/commons/toilet
	name = "\improper Dormitory Toilets"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/commons/toilet/auxiliary
	name = "\improper Auxiliary Restrooms"
	icon_state = "toilet"

/area/station/commons/toilet/locker
	name = "\improper Locker Toilets"
	icon_state = "toilet"

/area/station/commons/toilet/restrooms
	name = "\improper Restrooms"
	icon_state = "toilet"

/*
* Rec and Locker Rooms
*/

/area/station/commons/locker
	name = "\improper Locker Room"
	icon_state = "locker"

/area/station/commons/lounge
	name = "\improper Bar Lounge"
	icon_state = "lounge"
	mood_bonus = 5
	mood_message = "I love being in the bar!"
	mood_trait = TRAIT_EXTROVERT
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/commons/fitness
	name = "\improper Fitness Room"
	icon_state = "fitness"

/area/station/commons/fitness/locker_room
	name = "\improper Unisex Locker Room"
	icon_state = "locker"

/area/station/commons/fitness/locker_room/male
	name = "\improper Male Locker Room"
	icon_state = "locker_male"

/area/station/commons/fitness/locker_room/female
	name = "\improper Female Locker Room"
	icon_state = "locker_female"

/area/station/commons/fitness/recreation
	name = "\improper Recreation Area"
	icon_state = "rec"

/area/station/commons/fitness/recreation/entertainment
	name = "\improper Entertainment Center"
	icon_state = "entertainment"

/*
* Vacant Rooms
*/

/area/station/commons/vacant_room
	name = "\improper Vacant Room"
	icon_state = "vacant_room"
	ambience_index = AMBIENCE_MAINT

/area/station/commons/vacant_room/office
	name = "\improper Vacant Office"
	icon_state = "vacant_office"

/area/station/commons/vacant_room/commissary
	name = "\improper Vacant Commissary"
	icon_state = "vacant_commissary"

/*
* Storage Rooms
*/

/area/station/commons/storage
	name = "\improper Commons Storage"

/area/station/commons/storage/tools
	name = "\improper Auxiliary Tool Storage"
	icon_state = "tool_storage"

/area/station/commons/storage/primary
	name = "\improper Primary Tool Storage"
	icon_state = "primary_storage"

/area/station/commons/storage/art
	name = "\improper Art Supply Storage"
	icon_state = "art_storage"

/area/station/commons/storage/emergency/starboard
	name = "\improper Starboard Emergency Storage"
	icon_state = "emergency_storage"

/area/station/commons/storage/emergency/port
	name = "\improper Port Emergency Storage"
	icon_state = "emergency_storage"

/area/station/commons/storage/mining
	name = "\improper Public Mining Storage"
	icon_state = "mining_storage"
