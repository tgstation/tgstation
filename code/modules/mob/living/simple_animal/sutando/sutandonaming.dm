
/datum/sutandoname
	var/prefixname = "Default" //the prefix the sutando uses for its name
	var/suffixcolour = "Name" //the suffix the sutando uses for its name
	var/parasiteicon = "techbase" //the icon of the sutando
	var/bubbleicon = "holo" //the speechbubble icon of the sutando
	var/theme = "tech" //what the actual theme of the sutando is
	var/colour = "#C3C3C3" //what color the sutando's name is in chat and what color is used for effects from the sutando
	var/stainself = 0 //whether to use the color var to literally dye ourself our chosen colour, for lazy spriting

/datum/sutandoname/carp
	bubbleicon = "sutando"
	theme = "carp"
	parasiteicon = "holocarp"
	stainself = 1

/datum/sutandoname/carp/New()
	prefixname = pick(carp_names)

/datum/sutandoname/carp/sand
	suffixcolour = "Sand"
	colour = "#C2B280"

/datum/sutandoname/carp/seashell
	suffixcolour = "Seashell"
	colour = "#FFF5EE"

/datum/sutandoname/carp/coral
	suffixcolour = "Coral"
	colour = "#FF7F50"

/datum/sutandoname/carp/salmon
	suffixcolour = "Salmon"
	colour = "#FA8072"

/datum/sutandoname/carp/sunset
	suffixcolour = "Sunset"
	colour = "#FAD6A5"

/datum/sutandoname/carp/riptide
	suffixcolour = "Riptide"
	colour = "#89D9C8"

/datum/sutandoname/carp/seagreen
	suffixcolour = "Sea Green"
	colour = "#2E8B57"

/datum/sutandoname/carp/ultramarine
	suffixcolour = "Ultramarine"
	colour = "#3F00FF"

/datum/sutandoname/carp/cerulean
	suffixcolour = "Cerulean"
	colour = "#007BA7"

/datum/sutandoname/carp/aqua
	suffixcolour = "Aqua"
	colour = "#00FFFF"

/datum/sutandoname/carp/paleaqua
	suffixcolour = "Pale Aqua"
	colour = "#BCD4E6"

/datum/sutandoname/carp/hookergreen
	suffixcolour = "Hooker Green"
	colour = "#49796B"

/datum/sutandoname/magic
	bubbleicon = "sutando"
	theme = "magic"

/datum/sutandoname/magic/New()
	prefixname = pick("Aries", "Leo", "Sagittarius", "Taurus", "Virgo", "Capricorn", "Gemini", "Libra", "Aquarius", "Cancer", "Scorpio", "Pisces", "Ophiuchus")

/datum/sutandoname/magic/red
	suffixcolour = "Red"
	parasiteicon = "magicRed"
	colour = "#E32114"

/datum/sutandoname/magic/pink
	suffixcolour = "Pink"
	parasiteicon = "magicPink"
	colour = "#FB5F9B"

/datum/sutandoname/magic/orange
	suffixcolour = "Orange"
	parasiteicon = "magicOrange"
	colour = "#F3CF24"

/datum/sutandoname/magic/green
	suffixcolour = "Green"
	parasiteicon = "magicGreen"
	colour = "#A4E836"

/datum/sutandoname/magic/blue
	suffixcolour = "Blue"
	parasiteicon = "magicBlue"
	colour = "#78C4DB"

/datum/sutandoname/tech/New()
	prefixname = pick("Gallium", "Indium", "Thallium", "Bismuth", "Aluminium", "Mercury", "Iron", "Silver", "Zinc", "Titanium", "Chromium", "Nickel", "Platinum", "Tellurium", "Palladium", "Rhodium", "Cobalt", "Osmium", "Tungsten", "Iridium")

/datum/sutandoname/tech/rose
	suffixcolour = "Rose"
	parasiteicon = "techRose"
	colour = "#F62C6B"

/datum/sutandoname/tech/peony
	suffixcolour = "Peony"
	parasiteicon = "techPeony"
	colour = "#E54750"

/datum/sutandoname/tech/lily
	suffixcolour = "Lily"
	parasiteicon = "techLily"
	colour = "#F6562C"

/datum/sutandoname/tech/daisy
	suffixcolour = "Daisy"
	parasiteicon = "techDaisy"
	colour = "#ECCD39"

/datum/sutandoname/tech/zinnia
	suffixcolour = "Zinnia"
	parasiteicon = "techZinnia"
	colour = "#89F62C"

/datum/sutandoname/tech/ivy
	suffixcolour = "Ivy"
	parasiteicon = "techIvy"
	colour = "#5DF62C"

/datum/sutandoname/tech/iris
	suffixcolour = "Iris"
	parasiteicon = "techIris"
	colour = "#2CF6B8"

/datum/sutandoname/tech/petunia
	suffixcolour = "Petunia"
	parasiteicon = "techPetunia"
	colour = "#51A9D4"

/datum/sutandoname/tech/violet
	suffixcolour = "Violet"
	parasiteicon = "techViolet"
	colour = "#8A347C"

/datum/sutandoname/tech/lotus
	suffixcolour = "Lotus"
	parasiteicon = "techLotus"
	colour = "#463546"

/datum/sutandoname/tech/lilac
	suffixcolour = "Lilac"
	parasiteicon = "techLilac"
	colour = "#C7A0F6"

/datum/sutandoname/tech/orchid
	suffixcolour = "Orchid"
	parasiteicon = "techOrchid"
	colour = "#F62CF5"
