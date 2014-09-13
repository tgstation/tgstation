//This should hold all the vampire related powers


/mob/proc/vampire_power(required_blood=0, max_stat=0)

	if(!src.mind)		return 0
	if(!ishuman(src))
		src << "<span class='warning'>You are in too weak of a form to do this!</span>"
		return 0

	var/datum/vampire/vampire = src.mind.vampire

	if(!vampire)
		world.log << "[src] has vampire verbs but isn't a vampire."
		return 0

	var/fullpower = (VAMP_FULL in vampire.powers)

	if(src.stat > max_stat)
		src << "<span class='warning'>You are incapacitated.</span>"
		return 0

	if(vampire.nullified)
		if(!fullpower)
			src << "<span class='warning'>Something is blocking your powers!</span>"
			return 0
	if(vampire.bloodusable < required_blood)
		src << "<span class='warning'>You require at least [required_blood] units of usable blood to do that!</span>"
		return 0
	//chapel check
	if(istype(loc.loc, /area/chapel))
		if(!fullpower)
			src << "<span class='warning'>Your powers are useless on this holy ground.</span>"
			return 0
	return 1

/mob/proc/vampire_affected(datum/mind/M)
	//Other vampires aren't affected
	if(mind && mind.vampire) return 0
	//Vampires who have reached their full potential can affect nearly everything
	if(M && M.vampire && (VAMP_FULL in M.vampire.powers))
		return 1
	//Chaplains are resistant to vampire powers
	if(mind && mind.assigned_role == "Chaplain")
		return 0
	return 1

/mob/proc/vampire_can_reach(mob/M as mob, active_range = 1)
	if(M.loc == src.loc) return 1 //target and source are in the same thing
	if(!isturf(src.loc) || !isturf(M.loc)) return 0 //One is inside, the other is outside something.
	if(Adjacent(M))//if(AStar(src.loc, M.loc, /turf/proc/AdjacentTurfs, /turf/proc/Distance, active_range)) //If a path exists, good!
		return 1
	return 0

/mob/proc/vampire_active(required_blood=0, max_stat=0, active_range=1)
	var/pass = vampire_power(required_blood, max_stat)
	if(!pass)								return
	var/datum/vampire/vampire = mind.vampire
	if(!vampire) return
	var/list/victims = list()
	for(var/mob/living/carbon/C in view(active_range))
		victims += C
	var/mob/living/carbon/T = input(src, "Victim?") as null|anything in victims

	if(!T) return
	if(!(T in view(active_range))) return
	if(!vampire_can_reach(T, active_range)) return
	if(!vampire_power(required_blood, max_stat)) return
	return T

/client/proc/vampire_rejuvinate()
	set category = "Vampire"
	set name = "Rejuvinate "
	set desc= "Flush your system with spare blood to remove any incapacitating effects"
	var/datum/mind/M = usr.mind
	if(!M) return
	if(M.current.vampire_power(0, 1))
		M.current.weakened = 0
		M.current.stunned = 0
		M.current.paralysis = 0
		//M.vampire.bloodusable -= 10
		M.current << "\blue You flush your system with clean blood and remove any incapacitating effects."
		spawn(1)
			if(M.vampire.bloodtotal >= 200)
				for(var/i = 0; i < 5; i++)
					M.current.adjustBruteLoss(-2)
					M.current.adjustOxyLoss(-5)
					M.current.adjustToxLoss(-2)
					M.current.adjustFireLoss(-2)
					sleep(35)
		M.current.verbs -= /client/proc/vampire_rejuvinate
		spawn(200)
			M.current.verbs += /client/proc/vampire_rejuvinate

