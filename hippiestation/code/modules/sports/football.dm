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
		to_chat(H, "<span class='warning'>Coach always said, \"never forget your helmet or your pads when you play football!\"</span>")
		return FALSE
	next_trigger = world.time + FOOTBALL_TACKLE_COOLDOWN
	var/turf/end = get_ranged_target_turf(H, H.dir, 7)
	H.Stun(18)
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
				H.visible_message("<span class='danger'>[H] slams into [A]!</span>","<span class='userdanger'>You slam into [A]!</span>")
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
	desc = "It should more accurately be called a \"hand-egg.\""
	force = 1
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 1
	var/stage = 0

/obj/item/weapon/football/throw_at(atom/target, range, speed, mob/thrower, spin=FALSE, diagonals_first = FALSE, datum/callback/callback)
	dir = thrower.dir
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
		if(stage > 3)
			explosion(get_turf(src), 0, 0, 1)
			visible_message("<span class='danger'>[src] explosively collides with [hit_atom]!</span>")
		if(ishuman(hit_atom))
			var/mob/living/carbon/human/H = hit_atom
			if(stage < 4)
				if(stage > 1)
					T.hotspot_expose(700, 40)
					visible_message("<span class='danger'>[src] combusts [H]!</span>")
			H.adjust_blurriness(stage)
			H.adjustStaminaLoss(2 * stage)
			playsound(src, 'sound/effects/hit_punch.ogg', 75)
		stage = 0
		throwforce = 0
		unlimitedthrow = FALSE
	dir = initial(dir)
	icon_state = "football"

/obj/item/weapon/football/is_hot()
	return stage * 900
