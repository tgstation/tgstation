#define FOOTBALL_TACKLE_COOLDOWN 150
#define FOOTBALL_THROW_COOLDOWN 40

/datum/action/item_action/tackle
	name = "Tackle"
	desc = "Charge forward and tackle anyone in your path."
	var/next_trigger = 1

/datum/action/item_action/tackle/Trigger()
	if(!..() || !ishuman(owner) || (next_trigger > world.time))
		return FALSE
	var/mob/living/carbon/human/H = owner
	if(!istype(H.wear_suit, /obj/item/clothing/suit/hippie/football) || !istype(H.head, /obj/item/clothing/head/helmet/hippie/football))
		to_chat(H, "<span class='warning'>You can't play football without the proper equipment on!</span>")
		return FALSE
	next_trigger = world.time + FOOTBALL_TACKLE_COOLDOWN
	var/turf/end = get_ranged_target_turf(H, H.dir, 7)
	H.Stun(16)
	var/slammed
	for(var/turf/T in getline(get_turf(H), end))
		for(var/atom/A in T)
			if(A == H)
				continue
			if(isliving(A))
				var/mob/living/M = A
				if(M.lying)
					continue
				slammed = TRUE
				M.visible_message("<span class='danger'>[H] tackles down [M]!</span>","<span class='userdanger'>You get tackled down by [H]!</span>")
				H.forceMove(T)
				H.Knockdown(20)
				M.Knockdown(110)
				M.adjustBrainLoss(20)
				M.adjustBruteLoss(15)
				playsound(H, "punch", 50, 1)
				break
			if(!A.CanPass(H, T) || istype(T, /turf/closed))
				slammed = TRUE
				var/hit_message = "[istype(T, /turf/closed) ? T.name : A.name]" //You will hit 'proximity checker' otherwise
				H.visible_message("<span class='danger'>[H] slams into the [hit_message]!</span>","<span class='userdanger'>You slam into the [hit_message]!</span>")
				H.blur_eyes(8)
				H.Knockdown(80)
				H.adjustBrainLoss(18)
				playsound(H, 'hippiestation/sound/misc/crack.ogg', 100, 1)
				break
		if(slammed)
			break
		playsound(H, 'sound/effects/pressureplate.ogg', 40, 1)
		H.forceMove(T)
		if(T == end)
			break
		sleep(1)
		continue
	return TRUE

/obj/item/weapon/football
	name = "football"
	icon = 'hippiestation/icons/obj/weapons.dmi'
	icon_state = "football"
	resistance_flags = FIRE_PROOF
	desc = "It should more accurately be called a \"hand-egg.\""
	force = 1
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 1
	var/stage = 0

/obj/item/weapon/football/throw_at(atom/target, range, speed, mob/thrower, spin=FALSE, diagonals_first = TRUE, datum/callback/callback)
	throw_speed = 1
	icon_state = "football_air"
	if(istype(thrower, /mob/living/carbon/human))
		var/mob/living/carbon/human/user = thrower
		if(user.wear_suit && istype(user.wear_suit, /obj/item/clothing/suit/hippie/football))
			var/obj/item/clothing/suit/hippie/football/suit = user.wear_suit
			if(suit.next_throw < world.time)
				playsound(src, 'hippiestation/sound/effects/whoosh.ogg', 50)
				suit.next_throw = world.time + FOOTBALL_THROW_COOLDOWN
				unlimitedthrow = TRUE
				stage = 1
				throwforce = 2
				START_PROCESSING(SSobj, src)
			else
				to_chat(thrower, "<span class='warning'>You fumble the ball! Wait a little bit before doing another pro-throw!</span>")
				icon_state = "football"
				return FALSE
	. = ..(target, range, speed, thrower, FALSE, diagonals_first, callback)

/obj/item/weapon/football/process()
	if(stage == 2)
		icon_state = "football_hot"
		visible_message("<span class='danger'>[src] bursts into flames!</span>")
		do_sparks(10, FALSE, src)
	stage++

/obj/item/weapon/football/throw_impact(atom/hit_atom)
	if(stage)
		STOP_PROCESSING(SSobj, src)
		throwforce = (stage * 7)
		if(stage > 2)
			var/turf/T = get_turf(hit_atom)
			var/obj/effect/hotspot/W = new(T)
			W.temperature = Clamp(350 * stage, 0, 1600)
			W.volume = Clamp(20 * stage, 0, 100)
		if(stage > 4)
			var/light = round(stage / 1.5)
			explosion(get_turf(hit_atom), 0, 0, light)
		if(ishuman(hit_atom))
			var/mob/living/carbon/human/H = hit_atom
			H.adjust_blurriness(stage)
			H.adjustStaminaLoss(2 * stage)
			playsound(src, 'sound/effects/hit_punch.ogg', 75)
		stage = 0
		throwforce = 0
		unlimitedthrow = FALSE
	icon_state = "football"

/obj/item/weapon/football/is_hot()
	return stage * 900
	
/obj/item/weapon/football/ex_act()
	return

#undef FOOTBALL_TACKLE_COOLDOWN
#undef FOOTBALL_THROW_COOLDOWN