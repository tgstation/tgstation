#define PHASE_VOID "void" //The Seer hasn't been aggroed.
#define PHASE_ALPHA "alpha" //The first phase; the Seer swaps between megafauna types, using different abilities for each.
#define FORM_TIME_ALPHA 7 //The amount of ticks the Seer will spend in a form in Alpha phase
#define PHASE_MU "mu" //The second phase; the Seer swaps rapidly between mob types, using different abilities for each.
#define FORM_TIME_MU 5 //The amount of ticks the Seer will spend in a form in Alpha phase
#define PHASE_OMEGA "omega" //The final phase; the Seer stands in the center of the room unleashing a torrent of curses until defeated.
#define FORM_ACCURSED "mass of curses"
#define FORM_DRAGON "dragon"
#define FORM_BUBBLEGUM "bubblegum"
#define FORM_COLOSSUS "colossus"
#define FORM_HIEROPHANT "hierophant"

/mob/living/simple_animal/hostile/megafauna/seer
	name = "\improper Seer"
	desc = "A witness to the end."
	icon_state = "seer"
	icon_living = "seer"
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	pixel_x = -16
	pixel_y = -16
	health = 2500
	maxHealth = 2500
	attacktext = "lashes out at"
	attack_sound = 'sound/magic/clockwork/narsie_attack.ogg'
	speak_emote = list("sibilates")
	armour_penetration = 100
	melee_damage_lower = 15
	melee_damage_upper = 15
	speed = 1
	move_to_delay = 10
	ranged = TRUE
	del_on_death = TRUE
	wander = FALSE
	idle_vision_range = 7
	vision_range = 7
	aggro_vision_range = 15
	var/phase = PHASE_VOID
	var/form = FORM_DRAGON
	var/transition = FALSE //If we're transitioning between phases
	var/list/forms = list(, \
	"base" = list(-16, -16), \
	"dragon" = list(-16, 0), \
	"bubblegum" = list(-32, 0), \
	"colossus" = list(-32, 0), \
	"watcher" = list(-10, 0)) //A list of all the possible forms, with pixel offsets; if pixel_x and pixel_y are 0 for a mob, don't add an entry!
	var/list/forms_this_cycle //Forms done during this "transition" cycle; we go through each form once before we reset
	var/has_used_ability = FALSE //If the Seer has used its form's "special ability" yet
	var/time_in_form = 0 //How many ticks the Seer has spent in this form
	var/turf/original_location

/mob/living/simple_animal/hostile/megafauna/seer/Initialize()
	. = ..()
	original_location = get_turf(src)

/mob/living/simple_animal/hostile/megafauna/seer/Destroy()
	new/obj/effect/seer_death(get_turf(src))
	return ..()

/mob/living/simple_animal/hostile/megafauna/seer/Life()
	. = ..()
	time_in_form++
	if(!target)
		adjustBruteLoss(-25) //rapid healing while not engaged
		if(form != FORM_ACCURSED)
			change_form(FORM_ACCURSED)
		if(prob(10))
			playsound(src, "curse", 50, TRUE)
	else
		handle_phases()
		switch(phase)
			if(PHASE_ALPHA)
				if(time_in_form >= FORM_TIME_ALPHA)
					change_form()
			if(PHASE_MU)
				if(time_in_form >= FORM_TIME_MU)
					change_form()
	update_icon()

/mob/living/simple_animal/hostile/megafauna/seer/proc/handle_phases()
	var/health_percentage = health / maxHealth
	switch(health_percentage)
		if(0 to 0.2)
			if(phase != PHASE_OMEGA)
				visible_message("<span class='revenboldnotice'>[src] goes into a frenzy!</span>")
				playsound(src, 'sound/magic/blink.ogg', 50, FALSE)
				forceMove(original_location)
				playsound(src, 'sound/magic/blink.ogg', 50, FALSE)
				playsound(src, 'sound/creatures/seer_frenzy.ogg', 100, FALSE)
				canmove = FALSE
				update_icon()
				phase = PHASE_OMEGA
		if(0.2 to 0.5)
			phase = PHASE_MU
		if(0.5 to 1)
			phase = PHASE_ALPHA
		if(1)
			if(phase != PHASE_VOID)
				phase = PHASE_VOID
				forceMove(original_location)
				update_icon()

