/obj/item/clockwork/slab //redo quickbinds
	var/list/quickbound = list(/datum/clockwork_scripture/ranged_ability/geis_prep, /datum/clockwork_scripture/create_object/replicant, /datum/clockwork_scripture/create_object/tinkerers_cache, /datum/clockwork_scripture/ranged_ability/sentinels_compromise) //quickbound scripture, accessed by index


////////////////////////
//////GEIS ABILITY//////
////////////////////////

/obj/effect/proc_holder/slab/geis
	ranged_mousepointer = 'icons/effects/geis_target.dmi'

/obj/effect/proc_holder/slab/geis/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return TRUE

	var/turf/T = ranged_ability_user.loc
	if(!isturf(T))
		return TRUE

	var/target_is_binding = istype(target, /obj/structure/destructible/clockwork/geis_binding_hippie)

	if((target_is_binding || isliving(target)) && ranged_ability_user.Adjacent(target))
		if(target_is_binding)
			var/obj/structure/destructible/clockwork/geis_binding_hippie/GB = target
			GB.repair_and_interrupt()
			for(var/m in GB.buckled_mobs)
				if(m)
					add_logs(ranged_ability_user, m, "rebound with Geis")
			successful = TRUE
		else
			var/mob/living/L = target
			if(L.null_rod_check())
				to_chat(ranged_ability_user, "<span class='sevtug'>\"A void weapon? Really, you expect me to be able to do anything?\"</span>")
				return TRUE
			if(is_servant_of_ratvar(L))
				if(L != ranged_ability_user)
					to_chat(ranged_ability_user, "<span class='sevtug'>\"[L.p_they(TRUE)] already serve[L.p_s()] Ratvar. [text2ratvar("Perhaps [ranged_ability_user.p_theyre()] into bondage?")]\"</span>")
				return TRUE
			if(L.stat == DEAD)
				to_chat(ranged_ability_user, "<span class='sevtug'>\"[L.p_theyre(TRUE)] dead, idiot.\"</span>")
				return TRUE

			if(istype(L.buckled, /obj/structure/destructible/clockwork/geis_binding_hippie)) //if they're already bound, just stun them
				var/obj/structure/destructible/clockwork/geis_binding_hippie/GB = L.buckled
				GB.repair_and_interrupt()
				add_logs(ranged_ability_user, L, "rebound with Geis")
				successful = TRUE
			else
				in_progress = TRUE
				clockwork_say(ranged_ability_user, text2ratvar("Be bound, heathen!"))
				remove_mousepointer(ranged_ability_user.client)
				add_logs(ranged_ability_user, L, "bound with Geis")
				if(slab.speed_multiplier >= 0.5) //excuse my debug...
					ranged_ability_user.notransform = TRUE
					addtimer(CALLBACK(src, .proc/reset_user_notransform, ranged_ability_user), 5) //stop us moving for a little bit so we don't break the scripture following this
				slab.busy = null
				var/datum/clockwork_scripture/geis/conversion = new
				conversion.slab = slab
				conversion.invoker = ranged_ability_user
				conversion.target = target
				conversion.run_scripture()
				successful = TRUE

		remove_ranged_ability()

	return TRUE

/obj/effect/proc_holder/slab/geis/proc/reset_user_notransform(mob/living/user)
	if(user)
		user.notransform = FALSE


////////////////////////
/////GEIS SCRIPTURE/////
////////////////////////

//Geis: Grants a short-range binding that will immediately start chanting on binding a valid target.
/datum/clockwork_scripture/ranged_ability/geis_prep
	descname = "Melee Convert Attack"
	name = "Geis"
	desc = "Charges your slab with divine energy, allowing you to bind a nearby heretic for conversion. This is very obvious and will make your slab visible in-hand."
	invocations = list("Divinity, grant...", "...me strength...", "...to enlighten...", "...the heathen!")
	whispered = TRUE
	channel_time = 20
	usage_tip = "Is melee range and does not penetrate mindshield implants. Much more efficient than a Sigil of Submission at low Servant amounts."
	tier = SCRIPTURE_DRIVER
	primary_component = GEIS_CAPACITOR
	sort_priority = 5
	quickbind = TRUE
	quickbind_desc = "Allows you to bind and start converting an adjacent target non-Servant.<br><b>Click your slab to disable.</b>"
	slab_overlay = "geis"
	ranged_type = /obj/effect/proc_holder/slab/geis
	ranged_message = "<span class='sevtug_small'><i>You charge the clockwork slab with divine energy.</i>\n\
	<b>Left-click a target within melee range to convert!\n\
	Click your slab to cancel.</b></span>"
	timeout_time = 100

