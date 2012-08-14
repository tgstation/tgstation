  /////////////////////////////////////////////////////////////////////////////
 //Contents: Map datums for use with runtime map loading, and voteable maps.//
/////////////////////////////////////////////////////////////////////////////

map
	var
		name = "Default/Debug Map"
		desc = "You should not see this, tell a coder."
		is_playable = 1
		is_flotilla = 0
		relative_path = "maps/tgstation.2.0.8.dmm" //Path from the .dmb file to the map.  Set to TG station in case of derp.

		x = 1
		y = 1
		z = 1

		engsec_job_flags = 0
		list/engsec_spawn_positions = list()
		list/engsec_total_positions = list()

		medsci_job_flags = 0
		list/medsci_spawn_positions = list()
		list/medsci_total_positions = list()

		civilian_job_flags = 0
		list/civilian_spawn_positions = list()
		list/civilian_total_positions = list()



map/tg_station
	name = "/TG/'s SS13 map, TGstation 2.0.8"
	desc = "A large map featuring a space station, derelict, mining asteroid, and communication satelite."
	relative_path = "maps/tgstation.2.0.8.dmm"
	x = 255
	y = 255
	z = 6

//All possible jobs availible.
	engsec_job_flags = CAPTAIN|HOS|WARDEN|DETECTIVE|OFFICER|CHIEF|ENGINEER|ATMOSTECH|ROBOTICIST|AI|CYBORG
	engsec_spawn_positions = list("[CAPTAIN]" = 1,


	medsci_job_flags = RD|SCIENTIST|CHEMIST|CMO|DOCTOR|GENETICIST


	civilian_job_flags = HOP|BARTENDER|BOTANIST|CHEF|JANITOR|LIBRARIAN|QUARTERMASTER|CARGOTECH|MINER|LAWYER|CHAPLAIN|CLOWN|MIME|ASSISTANT