/mob/living/simple_animal/hostile/megafauna/seer/Move()
	. = ..()
	if(form == FORM_BUBBLEGUM)
		if(!canmove) //charge!
			new/obj/effect/temp_visual/decoy/fading(loc, src)
		playsound(src, 'sound/effects/meteorimpact.ogg', 50, TRUE)

/mob/living/simple_animal/hostile/megafauna/seer/Goto(target, delay, minimum_distance)
	if(!canmove)
		return
	. = ..()

/mob/living/simple_animal/hostile/megafauna/seer/proc/change_form(force_form, silent)
	if(!LAZYLEN(forms_this_cycle))
		update_forms()
		if(!LAZYLEN(forms_this_cycle)) //still nothing! these alterra ships...
			return
	if(!force_form)
		form = pick(forms_this_cycle - form)
		LAZYREMOVE(forms_this_cycle, form)
	else
		form = force_form
	if(!silent)
		visible_message("<span class='revenboldnotice italics'>[src]'s silhouette [pick("twists", "morphs", "shifts")] into that of a [form]!</span>")
		playsound(src, 'sound/magic/clockwork/invoke_general.ogg', 50, TRUE, frequency = 1.5)
	time_in_form = 0
	has_used_ability = FALSE
	update_icon()

/mob/living/simple_animal/hostile/megafauna/seer/proc/update_forms()
	switch(phase)
		if(PHASE_ALPHA)
			forms_this_cycle = list(FORM_DRAGON, FORM_BUBBLEGUM, FORM_COLOSSUS, FORM_HIEROPHANT)
		if(PHASE_OMEGA)
			forms_this_cycle = list()

/mob/living/simple_animal/hostile/megafauna/seer/proc/update_icon()
	if(transition)
		return
	cut_overlays()
	pixel_x = -16
	pixel_y = -16
	switch(phase)
		if(PHASE_VOID)
			icon_state = "seer"
		if(PHASE_ALPHA, PHASE_MU)
			/*icon_state = "seer_[form]"
			if(forms[form])
				var/list/L = forms[form]
				pixel_x = L[1]
				pixel_y = L[2]
			else
				pixel_x = 0
				pixel_y = 0*/
		if(PHASE_OMEGA)
			icon_state = "seer_frenzy"

/mob/living/simple_animal/hostile/megafauna/seer/OpenFire()
	if(phase != PHASE_OMEGA)
		if(has_used_ability || !prob(20 * (time_in_form + 1)))
			return
		has_used_ability = TRUE
		switch(form)
			if(FORM_DRAGON)
				cursed_flames()
			if(FORM_BUBBLEGUM)
				howling_charge()
			if(FORM_COLOSSUS)
				vacuous_spiral()
			if(FORM_HIEROPHANT)
				hunting_curse()
	else
		switch(rand(1, 3))
			if(1)
				cursed_flames()
			if(2)
				vacuous_spiral()
			if(3)
				blackflame_firestorm()



//Cursed Flames: Dragon form attack. Spews cursed fire in the cardinal directions.
/mob/living/simple_animal/hostile/megafauna/seer/proc/cursed_flames(force_dir)
	visible_message("<span class='revenboldnotice'>[src] spews cursed flames!</span>")
	playsound(src, 'sound/magic/fireball.ogg', 100, TRUE)
	playsound(src, 'sound/effects/ghost2.ogg', 100, TRUE, frequency = 0.5)
	var/list/flame_dirs
	if(!force_dir)
		flame_dirs = pick(GLOB.cardinals, GLOB.diagonals)
	else
		flame_dirs = force_dir
	for(var/D in flame_dirs)
		new/obj/effect/cursed_flames(get_step(src, D), D, 1)

/obj/effect/cursed_flames
	name = "cursed flames"
	desc = "A frothing, fiery mass of blackflame."
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	color = list(rgb(15, 15, 15), rgb(15, 15, 15), rgb(15, 15, 15), rgb(15, 15, 15)) //very dark gray
	light_range = 3
	light_color = "#35005B"
	var/chain_length = 1

