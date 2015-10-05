
/obj/item/verbs/borer/detached/verb/infest()
	set category = "Alien"
	set name = "Infest"
	set desc = "Infest a suitable humanoid host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.infest()

/obj/item/verbs/borer/detached/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Alien"

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.ventcrawl()

/obj/item/verbs/borer/detached/verb/borer_hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Alien"

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.hide()

/obj/item/verbs/borer/detached/verb/borer_reproduce()
	set name = "Reproduce"
	set desc = "Produce offspring in the form of an egg."
	set category = "Alien"

	var/mob/living/simple_animal/borer/B = loc
	if(!istype(B)) return
	B.reproduce()