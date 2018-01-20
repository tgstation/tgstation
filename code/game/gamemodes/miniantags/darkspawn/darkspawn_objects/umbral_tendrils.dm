//Created by Pass.
/obj/item/umbral_tendrils
	name = "umbral tendrils"
	desc = "A mass of pulsing, chitonous tendrils with exposed violet flesh."
	force = 15
	flags_1 = NODROP_1
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "umbral_tendrils"
	item_state = "umbral_tendrils"
	lefthand_file = 'icons/mob/inhands/antag/darkspawn_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/darkspawn_righthand.dmi'
	hitsound = 'sound/magic/pass_attack.ogg'
	attack_verb = list("impaled", "tentacled", "torn")
	var/datum/antagonist/darkspawn/darkspawn

/obj/item/umbral_tendrils/Initialize(mapload, new_darkspawn)
	. = ..()
	darkspawn = new_darkspawn

/obj/item/umbral_tendrils/examine(mob/user)
	..()
	if(isobserver(user) || isdarkspawn(user))
		to_chat(user, "<span class='velvet bold'>Functions:<span>")
		to_chat(user, "<span class='velvet'><b>Help intent:</b> Click on an open tile within seven meters to jump to it for 10 Psi.</span>")
		to_chat(user, "<span class='velvet'><b>Disarm intent:</b> Click on an airlock to force it open for 15 Psi (or 30 if it's bolted.)</span>")
		to_chat(user, "<span class='velvet'><b>Harm intent:</b> Click on a mob within four tiles to knock them down after half a second.</span>")
		to_chat(user, "<span class='velvet'>The tendrils will shatter light fixtures instantly, as opposed to in several attacks.</span>")
		to_chat(user, "<span class='velvet'>Also functions to pry open depowered airlocks on any intent other than harm.</span>")

/obj/item/umbral_tendrils/afterattack(atom/target, mob/living/user, proximity)
	if(!darkspawn)
		return
	switch(user.a_intent) //Note that airlock interactions can be found in airlock.dm.
		if(INTENT_HELP)
			if(isopenturf(target))
				tendril_jump(user, target)
		if(INTENT_HARM)
			if(isliving(target) && !proximity)
				tendril_swing(user, target)

/obj/item/umbral_tendrils/proc/tendril_jump(mob/living/user, turf/open/target) //throws the user towards the target turf
	if(!darkspawn.has_psi(10))
		to_chat(user, "<span class='warning'>You need at least 10 Psi to jump!</span>")
		return
	if(!(target in view(5, user)))
		to_chat(user, "<span class='warning'>You can't access that area, or it's too far away!</span>")
		return
	to_chat(user, "<span class='velvet'>You pull yourself towards [target].</span>")
	playsound(user, 'sound/magic/tail_swing.ogg', 10, TRUE)
	user.throw_at(target, 5, 3)
	darkspawn.use_psi(10)

/obj/item/umbral_tendrils/proc/tendril_swing(mob/living/user, mob/living/target) //swing the tendrils to knock someone down
	if(!(target in view(4, user)))
		to_chat(user, "<span class='warning'>[target] is not accessible or needs to be closer!</span>")
		return
	user.visible_message("<span class='warning'>[user] draws back [src] and swings them towards [target]!</span>", \
	"<span class='velvet'><b>opehhjaoo</b><br>You swing your tendrils towards [target]!</span>")
	playsound(user, 'sound/magic/tail_swing.ogg', 50, TRUE)
	addtimer(CALLBACK(src, .proc/tendril_knockdown, user, target), 5)

/obj/item/umbral_tendrils/proc/tendril_knockdown(mob/living/user, mob/living/target)
	if(QDELETED(src))
		return
	if(!(target in view(4, user)))
		user.visible_message("<span class='warning'>[user]'s tendrils crack as they whip harmlessly through the air!</span>", \
		"<span class='velvet italics'>[target] escaped your range!</span>")
		return
	if(!issilicon(target))
		target.visible_message("<span class='warning'>[user]'s [name] slam into [target], knocking \them off \their feet!</span>", \
		"<span class='userdanger'>You feel something slam into your stomach, knocking you off your feet!</span>")
		playsound(user, 'sound/magic/pass_attack.ogg', 50, TRUE)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, target, 'sound/magic/pass_attack.ogg', 50, TRUE), 2)
		target.Knockdown(50)
	else
		target.visible_message("<span class='warning'>[user]'s [name] smashes into [target]'s chassis!</span>", \
		"<span class='userdanger'>Heavy percussive impact detected. Recalibrating motor input.</span>")
		target.playsound_local(target, 'sound/misc/interference.ogg', 25, FALSE)
		target.Knockdown(40)
		playsound(user, 'sound/effects/bang.ogg', 50, TRUE)
		target.adjustBruteLoss(10)
	qdel(src)