/obj/effect/cursed_flames/Initialize(mapload, direction, chain_len)
	. = ..()
	chain_length = chain_len
	setDir(direction)
	if(chain_length >= 10)
		return INITIALIZE_HINT_QDEL //no chains longer than 7!
	for(var/mob/living/L in get_turf(src))
		engulf(L)
	addtimer(CALLBACK(src, .proc/new_flames), 1)
	QDEL_IN(src, 10)

/obj/effect/cursed_flames/Crossed(atom/movable/M)
	if(isliving(M))
		engulf(M)

/obj/effect/cursed_flames/proc/new_flames()
	var/turf/T = get_step(src, dir)
	if(iswallturf(T))
		return //and no fire on walls!
	new/obj/effect/cursed_flames(get_step(src, dir), dir, chain_length + 1)

/obj/effect/cursed_flames/proc/engulf(mob/living/L)
	if("boss" in L.faction)
		return
	L.visible_message("<span class='warning'>[src] engulf [L]!</span>", "<span class='userdanger'>The roaring curses engulf you!</span>")
	L.adjust_fire_stacks(2)
	L.IgniteMob()
	L.adjustFireLoss(10)
	playsound(L, 'sound/effects/curse3.ogg', 50, TRUE)
	playsound(L, 'sound/effects/comfyfire.ogg', 50, FALSE) //"comfy"



//Howling Charge: Bubblegum form attack. Charges towards the target location, cursing anything hit.
/mob/living/simple_animal/hostile/megafauna/seer/proc/howling_charge()
	var/turf/T = get_turf(target)
	if(QDELETED(T) && T == get_turf(src))
		return
	new/obj/effect/temp_visual/dragon_swoop/bubblegum(T)
	canmove = FALSE
	setDir(get_dir(src, T))
	visible_message("<span class='revenboldnotice'>[src] howls and prepares to charge!</span>")
	playsound(src, 'sound/effects/curseattack.ogg', 75, TRUE, frequency = 0.9)
	sleep(3)
	throw_at(T, get_dist(src, T), 1, src, 0)

/mob/living/simple_animal/hostile/megafauna/seer/throw_impact(atom/A)
	if(form != FORM_BUBBLEGUM || canmove || !isliving(A))
		. = ..()
	else
		var/mob/living/L = A
		L.visible_message("<span class='revenboldnotice italics'>[src] slams into [L]!</span>", \
		"<span class='userdanger'>[src]'s shadowy body passes through you, and churning darkness envelops your vision!</span>")
		L.apply_damage(5, BURN)
		L.apply_necropolis_curse(CURSE_BLINDING)
		playsound(L, 'sound/effects/meteorimpact.ogg', 100, TRUE)
		shake_camera(src, 2, 3)
		shake_camera(L, 4, 3)
		var/throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(L, src)))
		L.throw_at(throwtarget, 3)
	canmove = TRUE



//Vacuous Spiral: Colossus form attack. Emits a spiral of bolts.
/mob/living/simple_animal/hostile/megafauna/seer/proc/vacuous_spiral()
	set waitfor = FALSE
	var/counter = 1
	var/turf/marker
	for(var/i in 1 to 40)
		switch(counter)
			if(1)
				marker = locate(x, y - 2, z)
			if(2)
				marker = locate(x - 1, y - 2, z)
			if(3)
				marker = locate(x - 2, y - 2, z)
			if(4)
				marker = locate(x - 2, y - 1, z)
			if(5)
				marker = locate(x - 2, y, z)
			if(6)
				marker = locate(x - 2, y + 1, z)
			if(7)
				marker = locate(x - 2, y + 2, z)
			if(8)
				marker = locate(x - 1, y + 2, z)
			if(9)
				marker = locate(x, y + 2, z)
			if(10)
				marker = locate(x + 1, y + 2, z)
			if(11)
				marker = locate(x + 2, y + 2, z)
			if(12)
				marker = locate(x + 2, y + 1, z)
			if(13)
				marker = locate(x + 2, y, z)
			if(14)
				marker = locate(x + 2, y - 1, z)
			if(15)
				marker = locate(x + 2, y - 2, z)
			if(16)
				marker = locate(x + 1, y - 2, z)
		counter++
		if(counter > 16)
			counter = 1
		if(counter < 1)
			counter = 16
		vacuous_bolt(marker)
		playsound(src, 'sound/magic/clockwork/invoke_general.ogg', 10, TRUE)
		playsound(src, "curse", 30, TRUE)
		sleep(1)

