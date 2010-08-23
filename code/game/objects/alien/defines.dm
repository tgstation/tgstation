/obj/alien
	name = "alien thing"
	desc = "theres something alien about this"
	icon = 'alien.dmi'

/obj/alien/egg
	desc = "It looks like a weird egg"
	name = "egg"
	icon_state = "egg"

	density = 0
	anchored = 1

	var/health = 100


/obj/alien/head
	name = "severed head"
	desc = "a severed head..."
	icon_state = "weeds"

	density = 0
	anchored = 0

/obj/alien/skin_suit
	name = "skin"
	desc = "a persons skin, disgusting"
	icon_state = "weeds"

	density = 0
	anchored = 0

/obj/alien/resin
	name = "resin"
	desc = "Looks like some kind of slimy growth."
	icon_state = "resin"

	density = 1
	opacity = 1
	anchored = 1

	var/health = 20

/obj/alien/weeds
	name = "weeds"
	desc = "Weird purple weeds."
	icon_state = "weeds"

	anchored = 1
	density = 0
	var/health = 50

/obj/alien/acid
	name = "acid"
	desc = "Burbling corrossive stuff. I wouldn't want to touch it."
	icon_state = "acid"

	density = 0
	opacity = 0
	anchored = 1

	var/obj/target
	var/ticks = 0