/datum/clockwork_scripture/ranged_ability/geis_prep/run_scripture()
	var/servants = 0
	if(!GLOB.ratvar_awakens)
		for(var/mob/living/M in GLOB.living_mob_list)
			if(can_recite_scripture(M, TRUE))
				servants++
	if(servants > SCRIPT_SERVANT_REQ)
		whispered = FALSE
		servants -= SCRIPT_SERVANT_REQ
		channel_time = min(channel_time + servants*3, 50)
	return ..()

//The scripture that does the converting.
/datum/clockwork_scripture/geis
	name = "Geis Conversion"
	invocations = list("Enlighten this heathen!", "All are insects before Engine!", "Purge all untruths and honor Engine.")
	channel_time = 49
	tier = SCRIPTURE_PERIPHERAL
	var/mob/living/target
	var/obj/structure/destructible/clockwork/geis_binding_hippie/binding

/datum/clockwork_scripture/geis/Destroy()
	if(binding && !QDELETED(binding))
		qdel(binding)
	return ..()

/datum/clockwork_scripture/geis/can_recite()
	if(!target)
		return FALSE
	return ..()

/datum/clockwork_scripture/geis/run_scripture()
	var/servants = 0
	if(!GLOB.ratvar_awakens)
		for(var/mob/living/M in GLOB.living_mob_list)
			if(can_recite_scripture(M, TRUE))
				servants++
	if(target.buckled)
		target.buckled.unbuckle_mob(target, TRUE)
	binding = new(get_turf(target))
	if(servants > SCRIPT_SERVANT_REQ)
		servants -= SCRIPT_SERVANT_REQ
		channel_time = min(channel_time + servants*7, 120)
		binding.can_resist = TRUE
	binding.setDir(target.dir)
	binding.buckle_mob(target, TRUE)
	return ..()

/datum/clockwork_scripture/geis/check_special_requirements()
	return target && binding && target.buckled == binding && !is_servant_of_ratvar(target) && target.stat != DEAD

/datum/clockwork_scripture/geis/scripture_effects()
	. = add_servant_of_ratvar(target)
	if(.)
		add_logs(invoker, target, "Converted", object = "Geis")

///////////////////////////
///////BINDING SHIT////////
///////////////////////////

//Used by the Geis scripture to hold its target in place
/obj/structure/destructible/clockwork/geis_binding_hippie
	name = "glowing ring"
	desc = "A flickering, glowing purple ring around a target."
	clockwork_desc = "A binding ring around a target, preventing them from taking action while they're being converted."
	max_integrity = 25
	obj_integrity = 25
	light_range = 2
	light_power = 0.5
	light_color = "#AF0AAF"
	density = FALSE
	immune_to_servant_attacks = TRUE
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "geisbinding_full"
	break_message = null
	break_sound = 'sound/magic/repulse.ogg'
	debris = list()
	can_buckle = TRUE
	buckle_lying = 0
	buckle_prevents_pull = TRUE
	var/resisting = FALSE
	var/can_resist = FALSE
	var/mob_layer = MOB_LAYER

/obj/structure/destructible/clockwork/geis_binding_hippie/examine(mob/user)
	icon_state = "geisbinding_full"
	..()
	icon_state = "geisbinding"

/obj/structure/destructible/clockwork/geis_binding_hippie/attack_hand(mob/living/user)
	return

/obj/structure/destructible/clockwork/geis_binding_hippie/emp_act(severity)
	new /obj/effect/temp_visual/emp(loc)
	qdel(src)

