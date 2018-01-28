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
	var/obj/item/umbral_tendrils/twin

/obj/item/umbral_tendrils/Initialize(mapload, new_darkspawn)
	. = ..()
	darkspawn = new_darkspawn
	for(var/obj/item/umbral_tendrils/U in loc)
		if(U != src)
			twin = U
			U.twin = src
			force = 12
			U.force = 12

/obj/item/umbral_tendrils/Destroy()
	if(twin)
		qdel(twin)
	. = ..()

/obj/item/umbral_tendrils/examine(mob/user)
	..()
	if(isobserver(user) || isdarkspawn(user))
		to_chat(user, "<span class='velvet bold'>Functions:<span>")
		to_chat(user, "<span class='velvet'><b>Help intent:</b> Click on an open tile within seven tiles to jump to it for 10 Psi.</span>")
		to_chat(user, "<span class='velvet'><b>Disarm intent:</b> Click on an airlock to force it open for 15 Psi (or 30 if it's bolted.)</span>")
		to_chat(user, "<span class='velvet'><b>Harm intent:</b> Click on a mob within five tiles to knock them down after half a second.</span>")
		to_chat(user, "<span class='velvet'>The tendrils will shatter light fixtures instantly, as opposed to in several attacks.</span>")
		to_chat(user, "<span class='velvet'>Also functions to pry open depowered airlocks on any intent other than harm.</span>")

/obj/item/umbral_tendrils/attack(mob/living/target, mob/living/user, twinned_attack = TRUE)
	set waitfor = FALSE
	..()
	sleep(1)
	if(twin && twinned_attack && user.Adjacent(target))
		twin.attack(target, user, FALSE)

/obj/item/umbral_tendrils/afterattack(atom/target, mob/living/user, proximity)
	if(!darkspawn)
		return
	switch(user.a_intent) //Note that airlock interactions can be found in airlock.dm.
		if(INTENT_HELP)
			if(isopenturf(target))
				tendril_jump(user, target)
		if(INTENT_HARM)
			tendril_swing(user, target)

/obj/item/umbral_tendrils/proc/tendril_jump(mob/living/user, turf/open/target) //throws the user towards the target turf
	if(!darkspawn.has_psi(10))
		to_chat(user, "<span class='warning'>You need at least 10 Psi to jump!</span>")
		return
	if(!(target in view(7, user)))
		to_chat(user, "<span class='warning'>You can't access that area, or it's too far away!</span>")
		return
	to_chat(user, "<span class='velvet'>You pull yourself towards [target].</span>")
	playsound(user, 'sound/magic/tail_swing.ogg', 10, TRUE)
	user.throw_at(target, 5, 3)
	darkspawn.use_psi(10)

/obj/item/umbral_tendrils/proc/tendril_swing(mob/living/user, mob/living/target) //swing the tendrils to knock someone down
	if(isliving(target) && target.lying)
		to_chat(user, "<span class='warning'>[target] is already knocked down!</span>")
		return
	user.visible_message("<span class='warning'>[user] draws back [src] and swings them towards [target]!</span>", \
	"<span class='velvet'><b>opehhjaoo</b><br>You swing your tendrils towards [target]!</span>")
	playsound(user, 'sound/magic/tail_swing.ogg', 50, TRUE)
	var/obj/item/projectile/umbral_tendrils/T = new(get_turf(user))
	T.preparePixelProjectile(target, user)
	T.twinned = twin
	T.firer = user
	T.fire()
	qdel(src)

/obj/item/projectile/umbral_tendrils
	name = "umbral tendrils"
	icon_state = "cursehand0"
	hitsound = 'sound/magic/pass_attack.ogg'
	layer = LARGE_MOB_LAYER
	damage = 0
	knockdown = 40
	speed = 1
	range = 5
	var/twinned = FALSE
	var/beam

/obj/item/projectile/umbral_tendrils/fire(setAngle)
	beam = firer.Beam(src, icon_state = "curse0", time = INFINITY, maxdistance = INFINITY)
	..()

/obj/item/projectile/umbral_tendrils/Destroy()
	qdel(beam)
	. = ..()

/obj/item/projectile/umbral_tendrils/on_hit(atom/movable/target, blocked = FALSE)
	if(blocked >= 100)
		return
	. = TRUE
	if(isliving(target))
		var/mob/living/L = target
		if(!iscyborg(target))
			playsound(target, 'sound/magic/pass_attack.ogg', 50, TRUE)
			if(!twinned)
				target.visible_message("<span class='warning'>[firer]'s [name] slam into [target], knocking them off their feet!</span>", \
				"<span class='userdanger'>You're knocked off your feet!</span>")
				L.Knockdown(40)
			else
				target.throw_at(get_step_towards(firer, target), 7, 2) //pull them towards us!
				target.visible_message("<span class='warning'>[firer]'s [name] slam into [target] and drag them across the ground!</span>", \
				"<span class='userdanger'>You're suddenly dragged across the floor!</span>")
				L.Knockdown(60)
				addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, target, 'sound/magic/pass_attack.ogg', 50, TRUE), 1)
		else
			var/mob/living/silicon/robot/R = target
			R.update_headlamp(TRUE) //disable headlamps
			target.visible_message("<span class='warning'>[firer]'s [name] smashes into [target]'s chassis!</span>", \
			"<span class='userdanger'>Heavy percussive impact detected. Recalibrating motor input.</span>")
			R.playsound_local(target, 'sound/misc/interference.ogg', 25, FALSE)
			playsound(R, 'sound/effects/bang.ogg', 50, TRUE)
			R.Knockdown(30)
			R.adjustBruteLoss(10)
