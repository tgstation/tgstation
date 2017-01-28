//Judicial visor: Grants the ability to smite an area and stun the unfaithful nearby every thirty seconds.
/obj/item/clothing/glasses/judicial_visor
	name = "judicial visor"
	desc = "A strange purple-lensed visor. Looking at it inspires an odd sense of guilt."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "judicial_visor_0"
	item_state = "sunglasses"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flash_protect = 1
	var/active = FALSE //If the visor is online
	var/recharging = FALSE //If the visor is currently recharging
	var/obj/effect/proc_holder/judicial_visor/blaster
	var/recharge_cooldown = 300 //divided by 10 if ratvar is alive
	actions_types = list(/datum/action/item_action/clock/toggle_visor)

/obj/item/clothing/glasses/judicial_visor/New()
	..()
	all_clockwork_objects += src
	blaster = new(src)
	blaster.visor = src

/obj/item/clothing/glasses/judicial_visor/Destroy()
	all_clockwork_objects -= src
	if(blaster.ranged_ability_user)
		blaster.remove_ranged_ability()
	blaster.visor = null
	qdel(blaster)
	return ..()

/obj/item/clothing/glasses/judicial_visor/item_action_slot_check(slot, mob/user)
	if(slot != slot_glasses)
		return 0
	return ..()

/obj/item/clothing/glasses/judicial_visor/equipped(mob/living/user, slot)
	..()
	if(slot != slot_glasses)
		update_status(FALSE)
		if(blaster.ranged_ability_user)
			blaster.remove_ranged_ability()
		return 0
	if(is_servant_of_ratvar(user))
		update_status(TRUE)
	else
		update_status(FALSE)
	if(iscultist(user)) //Cultists spontaneously combust
		user << "<span class='heavy_brass'>\"Consider yourself judged, whelp.\"</span>"
		user << "<span class='userdanger'>You suddenly catch fire!</span>"
		user.adjust_fire_stacks(5)
		user.IgniteMob()
	return 1

/obj/item/clothing/glasses/judicial_visor/dropped(mob/user)
	. = ..()
	addtimer(CALLBACK(src, .proc/check_on_mob, user), 1) //dropped is called before the item is out of the slot, so we need to check slightly later

/obj/item/clothing/glasses/judicial_visor/proc/check_on_mob(mob/user)
	if(user && src != user.get_item_by_slot(slot_glasses)) //if we happen to check and we AREN'T in the slot, we need to remove our shit from whoever we got dropped from
		update_status(FALSE)
		if(blaster.ranged_ability_user)
			blaster.remove_ranged_ability()

/obj/item/clothing/glasses/judicial_visor/attack_self(mob/user)
	if(is_servant_of_ratvar(user) && src == user.get_item_by_slot(slot_glasses))
		blaster.toggle(user)

/obj/item/clothing/glasses/judicial_visor/proc/update_status(change_to)
	if(recharging || !isliving(loc))
		icon_state = "judicial_visor_0"
		return 0
	if(active == change_to)
		return 0
	var/mob/living/L = loc
	active = change_to
	icon_state = "judicial_visor_[active]"
	L.update_action_buttons_icon()
	L.update_inv_glasses()
	if(!is_servant_of_ratvar(L) || L.stat)
		return 0
	switch(active)
		if(TRUE)
			L << "<span class='notice'>As you put on [src], its lens begins to glow, information flashing before your eyes.</span>\n\
			<span class='heavy_brass'>Judicial visor active. Use the action button to gain the ability to smite the unworthy.</span>"
		if(FALSE)
			L << "<span class='notice'>As you take off [src], its lens darkens once more.</span>"
	return 1

/obj/item/clothing/glasses/judicial_visor/proc/recharge_visor(mob/living/user)
	if(!src)
		return 0
	recharging = FALSE
	if(user && src == user.get_item_by_slot(slot_glasses))
		user << "<span class='brass'>Your [name] hums. It is ready.</span>"
	else
		active = FALSE
	icon_state = "judicial_visor_[active]"
	if(user)
		user.update_action_buttons_icon()
		user.update_inv_glasses()

/obj/effect/proc_holder/judicial_visor
	active = FALSE
	ranged_mousepointer = 'icons/effects/visor_reticule.dmi'
	var/obj/item/clothing/glasses/judicial_visor/visor

/obj/effect/proc_holder/judicial_visor/proc/toggle(mob/user)
	var/message
	if(active)
		message = "<span class='brass'>You dispel the power of [visor].</span>"
		remove_ranged_ability(message)
	else
		message = "<span class='brass'><i>You harness [visor]'s power.</i> <b>Left-click to place a judical marker!</b></span>"
		add_ranged_ability(user, message)

