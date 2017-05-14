/*

Jesus icons by rumpelgeist and FurryMcFlurry

*/

/obj/effect/proc_holder/spell/targeted/jesus_btw
	name = "Miracle: Blood To Wine!"
	desc = "This miracle turns blood into wine, leaving anybody nearby extremely intoxicated and unable to fight for a few minutes."
	clothes_req = 0
	max_targets = 0
	range = 7
	panel = "Miracles"
	charge_max = 600
	invocation = "SANGUIS EST VINUM"
	invocation_type = "shout"
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	action_icon_state = "jesus_btw"

/obj/effect/proc_holder/spell/targeted/jesus_btw/cast(list/targets,mob/user = usr)
	var/mob/living/carbon/target = targets[1]
	var/dist = range-get_dist(user,target)
	target.Dizzy(15)
	if(target.reagents)
		target.reagents.add_reagent("wine",rand(25,100))
	if(prob(100*dist/range))
		addtimer(CALLBACK(target, /mob/living/proc/apply_effect, rand(5,20), PARALYZE), rand(10,60))
	target.visible_message("<span class='danger'>Some of [target]'s blood turns into wine!</span>", \
							"<span class='userdanger'>Some of your blood turns into wine!</span>")

/obj/effect/proc_holder/spell/targeted/jesus_revive
	name = "Miracle: Ressurection!"
	desc = "After a short channeling period, this miracle brings a target back from the dead."
	clothes_req = 0
	max_targets = 1
	range = 1
	panel = "Miracles"
	charge_max = 400
	invocation = "AD VITAM"
	invocation_type = "shout"
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	action_icon_state = "jesus_revive"

/obj/effect/proc_holder/spell/targeted/jesus_revive/cast(list/targets,mob/user = usr)
	var/mob/living/carbon/target = targets[1]
	if(target.stat == DEAD)
		target.notify_ghost_cloning("[user] the Messiah is attempting to give you life. Re-enter your corpse if you want to be revived!")
		user.visible_message("<span class='notice'>[user.real_name] hums and puts his hands on [target]!</span>")
		if(do_mob(user,target,80))
			target.revive(full_heal = TRUE)
			playsound(src,'sound/effects/pray.ogg',10)
			target.visible_message("<span class='notice'>[target] springs back to life!</span>")
		else
			to_chat(user, "<span class='warning'>You must stand still to properly revive somebody.</span>")
			charge_counter = charge_max
	else
		to_chat(user, "<span class='warning'>Resurrection only works on the dead!</span>")
		charge_counter = charge_max

/obj/effect/proc_holder/spell/targeted/jesus_deconvert
	name = "Miracle: Repent for your Sins!"
	desc = "After channeling for two minutes, this miracle will show any sinner the righteous path, removing their antagonist status."
	clothes_req = 0
	max_targets = 1
	range = 1
	panel = "Miracles"
	charge_max = 6000
	invocation = "PAENITET TE DAEMONIS"
	invocation_type = "shout"
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	action_icon_state = "jesus_repent"

/obj/effect/proc_holder/spell/targeted/jesus_deconvert/cast(list/targets,mob/user = usr)
	var/mob/living/carbon/target = targets[1]
	if(!target.mind || target.stat == DEAD)
		charge_counter = charge_max
		return
	var/is_antag = target.mind.special_role
	if(do_mob(user,target,400))
		if(is_antag)
			to_chat(target, "<span class='danger'>You remain unwavering in your evil ways!</span>")
		if(do_mob(user,target,400))
			if(is_antag)
				to_chat(target, "<span class='danger'>But this [user.real_name] guy is pretty convincing...</span>")
				target.jitteriness += 1000
				target.do_jitter_animation(target.jitteriness)
			if(do_mob(user,target,400) && is_antag)
				to_chat(target, "<span class='userdanger'>You finally see the light! You are no longer an antagonist thanks to [user.real_name] the Messiah and may live a sin-free life!</span>")
				target.mind.remove_all_antag()
				message_admins("[target]/([target.ckey]) has had their antagonist status removed by [user]/([user.ckey]) the Messiah.")
				to_chat(user, "<span class='notice'>You feel the deep sin within [target.name] slowly fade away.</notice>")
			else
				to_chat(target, "You feel refreshed as you are freed of the sins of your past.")
			playsound(target,'sound/effects/pray.ogg',10)
	else
		to_chat(user, "Only those alive in body and mind may repent!")
		charge_counter = charge_max


/obj/effect/proc_holder/spell/aoe_turf/knock/jesus
	name = "Miracle: Parting Waves!"
	desc = "Once used to split the very ocean in two, this miracle is now relegated to opening airlocks. Extremely useful."
	invocation = "Et Fores Parte"
	panel = "Miracles"
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	action_icon_state = "jesus_knock"

/obj/effect/proc_holder/spell/self/jesus_ascend
	name = "Miracle: Ascend!"
	desc = "Escape from danger by going up to the heavens and then coming back down in a safer area."
	clothes_req = 0
	panel = "Miracles"
	charge_max = 1200
	invocation_type = "none"
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	action_icon_state = "jesus_ascend"

/obj/effect/proc_holder/spell/self/jesus_ascend/cast(list/targets,mob/living/user = usr)
	user.ascend_animation()
	user.revive(full_heal = TRUE)
	addtimer(CALLBACK(user, /mob/proc/jesus_unascend), 20)

/mob/proc/ascend_animation(time = 20)
	dir = 2
	src.visible_message("<span class='notice'>[src] ascends beyond this plane of existence!</span>")
	opacity = FALSE
	mouse_opacity = FALSE
	Stun(2)
	playsound(src, 'hippiestation/sound/misc/choir.ogg', 50)
	animate(src, pixel_y = 128, alpha = 0, time = time, easing = LINEAR_EASING)

/mob/proc/jesus_unascend()
	var/turf/spawnloc = PrepareJesusSpawns()
	if(spawnloc)
		loc = spawnloc
	alpha = 255
	pixel_y = 0
	opacity = TRUE
	mouse_opacity = TRUE
	unascend_animation()

/mob/proc/unascend_animation()
	var/obj/effect/holy/HL = new /obj/effect/holy()
	HL.start(src)

/obj/effect/holy
	name = "holy"
	icon = 'hippiestation/icons/effects/96x96.dmi'
	layer = ABOVE_MOB_LAYER
	mouse_opacity = 0
	pixel_x = -32
	pixel_y = 0
	var/holystate = "beamin"
	var/holysound = 'sound/effects/pray.ogg'

/obj/effect/holy/proc/start(atom/location)
	loc = get_turf(location)
	flick(holystate,src)
	playsound(src,holysound,50,1)
	QDEL_IN(src, 20)
