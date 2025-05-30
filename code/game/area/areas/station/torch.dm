/area/station/commons/upper_cryo
	name = "\improper Upper Cryogenics"
	area_flags = UNIQUE_AREA | EVENT_PROTECTED

/area/station/commons/upper_cryo/on_joining_game(mob/living/new_character)

/area/station/commons/lower_cryo
	name = "\improper Lower Cryogenics"
	area_flags = UNIQUE_AREA | EVENT_PROTECTED

/area/station/commons/lower_cryo/on_joining_game(mob/living/new_character)

/area/station/commons/storage/emergency/first
	name = "\improper 3st Floor Emergency Storage"

/area/station/commons/storage/emergency/second
	name = "\improper 4nd Floor Emergency Storage"

/area/station/commons/storage/emergency/third
	name = "\improper 5rd Floor Emergency Storage"

/area/station/commons/storage/emergency/fourth
	name = "\improper 6th Floor Emergency Storage"

/area/station/commons/toilet/fitroom
	name = "\improper Fitness Room Restroom"

/area/station/commons/lounge/command
	name = "\improper Corporate Lounge"
	sound_environment = SOUND_ENVIRONMENT_LIVINGROOM

/area/station/commons/toilet/lower_cryo
	name = "\improper 3nd Floor Primary Restroom"
	area_flags = UNIQUE_AREA | EVENT_PROTECTED

/area/station/commons/toilet/upper_cryo
	name = "\improper 5th Floor Primary Restroom"
	area_flags = UNIQUE_AREA | EVENT_PROTECTED

/area/station/commons/toilet/evac
	name = "\improper 2nd Floor Primary Restroom"
	area_flags = UNIQUE_AREA | EVENT_PROTECTED

/area/station/command/heads_quarters/hop/line
	name = "\improper Access Line"

/area/station/command/heads_quarters/hop/quarters
	name = "\improper Executive Officer's Quarters"

/area/station/command/heads_quarters/hos/quarters
	name = "\improper Head of Security's Quarters"

/area/station/engineering/supermatter_command
	name = "\improper Supermatter Control Room"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/gravity_generator_command
	name = "\improper Gravity Generator Control Room"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/storage/secure
	name = "\improper Engineering Hard Storage"

/area/station/medical/surgery/room_a
	name = "\improper Operating Room A"

/area/station/medical/surgery/room_b
	name = "\improper Operating Room B"

/area/station/medical/bathroom
	name = "\improper Medbay Decontamination Room"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/medical/morgue/office
	name = "\improper Morgue Office"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/medical/storage/auxiliary
	name = "\improper Medbay Auxiliary Storage"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/cargo/storage/auxiliary
	name = "\improper Cargo Auxiliary Storage"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/security/checkpoint/first/alt
	name = "1st Floor Security Post"
	icon_state = "checkpoint_1"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/security/checkpoint/second/alt
	name = "2nd Floor Security Post"
	icon_state = "checkpoint_2"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/security/checkpoint/third/alt
	name = "3rd Floor Security Post"
	icon_state = "checkpoint_3"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/security/checkpoint/fourth
	name = "4th Floor Security Post"
	icon_state = "checkpoint_3" // lol
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/security/checkpoint/fifth
	name = "5th Floor Security Post"
	icon_state = "checkpoint_3"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/security/checkpoint/sixth
	name = "6th Floor Security Post"
	icon_state = "checkpoint_3"

/area/station/science/robotics/office
	name = "\improper Robotics Office"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/science/storage
	name = "\improper Auxiliary Research Division Storage"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/holodeck_control
	name = "\improper Holodeck Control Room"
	icon_state = "Holodeck"

/area/station/maintenance/department/engine/atmos/aux
	name = "\improper Auxiliary Atmospherics"

/area/station/commons/port_dock
	name = "\improper Port Docking Bay"

/area/station/commons/port_dock/storage
	name = "\improper Port Docking Bay Storage"

/area/station/commons/starboard_dock
	name = "\improper Starboard Docking Bay"

/area/station/commons/starboard_dock/storage
	name = "\improper Starboard Docking Bay Storage"

/area/station/cargo/mining_breakroom/storage
	name = "\improper Mining Storage"

/area/station/cargo/mining_breakroom/eva
	name = "\improper Mining EVA Storage"

/area/station/medical/emergency_infirmary
	name = "\improper Emergency Infimary"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/shuttle/ship
	name = "\improper Mining FOB Ship"
	ambient_buzz = 'sound/ambience/general/shipambience.ogg'