/obj/effect/proc_holder/judicial_visor/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return
	if(ranged_ability_user.incapacitated() || !visor || visor != ranged_ability_user.get_item_by_slot(slot_glasses))
		remove_ranged_ability()
		return

	var/turf/T = ranged_ability_user.loc
	if(!isturf(T))
		return FALSE

	if(target in view(7, get_turf(ranged_ability_user)))
		visor.recharging = TRUE
		visor.update_status()
		for(var/obj/item/clothing/glasses/judicial_visor/V in ranged_ability_user.GetAllContents())
			if(V == visor)
				continue
			V.recharging = TRUE //To prevent exploiting multiple visors to bypass the cooldown
			V.update_status()
			addtimer(CALLBACK(V, /obj/item/clothing/glasses/judicial_visor.proc/recharge_visor, ranged_ability_user), (ratvar_awakens ? visor.recharge_cooldown*0.1 : visor.recharge_cooldown) * 2)
		clockwork_say(ranged_ability_user, text2ratvar("Kneel, heathens!"))
		ranged_ability_user.visible_message("<span class='warning'>[ranged_ability_user]'s judicial visor fires a stream of energy at [target], creating a strange mark!</span>", "<span class='heavy_brass'>You direct [visor]'s power to [target]. You must wait for some time before doing this again.</span>")
		var/turf/targetturf = get_turf(target)
		new/obj/effect/clockwork/judicial_marker(targetturf, ranged_ability_user)
		add_logs(ranged_ability_user, targetturf, "created a judicial marker")
		ranged_ability_user.update_action_buttons_icon()
		ranged_ability_user.update_inv_glasses()
		addtimer(CALLBACK(visor, /obj/item/clothing/glasses/judicial_visor.proc/recharge_visor, ranged_ability_user), ratvar_awakens ? visor.recharge_cooldown*0.1 : visor.recharge_cooldown)//Cooldown is reduced by 10x if Ratvar is up
		remove_ranged_ability()

		return TRUE
	return FALSE

//Judicial marker: Created by the judicial visor. After three seconds, stuns any non-servants nearby and damages Nar-Sian cultists.
/obj/effect/clockwork/judicial_marker
	name = "judicial marker"
	desc = "You get the feeling that you shouldn't be standing here."
	clockwork_desc = "A sigil that will soon erupt and smite any unenlightened nearby."
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32
	layer = BELOW_MOB_LAYER
	var/mob/user

/obj/effect/clockwork/judicial_marker/New(loc, caster)
	..()
	SetLuminosity(4, 3)
	user = caster
	INVOKE_ASYNC(src, .proc/judicialblast)

/obj/effect/clockwork/judicial_marker/proc/judicialblast()
	playsound(src, 'sound/magic/MAGIC_MISSILE.ogg', 50, 1, 1, 1)
	flick("judicial_marker", src)
	sleep(16)
	layer = ABOVE_ALL_MOB_LAYER
	flick("judicial_explosion", src)
	sleep(13)
	var/targetsjudged = 0
	playsound(src, 'sound/effects/explosionfar.ogg', 100, 1, 1, 1)
	SetLuminosity(0)
	for(var/mob/living/L in range(1, src))
		if(is_servant_of_ratvar(L))
			continue
		if(L.null_rod_check())
			var/obj/item/I = L.null_rod_check()
			L.visible_message("<span class='warning'>Strange energy flows into [L]'s [I.name]!</span>", \
			"<span class='userdanger'>Your [I.name] shields you from [src]!</span>")
			continue
		if(!iscultist(L))
			L.visible_message("<span class='warning'>[L] is struck by a judicial explosion!</span>", \
			"<span class='userdanger'>[!issilicon(L) ? "An unseen force slams you into the ground!" : "ERROR: Motor servos disabled by external source!"]</span>")
			L.Weaken(8)
		else
			L.visible_message("<span class='warning'>[L] is struck by a judicial explosion!</span>", \
			"<span class='heavy_brass'>\"Keep an eye out, filth.\"</span>\n<span class='userdanger'>A burst of heat crushes you against the ground!</span>")
			L.Weaken(4) //half the stun, but sets cultists on fire
			L.adjust_fire_stacks(2)
			L.IgniteMob()
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			C.silent += 6
		targetsjudged++
		L.adjustBruteLoss(10)
		add_logs(user, L, "struck with a judicial blast")
	user << "<span class='brass'><b>[targetsjudged ? "Successfully judged <span class='neovgre'>[targetsjudged]</span>":"Judged no"] heretic[!targetsjudged || targetsjudged > 1 ? "s":""].</b></span>"
	sleep(3) //so the animation completes properly
	qdel(src)

/obj/effect/clockwork/judicial_marker/ex_act(severity)
	return
