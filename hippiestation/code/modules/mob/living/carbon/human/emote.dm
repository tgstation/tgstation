/mob/living
	var/list/alternate_farts

/datum/emote/living/carbon/fart
	key = "fart"
	key_third_person = "farts"

/datum/emote/living/carbon/fart/run_emote(mob/living/carbon/user, params)
	var/fartsound = 'hippiestation/sound/effects/fart.ogg'
	var/bloodkind = /obj/effect/decal/cleanable/blood
	message = null
	if(user.stat != CONSCIOUS)
		return
	var/obj/item/organ/butt/B = user.getorgan(/obj/item/organ/butt)
	if(!B)
		to_chat(user, "<span class='warning'>You don't have a butt!</span>")
		return
	var/lose_butt = prob(12)
	for(var/mob/living/M in get_turf(user))
		if(M == user)
			continue
		if(lose_butt)
			message = "hits <b>[M]</b> in the face with [B]!"
			M.apply_damage(15,"brute","head")
		else
			message = pick(
				"farts in <b>[M]</b>'s face!",
				"gives <b>[M]</b> the silent but deadly treatment!",
				"rips mad ass in <b>[M]</b>'s mug!",
				"releases the musical fruits of labor onto <b>[M]</b>!",
				"commits an act of butthole bioterror all over <b>[M]</b>!",
				"poots, singing <b>[M]</b>'s eyebrows!",
				"humiliates <b>[M]</b> like never before!",
				"gets real close to <b>[M]</b>'s face and cuts the cheese!")
	if(!message)
		message = pick(
			"rears up and lets loose a fart of tremendous magnitude!",
			"farts!",
			"toots.",
			"harvests methane from uranus at mach 3!",
			"assists global warming!",
			"farts and waves their hand dismissively.",
			"farts and pretends nothing happened.",
			"is a <b>farting</b> motherfucker!",
			"<B><font color='red'>f</font><font color='blue'>a</font><font color='red'>r</font><font color='blue'>t</font><font color='red'>s</font></B>",
			"unleashes their unholy rectal vapor!",
			"assblasts gently.",
			"lets out a wet sounding one!",
			"exorcises a <b>ferocious</b> colonic demon!",
			"pledges ass-legience to the flag!",
			"cracks open a tin of beans!",
			"tears themselves a new one!",
			"looses some pure assgas!",
			"displays the most sophisticated type of humor.",
			"strains to get the fart out. Is that <font color='red'>blood</font>?",
			"sighs and farts simultaneously.",
			"expunges a gnarly butt queef!",
			"contributes to the erosion of the ozone layer!",
			"just farts. It's natural, everyone does it.",
			"had one too many tacos this week!",
			"has the phantom shits.",
			"flexes their bunghole.",
			"'s ass sings the song that ends the earth!",
			"had to go and ruin the mood!",
			"unflinchingly farts. True confidence.",
			"shows everyone what they had for breakfast!",
			"farts so loud it startles them!",
			"breaks wind and a nearby wine glass!",
			"<b>finally achieves the perfect fart. All downhill from here.</b>")
	LAZYINITLIST(user.alternate_farts)
	if(LAZYLEN(user.alternate_farts))
		fartsound = pick(user.alternate_farts)
	if(istype(user,/mob/living/carbon/alien))
		bloodkind = /obj/effect/decal/cleanable/xenoblood
	var/obj/item/storage/book/bible/Y = locate() in get_turf(user.loc)
	if(istype(Y))
		user.Stun(20)
		playsound(Y,'hippiestation/sound/effects/thunder.ogg', 90, 1)
		var/turf/T = get_ranged_target_turf(user, NORTH, 8)
		T.Beam(user, icon_state="lightning[rand(1,12)]", time = 5)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.electrocution_animation(10)
		addtimer(CALLBACK(user, /mob/proc/gib), 10)
	else
		var/obj/item/storage/internal/pocket/butt/theinv = B.inv
		if(theinv.contents.len)
			var/obj/item/O = pick(theinv.contents)
			if(istype(O, /obj/item/lighter))
				var/obj/item/lighter/G = O
				if(G.lit && user.loc)
					new/obj/effect/hotspot(user.loc)
					playsound(user, fartsound, 50, 1, 5)
			else if(istype(O, /obj/item/weldingtool))
				var/obj/item/weldingtool/J = O
				if(J.welding && user.loc)
					new/obj/effect/hotspot(user.loc)
					playsound(user, fartsound, 50, 1, 5)
			else if(istype(O, /obj/item/bikehorn))
				for(var/obj/item/bikehorn/Q in theinv.contents)
					playsound(Q, 'sound/items/bikehorn.ogg', 50, 1, 5)
				message = "<span class='clown'>farts.</span>"
			else if(istype(O, /obj/item/device/megaphone))
				message = "<span class='reallybig'>farts.</span>"
				playsound(user, 'hippiestation/sound/effects/fartmassive.ogg', 75, 1, 5)
			else
				playsound(user, fartsound, 50, 1, 5)
			if(prob(33))
				theinv.remove_from_storage(O, user.loc)
		else
			playsound(user, fartsound, 50, 1, 5)
		sleep(1)
		if(lose_butt)
			B.Remove(user)
			B.forceMove(get_turf(user))
			new bloodkind(user.loc)
			user.nutrition = max(user.nutrition - rand(5, 20), NUTRITION_LEVEL_STARVING)
			user.visible_message("<span class='warning'><b>[user]</b> blows their ass off!</span>", "<span class='warning'>Holy shit, your butt flies off in an arc!</span>")
		else
			user.nutrition = max(user.nutrition - rand(2, 10), NUTRITION_LEVEL_STARVING)
		..()
		if(!ishuman(user)) //nonhumans don't have the message appear for some reason
			user.visible_message("<b>[user]</b> [message]")

