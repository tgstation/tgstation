/obj/structure/speaking_tile
	name = "Ludicrous Turtle"
	desc = "A weird talking turtle."
	verb_say = "says"
	icon = 'icons/obj/structures.dmi'
	icon_state = "absurdlyludicrous"
	layer = 5
	resistance_flags = INDESTRUCTIBLE
	density = TRUE
	var/speaking = FALSE
	var/times_spoken_to = 0
	var/list/shenanigans = list("Hey.","Memes are great.","I had to do a lot of editing.","Yeehaw","I wonder how Hikari's Haven is doing.","I'm going to hell for all the jokes i made about a sick eevee.","Hello","Bonjour. learned that from Futurama.", "Aloha.","hmmm...")

/obj/structure/speaking_tile/interact(mob/user)
	if(!isliving(user) || speaking)
		return
	speaking = TRUE

	switch(times_spoken_to)
		if(0)
			SpeakPeace(list("Welcome to the error handling castle.","Yeah, we must have fucked up the coding really badly.","You should probably tell the diamond authority on discord what you were doing, or make a bug report on the github."))
			for(var/obj/structure/signpost/salvation/S in orange(7))
				S.invisibility = 0
				var/datum/effect_system/smoke_spread/smoke = new
				smoke.set_up(1, S.loc)
				smoke.start()
				break
		if(1)
			SpeakPeace(list("Take that ladder up.","It'll send you back to earth.","Hopefully you'll never need to see this place again."))
		if(2)
			SpeakPeace(list("Curious about what happened?","Somehow your corporeal form was sent to nullspace with you still in it.","Lucky for you this castle exists in nullspace."))
		if(3)
			SpeakPeace(list("So yeah, might as well grab some goodies while you're here.","Anyway don't you have things to do?","There's no real point to sticking around here forever."))
		if(4)
			SpeakPeace(list("I'm flattered you care this much about this room.","Y'know sticking around here's not good for you right?","I'm going to work hard to be more boring so you'll leave."))
		if(5 to 8)
			SpeakPeace(list("..."))
		if(9)
			SpeakPeace(list("Alright maybe that's <b>too</b> boring.", "I can't keep manually typing these lines out though.", "My name's Absurdly Ludicrous, by the way. I'm just someone's pokemon avatar and i'm not really here."))
			name = "Absurdly Ludicrous"
			desc = "A talking mememon."
		if(10)
			SpeakPeace(list("Oh I have an idea!", "Lets outsource this endless banter to Poly!", "Except Poly doesn't really exist in this codebase unless some Xenobiology shenanigans happen."))
		if(11 to 14, 16 to 50, 52 to 99, 103 to 107, 109 to 203, 205 to 249, 252 to 419, 421 to 665, 667 to 998)
			SpeakPeace(pick(shenanigans))
			if(times_spoken_to % 10 == 0)
				SpeakPeace(list("That's [times_spoken_to] times you've spoken to me by the way."))
		if(15)
			SpeakPeace(list("I'm not gonna outsource it cause there's no point.","Oh well.","Anyway I'll leave you it."))
		if(51)
			SpeakPeace(list("The fun never ends around here.", "The Poly text files stores up to 500 statements.", "but there's no poly so what's the point?"))
		if(100)
			SpeakPeace(list("And that's a solid hundred.", "Good hustle I guess.", "You've probably heard a lot of repeats by now."))
		if(101)
			SpeakPeace(list("I hope you're enjoying the rewrite of this room.", "As well as the codebase we helped make.", "So... yeah."))
		if(102)
			SpeakPeace(list("I am very tempted to just stretch this out forever.","It's technically easier than doing this.","Just an option."))
		if(108)
			SpeakPeace(list("But you have my respect for being this dedicated to the joke.", "So tell you what we're going to do, we're going to set a goal.", "250 is your final mission."))
		if(204)
			SpeakPeace(list("Notice how there was no special message at 200?", "The slow automation of what used to be meaningful milestones?","It's all part of the joke."))
		if(250)
			SpeakPeace(list("Congratulations.", "By my very loose calculations you've now wasted a decent chunk of the round doing this.", "But you've seen this meme to its conclusion, and that's an experience in itself, right?"))
		if(251)
			SpeakPeace(list("Anyway, here.", "Have fun with this infinite cup.","well, not actually infinite but close enough. What would you do with 1,000,000 units anyways?"))
			var/obj/item/reagent_containers/food/drinks/trophy/gold_cup/the_ride = new(get_turf(user))
			the_ride.name = "The Infinity Cup"
			the_ride.desc = "AW YEAH, TIME TO GET CRUNK ON ERRORS!"
			the_ride.volume = 1000000
		if(252)
			SpeakPeace(list("You know what this means right?", "Of course it's not over!", "The question becomes now is it more impressive to solider on to an unknown finish, or to have to common sense to stop here?"))
		if(420)
			SpeakPeace(list("Heeeey the meme number!", "Here, have some SCP-420-J", "The world's strongest blunt."))
			var/obj/item/clothing/mask/cigarette/rollie/omega/scpj = new(get_turf(user))
			scpj.name = "SCP-420-J"
			scpj.desc = "A rollie this majestic can't be smoked just anywhere."
		if(666)
			SpeakPeace(list("The darkness in your heart won't be filled by simple platitudes.","You won't stop now, you're in this to the end.", "Will you reach the finish line before the round ends?"))
		if(999)
			SpeakPeace(list("Seriously, this is what you do for fun?", "Please, do NOT click another time!", "Just leave."))
		if(1000)
			for(var/obj/structure/signpost/salvation/S in orange(7))
				var/datum/effect_system/smoke_spread/smoke = new
				smoke.set_up(1, S.loc)
				smoke.start()
				qdel(S)
				break
			SpeakPeace(list("AH FUCK IT OVERFLOWED!", "Welp, you're here forever now thanks to my shitty code.", "I'll unlock the other rooms so you at least won't die here right away. I'm going home."))
			SSmedals.UnlockMedal(MEDAL_TIMEWASTE, user.client)

			for(var/turf/closed/indestructible/fakedoor/glitch/G in world)
				new /obj/structure/mineral_door/paperframe/glitch(locate(G.x,G.y,G.z))
				new /turf/open/indestructible/hoteltile(locate(G.x,G.y,G.z))
			new /obj/item/clothing/head/sombrero/ludicrous(get_turf(src))
			var/datum/effect_system/smoke_spread/smoke = new
			smoke.set_up(1, src.loc)
			smoke.start()
			qdel(src)
		else
			y += 2
	speaking = FALSE
	times_spoken_to++

