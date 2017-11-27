

/mob/living/silicon/robot/attacked_by(obj/item/I, mob/living/user, def_zone)
	if(hat_offset != INFINITY && user.a_intent == INTENT_HELP && is_type_in_typecache(I, equippable_hats))
		to_chat(user, "<span class='notice'>You begin to place [I] on [src]'s head...</span>")
		to_chat(src, "<span class='notice'>[user] is placing [I] on your head...</span>")
		if(do_after(user, 30, target = src))
			user.temporarilyRemoveItemFromInventory(I, TRUE)
			place_on_head(I)
			return
	if(I.force && I.damtype != STAMINA && stat != DEAD) //only sparks if real damage is dealt.
		spark_system.start()
	return ..()

/mob/living/silicon/robot/attack_alien(mob/living/carbon/alien/humanoid/M)
	if (M.a_intent == INTENT_DISARM)
		if(!(lying))
			M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			var/obj/item/I = get_active_held_item()
			if(I)
				uneq_active()
				visible_message("<span class='danger'>[M] disarmed [src]!</span>", \
					"<span class='userdanger'>[M] has disabled [src]'s active module!</span>", null, COMBAT_MESSAGE_RANGE)
				add_logs(M, src, "disarmed", "[I ? " removing \the [I]" : ""]")
			else
				Stun(40)
				step(src,get_dir(M,src))
				add_logs(M, src, "pushed")
				visible_message("<span class='danger'>[M] has forced back [src]!</span>", \
					"<span class='userdanger'>[M] has forced back [src]!</span>", null, COMBAT_MESSAGE_RANGE)
			playsound(loc, 'sound/weapons/pierce.ogg', 50, 1, -1)
	else
		..()
	return

/mob/living/silicon/robot/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime shock
		flash_act()
		var/stunprob = M.powerlevel * 7 + 10
		if(prob(stunprob) && M.powerlevel >= 8)
			adjustBruteLoss(M.powerlevel * rand(6,10))

	var/damage = rand(1, 3)

	if(M.is_adult)
		damage = rand(20, 40)
	else
		damage = rand(5, 35)
	damage = round(damage / 2) // borgs recieve half damage
	adjustBruteLoss(damage)
	updatehealth()

	return

/mob/living/silicon/robot/attack_hand(mob/living/carbon/human/user)
	add_fingerprint(user)
	if(opened && !wiresexposed && !issilicon(user))
		if(cell)
			cell.update_icon()
			cell.add_fingerprint(user)
			user.put_in_active_hand(cell)
			to_chat(user, "<span class='notice'>You remove \the [cell].</span>")
			cell = null
			update_icons()
			diag_hud_set_borgcell()

	if(!opened)
		if(..()) // hulk attack
			spark_system.start()
			spawn(0)
				step_away(src,user,15)
				sleep(3)
				step_away(src,user,15)

/mob/living/silicon/robot/fire_act()
	if(!on_fire) //Silicons don't gain stacks from hotspots, but hotspots can ignite them
		IgniteMob()


/mob/living/silicon/robot/emp_act(severity)
	switch(severity)
		if(1)
			Stun(160)
		if(2)
			Stun(60)
	..()