/datum/emote/living/carbon/human/superfart
	key = "superfart"
	key_third_person = "superfarts"

/datum/emote/living/carbon/human/superfart/run_emote(mob/living/carbon/human/user, params)
	if(!ishuman(user))
		to_chat(user, "<span class='warning'>You lack that ability!</span>")
		return
	var/obj/item/organ/butt/B = user.getorgan(/obj/item/organ/butt)
	if(!B)
		to_chat(user, "<span class='danger'>You don't have a butt!</span>")
		return
	if(B.loose)
		to_chat(user, "<span class='danger'>Your butt's too loose to superfart!</span>")
		return
	B.loose = TRUE // to avoid spamsuperfart
	var/fart_type = 1 //Put this outside probability check just in case. There were cases where superfart did a normal fart.
	if(prob(76)) // 76%     1: ASSBLAST  2:SUPERNOVA  3: FARTFLY
		fart_type = 1
	else if(prob(12)) // 2.89%
		fart_type = 2
	else if(prob(12)) // 0.35%
		if(user.loc && user.loc.z == 1)
			fart_type = 3
		else
			fart_type = 2
	var/obj/item/storage/book/bible/Y = locate() in get_turf(user.loc)
	if(istype(Y))
		user.Stun(20)
		playsound(Y,'hippiestation/sound/effects/thunder.ogg', 90, 1)
		var/turf/T = get_ranged_target_turf(user, NORTH, 8)
		T.Beam(user, icon_state="lightning[rand(1,12)]", time = 5)
		user.electrocution_animation(10)
		addtimer(CALLBACK(user, /mob/proc/gib), 10)
	else
		for(var/i in 1 to 10)
			playsound(user, 'hippiestation/sound/effects/fart.ogg', 50, 1, 5)
			sleep(1)
		playsound(user, 'hippiestation/sound/effects/fartmassive.ogg', 75, 1, 5)
		var/obj/item/storage/internal/pocket/butt/theinv = B.inv
		if(theinv.contents.len)
			for(var/obj/item/O in theinv.contents)
				theinv.remove_from_storage(O, user.loc)
				O.throw_range = 7//will be reset on hit
				var/turf/target = get_turf(O)
				var/range = 7
				var/turf/new_turf
				var/new_dir
				switch(user.dir)
					if(1)
						new_dir = 2
					if(2)
						new_dir = 1
					if(4)
						new_dir = 8
					if(8)
						new_dir = 4
				for(var/i = 1; i < range; i++)
					new_turf = get_step(target, new_dir)
					target = new_turf
					if(new_turf.density)
						break
				O.throw_at(target,range,O.throw_speed)
		B.Remove(user)
		B.forceMove(get_turf(user))
		if(B.loose)
			B.loose = FALSE
		new /obj/effect/decal/cleanable/blood(user.loc)
		user.nutrition = max(user.nutrition - 500, NUTRITION_LEVEL_STARVING)
		switch(fart_type)
			if(1)
				for(var/mob/living/M in range(0))
					if(M != user)
						user.visible_message("<span class='warning'><b>[user]</b>'s ass blasts <b>[M]</b> in the face!</span>", "<span class='warning'>You ass blast <b>[M]</b>!</span>")
						M.apply_damage(50,"brute","head")

				user.visible_message("<span class='warning'><b>[user]</b> blows their ass off!</span>", "<span class='warning'>Holy shit, your butt flies off in an arc!</span>")

			if(2)
				user.visible_message("<span class='warning'><b>[user]</b> rips their ass apart in a massive explosion!</span>", "<span class='warning'>Holy shit, your butt goes supernova!</span>")
				explosion(user.loc, 0, 1, 3, adminlog = FALSE, flame_range = 3)
				user.gib()

			if(3)
				var/endy = 0
				var/endx = 0

				switch(user.dir)
					if(NORTH)
						endy = 8
						endx = user.loc.x
					if(EAST)
						endy = user.loc.y
						endx = 8
					if(SOUTH)
						endy = 247
						endx = user.loc.x
					else
						endy = user.loc.y
						endx = 247

				//ASS BLAST USA
				user.visible_message("<span class='warning'><b>[user]</b> blows their ass off with such force, they explode!</span>", "<span class='warning'>Holy shit, your butt flies off into the galaxy!</span>")
				user.gib() //can you belive I forgot to put this here?? yeah you need to see the message BEFORE you gib
				new /obj/effect/immovablerod/butt(B.loc, locate(endx, endy, 1))
				priority_announce("What the fuck was that?!", "General Alert")
				qdel(B)