/client/proc/vampire_hypnotise()
	set category = "Vampire"
	set name = "Hypnotise (20)"
	set desc= "A piercing stare that incapacitates your victim for a good length of time."
	var/datum/mind/M = usr.mind
	if(!M) return

	var/mob/living/carbon/C = M.current.vampire_active(20, 0, 1)

	if(!C) return
	M.current.visible_message("<span class='warning'>[M.current.name]'s eyes flash briefly as he stares into [C.name]'s eyes</span>")
	M.current.verbs -= /client/proc/vampire_hypnotise
	spawn(1800)
		M.current.verbs += /client/proc/vampire_hypnotise
	if(do_mob(M.current, C, 50))
		if(C.mind && C.mind.vampire)
			M.current << "\red Your piercing gaze fails to knock out [C.name]."
			C << "\blue [M.current.name]'s feeble gaze is ineffective."
			return
		else
			M.current << "\red Your piercing gaze knocks out [C.name]."
			C << "\red You find yourself unable to move and barely able to speak"
			C.Weaken(20)
			C.Stun(20)
			C.stuttering = 20
		M.current.remove_vampire_blood(20)
	else
		M.current << "\red You broke your gaze."
		return

/client/proc/vampire_disease()
	set category = "Vampire"
	set name = "Diseased Touch (100)"
	set desc = "Touches your victim with infected blood giving them the Shutdown Syndrome which quickly shutsdown their major organs resulting in a quick painful death."
	var/datum/mind/M = usr.mind
	if(!M) return

	var/mob/living/carbon/C = M.current.vampire_active(100, 0, 1)
	if(!C) return
	if(!M.current.vampire_can_reach(C, 1))
		M.current << "\red <b>You cannot touch [C.name] from where you are standing!"
		return
	M.current << "\red You stealthily infect [C.name] with your diseased touch."
	/*var/t_him = "it"
	if (src.gender == MALE)
		t_him = "him"
	else if (src.gender == FEMALE)
		t_him = "her"
	M.current.visible_message("\blue [M] shakes [src] trying to wake [t_him] up!" )
	playsound(get_turf(src), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)*/
	C.help_shake_act(M.current) // i use da colon
	if(!C.vampire_affected(M))
		M.current << "\red They seem to be unaffected."
		return
	var/datum/disease2/disease/shutdown = new /datum/disease2/disease("Created by vamp [key_name(C)].")
	var/datum/disease2/effectholder/holder = new /datum/disease2/effectholder
	var/datum/disease2/effect/organs/vampire/O = new /datum/disease2/effect/organs/vampire
	holder.effect += O
	holder.chance = 10
	shutdown.infectionchance = 100
	shutdown.antigen |= text2num(pick(ANTIGENS))
	shutdown.antigen |= text2num(pick(ANTIGENS))
	shutdown.spreadtype = "None"
	shutdown.uniqueID = rand(0,10000)
	shutdown.effects += holder
	shutdown.speed = 1
	shutdown.stage = 2
	shutdown.clicks = 185
	infect_virus2(C,shutdown,0)
	M.current.remove_vampire_blood(100)
	M.current.verbs -= /client/proc/vampire_disease
	spawn(1800) M.current.verbs += /client/proc/vampire_disease

/client/proc/vampire_glare()
	set category = "Vampire"
	set name = "Glare"
	set desc= "A scary glare that incapacitates people for a short while around you."
	var/datum/mind/M = usr.mind
	if(!M) return
	if(M.current.vampire_power(0, 1))
		M.current.visible_message("\red <b>[M.current.name]'s eyes emit a blinding flash!")
		//M.vampire.bloodusable -= 10
		M.current.verbs -= /client/proc/vampire_glare
		spawn(300)
			M.current.verbs += /client/proc/vampire_glare
		if(istype(M.current:glasses, /obj/item/clothing/glasses/sunglasses/blindfold))
			M.current << "<span class='warning'>You're blindfolded!</span>"
			return
		for(var/mob/living/carbon/C in view(1))
			if(!C.vampire_affected(M)) continue
			if(!M.current.vampire_can_reach(C, 1)) continue
			C.Stun(8)
			C.Weaken(8)
			C.stuttering = 20
			C << "\red You are blinded by [M.current.name]'s glare"

