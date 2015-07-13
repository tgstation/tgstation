/obj/structure/spirit_board
	name = "spirit board"
	desc = "A wooden board with letters etched into it, used in seances."
	icon = 'icons/obj/objects.dmi'
	icon_state = "spirit_board"
	density = 1
	anchored = 0
	var/virgin = 1
	var/cooldown = 0
	var/planchette = "A"
	var/lastuser = null

/obj/structure/spirit_board/examine()
	desc = "[initial(desc)] The planchette is sitting at \"[planchette]\"."
	..()

/obj/structure/spirit_board/attack_hand(mob/user as mob)
	if(..())
		return
	spirit_board_pick_letter(user)


/obj/structure/spirit_board/attack_ghost(mob/dead/observer/user as mob)
	spirit_board_pick_letter(user)


/obj/structure/spirit_board/proc/spirit_board_pick_letter(var/mob/M)
	if(!spirit_board_checks(M))
		return 0

	if(virgin)
		virgin = 0
		notify_ghosts("Someone has begun playing with a [src.name] in [get_area(src)]!")

	planchette = input("Choose the letter.", "Seance!") in list("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
	add_logs(M, src, "picked a letter on", " which was \"[planchette]\".")
	cooldown = world.time
	lastuser = M.ckey

	var/turf/T = loc
	sleep(rand(20,30))
	if(T == loc)
		visible_message("<span class='notice'>The planchette slowly moves... and stops at the letter \"[planchette]\".</span>")


/obj/structure/spirit_board/proc/spirit_board_checks(var/mob/M)
	//cooldown
	var/bonus = 0
	if(M.ckey == lastuser)
		bonus = 10 //Give some other people a chance, hog.

	if(cooldown > world.time - (30 + bonus))
		return 0 //No feedback here, hiding the cooldown a little makes it harder to tell who's really picking letters.

	//lighting check
	var/light_amount = 0
	var/turf/T = get_turf(src)
	var/area/A = T.loc

	if(A)
		if(A.lighting_use_dynamic)
			light_amount = T.lighting_lumcount
		else
			light_amount =  10

	if(light_amount > 2)
		M << "<span class='warning'>It's too bright here to use [src.name]!</span>"
		return 0

	//mobs in range check
	var/users_in_range = 0
	for(var/mob/living/L in orange(1,src))
		if(L.ckey && L.client)
			if((world.time - L.client.inactivity) < (world.time - 300) || L.stat != CONSCIOUS || L.restrained())//no playing with braindeads or corpses or handcuffed dudes.
				M << "<span class='warning'>[L] doesn't seem to be paying attention...</span>"
			else
				users_in_range++

	if(users_in_range < 2)
		M << "<span class='warning'>There aren't enough people to use the [src.name]!</span>"
		return 0

	return 1