/mob/living/simple_animal/hostile/megafauna/seer/proc/vacuous_bolt(turf/marker)
	if(!marker || marker == loc)
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/vacuous_bolt(startloc)
	P.current = startloc
	P.starting = startloc
	P.firer = src
	P.yo = marker.y - startloc.y
	P.xo = marker.x - startloc.x
	if(target)
		P.original = target
	else
		P.original = marker
	P.fire()

/obj/item/projectile/vacuous_bolt
	name = "vacuous bolt"
	icon_state = "greyscale_bolt"
	damage = 15
	armour_penetration = 100
	speed = 2
	eyeblur = 0
	damage_type = OXY
	pass_flags = PASSTABLE
	color = "#150025"
	light_range = 1
	light_color = "#150025"



//Hunting Curse: Hierophant form attack. Spawns a Hierophant chaser.
/mob/living/simple_animal/hostile/megafauna/seer/proc/hunting_curse()
	visible_message("<span class='revenboldnotice'>[src] disgorges a blob of shadows that crawls towards [target]!</span>")
	playsound(src, 'sound/effects/splat.ogg', 75, TRUE)
	var/list/cardinal_copy = GLOB.cardinals.Copy()
	for(var/i in 1 to 3)
		var/obj/effect/temp_visual/hierophant/chaser/cursed/C = new(loc, src, target, 3, FALSE)
		C.moving = 4
		C.moving_dir = pick_n_take(cardinal_copy)

/obj/effect/temp_visual/hierophant/chaser/cursed
	blast_type = /obj/effect/temp_visual/hierophant/blast/cursed

/obj/effect/temp_visual/hierophant/blast/cursed
	name = "cursed blast"
	color = list(rgb(15, 15, 15), rgb(15, 15, 15), rgb(15, 15, 15), rgb(15, 15, 15))



//Blackflame Firestorm: Omega form attack. Blankets the area in blackflame.
/mob/living/simple_animal/hostile/megafauna/seer/proc/blackflame_firestorm()
	visible_message("<span class='big revenboldnotice'>Black flames fill the room!</span>")
	playsound(src, 'sound/magic/fireball.ogg', 100, TRUE, frequency = 0.5)
	playsound(src, 'sound/effects/ghost2.ogg', 100, TRUE, frequency = 0.5)
	for(var/D in GLOB.alldirs)
		new/obj/effect/cursed_flames(get_step(src, D), D, 1)



//Seer death "cinematic."
/obj/effect/seer_death
	name = "\improper Seer"
	desc = "A witness to the end of its days."
	icon_state = "seer_frenzy"
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	pixel_x = -16
	pixel_y = -16

/obj/effect/seer_death/Initialize()
	. = ..()
	death_animation()

/obj/effect/seer_death/Destroy()
	playsound(src, 'sound/creatures/seer_death.ogg', 100, FALSE)
	new/obj/item/weapon/staff/storm(get_turf(src))
	return ..()

/obj/effect/seer_death/proc/death_animation()
	visible_message("<span class='big revenboldnotice'>[src] writhes and howls with unearthly agony!</span>")
	playsound(src, 'sound/creatures/seer_deathblow.ogg', 100, FALSE)
	sleep(35)
	playsound(src, 'sound/creatures/seer_scream.ogg', 100, FALSE)
	animate(src, pixel_y = -9, alpha = 0, time = 50)
	QDEL_IN(src, 50)

#undef PHASE_VOID
#undef PHASE_ALPHA
#undef PHASE_MU
#undef PHASE_OMEGA
#undef FORM_ACCURSED
#undef FORM_DRAGON
#undef FORM_BUBBLEGUM
#undef FORM_COLOSSUS
#undef FORM_HIEROPHANT
#undef FORM_GOLIATH
#undef FORM_WATCHER
#undef FORM_LEGION
#undef FORM_GOLDGRUB
