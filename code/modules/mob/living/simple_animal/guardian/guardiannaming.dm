
/datum/guardianname
	var/prefixname = "Default"
	var/suffixcolour = "Name"
	var/theme = "guardian"
	var/colour = "#FFFFFF"

/datum/guardianname/magic/New()
	prefixname = pick("Aries", "Leo", "Sagittarius", "Taurus", "Virgo", "Capricorn", "Gemini", "Libra", "Aquarius", "Cancer", "Scorpio", "Pisces")

/datum/guardianname/magic/red
	suffixcolour = "Red"
	colour = "#E32114"

/datum/guardianname/magic/pink
	suffixcolour = "Pink"
	colour = "#FB5F9B"

/datum/guardianname/magic/orange
	suffixcolour = "Orange"
	colour = "#F3CF24"

/datum/guardianname/magic/green
	suffixcolour = "Green"
	colour = "#A4E836"

/datum/guardianname/magic/blue
	suffixcolour = "Blue"
	colour = "#78C4DB"

/datum/guardianname/tech
	theme = "holo"

/datum/guardianname/tech/New()
	prefixname = pick("Gallium", "Indium", "Thallium", "Bismuth", "Aluminium", "Mercury", "Iron", "Silver", "Zinc", "Titanium", "Chromium", "Nickel", "Platinum", "Tellurium", "Palladium", "Rhodium", "Cobalt", "Osmium", "Tungsten", "Iridium")

/datum/guardianname/tech/rose
	suffixcolour = "Rose"
	colour = "#F62C6B"

/datum/guardianname/tech/peony
	suffixcolour = "Peony"
	colour = "#E54750"

/datum/guardianname/tech/lily
	suffixcolour = "Lily"
	colour = "#F6562C"

/datum/guardianname/tech/daisy
	suffixcolour = "Daisy"
	colour = "#F6F446"

/datum/guardianname/tech/zinnia
	suffixcolour = "Zinnia"
	colour = "#BFF62C"

/datum/guardianname/tech/ivy
	suffixcolour = "Ivy"
	colour = "#5DF62C"

/datum/guardianname/tech/iris
	suffixcolour = "Iris"
	colour = "#2CF6B8"

/datum/guardianname/tech/petunia
	suffixcolour = "Petunia"
	colour = "#51A9D4"

/datum/guardianname/tech/violet
	suffixcolour = "Violet"
	colour = "#8A347C"

/datum/guardianname/tech/lotus
	suffixcolour = "Lotus"
	colour = "#463546"

/datum/guardianname/tech/lilac
	suffixcolour = "Lilac"
	colour = "#C7A0F6"

/datum/guardianname/tech/orchid
	suffixcolour = "Orchid"
	colour = "#F62CF5"
