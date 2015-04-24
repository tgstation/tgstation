/*NOTES:
These are general powers. Specific powers are stored under the appropriate alien creature type.
*/

/*Alien spit now works like a taser shot. It won't home in on the target but will act the same once it does hit.
Doesn't work on other aliens/AI.*/

/datum/action/spell_action/alien

/datum/action/spell_action/alien/UpdateName()
	var/obj/effect/proc_holder/alien/ab = target
	return ab.name

/datum/action/spell_action/alien/IsAvailable()
	if(!target)
		return 0
	var/obj/effect/proc_holder/alien/ab = target

	if(usr)
		return ab.cost_check(ab.check_turf,usr,1)
	else
		if(owner)
			return ab.cost_check(ab.check_turf,owner,1)
	return 1

/datum/action/spell_action/alien/CheckRemoval()
	return !isalien(owner)


/obj/effect/proc_holder/alien
	name = "Alien Power"
	panel = "Alien"
	var/plasma_cost = 0
	var/check_turf = 0

	var/has_action = 1
	var/datum/action/spell_action/alien/action = null
	var/action_icon = 'icons/mob/actions.dmi'
	var/action_icon_state = "spell_default"
	var/action_background_icon_state = "bg_alien"

/obj/effect/proc_holder/alien/Click()
	if(!istype(usr,/mob/living/carbon/alien))
		return 1
	var/mob/living/carbon/alien/user = usr
	if(cost_check(check_turf,user))
		if(fire(user) && user) // Second check to prevent runtimes when evolving
			user.adjustToxLoss(-plasma_cost)
	return 1

/obj/effect/proc_holder/alien/proc/on_gain(var/mob/living/carbon/alien/user)
	return

/obj/effect/proc_holder/alien/proc/fire(var/mob/living/carbon/alien/user)
	return 1

/obj/effect/proc_holder/alien/proc/cost_check(check_turf=0,var/mob/living/carbon/alien/user,var/silent = 0)
	if(user.stat)
		if(!silent)
			user << "<span class='noticealien'>You must be conscious to do this.</span>"
		return 0
	if(user.getPlasma() < plasma_cost)
		if(!silent)
			user << "<span class='noticealien'>Not enough plasma stored.</span>"
		return 0
	if(check_turf && (!isturf(user.loc) || istype(user.loc, /turf/space)))
		if(!silent)
			user << "<span class='noticealien'>Bad place for a garden!</span>"
		return 0
	return 1

/obj/effect/proc_holder/alien/plant
	name = "Plant Weeds"
	desc = "Plants some alien weeds"
	plasma_cost = 50
	check_turf = 1

	action_icon_state = "alien_plant"

/obj/effect/proc_holder/alien/plant/fire(var/mob/living/carbon/alien/user)
	if(locate(/obj/structure/alien/weeds/node) in get_turf(user))
		src << "There's already a weed node here."
		return 0
	for(var/mob/O in viewers(user, null))
		O.show_message(text("<span class='alertalien'>[user] has planted some alien weeds!</span>"), 1)
	new/obj/structure/alien/weeds/node(user.loc)
	return 1

/obj/effect/proc_holder/alien/whisper
	name = "Whisper"
	desc = "Whisper to someone"
	plasma_cost = 10

	action_icon_state = "alien_whisper"

/obj/effect/proc_holder/alien/whisper/fire(var/mob/living/carbon/alien/user)
	var/mob/M = input("Select who to whisper to:","Whisper to?",null) as mob in oview(user)
	if(!M)
		return 0
	var/msg = sanitize(input("Message:", "Alien Whisper") as text|null)
	if(msg)
		log_say("AlienWhisper: [key_name(user)]->[M.key] : [msg]")
		M << "<span class='noticealien'>You hear a strange, alien voice in your head...</span>[msg]"
		user << {"<span class='noticealien'>You said: "[msg]" to [M]</span>"}
	else
		return 0
	return 1

/obj/effect/proc_holder/alien/transfer
	name = "Transfer Plasma"
	desc = "Transfer Plasma to another alien"
	plasma_cost = 0

	action_icon_state = "alien_transfer"

/obj/effect/proc_holder/alien/transfer/fire(var/mob/living/carbon/alien/user)
	var/list/mob/living/carbon/alien/aliens_around = list()
	for(var/mob/living/carbon/alien/A  in oview(user))
		aliens_around.Add(A)
	var/mob/living/carbon/alien/M = input("Select who to transfer to:","Transfer plasma to?",null) as mob in aliens_around
	if(!M)
		return 0
	if(isalien(M))
		var/amount = input("Amount:", "Transfer Plasma to [M]") as num
		if (amount)
			amount = abs(round(amount))
			if(user.getPlasma() > amount)
				if (get_dist(user,M) <= 1)
					M.adjustToxLoss(amount)
					user.adjustToxLoss(-amount)
					M << "<span class='noticealien'>[user] has transfered [amount] plasma to you.</span>"
					user << {"<span class='noticealien'>You trasfer [amount] plasma to [M]</span>"}
				else
					user << "<span class='noticealien'>You need to be closer!</span>"
	return

/obj/effect/proc_holder/alien/acid
	name = "Corrossive Acid"
	desc = "Drench an object in acid, destroying it over time."
	plasma_cost = 200

	action_icon_state = "alien_acid"

/obj/effect/proc_holder/alien/acid/on_gain(var/mob/living/carbon/alien/user)
	user.verbs.Add(/mob/living/carbon/alien/humanoid/proc/corrosive_acid)