/client/proc/vampire_shapeshift()
	set category = "Vampire"
	set name = "Shapeshift (50)"
	set desc = "Changes your name and appearance at the cost of 50 blood and has a cooldown of 3 minutes."
	var/datum/mind/M = usr.mind
	if(!M) return
	if(M.current.vampire_power(50, 0))
		M.current.visible_message("<span class='warning'>[M.current.name] transforms!</span>")
		M.current.client.prefs.real_name = M.current.generate_name() //random_name(M.current.gender)
		M.current.client.prefs.randomize_appearance_for(M.current)
		M.current.regenerate_icons()
		M.current.remove_vampire_blood(50)
		M.current.verbs -= /client/proc/vampire_shapeshift
		spawn(1800) M.current.verbs += /client/proc/vampire_shapeshift

/client/proc/vampire_screech()
	set category = "Vampire"
	set name = "Chiroptean Screech (30)"
	set desc = "An extremely loud shriek that stuns nearby humans and breaks windows as well."
	var/datum/mind/M = usr.mind
	if(!M) return
	if(M.current.vampire_power(30, 0))
		M.current.visible_message("\red [M.current.name] lets out an ear piercing shriek!", "\red You let out a loud shriek.", "\red You hear a loud painful shriek!")
		for(var/mob/living/carbon/C in hearers(4, M.current))
			if(C == M.current) continue
			if(ishuman(C) && C:is_on_ears(/obj/item/clothing/ears/earmuffs)) continue
			if(!C.vampire_affected(M)) continue
			C << "<span class='warning'><font size='3'><b>You hear a ear piercing shriek and your senses dull!</font></b></span>"
			C.Weaken(8)
			C.ear_deaf = 20
			C.stuttering = 20
			C.Stun(8)
			C.make_jittery(150)
		for(var/obj/structure/window/W in view(4))
			W.destroy()
		playsound(M.current.loc, 'sound/effects/creepyshriek.ogg', 100, 1)
		M.current.remove_vampire_blood(30)
		M.current.verbs -= /client/proc/vampire_screech
		spawn(1800) M.current.verbs += /client/proc/vampire_screech

/client/proc/vampire_enthrall()
	set category = "Vampire"
	set name = "Enthrall (300)"
	set desc = "You use a large portion of your power to sway those loyal to none to be loyal to you only."
	var/datum/mind/M = usr.mind
	if(!M) return
	var/mob/living/carbon/C = M.current.vampire_active(300, 0, 1)
	if(!C) return
	M.current.visible_message("\red [M.current.name] bites [C.name]'s neck!", "\red You bite [C.name]'s neck and begin the flow of power.")
	C << "<span class='warning'>You feel the tendrils of evil invade your mind.</span>"
	if(!ishuman(C))
		M.current << "\red You can only enthrall humans"
		return

	if(do_mob(M.current, C, 50))
		if(M.current.can_enthrall(C) && M.current.vampire_power(300, 0)) // recheck
			M.current.handle_enthrall(C)
			M.current.remove_vampire_blood(300)
			M.current.verbs -= /client/proc/vampire_enthrall
			spawn(1800) M.current.verbs += /client/proc/vampire_enthrall
		else
			M.current << "\red You or your target either moved or you dont have enough usable blood."
			return



/client/proc/vampire_cloak()
	set category = "Vampire"
	set name = "Cloak of Darkness (toggle)"
	set desc = "Toggles whether you are currently cloaking yourself in darkness."
	var/datum/mind/M = usr.mind
	if(!M) return
	if(M.current.vampire_power(0, 0))
		M.vampire.iscloaking = !M.vampire.iscloaking
		M.current << "\blue You will now be [M.vampire.iscloaking ? "hidden" : "seen"] in darkness."

/mob/proc/handle_vampire_cloak()
	if(!mind || !mind.vampire || !ishuman(src))
		alpha = 255
		return
	var/turf/simulated/T = get_turf(src)

	if(!istype(T))
		return 0

	if(!mind.vampire.iscloaking)
		alpha = 255
		return 0
	if(T.lighting_lumcount <= 2)
		alpha = round((255 * 0.15))
		return 1
	else
		alpha = round((255 * 0.80))

