/obj/item/weapon/p_folded
	name = "paper"
	gender = NEUTER
	icon = 'icons/obj/paper.dmi'
	icon_state = "paper"
	throwforce = 0
	w_class = 1.0
	throw_range = 1
	throw_speed = 1
	layer = 3.9
	pressure_resistance = 1
	attack_verb = list("slapped")

	autoignition_temperature = AUTOIGNITION_PAPER
	fire_fuel = 1
	var/obj/item/unfolded = /obj/item/weapon/paper
	var/nano = 0

/obj/item/weapon/p_folded/Destroy()
	if (unfolded) qdel(src.unfolded)
	return ..()

/obj/item/weapon/p_folded/attack_self(mob/user as mob)
	if (!canunfold(src, user)) return
	processunfolding(src, user)
	return

/obj/item/weapon/p_folded/attackby(obj/item/I, mob/user)
	if(istype(I,/obj/item/weapon/pen))
		var/N = copytext(sanitize(input(user, "What would you like to name [src.name]?", "Paper Labelling", null)  as text), 1, MAX_NAME_LEN)
		if(N && Adjacent(user) && !user.stat)
			src.name = N
	else if(istype(I, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = I
		src.color = C.colour //doesn't work with paper hats but I haven't found a way to fix it, who will even notice anyways
		src.unfolded.color = C.colour
	else if(I.is_hot())
		src.ashify_item(user)
		return
	return ..()

/obj/item/weapon/p_folded/throw_at(var/atom/A, throw_range, throw_speed)
	pixel_y = rand(-7, 7)
	pixel_x = rand(-8, 8)
	..()

/obj/item/weapon/p_folded/verb/unfold()
	set category = "Object"
	set name = "Unfold"
	set src in usr
	if (!canunfold(src, usr)) return
	processunfolding(src, usr) //this is a verb so we have to use usr
	return

/obj/item/weapon/p_folded/proc/processunfolding(var/obj/item/weapon/p_folded/P, mob/user)
	user.drop_item(P, src) //drop the item first to free our hand, but don't delete it yet because it contains the unfolding result.
	if(P.unfolded)
		user.put_in_hands(P.unfolded)
		user.visible_message("<span class='notice'>[user] unfolds \the [src].</span>", \
			"<span class='notice'>You unfold \the [src].</span>")
		P.unfolded.add_fingerprint(user)
	P.unfolded = null
	qdel(P) //now we can delete it
	return 1

/obj/item/weapon/p_folded/proc/canunfold(var/obj/item/weapon/p_folded/P, mob/user)
	if(!user)
		return 0
	if(user.stat || user.restrained())
		to_chat(user, "<span class='notice'>You can't do that while restrained.</span>")
		return 0
	if(user.l_hand != P && user.r_hand != P)
		to_chat(user, "<span class='notice'>You'll need \the [src] in your hands to do that.</span>")
		return 0
	return 1

/obj/item/weapon/p_folded/crane
	name = "paper crane"
	desc = "They say if you fold one thousand cranes, you will be granted a wish!" //good luck folding 1000 cranes in one shift
	icon_state = "crane_1"
	var/frame = 0
/obj/item/weapon/p_folded/crane/attack_self(mob/user)
	if(user.stat || user.restrained())
		to_chat(user, "<span class='notice'>You can't do that while restrained.</span>")
		return 0
	frame = !frame
	icon_state = (frame ? "crane_2" : "crane_1")

/obj/item/weapon/p_folded/plane
	name = "paper airplane"
	icon_state = "plane_east"
	attack_verb = list("stabbed", "jabbed")

	desc = "Not terribly intimidating, but just might put someone's eye out."
	throw_range = 12
	throw_speed = 1
/obj/item/weapon/p_folded/plane/throw_impact(var/atom/target, speed, mob/user)
	..()
	if(user) //runtimes not allowed
		if(ishuman(target) && (user.zone_sel.selecting == "eyes" || prob(20)))
			var/mob/living/carbon/human/H = target
			if (H.check_body_part_coverage(EYES))
				to_chat(H, "<span class='warning'>\The [src] flies right into your eyes! Luckily your eyewear protects you.</span>")
			else
				if (src.nano)
					to_chat(H, "<span class='warning'>OW! Something sharp stabs your [pick("right","left")] eye!</span>")
					H.eye_blurry = max(H.eye_blurry, rand(10,15))
					H.eye_blind = max(H.eye_blind, 2)
					H.Stun(2)
					var/datum/organ/internal/eyes/eyes = H.internal_organs_by_name["eyes"]
					eyes.damage += 3
				else
					to_chat(H, "<span class='warning'>\The [src] flies right into your [pick("right","left")] eye!</span>")
					H.eye_blurry = max(H.eye_blurry, rand(3,6))
					H.eye_blind = max(H.eye_blind, src.nano)
//at last, my block at a rest, bereft of all mortal doubts, I have been enlightened, touched by the sage wisdom, my undying gratitude goes to Comic in this emotional moment
/obj/item/weapon/p_folded/plane/throw_at(var/atom/A, throw_range, throw_speed)
	if (A.x > src.x)
		src.icon_state = "plane_east"
	else
		src.icon_state = "plane_west"
	return ..()

/obj/item/weapon/p_folded/ball
	name = "ball of paper"
	icon_state = "paperball"
	throw_range = 6
	throw_speed = 3

/obj/item/weapon/p_folded/hat
	name = "paper hat"
	desc = "What looks like an ordinary paper hat, IS actually an ordinary paper hat, in no way collectible. Wow!"
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "paper"
	slot_flags = SLOT_HEAD
	body_parts_covered = HEAD

/obj/item/weapon/p_folded/note_small
	name = "folded note"
	icon_state = "note_small"
	desc = "Open me!"
	throw_range = 3

/obj/item/weapon/p_folded/folded_heart
	name = "origami heart"
	icon_state = "folded_heart"
	desc = "Is it for you?"

/obj/item/weapon/p_folded/boat
	name = "origami boat"
	desc = "Sailing the starry sea."
	icon_state = "folded_boat"
/*
/obj/item/weapon/p_folded/fortune	//Sadly after a hastily-made test I realized this really, really wouldn't work
	name = "fortune teller"			//RIP fortuneteller you were never meant to be
	desc = "Like a paper 8-ball."
	var/list/colors = list("red", "blue", "green", "yellow")
	var/list/numbers = list("one", "two", "three", "four", "five", "six", "seven", "eight")
	var/list/fortunes = list(\
		"Get out of there.",\
		"The Syndicate will soon collect a favor from you.",\
		"Don't leave your department today.",\
		"Be wary of [pick("silicons","clowns","doctors","Vox")].",\
		"[pick("R&D","Cargo","The Chemist")] will leave you a gift.",\
		"You will soon find yourself in [pick("Medbay","Brig","outer space","the Morgue")].",\
		"Don't count in the escape shuttle.",\
		"The [pick("Clown","Head of Security","Chaplain","Janitor")] is after you.")
	var/flop = 0
	icon_state = "fortuneteller_closed"
/obj/item/weapon/p_folded/fortune/attack_self(mob/user)
	flop = rand(0,1)
	for (var/i = 1 to length(input("Pick a color!") in colors))
		icon_state = "fortuneteller_closed"
		sleep(1)
		icon_state = (flop ? "fortuneteller_flop" : "fortuneteller_flip")
		flop = !flop
		sleep(4)
	var/list/available_numbers = (flop? list(1, 2, 6, 5) : list(8, 3, 7, 4))
	for (var/o = 1 to input("Pick a number!") in available_numbers)
		icon_state = "fortuneteller_closed"
		sleep(1)
		icon_state = (flop ? "fortuneteller_flop" : "fortuneteller_flip")
		flop = !flop
		sleep(4)
	available_numbers = (flop? list(1, 2, 6, 5) : list(8, 3, 7, 4))
	alert("[fortunes[input("What's your fortune?") in available_numbers]]", "Your fortune is...", "OK")
	icon_state = "fortuneteller_closed"*/