/area/shuttle/mining_ship/cockpit
	name = "\improper Mining FOB Ship Cockpit"

/area/shuttle/mining_ship/eva
	name = "\improper Mining FOB Ship EVA"

/area/shuttle/mining_ship/power_maintenance
	name = "\improper Mining FOB Ship Power Maintenance"

/area/shuttle/mining_ship/atmos_maintenance
	name = "\improper Mining FOB Ship Atmospherics Maintenance"

/area/shuttle/mining_ship/engine_maintenance
	name = "\improper Mining FOB Ship Engine Maintenance"

/area/shuttle/mining_ship/medbay
	name = "\improper Mining FOB Ship Medbay"

/area/shuttle/mining_ship/storage
	name = "\improper Mining FOB Ship Cargo Hold"

/area/station/maintenance/floor5
	name = "\improper 5th Floor Maint"

/area/station/maintenance/floor5/port
	name = "\improper 5th Floor Central Port Maint"
	icon_state = "maintcentral"

/area/station/maintenance/floor5/port/fore
	name = "\improper 5th Floor Fore Port Maint"
	icon_state = "maintfore"

/area/station/maintenance/floor5/port/aft
	name = "\improper 5th Floor Aft Port Maint"
	icon_state = "maintaft"

/area/station/maintenance/floor5/starboard
	name = "\improper 5th Floor Central Starboard Maint"
	icon_state = "maintcentral"

/area/station/maintenance/floor5/starboard/fore
	name = "\improper 5th Floor Fore Starboard Maint"
	icon_state = "maintfore"

/area/station/maintenance/floor5/starboard/aft
	name = "\improper 5th Floor Aft Starboard Maint"
	icon_state = "maintaft"

/area/station/maintenance/floor6
	name = "\improper 6th Floor Maint"

/area/station/maintenance/floor6/port
	name = "\improper 6th Floor Central Port Maint"

/area/station/maintenance/floor6/port/fore
	name = "\improper 6th Floor Fore Port Maint"
	icon_state = "maintfore"

/area/station/maintenance/floor6/port/aft
	name = "\improper 6th Floor Aft Port Maint"
	icon_state = "maintaft"

/area/station/maintenance/floor6/starboard
	name = "\improper 6th Floor Central Starboard Maint"

/area/station/maintenance/floor6/starboard/fore
	name = "\improper 6th Floor Fore Starboard Maint"
	icon_state = "maintfore"

/area/station/maintenance/floor6/starboard/aft
	name = "\improper 6th Floor Aft Starboard Maint"
	icon_state = "maintaft"

/area/station/hallway/floor5
	name = "\improper Fifth Floor Hallway"

/area/station/hallway/floor5/aft
	name = "\improper Fifth Floor Aft Hallway"
	icon_state = "4_aft"

/area/station/hallway/floor5/fore
	name = "\improper Fifth Floor Fore Hallway"
	icon_state = "4_fore"

/area/station/hallway/floor6
	name = "\improper Sixth Floor Hallway"

/area/station/hallway/floor6/aft
	name = "\improper Sixth Floor Aft Hallway"
	icon_state = "5_aft"

/area/station/hallway/floor6/fore
	name = "\improper Sixth Floor Fore Hallway"
	icon_state = "5_fore"

/area/station/command/bridge_office
	name = "\improper Bridge Office"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/ai_monitored/command/storage/eva/command
	name = "\improper Command EVA Storage"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/cargo/hanger
	name = "\improper Hanger Bay"
	icon_state = "cargo_hanger"
	sound_environment = SOUND_ENVIRONMENT_HANGAR

/area/station/cargo/hanger/fuel
	name = "\improper Hanger Fuel Storage"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/cargo/hanger/heavy_storage
	name = "\improper Hanger Heavy Machinery Storage"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/cargo/hanger/pump_storage
	name = "\improper Hanger Pumping Room"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/commons/storage/mining/eva
	name = "\improper Public Mining EVA Storage"

/area/station/maintenance/radshelter/command
	name = "\improper Command Radstorm Shelter"

/area/station/maintenance/radshelter/engineering
	name = "\improper Engineering Radstorm Shelter"

/area/station/ai_monitored/security/armory/restricted
	name = "\improper Restricted Armory"

/area/station/ai_monitored/security/armory/restricted/desk
	name = "\improper Restricted Armory Desk"
	icon_state = "armory_desk"

/area/station/command/teleporter/deck_five
	name = "\improper Deck Five Teleporter Room"

/area/station/command/teleporter/deck_three
	name = "\improper Deck Three Teleporter Room"