/mob/proc/can_enthrall(mob/living/carbon/C)
	var/enthrall_safe = 0
	for(var/obj/item/weapon/implant/loyalty/L in C)
		if(L && L.implanted)
			enthrall_safe = 1
			break
	for(var/obj/item/weapon/implant/traitor/T in C)
		if(T && T.implanted)
			enthrall_safe = 1
			break
	if(!C)
		world.log << "something bad happened on enthralling a mob src is [src] [src.key] \ref[src]"
		return 0
	if(!C.mind)
		src << "\red [C.name]'s mind is not there for you to enthrall."
		return 0
	if(enthrall_safe || ( C.mind in ticker.mode.vampires )||( C.mind.vampire )||( C.mind in ticker.mode.enthralled ))
		C.visible_message("\red [C] seems to resist the takeover!", "\blue You feel a familiar sensation in your skull that quickly dissipates.")
		return 0
	if(!C.vampire_affected(mind))
		C.visible_message("\red [C] seems to resist the takeover!", "\blue Your faith of [ticker.Bible_deity_name] has kept your mind clear of all evil")
	if(!ishuman(C))
		src << "\red You can only enthrall humans!"
		return 0
	return 1

/mob/proc/handle_enthrall(mob/living/carbon/human/H as mob)
	if(!istype(H))
		src << "<b>\red SOMETHING WENT WRONG, YELL AT POMF OR NEXIS</b>"
		return 0
	var/ref = "\ref[src.mind]"
	if(!(ref in ticker.mode.thralls))
		ticker.mode.thralls[ref] = list(H.mind)
	else
		ticker.mode.thralls[ref] += H.mind
	ticker.mode.enthralled.Add(H.mind)
	ticker.mode.enthralled[H.mind] = src.mind
	H.mind.special_role = "VampThrall"
	H << "<b>\red You have been Enthralled by [name]. Follow their every command.</b>"
	src << "\red You have successfully Enthralled [H.name]. <i>If they refuse to do as you say just adminhelp.</i>"
	ticker.mode.update_vampire_icons_added(H.mind)
	ticker.mode.update_vampire_icons_added(src.mind)
	log_admin("[ckey(src.key)] has mind-slaved [ckey(H.key)].")

/client/proc/vampire_bats()
	set category = "Vampire"
	set name = "Summon Bats (75)"
	set desc = "You summon a pair of space bats who attack nearby targets until they or their target is dead."
	var/datum/mind/M = usr.mind
	if(!M) return
	if(M.current.vampire_power(75, 0))
		var/list/turf/locs = new
		var/number = 0
		for(var/direction in alldirs) //looking for bat spawns
			if(locs.len == 2) //we found 2 locations and thats all we need
				break
			var/turf/T = get_step(M.current,direction) //getting a loc in that direction
			if(AStar(M.current.loc, T, /turf/proc/AdjacentTurfs, /turf/proc/Distance, 1)) // if a path exists, so no dense objects in the way its valid salid
				locs += T
		if(locs.len)
			for(var/turf/tospawn in locs)
				number++
				new /mob/living/simple_animal/hostile/scarybat(tospawn, M.current)
			if(number != 2) //if we only found one location, spawn one on top of our tile so we dont get stacked bats
				new /mob/living/simple_animal/hostile/scarybat(M.current.loc, M.current)
		else // we had no good locations so make two on top of us
			new /mob/living/simple_animal/hostile/scarybat(M.current.loc, M.current)
			new /mob/living/simple_animal/hostile/scarybat(M.current.loc, M.current)
		M.current.remove_vampire_blood(75)
		M.current.verbs -= /client/proc/vampire_bats
		spawn(1200) M.current.verbs += /client/proc/vampire_bats