/obj/structure/destructible/clockwork/geis_binding_hippie/post_buckle_mob(mob/living/M)
	..()
	if(M.buckled == src)
		desc = "A flickering, glowing purple ring around [M]."
		clockwork_desc = "A binding ring around [M], preventing [M.p_them()] from taking action while [M.p_theyre()] being converted."
		icon_state = "geisbinding"
		mob_layer = M.layer
		layer = M.layer - 0.01
		add_overlay(mutable_appearance('icons/effects/clockwork_effects.dmi', "geisbinding_top", M.layer + 0.01))
		for(var/obj/item/I in M.held_items)
			M.dropItemToGround(I)
		for(var/i in M.get_empty_held_indexes())
			var/obj/item/geis_binding/B = new(M)
			M.put_in_hands(B, i)
		M.regenerate_icons()
		M.visible_message("<span class='warning'>A [name] appears around [M]!</span>", \
		"<span class='warning'>A [name] appears around you!</span>[can_resist ? "\n<span class='userdanger'>Resist!</span>":""]")
		if(!can_resist)
			repair_and_interrupt()
	else
		var/obj/effect/temp_visual/ratvar/geis_binding/G = new /obj/effect/temp_visual/ratvar/geis_binding(M.loc)
		var/obj/effect/temp_visual/ratvar/geis_binding/T = new /obj/effect/temp_visual/ratvar/geis_binding/top(M.loc)
		G.layer = mob_layer - 0.01
		T.layer = mob_layer + 0.01
		G.alpha = alpha
		T.alpha = alpha
		animate(G, transform = matrix()*2, alpha = 0, time = 8, easing = EASE_OUT)
		animate(T, transform = matrix()*2, alpha = 0, time = 8, easing = EASE_OUT)
		M.visible_message("<span class='warning'>[src] snaps into glowing pieces and dissipates!</span>")
		for(var/obj/item/geis_binding/GB in M.held_items)
			M.dropItemToGround(GB, TRUE)

/obj/structure/destructible/clockwork/geis_binding_hippie/relaymove(mob/user, direction)
	if(isliving(user) && can_resist)
		var/mob/living/L = user
		L.resist()

/obj/structure/destructible/clockwork/geis_binding_hippie/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src, 'sound/effects/empulse.ogg', 50, 1)

/obj/structure/destructible/clockwork/geis_binding_hippie/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(.)
		update_icon()

/obj/structure/destructible/clockwork/geis_binding_hippie/update_icon()
	alpha = min(initial(alpha) + ((obj_integrity - max_integrity) * 5), 255)

/obj/structure/destructible/clockwork/geis_binding_hippie/proc/repair_and_interrupt()
	obj_integrity = max_integrity
	update_icon()
	for(var/m in buckled_mobs)
		var/mob/living/L = m
		if(L)
			L.Stun(20, 1, 1)
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				C.silent += 4
	visible_message("<span class='sevtug'>[src] flares brightly!</span>")
	var/obj/effect/temp_visual/ratvar/geis_binding/G1 = new /obj/effect/temp_visual/ratvar/geis_binding(loc)
	var/obj/effect/temp_visual/ratvar/geis_binding/G2 = new /obj/effect/temp_visual/ratvar/geis_binding(loc)
	var/obj/effect/temp_visual/ratvar/geis_binding/T1 = new /obj/effect/temp_visual/ratvar/geis_binding/top(loc)
	var/obj/effect/temp_visual/ratvar/geis_binding/T2 = new /obj/effect/temp_visual/ratvar/geis_binding/top(loc)
	G1.layer = mob_layer - 0.01
	G2.layer = mob_layer - 0.01
	T1.layer = mob_layer + 0.01
	T2.layer = mob_layer + 0.01
	animate(G1, pixel_y = pixel_y + 9, alpha = 0, time = 8, easing = EASE_IN)
	animate(G2, pixel_y = pixel_y - 9, alpha = 0, time = 8, easing = EASE_IN)
	animate(T1, pixel_y = pixel_y + 9, alpha = 0, time = 8, easing = EASE_IN)
	animate(T2, pixel_y = pixel_y - 9, alpha = 0, time = 8, easing = EASE_IN)

/obj/structure/destructible/clockwork/geis_binding_hippie/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(buckled_mob == user)
		if(!resisting && can_resist)
			resisting = TRUE
			user.visible_message("<span class='warning'>[user] starts struggling against [src]...</span>", "<span class='userdanger'>You start breaking out of [src]...</span>")
			while(do_after(user, 10, target = src) && resisting && obj_integrity)
				if(obj_integrity - 5 <= 0)
					user.visible_message("<span class='warning'>[user] breaks [src]!</span>", "<span class='userdanger'>You break [src]!</span>")
					take_damage(5)
					return user
				take_damage(5)
			resisting = FALSE
	else
		return ..()


