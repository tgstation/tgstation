/proc/station_name()
	if (station_name)
		return station_name

	var/name = ""

	if (prob(10))
		name += pick("Super", "Ultra", "Secret", "Top Secret", "Deep", "Death", "Zybourne", "Central", "Main", "Government", "Uoi", "Fat", "Automated", "Experimental")
		name += " "

	// Prefix
	name += pick("", "Space", "Star", "Moon", "System", "Mining", "Neckbeard", "Research", "Supply", "Military", "Goon", "Orbital", "Battle", "Science", "Asteroid", "Home", "Production", "Transport", "Delivery", "Extraplanetary", "Orbital", "Correctional", "Robot")
	if (name)
		name += " "

	// Suffix
	name += pick("Station", "Base", "Facility", "Depot", "Outpost", "Installation", "Drydock", "Observatory", "Array", "Relay", "Monitor", "Platform", "Construct", "Hangar", "Prison", "Center", "Port", "Waystation", "Factory", "Waypoint", "Stopover", "Hub", "HQ", "Office", "Object", "Fortification")
	name += " "

	// ID Number
	if (prob(40))
		name += "[rand(1, 99)]"
	else if (prob(50))
		name += pick("Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu", "Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega")
	else if (prob(30))
		name += pick("II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX")
	else if (prob(40))
		name += pick("Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet", "Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec", "Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "X-ray", "Yankee", "Zulu")
	else
		name += pick("One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen")

	station_name = name

	if (config && config.server_name)
		world.name = "[config.server_name]: [name]"
	else
		world.name = name

	return name
