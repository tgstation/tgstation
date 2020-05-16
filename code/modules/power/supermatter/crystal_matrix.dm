GLOBAL_LIST_EMPTY(crystal_matrix)

/obj/destabilized_supermatter
	name = "destabilized crystal"
	desc = "A strangely translucent and iridescent crystal."
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "psy"
	density = TRUE
	anchored = TRUE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	light_range = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/destabilized_supermatter/Initialize()
	. = ..()
	end_world_activation()
	SSshuttle.registerHostileEnvironment(src)

/obj/destabilized_supermatter/Destroy()
	return..()

///Start the process where the crystal matrix expands to devour the world
/obj/destabilized_supermatter/proc/end_world_activation()
	priority_announce("WARNING - Possible TK-end of the world scenario approaching, please standby")
	sound_to_playing_players('sound/misc/notice2.ogg')
	sleep(0.7 MINUTES)
	for(var/mob/M in GLOB.player_list)
		SEND_SOUND(M, 'sound/items/poster_ripped.ogg')
		sleep(10)
		SEND_SOUND(M, 'sound/items/poster_ripped.ogg')
		sleep(7)
		SEND_SOUND(M, 'sound/items/poster_ripped.ogg')
		sleep(15)
		SEND_SOUND(M, 'sound/effects/explosion3.ogg')
	var/turf/T = get_turf(src)
	explosion(T,0,5,10,1,1,1)
	T.ChangeTurf(/turf/closed/indestructible/crystal_matrix_core)
	priority_announce("WARNING - The crystal matrix has been uncontained! The spread of the free crystal structure is unkown but it has been \
						calculated to be able to devour the entire region of space. Emergency shuttle can't reach the station, good luck")
	sound_to_playing_players('sound/machines/alarm.ogg')
	sleep(2.5 MINUTES)
	total_annihilation()

///Process the world ending scenario by killing everyone and making everything a crystal matrix
/obj/destabilized_supermatter/proc/total_annihilation()
	for(var/T in GLOB.crystal_matrix)
		var/turf/Turf = T
		Turf.Melt()
	priority_announce("The Crystal Matrix has reached the Expansion point! This is a TK-Z Level of End of the World Scenario! \
						It has been estimated that it will devour your entire sector! Try to evaquate with all necessary means!")
	sound_to_playing_players('sound/machines/alarm.ogg')
	sleep(0.2 MINUTES)
	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		playsound(L, 'sound/effects/supermatter.ogg', 50, TRUE)
		L.death()
	for(var/area/A in GLOB.sortedAreas)
		A.name = "crystal_matrix"
		A.icon = 'icons/obj/supermatter.dmi'
		A.icon_state = "matrix"
		A.layer = MASSIVE_OBJ_LAYER
		A.invisibility = 0
		A.blend_mode = 0
	SSticker.force_ending = 1

/turf/closed/indestructible/crystal_matrix_core
	name = "Crystal Matrix"
	desc = "The inner structure of the SM crystal now free from any restrains."
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "matrix"
	color = "#E7BA12"
	layer = MASSIVE_OBJ_LAYER
	var/can_spread = TRUE
	var/max_spread = 4
	var/list/matrix

/turf/closed/indestructible/crystal_matrix_core/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	GLOB.crystal_matrix += src

/turf/closed/indestructible/crystal_matrix_core/Destroy()
	STOP_PROCESSING(SSobj, src)
	GLOB.crystal_matrix -= src
	return ..()

/turf/closed/indestructible/crystal_matrix_core/process()
	if(can_spread)
		if(max_spread <= 0)
			can_spread = FALSE
			STOP_PROCESSING(SSobj, src)
			return
		var/direction = pick(GLOB.cardinals)
		var/turf/T = get_step(src, direction)
		if(!T)
			max_spread--
			return
		if(istype(T, /turf/closed/indestructible/crystal_matrix_core))
			max_spread--
			return
		T.ChangeTurf(/turf/closed/indestructible/crystal_matrix_core)
		max_spread--