/obj/effect/proc_holder/alien/acid/proc/corrode(var/target,var/mob/living/carbon/alien/user = usr)
	if(target in oview(1,user))
		// OBJ CHECK
		if(isobj(target))
			var/obj/I = target
			if(I.unacidable)	//So the aliens don't destroy energy fields/singularies/other aliens/etc with their acid.
				user << "<span class='noticealien'>You cannot dissolve this object.</span>"
				return 0
		// TURF CHECK
		else if(istype(target, /turf/simulated))
			var/turf/T = target
			// R WALL
			if(istype(T, /turf/simulated/wall/r_wall))
				user << "<span class='noticealien'>You cannot dissolve this object.</span>"
				return 0
			// R FLOOR
			if(istype(T, /turf/simulated/floor/engine))
				user << "<span class='noticealien'>You cannot dissolve this object.</span>"
				return 0
		else// Not a type we can acid.
			return 0
		new /obj/effect/acid(get_turf(target), target)
		user.visible_message("<span class='alertalien'>[user] vomits globs of vile stuff all over [target]. It begins to sizzle and melt under the bubbling mess of acid!</span>")
		return 1
	else
		src << "<span class='noticealien'>Target is too far away.</span>"
		return 0


/obj/effect/proc_holder/alien/acid/fire(var/mob/living/carbon/alien/user)
	var/O = input("Select what to dissolve:","Dissolve",null) as obj|turf in oview(1,user)
	if(!O)
		return 0
	return corrode(O,user)

/mob/living/carbon/alien/humanoid/proc/corrosive_acid(O as obj|turf in oview(1)) // right click menu verb ugh
	set name = "Corrossive Acid"

	if(!isalien(usr))
		return
	var/mob/living/carbon/alien/humanoid/user = usr
	var/obj/effect/proc_holder/alien/acid/A = locate() in user.abilities
	if(!A)
		return
	if(user.getPlasma() > A.plasma_cost && A.corrode(O))
		user.adjustToxLoss(-A.plasma_cost)


/obj/effect/proc_holder/alien/neurotoxin
	name = "Spit Neurotoxin"
	desc = "Spits neurotoxin at someone, paralyzing them for a short time."
	plasma_cost = 50

	action_icon_state = "alien_neurotoxin"

/obj/effect/proc_holder/alien/neurotoxin/fire(var/mob/living/carbon/alien/user)
	user.visible_message("<span class='danger'>[user] spits neurotoxin!", "<span class='alertalien'>You spit neurotoxin.</span>")

	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir) // Get the tile infront of the move, based on their direction
	if(!isturf(U) || !isturf(T))
		return 0

	var/obj/item/projectile/bullet/neurotoxin/A = new /obj/item/projectile/bullet/neurotoxin(user.loc)
	A.current = U
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	A.fire()

	return 1


/obj/effect/proc_holder/alien/resin
	name = "Secrete Resin"
	desc = "Secrete tough malleable resin."
	plasma_cost = 55
	check_turf = 1

	action_icon_state = "alien_resin"

/obj/effect/proc_holder/alien/resin/fire(var/mob/living/carbon/alien/user)
	if(locate(/obj/structure/alien/resin) in user.loc.contents)
		user << "<span class='danger'>There is already a resin structure there.</span>"
		return 0
	var/choice = input("Choose what you wish to shape.","Resin building") as null|anything in list("resin wall","resin membrane","resin nest") //would do it through typesof but then the player choice would have the type path and we don't want the internal workings to be exposed ICly - Urist

	if(!choice)
		return 0

	user << "<span class='notice'>You shape a [choice].</span>"
	user.visible_message("<span class='notice'>[user] vomits up a thick purple substance and begins to shape it.</span>")

	switch(choice)
		if("resin wall")
			new /obj/structure/alien/resin/wall(user.loc)
		if("resin membrane")
			new /obj/structure/alien/resin/membrane(user.loc)
		if("resin nest")
			new /obj/structure/stool/bed/nest(user.loc)
	return 1

/obj/effect/proc_holder/alien/regurgitate
	name = "Regurgitate"
	desc = "Empties the contents of your stomach"
	plasma_cost = 0

	action_icon_state = "alien_barf"

/obj/effect/proc_holder/alien/regurgitate/fire(var/mob/living/carbon/alien/user)
	if(user.stomach_contents.len)
		for(var/atom/movable/A in user.stomach_contents)
			if(A in user.stomach_contents)
				user.stomach_contents.Remove(A)
				A.loc = user.loc
				//Paralyse(10)
		user.visible_message("<span class='alertealien'>[user] hurls out the contents of their stomach!</span>")
	return

/obj/effect/proc_holder/alien/nightvisiontoggle
	name = "Toggle Night Vision"
	desc = "Toggles Night Vision"
	plasma_cost = 0

	has_action = 0 // Has dedicated GUI button already

/obj/effect/proc_holder/alien/nightvisiontoggle/fire(var/mob/living/carbon/alien/user)

	if(!user.nightvision)
		user.see_in_dark = 8
		user.see_invisible = SEE_INVISIBLE_MINIMUM
		user.nightvision = 1
		user.hud_used.nightvisionicon.icon_state = "nightvision1"
	else if(user.nightvision == 1)
		user.see_in_dark = 4
		user.see_invisible = 45
		user.nightvision = 0
		user.hud_used.nightvisionicon.icon_state = "nightvision0"

	return 1

