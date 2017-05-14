/datum/emote/living/carbon/human/fart
	key = "fart"
	key_third_person = "farts"

/datum/emote/living/carbon/human/fart/run_emote(mob/user, params)
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
			message = "farts in <b>[M]</b>'s face!"
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
			"<B><font color='red'>f</font><font color='blue'>a</font><font color='red'>r</font><font color='blue'>t</font><font color='red'>s</font></B>")
	if(istype(user,/mob/living/carbon/alien))
		fartsound = 'hippiestation/sound/effects/alienfart.ogg'
		bloodkind = /obj/effect/decal/cleanable/xenoblood
	spawn(0)
		var/obj/item/weapon/storage/book/bible/Y = locate() in get_turf(user.loc)
		if(istype(Y))
			playsound(Y,'hippiestation/sound/effects/thunder.ogg', 90, 1)
			var/turf/T = get_step(get_step(user, NORTH), NORTH)
			T.Beam(user, icon_state="lightning[rand(1,12)]", time = 5)
			addtimer(CALLBACK(user, /mob/proc/gib), 10)
		var/obj/item/weapon/storage/internal/pocket/butt/theinv = B.inv
		if(theinv.contents.len)
			var/obj/item/O = pick(theinv.contents)
			if(istype(O, /obj/item/weapon/lighter))
				var/obj/item/weapon/lighter/G = O
				if(G.lit && user.loc)
					new/obj/effect/hotspot(user.loc)
					playsound(user, fartsound, 50, 1, 5)
			else if(istype(O, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/J = O
				if(J.welding == 1 && user.loc)
					new/obj/effect/hotspot(user.loc)
					playsound(user, fartsound, 50, 1, 5)
			else if(istype(O, /obj/item/weapon/bikehorn))
				for(var/obj/item/weapon/bikehorn/Q in theinv.contents)
					playsound(Q, pick(Q.honksound), 50, 1, 5)
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
			for(var/obj/item/I in theinv.contents)
				theinv.remove_from_storage(I, user.loc)
			B.loc = get_turf(user)
			B.Remove(user)
			new bloodkind(user.loc)
			user.nutrition -= rand(5, 20)
			user.visible_message("<span class='warning'><b>[user]</b> blows their ass off!</span>", "<span class='warning'>Holy shit, your butt flies off in an arc!</span>")
		else
			user.nutrition -= rand(2, 10)
		..()
		if(!ishuman(user)) //nonhumans don't have the message appear for some reason
			user.visible_message("<b>[user]</b> [message]")

/datum/emote/living/carbon/human/superfart
	key = "superfart"
	key_third_person = "superfarts"

/datum/emote/living/carbon/human/superfart/run_emote(mob/user, params)
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
	B.loose = 1 // to avoid spamsuperfart
	var/fart_type = 1 //Put this outside probability check just in case. There were cases where superfart did a normal fart.
	if(prob(76)) // 76%     1: ASSBLAST  2:SUPERNOVA  3: FARTFLY
		fart_type = 1
	else if(prob(12)) // 3%
		fart_type = 2
	else if(prob(12)) // 0.4%
		if(user.loc && user.loc.z == 1)
			fart_type = 3
		else
			fart_type = 2
	spawn(0)
		spawn(1)
			var/obj/item/weapon/storage/book/bible/Y = locate() in get_turf(user)
			if(Y)
				var/image/img = image(icon = 'icons/effects/224x224.dmi', icon_state = "lightning")
				img.pixel_x = -world.icon_size*3
				img.pixel_y = -world.icon_size
				flick_overlay_static(img, Y, 10)
				playsound(Y,'hippiestation/sound/effects/thunder.ogg', 90, 1)
				spawn(10)
					user.gib()
		sleep(4)
		for(var/i in 1 to 10)
			playsound(user, 'hippiestation/sound/effects/fart.ogg', 50, 1, 5)
			sleep(1)
		playsound(user, 'hippiestation/sound/effects/fartmassive.ogg', 75, 1, 5)
		var/obj/item/weapon/storage/internal/pocket/butt/theinv = B.inv
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
		if(B.loose) B.loose = 0
		new /obj/effect/decal/cleanable/blood(user.loc)
		user.nutrition -= 500
		switch(fart_type)
			if(1)
				for(var/mob/living/M in range(0))
					if(M != user)
						user.visible_message("<span class='warning'><b>[user]</b>'s ass blasts <b>[M]</b> in the face!</span>", "<span class='warning'>You ass blast <b>[M]</b>!</span>")
						M.apply_damage(50,"brute","head")

				user.visible_message("<span class='warning'><b>[user]</b> blows their ass off!</span>", "<span class='warning'>Holy shit, your butt flies off in an arc!</span>")

			if(2)
				user.visible_message("<span class='warning'><b>[user]</b> rips their ass apart in a massive explosion!</span>", "<span class='warning'>Holy shit, your butt goes supernova!</span>")
				explosion(user.loc, 0, 1, 3, adminlog = 0, flame_range = 3)
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