/obj/structure/flag
	name = "french flag"
	desc = "A white sheet hung up on the side of a wall."
	icon = 'icons/obj/banters/flags.dmi'
	icon_state = "blank"
	anchored = 1
	density = 0
	burn_state = FLAMMABLE
	burntime = 30
	var/ripped = 0

/obj/structure/flag/assblastusa
	name = "dusty flag"
	desc = "A striped relic of a time long before. You think you hear the screech of an eagle in the distance."
	icon_state = "assblastusa"

/obj/structure/flag/germany
	name = "dusty flag"
	desc = "A striped relic of a time long before. The stripes seem extremely organized."
	icon_state = "germany"

/obj/structure/flag/ckya
	name = "dusty flag"
	desc = "A striped relic of a time long before. Smells faintly of vodka."
	icon_state = "cyka"

/obj/structure/flag/attack_hand(mob/user)
	if(ripped)
		return
	var/temp_loc = user.loc
	if((user.loc != temp_loc) || ripped )
		return
	visible_message("[user] tears [src] in half!" )
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 100, 1)
	ripped = 1
	icon_state = "ripped"
	name = "ripped flag"
	desc = "The poor remains of a desecrated flag."
	add_fingerprint(user)