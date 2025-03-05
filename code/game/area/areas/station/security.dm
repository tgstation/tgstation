// When adding a new area to the security areas, make sure to add it to /datum/bounty/item/security/paperwork as well!

/area/station/security
	name = "Security"
	icon_state = "security"
	ambience_index = AMBIENCE_DANGER
	airlock_wires = /datum/wires/airlock/security
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/security/office
	name = "\improper Security Office"
	icon_state = "security"

/area/station/security/breakroom
	name = "\improper Security Break Room"
	icon_state = "brig"

/area/station/security/tram
	name = "\improper Security Transfer Tram"
	icon_state = "security"

/area/station/security/lockers
	name = "\improper Security Locker Room"
	icon_state = "securitylockerroom"

/area/station/security/brig
	name = "\improper Brig"
	icon_state = "brig"

/area/station/security/holding_cell
	name = "\improper Holding Cell"
	icon_state = "holding_cell"

/area/station/security/medical
	name = "\improper Security Medical"
	icon_state = "security_medical"

/area/station/security/brig/upper
	name = "\improper Brig Overlook"
	icon_state = "upperbrig"

/area/station/security/brig/lower
	name = "\improper Lower Brig"
	icon_state = "lower_brig"

/area/station/security/brig/entrance
	name = "\improper Brig Entrance"
	icon_state = "brigentry"

/area/station/security/courtroom
	name = "\improper Courtroom"
	icon_state = "courtroom"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/security/courtroom/holding
	name = "\improper Courtroom Prisoner Holding Room"

/area/station/security/processing
	name = "\improper Labor Shuttle Dock"
	icon_state = "sec_labor_processing"

/area/station/security/processing/cremation
	name = "\improper Security Crematorium"
	icon_state = "sec_cremation"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/security/interrogation
	name = "\improper Interrogation Room"
	icon_state = "interrogation"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/security/warden
	name = "Brig Control"
	icon_state = "warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/security/evidence
	name = "Evidence Storage"
	icon_state = "evidence"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/security/detectives_office
	name = "\improper Detective's Office"
	icon_state = "detective"
	ambientsounds = list(
		'sound/ambience/security/ambidet1.ogg',
		'sound/ambience/security/ambidet2.ogg',
		)

/area/station/security/detectives_office/private_investigators_office
	name = "\improper Private Investigator's Office"
	icon_state = "investigate_office"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/security/range
	name = "\improper Firing Range"
	icon_state = "firingrange"

/area/station/security/eva
	name = "\improper Security EVA"
	icon_state = "sec_eva"

/area/station/security/execution
	icon_state = "execution_room"

/area/station/security/execution/transfer
	name = "\improper Transfer Centre"
	icon_state = "sec_processing"

/area/station/security/execution/education
	name = "\improper Prisoner Education Chamber"

/area/station/security/mechbay
	name = "Security Mechbay"
	icon_state = "sec_mechbay"

/*
* Security Checkpoints
*/

/area/station/security/checkpoint
	name = "\improper Security Checkpoint"
	icon_state = "checkpoint"

/area/station/security/checkpoint/escape
	name = "\improper Departures Security Checkpoint"
	icon_state = "checkpoint_esc"

/area/station/security/checkpoint/arrivals
	name = "\improper Arrivals Security Checkpoint"
	icon_state = "checkpoint_arr"

/area/station/security/checkpoint/supply
	name = "Security Post - Cargo Bay"
	icon_state = "checkpoint_supp"

/area/station/security/checkpoint/engineering
	name = "Security Post - Engineering"
	icon_state = "checkpoint_engi"

/area/station/security/checkpoint/medical
	name = "Security Post - Medbay"
	icon_state = "checkpoint_med"

/area/station/security/checkpoint/medical/medsci
	name = "Security Post - Medsci"

/area/station/security/checkpoint/science
	name = "Security Post - Science"
	icon_state = "checkpoint_sci"

/area/station/security/checkpoint/science/research
	name = "Security Post - Research Division"
	icon_state = "checkpoint_res"

/area/station/security/checkpoint/customs
	name = "Customs"
	icon_state = "customs_point"

/area/station/security/checkpoint/customs/auxiliary
	name = "Auxiliary Customs"
	icon_state = "customs_point_aux"

/area/station/security/checkpoint/customs/fore
	name = "Fore Customs"
	icon_state = "customs_point_fore"

/area/station/security/checkpoint/customs/aft
	name = "Aft Customs"
	icon_state = "customs_point_aft"

/area/station/security/checkpoint/first
	name = "Security Post - First Floor"
	icon_state = "checkpoint_1"

/area/station/security/checkpoint/second
	name = "Security Post - Second Floor"
	icon_state = "checkpoint_2"

/area/station/security/checkpoint/third
	name = "Security Post - Third Floor"
	icon_state = "checkpoint_3"


/area/station/security/prison
	name = "\improper Prison Wing"
	icon_state = "sec_prison"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED | PERSISTENT_ENGRAVINGS

//Rad proof
/area/station/security/prison/toilet
	name = "\improper Prison Toilet"
	icon_state = "sec_prison_safe"

// Rad proof
/area/station/security/prison/safe
	name = "\improper Prison Wing Cells"
	icon_state = "sec_prison_safe"

/area/station/security/prison/upper
	name = "\improper Upper Prison Wing"
	icon_state = "prison_upper"

/area/station/security/prison/visit
	name = "\improper Prison Visitation Area"
	icon_state = "prison_visit"

/area/station/security/prison/rec
	name = "\improper Prison Rec Room"
	icon_state = "prison_rec"

/area/station/security/prison/mess
	name = "\improper Prison Mess Hall"
	icon_state = "prison_mess"

/area/station/security/prison/work
	name = "\improper Prison Work Room"
	icon_state = "prison_work"

/area/station/security/prison/shower
	name = "\improper Prison Shower"
	icon_state = "prison_shower"

/area/station/security/prison/workout
	name = "\improper Prison Gym"
	icon_state = "prison_workout"

/area/station/security/prison/garden
	name = "\improper Prison Garden"
	icon_state = "prison_garden"
