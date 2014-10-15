/obj/structure/sign/barsign        // All Signs are 64 by 32 pixels, they take two tiles
	name = "Bar Sign"
	desc = "A bar sign with no writing on it"
	icon = 'icons/obj/barsigns.dmi'
	icon_state = "empty"

	req_access = list(access_bar)

	var/list/barsigns=list()

/obj/structure/sign/barsign/New()
	..()

//filling the barsigns list
	for(var/bartype in typesof(/datum/barsign) - /datum/barsign)
		var/datum/barsign/signinfo = new bartype
		barsigns += signinfo

//randomly assigning a sign
	set_sign(pick(barsigns))

/obj/structure/sign/barsign/proc/set_sign(var/datum/barsign/sign)
	if(!istype(sign))
		return
	icon_state = sign.icon
	name = sign.name
	if(sign.desc)
		desc = sign.desc
	else
		desc = "It displays \"[name]\"."

/obj/structure/sign/barsign/attack_ai(mob/user as mob)
	return src.attack_hand(user)


/obj/structure/sign/barsign/attack_hand(mob/user as mob)
	if (!src.allowed(user))
		user << "<span class = 'info'>Access denied.</span>"
		return

	pick_sign()

/obj/structure/sign/barsign/proc/pick_sign()
	var/picked_name = input("Available Signage", "Bar Sign") as null|anything in barsigns
	if(!picked_name)
		return

	set_sign(picked_name)

//Code below is to define useless variables for datums.  It errors without these
/datum/barsign
	var/name = "Name"
	var/icon = "Icon"
	var/desc = "desc"

//Anything below this is where all the specific signs are. If people want to add more signs, add them below.

/datum/barsign/maltesefalcon
	name = "Maltese Falcon"
	icon = "maltesefalcon"
	desc = "The Maltese Faclon, Space Bar and Grill"

/datum/barsign/thebark
	name = "The Bark"
	icon = "thebark"
	desc = "Ian's bar of choice"

/datum/barsign/harmbaton
	name = "The Harmbaton"
	icon = "theharmbaton"
	desc = "A great dining experience for both security members and assistants"

/datum/barsign/thesingulo
	name = "The Singulo"
	icon = "thesingulo"
	desc = "You feel yourself gravitating towards this bar"

/datum/barsign/thedrunkcarp
	name = "The Drunk Carp"
	icon = "thedrunkcarp"
	desc = "Don't drink and Swim"

/datum/barsign/scotchservinwill
	name = "Scotch Servin Willy's"
	icon = "scotchservinwill"
	desc = "Willy sure moved up in the world from clown to bartender"

/datum/barsign/officerbeersky
	name = "Officer Beersky's"
	icon = "officerbeersky"
	desc = "Man eat a dong, these drinks are great"

/datum/barsign/zocalo
	name = "Zocalo"
	icon = "zocalo"
	desc = "The bar that is supposed to be located at the center of the station.  It's not"

/datum/barsign/thecavern
	name = "The Cavern"
	icon =  "thecavern"
	desc = "Fine drinks while listening to some fine tunes"

/datum/barsign/quarks
	name = "Quark's"
	icon = "quarks"
	desc = "Quark's Deep space bar and casino"

/datum/barsign/tenforward
	name = "Ten Forward"
	icon = "tenforward"
	desc = "The Final Frontier of bars in space"

/datum/barsign/prancingpony
	name = "The Prancing Pony"
	icon = "theprancingpony"
	desc = "Looks like a place suitable to get some drinks and rings...er, Wings."

/datum/barsign/vault13
	name = "Vault 13"
	icon = "vault13"
	desc = "Vault 13, I thought this was a space station"

/datum/barsign/solaris
	name = "Solaris"
	icon = "solaris"
	desc = "You will go crazy for these drinks"

/datum/barsign/thehive
	name = "The Hive"
	icon = "thehive"
	desc = "Augmented crew members get a discount"

/datum/barsign/chalmunscatina
	name = "Chalmun's Catina"
	icon = "chalmunscantina"
	desc = "This bar is known for it's popular band that seems to only play one song"

/datum/barsign/theouterspess
	name = "The Outer Spess"
	icon = "theouterspess"
	desc = "This bar isn't actually located in space, don't worry"

/datum/barsign/milliways42
	name = "Milliways 42"
	icon = "milliways42"
	desc = "The bar located at the end of the universe"

/datum/barsign/thetimeofeve
	name = "The Time of Eve"
	icon = "thetimeofeve"
	desc = "Everyone is welcome here, even cyborgs"

