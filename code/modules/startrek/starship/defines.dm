/datum/sector_object/starship
	obj_name = "Starship"
	var/ship_class  = "None"
	var/ship_type = "Freighter"
	var/warpspeed_max = 8.2
	var/warpspeed = 0
	var/total_power = 0
	var/list/z_levels = list()
	var/datum/sm_node/current_node = null
	var/cur_crew = 0
	var/ai_mode = "Federation"
	var/hailing_mode = "none" //Receptive, opened, closed
	onscreen_image = ""

/datum/sector_object/starship/pc
	obj_name = "Federation Starship"
	descrip = "An Oberth class Federation starship."
	ship_class = "Oberth"
	z_levels = list(2,3) //Temporary

/datum/sector_object/starship/rom_warbird
	obj_name = "IRW "
	ship_class = "Warbird"
	descrip = "A large, powerful Romulan vessel. It's probably hostile. Initiate hailing frequencies or blow it away!"
	is_away_mission = 0
	map_file = ""
	chance = 3
	faction = "Romulan"
	shields = 80
	weapons = 25
	ai_mode = "aggressive"
	hailing_mode = "receptive"
	cur_crew = 180

	New()
		..()
		obj_name = obj_name + pick("Adamant","Aulius","Cathex","Crolvius","Daami","Decius","D'dederix","Esemar","Ganelax","Harax","Pacestius")

/datum/sector_object/starship/kling_prey
	obj_name = "IKW "
	ship_class = "Bird of Prey"
	descrip = "A medium-sized, capable Klingon attack vessel. They are allied with the Federation and might initiate hailing."
	is_away_mission = 0
	map_file = ""
	chance = 5
	faction = "Klingon"
	shields = 55
	weapons = 50
	ai_mode = "friendly"
	hailing_mode = "receptive"
	cur_crew = 420

	New()
		..()
		obj_name = obj_name + pick("Khronus","Rampager","Destroyer","Desecrator","Annihilator","Obliterator","Slasher","Piercer","Bloodshed","Overlord","Krom II")

/datum/sector_object/starship/ferengi_marauder
	obj_name  = "FAS "
	ship_class = "D'Kora Marauder"
	descrip = "An advanced starship utilized by the Ferengi."
	is_away_mission = 0
	map_file = ""
	chance = 6
	faction = "Ferengi"
	shields = 70
	weapons = 75
	ai_mode = "friendly"
	hailing_mode = "receptive"
	cur_crew = 100

	New()
		..()
		obj_name = obj_name + pick("Latinum Ranger","Ode to Nog","Nog's Bounty","Nogaholic","Nog's Treasure","Lusty Quark","Barmaid's Delight","Slot Machine","Drunk's Luck","Tellurian Spicemaster","Nog's Place")