/obj/structure/speaking_tile/attackby(obj/item/W, mob/user, params)
	return interact(user)

/obj/structure/speaking_tile/attack_paw(mob/user)
	return interact(user)

/obj/structure/speaking_tile/attack_hulk(mob/user, does_attack_animation = 0)
	return interact(user)

/obj/structure/speaking_tile/attack_larva(mob/user)
	return interact(user)

/obj/structure/speaking_tile/attack_ai(mob/user)
	return interact(user)

/obj/structure/speaking_tile/attack_slime(mob/user)
	return interact(user)

/obj/structure/speaking_tile/attack_animal(mob/user)
	return interact(user)

/obj/structure/speaking_tile/proc/SpeakPeace(list/statements)
	for(var/i in 1 to statements.len)
		say("<span class='deadsay'>[statements[i]]</span>")
		if(i != statements.len)
			sleep(30)

/obj/item/rupee
	name = "weird crystal"
	desc = "Your excitement boils away as you realize it's just colored glass. Why would someone hoard these things?"
	icon = 'icons/obj/economy.dmi'
	icon_state = "rupee"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_GLASS = 500)

/obj/item/rupee/Initialize()
	. = ..()
	var/newcolor = color2hex(pick(10;"green", 5;"blue", 3;"red", 1;"purple"))
	add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)

/obj/item/rupee/Crossed(mob/M)
	if(!istype(M))
		return
	if(M.put_in_hands(src))
		if(src != M.get_active_held_item())
			M.swap_hand()
		equip_to_best_slot(M)
	..()

/obj/item/rupee/equipped(mob/user, slot)
	playsound(get_turf(loc), 'sound/misc/server-ready.ogg', 50, 1, -1)
	..()

/obj/effect/landmark/error
	name = "error"
	icon_state = "error_room"