/turf/closed/indestructible/crystal_matrix_core/proc/dust_mob(mob/living/nom, vis_msg, mob_msg, cause)
	if(!vis_msg)
		vis_msg = "<span class='danger'>[nom] reaches out and touches [src], inducing a resonance... [nom.p_their()] body starts to glow and burst into flames before flashing into dust!</span>"
	if(!mob_msg)
		mob_msg = "<span class='userdanger'>You reach out and touch [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"</span>"
	if(!cause)
		cause = "contact"
	nom.visible_message(vis_msg, mob_msg, "<span class='hear'>You hear an unearthly noise as a wave of heat washes over you.</span>")
	investigate_log("has been attacked ([cause]) by [key_name(nom)]", INVESTIGATE_SUPERMATTER)
	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
	Consume(nom)

/turf/closed/indestructible/crystal_matrix_core/attackby(obj/item/W, mob/living/user, params)
	if(!istype(W) || (W.item_flags & ABSTRACT) || !istype(user))
		return
	if(user.dropItemToGround(W))
		user.visible_message("<span class='danger'>As [user] touches \the [src] with \a [W], silence fills the room...</span>",\
			"<span class='userdanger'>You touch \the [src] with \the [W], and everything suddenly goes silent.</span>\n<span class='notice'>\The [W] flashes into dust as you flinch away from \the [src].</span>",\
			"<span class='hear'>Everything suddenly goes silent.</span>")
		investigate_log("has been attacked ([W]) by [key_name(user)]", INVESTIGATE_SUPERMATTER)
		Consume(W)
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)

		radiation_pulse(src, 150, 4)

	else if(Adjacent(user)) //if the item is stuck to the person, kill the person too instead of eating just the item.
		var/vis_msg = "<span class='danger'>[user] reaches out and touches [src] with [W], inducing a resonance... [W] starts to glow briefly before the light continues up to [user]'s body. [user.p_they(TRUE)] bursts into flames before flashing into dust!</span>"
		var/mob_msg = "<span class='userdanger'>You reach out and touch [src] with [W]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"</span>"
		dust_mob(user, vis_msg, mob_msg)

/turf/closed/indestructible/crystal_matrix_core/Bumped(atom/movable/AM)
	if(isliving(AM))
		AM.visible_message("<span class='danger'>\The [AM] slams into \the [src] inducing a resonance... [AM.p_their()] body starts to glow and burst into flames before flashing into dust!</span>",\
		"<span class='userdanger'>You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\"</span>",\
		"<span class='hear'>You hear an unearthly noise as a wave of heat washes over you.</span>")
	else if(isobj(AM) && !iseffect(AM))
		AM.visible_message("<span class='danger'>\The [AM] smacks into \the [src] and rapidly flashes to ash.</span>", null,\
		"<span class='hear'>You hear a loud crack as you are washed with a wave of heat.</span>")
	else
		return

	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)

	Consume(AM)

/turf/closed/indestructible/crystal_matrix_core/proc/Consume(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/user = AM
		if(user.status_flags & GODMODE)
			return
		message_admins("[src] has consumed [key_name_admin(user)] [ADMIN_JMP(src)].")
		investigate_log("has consumed [key_name(user)].", INVESTIGATE_SUPERMATTER)
		user.dust(force = TRUE)
	else if(istype(AM, /obj/singularity))
		return
	else if(isobj(AM))
		if(!iseffect(AM))
			var/suspicion = ""
			if(AM.fingerprintslast)
				suspicion = "last touched by [AM.fingerprintslast]"
				message_admins("[src] has consumed [AM], [suspicion] [ADMIN_JMP(src)].")
			investigate_log("has consumed [AM] - [suspicion].", INVESTIGATE_SUPERMATTER)
		qdel(AM)

	//Some poor sod got eaten, go ahead and irradiate people nearby.
	radiation_pulse(src, 3000, 2, TRUE)
	for(var/mob/living/L in range(10))
		investigate_log("has irradiated [key_name(L)] after consuming [AM].", INVESTIGATE_SUPERMATTER)
		if(L in view())
			L.show_message("<span class='danger'>As \the [src] slowly stops resonating, you find your skin covered in new radiation burns.</span>", MSG_VISUAL,\
				"<span class='danger'>The unearthly ringing subsides and you notice you have new radiation burns.</span>", MSG_AUDIBLE)
		else
			L.show_message("<span class='hear'>You hear an unearthly ringing and notice your skin is covered in fresh radiation burns.</span>", MSG_AUDIBLE)
