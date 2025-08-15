/area/station/medical
	name = "Medical"
	icon_state = "medbay"
	ambience_index = AMBIENCE_MEDICAL
	airlock_wires = /datum/wires/airlock/medbay
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/medical/abandoned
	name = "\improper Abandoned Medbay"
	icon_state = "abandoned_medbay"
	ambientsounds = list(
		'sound/ambience/misc/signal.ogg',
		)
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/medical/medbay/central
	name = "Medbay Central"
	icon_state = "med_central"

/area/station/medical/lower
	name = "\improper Lower Medbay"
	icon_state = "lower_med"

/area/station/medical/medbay/lobby
	name = "\improper Medbay Lobby"
	icon_state = "med_lobby"

/area/station/medical/medbay/aft
	name = "Medbay Aft"
	icon_state = "med_aft"

/area/station/medical/storage
	name = "Medbay Storage"
	icon_state = "med_storage"

/area/station/medical/paramedic
	name = "Paramedic Dispatch"
	icon_state = "paramedic"

/area/station/medical/office
	name = "\improper Medical Office"
	icon_state = "med_office"

/area/station/medical/break_room
	name = "\improper Medical Break Room"
	icon_state = "med_break"

/area/station/medical/coldroom
	name = "\improper Medical Cold Room"
	icon_state = "kitchen_cold"

/area/station/medical/patients_rooms
	name = "\improper Patients' Rooms"
	icon_state = "patients"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/medical/patients_rooms/room_a
	name = "Patient Room A"
	icon_state = "patients"

/area/station/medical/patients_rooms/room_b
	name = "Patient Room B"
	icon_state = "patients"

/area/station/medical/virology
	name = "Virology"
	icon_state = "virology"
	ambience_index = AMBIENCE_VIROLOGY

/area/station/medical/virology/isolation
	name = "Virology Isolation"
	icon_state = "virology_isolation"

/area/station/medical/morgue
	name = "\improper Morgue"
	icon_state = "morgue"
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/medical/chemistry
	name = "Chemistry"
	icon_state = "chem"

/area/station/medical/chemistry/minisat
	name = "Chemistry Mini-Satellite"

/area/station/medical/pharmacy
	name = "\improper Pharmacy"
	icon_state = "pharmacy"

/area/station/medical/chem_storage
	name = "\improper Chemical Storage"
	icon_state = "chem_storage"

/area/station/medical/surgery
	name = "\improper Operating Room"
	icon_state = "surgery"

/area/station/medical/surgery/fore
	name = "\improper Fore Operating Room"
	icon_state = "foresurgery"

/area/station/medical/surgery/aft
	name = "\improper Aft Operating Room"
	icon_state = "aftsurgery"

/area/station/medical/surgery/theatre
	name = "\improper Grand Surgery Theatre"
	icon_state = "surgerytheatre"

/area/station/medical/cryo
	name = "Cryogenics"
	icon_state = "cryo"

/area/station/medical/exam_room
	name = "\improper Exam Room"
	icon_state = "exam_room"

/area/station/medical/treatment_center
	name = "\improper Medbay Treatment Center"
	icon_state = "exam_room"

/area/station/medical/psychology
	name = "\improper Psychology Office"
	icon_state = "psychology"
	mood_bonus = 3
	mood_message = "I feel at ease here."
	ambientsounds = list(
		'sound/ambience/aurora_caelus/aurora_caelus_short.ogg',
		)