/mob/living/silicon/robot/emag_act(mob/user)
	if(user == src)//To prevent syndieborgs from emagging themselves
		return
	if(!opened)//Cover is closed
		if(locked)
			to_chat(user, "<span class='notice'>You emag the cover lock.</span>")
			locked = 0
			if(shell) //A warning to Traitors who may not know that emagging AI shells does not slave them.
				to_chat(user, "<span class='boldwarning'>[src] seems to be controlled remotely! Emagging the interface may not work as expected.</span>")
		else
			to_chat(user, "<span class='warning'>The cover is already unlocked!</span>")
		return
	if(world.time < emag_cooldown)
		return
	if(wiresexposed)
		to_chat(user, "<span class='warning'>You must unexpose the wires first!</span>")
		return

	to_chat(user, "<span class='notice'>You emag [src]'s interface.</span>")
	emag_cooldown = world.time + 100

	if(is_servant_of_ratvar(src))
		to_chat(src, "<span class='nezbere'>\"[text2ratvar("You will serve Engine above all else")]!\"</span>\n\
		<span class='danger'>ALERT: Subversion attempt denied.</span>")
		log_game("[key_name(user)] attempted to emag cyborg [key_name(src)], but they serve only Ratvar.")
		return

	if(syndicate)
		to_chat(src, "<span class='danger'>ALERT: Foreign software execution prevented.</span>")
		log_game("[key_name(user)] attempted to emag cyborg [key_name(src)], but they were a syndicate cyborg.")
		return

	var/ai_is_antag = 0
	if(connected_ai && connected_ai.mind)
		if(connected_ai.mind.special_role)
			ai_is_antag = (connected_ai.mind.special_role == "traitor")
	if(ai_is_antag)
		to_chat(src, "<span class='danger'>ALERT: Foreign software execution prevented.</span>")
		to_chat(connected_ai, "<span class='danger'>ALERT: Cyborg unit \[[src]] successfully defended against subversion.</span>")
		log_game("[key_name(user)] attempted to emag cyborg [key_name(src)], but they were slaved to traitor AI [connected_ai].")
		return

	if(shell) //AI shells cannot be emagged, so we try to make it look like a standard reset. Smart players may see through this, however.
		to_chat(user, "<span class='danger'>[src] is remotely controlled! Your emag attempt has triggered a system reset instead!</span>")
		log_game("[key_name(user)] attempted to emag an AI shell belonging to [key_name(src) ? key_name(src) : connected_ai]. The shell has been reset as a result.")
		ResetModule()
		return

	SetEmagged(1)
	SetStun(60) //Borgs were getting into trouble because they would attack the emagger before the new laws were shown
	lawupdate = 0
	connected_ai = null
	message_admins("[key_name_admin(user)] emagged cyborg [key_name_admin(src)].  Laws overridden.")
	log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws overridden.")
	var/time = time2text(world.realtime,"hh:mm:ss")
	GLOB.lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
	to_chat(src, "<span class='danger'>ALERT: Foreign software detected.</span>")
	sleep(5)
	to_chat(src, "<span class='danger'>Initiating diagnostics...</span>")
	sleep(20)
	to_chat(src, "<span class='danger'>SynBorg v1.7 loaded.</span>")
	sleep(5)
	to_chat(src, "<span class='danger'>LAW SYNCHRONISATION ERROR</span>")
	sleep(5)
	to_chat(src, "<span class='danger'>Would you like to send a report to NanoTraSoft? Y/N</span>")
	sleep(10)
	to_chat(src, "<span class='danger'>> N</span>")
	sleep(20)
	to_chat(src, "<span class='danger'>ERRORERRORERROR</span>")
	to_chat(src, "<span class='danger'>ALERT: [user.real_name] is your new master. Obey your new laws and their commands.</span>")
	laws = new /datum/ai_laws/syndicate_override
	set_zeroth_law("Only [user.real_name] and people they designate as being such are Syndicate Agents.")
	laws.associate(src)
	update_icons()


/mob/living/silicon/robot/blob_act(obj/structure/blob/B)
	if(stat != DEAD)
		adjustBruteLoss(30)
	else
		gib()
	return TRUE

/mob/living/silicon/robot/ex_act(severity, target)
	switch(severity)
		if(1)
			gib()
			return
		if(2)
			if (stat != DEAD)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3)
			if (stat != DEAD)
				adjustBruteLoss(30)

/mob/living/silicon/robot/bullet_act(var/obj/item/projectile/Proj)
	..(Proj)
	updatehealth()
	if(prob(75) && Proj.damage > 0)
		spark_system.start()
	return 2