/client/proc/vampire_jaunt()
	//AHOY COPY PASTE INCOMING
	set category = "Vampire"
	set name = "Mist Form (30)"
	set desc = "You take on the form of mist for a short period of time."
	var/jaunt_duration = 50 //in deciseconds
	var/datum/mind/M = usr.mind
	if(!M) return

	if(M.current.vampire_power(30, 0))
		if(M.current.buckled) M.current.buckled.unbuckle()
		spawn(0)
			var/mobloc = get_turf(M.current.loc)
			var/obj/effect/dummy/spell_jaunt/holder = new /obj/effect/dummy/spell_jaunt( mobloc )
			var/atom/movable/overlay/animation = new /atom/movable/overlay( mobloc )
			animation.name = "water"
			animation.density = 0
			animation.anchored = 1
			animation.icon = 'icons/mob/mob.dmi'
			animation.icon_state = "liquify"
			animation.layer = 5
			animation.master = holder
			M.current.ExtinguishMob()
			if(M.current.buckled)
				M.current.buckled.unbuckle()
			flick("liquify",animation)
			M.current.loc = holder
			M.current.client.eye = holder
			var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
			steam.set_up(10, 0, mobloc)
			steam.start()
			sleep(jaunt_duration)
			mobloc = get_turf(M.current.loc)
			animation.loc = mobloc
			steam.location = mobloc
			steam.start()
			M.current.canmove = 0
			sleep(20)
			flick("reappear",animation)
			sleep(5)
			if(!M.current.Move(mobloc))
				for(var/direction in list(1,2,4,8,5,6,9,10))
					var/turf/T = get_step(mobloc, direction)
					if(T)
						if(M.current.Move(T))
							break
			M.current.canmove = 1
			M.current.client.eye = M.current
			del(animation)
			del(holder)
		M.current.remove_vampire_blood(30)
		M.current.verbs -= /client/proc/vampire_jaunt
		spawn(600) M.current.verbs += /client/proc/vampire_jaunt

// Blink for vamps
// Less smoke spam.
/client/proc/vampire_shadowstep()
	set category = "Vampire"
	set name = "Shadowstep (30)"
	set desc = "Vanish into the shadows."
	var/datum/mind/M = usr.mind
	if(!M) return

	// Teleport radii
	var/inner_tele_radius = 0
	var/outer_tele_radius = 6

	// Maximum lighting_lumcount.
	var/max_lum = 1

	if(M.current.vampire_power(30, 0))
		if(M.current.buckled) M.current.buckled.unbuckle()
		spawn(0)
			var/list/turfs = new/list()
			for(var/turf/T in range(usr,outer_tele_radius))
				if(T in range(usr,inner_tele_radius)) continue
				if(istype(T,/turf/space)) continue
				if(T.density) continue
				if(T.x>world.maxx-outer_tele_radius || T.x<outer_tele_radius)	continue	//putting them at the edge is dumb
				if(T.y>world.maxy-outer_tele_radius || T.y<outer_tele_radius)	continue

				// LIGHTING CHECK
				if(T.lighting_lumcount > max_lum) continue
				turfs += T

			if(!turfs.len)
				usr << "\red You cannot find darkness to step to."
				return

			var/turf/picked = pick(turfs)

			if(!picked || !isturf(picked))
				return
			M.current.ExtinguishMob()
			if(M.current.buckled)
				M.current.buckled.unbuckle()
			var/atom/movable/overlay/animation = new /atom/movable/overlay( get_turf(usr) )
			animation.name = usr.name
			animation.density = 0
			animation.anchored = 1
			animation.icon = usr.icon
			animation.alpha = 127
			animation.layer = 5
			//animation.master = src
			usr.loc = picked
			spawn(10)
				del(animation)
		M.current.remove_vampire_blood(30)
		M.current.verbs -= /client/proc/vampire_shadowstep
		spawn(20)
			M.current.verbs += /client/proc/vampire_shadowstep

/mob/proc/remove_vampire_blood(amount = 0)
	var/bloodold
	if(!mind || !mind.vampire)
		return
	bloodold = mind.vampire.bloodusable
	mind.vampire.bloodusable = max(0, (mind.vampire.bloodusable - amount))
	if(bloodold != mind.vampire.bloodusable)
		src << "\blue <b>You have [mind.vampire.bloodusable] left to use.</b>"