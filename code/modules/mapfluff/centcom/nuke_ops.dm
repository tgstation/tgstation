//keycards
/obj/item/keycard/syndicate_bomb
	name = "Syndicate Ordnance Laboratory Access Card"
	desc = "A red keycard with an image of a bomb. Using this will allow you to gain access to the Ordnance Lab in Firebase Balthazord."
	color = "#9c0e26"
	puzzle_id = "syndicate_bomb"

/obj/item/keycard/syndicate_bio
	name = "Syndicate Bio-Weapon Laboratory Access Card"
	desc = "A red keycard with a biohazard symbol. Using this will allow you to gain access to the Bio-Weapon Lab in Firebase Balthazord."
	color = "#9c0e26"
	puzzle_id = "syndicate_bio"

/obj/item/keycard/syndicate_chem
	name = "Syndicate Chemical Plant Access Card"
	desc = "A red keycard with an image of a beaker. Using this will allow you to gain access to the Chemical Manufacturing Plant in Firebase Balthazord."
	color = "#9c0e26"
	puzzle_id = "syndicate_chem"

/obj/item/keycard/syndicate_fridge
	name = "Lopez's Access Card"
	desc = "A grey keycard with Lopez's Information on it. This is your ticket into the Fridge in Firebase Balthazord."
	color = "#636363"
	puzzle_id = "syndicate_fridge"

//keycard doors
/obj/machinery/door/puzzle/keycard/syndicate_bomb
	name = "Syndicate Ordinance Laboratory"
	desc = "Locked. Looks like you'll need a special access key to get in."
	puzzle_id = "syndicate_bomb"

/obj/machinery/door/puzzle/keycard/syndicate_bio
	name = "Syndicate Bio-Weapon Laboratory"
	desc = "Locked. Looks like you'll need a special access key to get in."
	puzzle_id = "syndicate_bio"

/obj/machinery/door/puzzle/keycard/syndicate_chem
	name = "Syndicate Chemical Manufacturing Plant"
	desc = "Locked. Looks like you'll need a special access key to get in."
	puzzle_id = "syndicate_chem"

/obj/machinery/door/puzzle/keycard/syndicate_fridge
	name = "The Walk-In Fridge"
	desc = "Locked. Lopez sure runs a tight galley."
	puzzle_id = "syndicate_fridge"

/// Terminals
/obj/machinery/computer/terminal/infiltrator
	desc = "A terminal running the latest build of SYNDIX. Whatever technician set this one up \
	configured it to only run via command line, and without any GUI. How will you play games on it now?"
	tguitheme = "syndicate"
	upperinfo = "YOU ARE RUNNING SYNDIX ON REVISION #31410. REPORT ANY BUGS PROMPTLY." // References the (/tg/station) PR plastitanium smoothing was added!
	content = list(
		"<b>C:/Users/ADMIN/Desktop/'Chords, Read Me.txt'</b><br> \
		Chords, I'm sorry about our last night out. I know you didn't like what you saw, and I know I dissapointed you, \
		greatly, when I acted the way I did - did what I did. I'm sorry, Chords, I can't hammer that home enough. \
		I've spent days now trying to think of something to say, trying to think of some way to fix things, and I... \
		I can't find any other than to sit here, in this shitty, dingy ass maintenance corridor, and just... type. \
		Please. I'll remember to put on my oxygen mask AND run internals properly next operation. Talk to me again.<br> \
		<br> \
		> sudo rm -rf") // This one goes out to every flukie who's forgotten their internals, including myself. Godspeed you dumb, dumb dweebs.
