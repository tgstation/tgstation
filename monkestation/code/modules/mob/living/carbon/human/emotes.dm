/datum/emote/living/carbon/human/superfart
	key = "superfart"

/datum/emote/living/carbon/human/superfart/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(user.stat > SOFT_CRIT) //Only superfart in softcrit or less.
		return
	if(!user.get_organ_slot(ORGAN_SLOT_BUTT) || !ishuman(user))
		to_chat(user, "<span class='warning'>You don't have a butt!</span>")
		return
	var/mob/living/carbon/human/ass_holder = user
	var/obj/item/organ/internal/butt/booty = user.get_organ_slot(ORGAN_SLOT_BUTT)
	if(booty.cooling_down)
		return
	booty.cooling_down = TRUE
	var/turf/Location = get_turf(ass_holder)

	//BIBLEFART/
	//This goes above all else because it's an instagib.
	for(var/obj/item/storage/book/bible/Holy in Location)
		if(Holy)
			var/mob/living/carbon/human/Person = user //We know they are human already, it was in the emote check.
			var/turf/T = get_step(get_step(Person, NORTH), NORTH)
			T.Beam(Person, icon_state="lightning[rand(1,12)]", time = 15)
			Person.Paralyze(15)
			to_chat(Person, "<span class='warning'>[Person] attempts to fart on the [Holy], uh oh.<span>")
			playsound(user,'sound/magic/lightningshock.ogg', 50, 1)
			playsound(user,	'monkestation/sound/misc/dagothgod.ogg', 80)
			Person.electrocution_animation(15)
			spawn(15)
				to_chat(Person,"<span class='ratvar'>What a grand and intoxicating innocence. Perish.</span>")
				Person.gib()
				dyn_explosion(Location, 1, 0)
			return

	playsound(ass_holder, "monkestation/sound/effects/superfart.ogg", 100, FALSE, pressure_affected = FALSE, mixer_channel = CHANNEL_PRUDE)
	spawn(8)
		Location = get_turf(user)
		switch(rand(1000))
			if(0) //Ass Rod
				var/butt_end
				var/butt_x
				var/butt_y
				switch(user.dir)
					if(SOUTH)
						butt_y = world.maxy-(TRANSITIONEDGE+1)
						butt_x = user.x
					if(WEST)
						butt_x = world.maxx-(TRANSITIONEDGE+1)
						butt_y = user.y
					if(NORTH)
						butt_y = (TRANSITIONEDGE+1)
						butt_x = user.x
					else
						butt_x = (TRANSITIONEDGE+1)
						butt_y = user.y
				butt_end = locate(butt_x, butt_y, Location.z)
				user.visible_message("<span class='warning'><b>[ass_holder]</b> blows their ass off with such force, they explode!</span>", "<span class='warning'>Holy shit, your butt flies off into the galaxy!</span>")
				priority_announce("What the fuck was that?!", "General Alert", SSstation.announcer.get_rand_alert_sound())
				ass_holder.gib()
				qdel(booty)
				new /obj/effect/immovablerod/butt(Location, butt_end)
				return
			if(1 to 11) 	//explosive fart
				user.visible_message("<span class='warning'>[ass_holder]'s ass explodes violently!</span>")
				dyn_explosion(Location, 5, 5)
				return
			if(12 to 1000)		//Regular superfart
				if(!Location.has_gravity())
					var/atom/target = get_edge_target_turf(user, user.dir)
					user.throw_at(target, 1, 20, spin = FALSE)
				user.visible_message("<span class='warning'>[ass_holder]'s butt goes flying off!</span>")
				new /obj/effect/decal/cleanable/blood(Location)
				user.nutrition = max(user.nutrition - rand(10, 40), NUTRITION_LEVEL_STARVING)
				booty.Remove(user)
				booty.forceMove(Location)
				for(var/mob/living/Struck in Location)
					if(Struck != user)
						user.visible_message("<span class='danger'>[Struck] is violently struck in the face by [user]'s flying ass!</span>")
						Struck.apply_damage(20, "brute", BODY_ZONE_HEAD)
		spawn(20)
			booty.cooling_down = FALSE
