#define GUARDIANCOLOROVERLAY "color overlay" //Used with spritecolor var for guardians to determine what color to apply
#define GUARDIANCOLORBASE "color base"
#define GUARDIANCOLORBOTH "color both"
#define GUARDIANCOLORNONE "color none"
/datum/guardianname
	var/prefixname = "Default" //the prefix the guardian uses for its name
	var/suffixcolour = "Name" //the suffix the guardian uses for its name
	var/parasitebaseicon = "techbase" //the icon of the guardian
	var/parasiteoverlayicon = "techglowbase"
	var/bubbleicon = "holo" //the speechbubble icon of the guardian
	var/theme = "tech" //what the actual theme of the guardian is
	var/colour = "#C3C3C3" //what color the guardian's name is in chat and what color is used for effects from the guardian
	var/spritecolor = GUARDIANCOLOROVERLAY //whether to use the color var to literally dye ourself our chosen colour.

/datum/guardianname/proc/update(mob/living/simple_animal/hostile/guardian/G)
	G.name = "[prefixname] [suffixcolour]"
	G.real_name = "[G.name]"
	G.icon_living = "[parasitebaseicon]"
	G.icon_state = "[parasitebaseicon]"
	G.icon_dead = "[parasitebaseicon]"
	G.bubble_icon = "[bubbleicon]"

	G.overlays.Cut()
	if(parasiteoverlayicon)
		G.guardianoverlay = image('icons/mob/guardian.dmi',parasiteoverlayicon)

	switch(spritecolor)
		if(GUARDIANCOLORBASE)
			G.color = colour
		if(GUARDIANCOLOROVERLAY)
			G.guardianoverlay.color = colour
		if(GUARDIANCOLORBOTH)
			G.color = colour
			G.guardianoverlay.color = colour

	if(parasiteoverlayicon)
		G.overlays += G.guardianoverlay

/datum/guardianname/carp
	bubbleicon = "guardian"
	theme = "carp"
	parasitebaseicon = "holocarp"
	parasiteoverlayicon = null
	spritecolor = GUARDIANCOLORBASE

/datum/guardianname/carp/New()
	prefixname = pick(carp_names)

/datum/guardianname/carp/update(mob/living/simple_animal/hostile/guardian/G)
	..()
	G.speak_emote = list("gnashes")
	G.desc = "A mysterious fish that stands by its charge, ever vigilant."

	G.attacktext = "bites"
	G.attack_sound = 'sound/weapons/bite.ogg'

/datum/guardianname/carp/seagreen
	suffixcolour = "Sea Green"
	colour = "#2E8B57"

/datum/guardianname/carp/ultramarine
	suffixcolour = "Ultramarine"
	colour = "#3F00FF"

/datum/guardianname/carp/cerulean
	suffixcolour = "Cerulean"
	colour = "#007BA7"

/datum/guardianname/carp/aqua
	suffixcolour = "Aqua"
	colour = "#00FFFF"

/datum/guardianname/carp/paleaqua
	suffixcolour = "Pale Aqua"
	colour = "#BCD4E6"

/datum/guardianname/carp/hookergreen
	suffixcolour = "Hooker Green"
	colour = "#49796B"

/datum/guardianname/magic
	bubbleicon = "guardian"
	theme = "magic"
	parasiteoverlayicon = null
	spritecolor = GUARDIANCOLORNONE

/datum/guardianname/magic/New()
	prefixname = pick("Aries", "Leo", "Sagittarius", "Taurus", "Virgo", "Capricorn", "Gemini", "Libra", "Aquarius", "Cancer", "Scorpio", "Pisces", "Ophiuchus")

/datum/guardianname/magic/red
	suffixcolour = "Red"
	parasitebaseicon = "magicRed"
	colour = "#E32114"

/datum/guardianname/magic/pink
	suffixcolour = "Pink"
	parasitebaseicon = "magicPink"
	colour = "#FB5F9B"

/datum/guardianname/magic/orange
	suffixcolour = "Orange"
	parasitebaseicon = "magicOrange"
	colour = "#F3CF24"

/datum/guardianname/magic/green
	suffixcolour = "Green"
	parasitebaseicon = "magicGreen"
	colour = "#A4E836"

/datum/guardianname/magic/blue
	suffixcolour = "Blue"
	parasitebaseicon = "magicBlue"
	colour = "#78C4DB"

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
	colour = "#ECCD39"

/datum/guardianname/tech/zinnia
	suffixcolour = "Zinnia"
	colour = "#89F62C"

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

#undef GUARDIANCOLOROVERLAY
#undef GUARDIANCOLORBASE
#undef GUARDIANCOLORBOTH
#undef GUARDIANCOLORNONE