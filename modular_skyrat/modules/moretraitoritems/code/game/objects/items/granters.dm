/obj/item/book/granter/traitsr //They're for traits from our skyrat idk what else to say dude
	var/traits
	var/traitname = "bug"
	var/greet = "You’ve mastered the art of breaking code. Congrats."

/obj/item/book/granter/traitsr/already_known(mob/user)
	if(!traits)
		return TRUE
	if(HAS_TRAIT(src, (traits)))
		to_chat(user, "<span class='boldwarning'>You already know about [traitname].</span>")
		return
	return FALSE

/obj/item/book/granter/traitsr/on_reading_start(mob/user)
	to_chat(user, "<span class='notice'>You start reading about [traitname]...</span>")

/obj/item/book/granter/traitsr/on_reading_finished(mob/user)
	to_chat(user, "[greet]")
	ADD_TRAIT(user, (traits), type) //wtf
	user.log_message("Gained the ability [traitname] ([traits])", LOG_ATTACK, color="orange")
	onlearned(user)

/obj/item/book/granter/traitsr/onlearned(mob/user)
	..()
	if(oneuse)
		user.visible_message("<span class='warning'>You rip out the pages of the [src]!</span>")

/obj/item/book/granter/traitsr/ventcrawl_book
	traits = TRAIT_VENTCRAWLER_ALWAYS
	name = "Military Contortionist Guide"
	traitname = "ventcrawling expert"
	desc = "A special operations handbook for teaching people with at least a basic understanding of infiltration tactics how to most effectively utilize small spaces such as air ducts or pipes."
	greet = "<span class='boldannounce'>You’ve mastered the art of climbing through air pipes!</span>"
	icon_state = "stealthmanual"
	remarks = list("Have a healthy diet...", "Know when to use vents to your advantage...", "Don't be seen climbing into vents...", "Best paired with close quarters skills...", "Pressure resistant gear recommended...")
