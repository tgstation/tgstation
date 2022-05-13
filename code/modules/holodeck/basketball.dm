//Basketball items and structures

/obj/item/toy/basketball
	name = "basketball"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "basketball"
	inhand_icon_state = "basketball"
	desc = "Here's your chance, do your dance at the Space Jam."
	w_class = WEIGHT_CLASS_BULKY //Stops people from hiding it in their bags/pockets


/obj/structure/hoop
	name = "basketball hoop"
	desc = "Boom, shakalaka!"
	icon = 'icons/obj/basketball.dmi'
	icon_state = "hoop"
	anchored = TRUE
	density = TRUE

/**
* this proc is for dunking an object
*
* ball_exp is how much exp you get for a dunk, ball_skill is balling skill level modifier
* dunking has a 60% chance of failure which decreases based on balling skill
*			unsuccessful: 5 exp; 50 stamina damage; ball goes in a random direction one step away
*			sucessful: 20 exp; 40-10 stamina damage (based on ball_skill); ball goes in net
*/
/obj/structure/hoop/attackby(obj/item/dunk_object, mob/user, params)
	if(get_dist(src,user)>=2) //can only dunk when close
		return

	var/ball_skill = user.mind?.get_skill_modifier(/datum/skill/balling, SKILL_PROBS_MODIFIER)
	var/ball_exp = 0

	if(prob(60 - ball_skill)) //60% base chance to fail a dunk
		if(isliving(user))
			var/mob/living/living_baller = user
			living_baller.apply_damage(50, STAMINA) //failing a dunk is universally taxing
		ball_exp = 5
		user?.mind.adjust_experience(/datum/skill/balling, ball_exp)
		visible_message(span_danger("[user] fumbles the dunk!"))
		user.dropItemToGround(dunk_object)
		step(dunk_object, pick(NORTH,SOUTH,EAST,WEST))
		return

	if(user.transferItemToLoc(dunk_object, drop_location()))
		var/stam_cost = 40 - ball_skill / 2
		if(isliving(user))
			var/mob/living/living_baller = user
			living_baller.apply_damage(stam_cost, STAMINA)
		ball_exp = 20
		user?.mind.adjust_experience(/datum/skill/balling, ball_exp)
		visible_message(span_warning("[user] dunks [dunk_object] into \the [src]!"))

/obj/structure/hoop/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(user.pulling && isliving(user.pulling))
		var/mob/living/victim = user.pulling
		if(user.grab_state < GRAB_AGGRESSIVE)
			to_chat(user, span_warning("You need a better grip to do that!"))
			return
		victim.forceMove(loc)
		victim.Paralyze(100)
		visible_message(span_danger("[user] dunks [victim] into \the [src]!"))
		user.stop_pulling()
	else
		..()
/**
* this proc is for when a hoop is hit by a thrown item, and calculates whether it goes in
*
* baller is the person who threw the ball, ball_skill is balling skill level modifier,
* shot_difficulty is a measure of how difficult a shot is. based on distance to net - (ball_skill / 10). capped between 0 and 9
* stam_cost is how taxing a shot is. success is not a factor and scales with distance. capped between 5 and 15 stam damage
* ball_exp is how much exp you get for a shot. success is a factor and scales with distance. capped between 10 and 50
* odds of *not* making a shot are calculated by taking the prob of shot_difficulty*10. so higher difficulty = harder shot.
*			unsuccessful: 5 exp; 5-15 stam_cost; ball bounces off
*			successful: 10-50 exp; 5-15 stam_cost; ball goes in net
*/
/obj/structure/hoop/hitby(atom/movable/thrownitem, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(!isitem(thrownitem) || istype(thrownitem,/obj/projectile))
		return ..()

	var/mob/baller = throwingdatum?.thrower
	var/ball_skill = baller.mind?.get_skill_modifier(/datum/skill/balling, SKILL_PROBS_MODIFIER)
	var/shot_difficulty = clamp((throwingdatum?.maxrange - (ball_skill / 10)), 0, 9)
	var/stam_cost = clamp((throwingdatum?.maxrange * 2), 5, 15)
	var/ball_exp = clamp((throwingdatum?.maxrange * 8), 10, 50)

	if(isliving(baller))
		var/mob/living/living_baller = baller
		living_baller.apply_damage(stam_cost, STAMINA)

	if(prob(shot_difficulty*10)) //chance of missing the shot
		visible_message(span_warning("[thrownitem] bounces off of [src]'s rim!"))
		baller?.mind.adjust_experience(/datum/skill/balling, 5)
		return ..()

	thrownitem.forceMove(get_turf(src))
	baller?.mind.adjust_experience(/datum/skill/balling, ball_exp)
	visible_message(span_warning("Swish! [thrownitem] lands in [src]."))
	return
