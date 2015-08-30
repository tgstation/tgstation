//Revenants: based off of wraiths from Goon
//"Ghosts" that are invisible and move like ghosts, cannot take damage while invsible
//Don't hear deadchat and are NOT normal ghosts
//Admin-spawn or random event

/mob/living/simple_animal/revenant
	name = "revenant"
	desc = "A malevolent spirit."
	icon = 'icons/mob/mob.dmi'
	icon_state = "revenant_idle"
	incorporeal_move = 3
	invisibility = INVISIBILITY_OBSERVER
	health = 25
	maxHealth = 25
	healable = 0
	see_invisible = SEE_INVISIBLE_OBSERVER
	languages = ALL
	response_help   = "passes through"
	response_disarm = "swings at"
	response_harm   = "punches through"
	unsuitable_atmos_damage = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	harm_intent_damage = 0
	friendly = "touches"
	status_flags = 0
	wander = 0
	density = 0
	flying = 1
	anchored = 1

	var/essence = 25 //The resource of revenants. Max health is equal to three times this amount
	var/essence_regen_cap = 25 //The regeneration cap of essence (go figure); regenerates every Life() tick up to this amount.
	var/essence_regenerating = 1 //If the revenant regenerates essence or not; 1 for yes, 0 for no
	var/essence_regen_amount = 2 //How much essence regenerates
	var/essence_min = 1 //The minimum amount of essence a revenant can have; by default, it never drops below one
	var/essence_accumulated = 0 //How much essence the revenant has stolen
	var/revealed = 0 //If the revenant can take damage from normal sources.
	var/inhibited = 0 //If the revenant's abilities are blocked by a chaplain's power.
	var/essence_drained = 0 //How much essence the revenant has drained.
	var/draining = 0 //If the revenant is draining someone.
	var/list/drained_mobs = list() //Cannot harvest the same mob twice

/mob/living/simple_animal/revenant/Life()
	..()
	if(essence < essence_min)
		essence = essence_min
	if(essence_regenerating && !inhibited && essence < essence_regen_cap) //While inhibited, essence will not regenerate
		essence += essence_regen_amount
		if(essence > essence_regen_cap)
			essence = essence_regen_cap
	maxHealth = essence * 3
	if(!revealed)
		health = maxHealth //Heals to full when not revealed

/mob/living/simple_animal/revenant/ex_act(severity, target)
	return 1 //Immune to the effects of explosions.

/mob/living/simple_animal/revenant/blob_act()
	return //blah blah blobs aren't in tune with the spirit world, or something.

/mob/living/simple_animal/revenant/ClickOn(atom/A, params) //Copypaste from ghost code - revenants can't interact with the world directly.
	if(client.buildmode)
		build_click(src, client.buildmode, params, A)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"])
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(world.time <= next_move)
		return
	A.attack_ghost(src)
	if(ishuman(A) && in_range(src, A))
		Harvest(A)


/mob/living/simple_animal/revenant/proc/Harvest(mob/living/carbon/human/target)
	if(!castcheck(0))
		return
	if(draining)
		src << "<span class='warning'>You are already siphoning the essence of a soul!</span>"
		return
	if(target in drained_mobs)
		src << "<span class='warning'>[target]'s soul is dead and empty.</span>"
		return
	if(!target.stat)
		src << "<span class='notice'>This being's soul is too strong to harvest.</span>"
		if(prob(10))
			target << "You feel as if you are being watched."
		return
	draining = 1
	essence_drained = 2
	src << "<span class='notice'>You search for the soul of [target].</span>"
	if(do_after(src, 10, 3, 0, target)) //did they get deleted in that second?
		if(target.ckey)
			src << "<span class='notice'>Their soul burns with intelligence.</span>"
			essence_drained += 2
		if(target.stat != DEAD)
			src << "<span class='notice'>Their soul blazes with life!</span>"
			essence_drained += 2
		else
			src << "<span class='notice'>Their soul is weak and faltering.</span>"
		if(do_after(src, 20, 6, 0, target)) //did they get deleted NOW?
			switch(essence_drained)
				if(1 to 2)
					src << "<span class='info'>[target] will not yield much essence. Still, every bit counts.</span>"
				if(3 to 4)
					src << "<span class='info'>[target] will yield an average amount of essence.</span>"
				if(5 to INFINITY)
					src << "<span class='info'>Such a feast! [target] will yield much essence to you.</span>"
			if(do_after(src, 30, 9, 0, target)) //how about now
				if(!target.stat)
					src << "<span class='warning'>They are now powerful enough to fight off your draining.</span>"
					target << "<span class='boldannounce'>You feel something tugging across your body before subsiding.</span>"
					draining = 0
					return //hey, wait a minute...
				src << "<span class='danger'>You begin siphoning essence from [target]'s soul.</span>"
				if(target.stat != DEAD)
					target << "<span class='warning'>You feel a horribly unpleasant draining sensation as your grip on life weakens...</span>"
				icon_state = "revenant_draining"
				reveal(65)
				stun(65)
				target.visible_message("<span class='warning'>[target] suddenly rises slightly into the air, their skin turning an ashy gray.</span>")
				target.Beam(src,icon_state="drain_life",icon='icons/effects/effects.dmi',time=60)
				if(target) //As one cannot prove the existance of ghosts, ghosts cannot prove the existance of the target they were draining.
					change_essence_amount(essence_drained * 5, 0, target)
					src << "<span class='info'>[target]'s soul has been considerably weakened and will yield no more essence for the time being.</span>"
					target.visible_message("<span class='warning'>[target] gently slumps back onto the ground.</span>")
					drained_mobs.Add(target)
					target.death(0)
				icon_state = "revenant_idle"
			else
				src << "<span class='warning'>You are not close enough to siphon [target]'s soul. The link has been broken.</span>"
				draining = 0
				return
	draining = 0
	return


/mob/living/simple_animal/revenant/say(message)
	return 0 //Revenants cannot speak out loud.

/mob/living/simple_animal/revenant/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Current essence: [essence]E")
		stat(null, "Stolen essence: [essence_accumulated]E")

/mob/living/simple_animal/revenant/New()
	..()
	spawn(5)
		if(src.mind)
			src.mind.remove_all_antag()
			src.mind.wipe_memory()
			src << 'sound/effects/ghost.ogg'
			src << "<br>"
			src << "<span class='deadsay'><font size=3><b>You are a revenant.</b></font></span>"
			src << "<b>Your formerly mundane spirit has been infused with alien energies and empowered into a revenant.</b>"
			src << "<b>You are not dead, not alive, but somewhere in between. You are capable of limited interaction with both worlds.</b>"
			src << "<b>You are invincible and invisible to everyone but other ghosts. Some abilities may change this.</b>"
			src << "<b>To function, you are to drain the life essence from humans. This essence is a resource and will power all of your abilities.</b>"
			src << "<b><i>You do not remember anything of your past lives, nor will you remember anything about this one after your death.</i></b>"
			src << "<b>Be sure to read the wiki page at https://tgstation13.org/wiki/Revenant to learn more.</b>"
			var/datum/objective/revenant/objective = new
			objective.owner = src.mind
			src.mind.objectives += objective
			src << "<b>Objective #1</b>: [objective.explanation_text]"
			var/datum/objective/revenantFluff/objective2 = new
			objective2.owner = src.mind
			src.mind.objectives += objective2
			src << "<b>Objective #2</b>: [objective2.explanation_text]"
			ticker.mode.traitors |= src.mind //Necessary for announcing
		mob_spell_list += new /obj/effect/proc_holder/spell/targeted/revenant_transmit
		mob_spell_list += new /obj/effect/proc_holder/spell/aoe_turf/revenant_light
		mob_spell_list += new /obj/effect/proc_holder/spell/aoe_turf/revenant_defile
		mob_spell_list += new /obj/effect/proc_holder/spell/aoe_turf/revenant_malf

/mob/living/simple_animal/revenant/death()
	..(1)
	src << "<span class='userdanger'><b>NO! No... it's too late, you can feel yourself fading...</b></span>"
	notransform = 1
	revealed = 1
	invisibility = 0
	playsound(src, 'sound/effects/screech.ogg', 100, 1)
	visible_message("<span class='warning'>[src] lets out a waning screech as violet mist swirls around its dissolving body!</span>")
	icon_state = "revenant_draining"
	for(var/i = alpha, i > 0, i -= 10)
		sleep(0.1)
		alpha = i
	visible_message("<span class='danger'>[src]'s body breaks apart into blue dust.</span>")
	new /obj/item/weapon/ectoplasm/revenant(get_turf(src))
	ghostize()
	qdel(src)
	return


/mob/living/simple_animal/revenant/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/weapon/nullrod))
		visible_message("<span class='warning'>[src] violently flinches!</span>", \
						"<span class='boldannounce'>As the null rod passes through you, you feel your essence draining away!</span>")
		essence -= 25 //hella effective
		inhibited = 1
		spawn(30)
			inhibited = 0
	..()


/mob/living/simple_animal/revenant/proc/castcheck(essence_cost)
	if(!src)
		return
	var/turf/T = get_turf(src)
	if(istype(T, /turf/simulated/wall))
		src << "<span class='warning'>You cannot use abilities from inside of a wall.</span>"
		return 0
	if(src.inhibited)
		src << "<span class='warning'>Your powers have been suppressed by nulling energy!</span>"
		return 0
	if(!src.change_essence_amount(essence_cost, 1))
		src << "<span class='warning'>You lack the essence to use that ability.</span>"
		return 0
	return 1



/mob/living/simple_animal/revenant/proc/change_essence_amount(essence_amt, silent = 0, source = null)
	if(!src)
		return
	if(essence + essence_amt <= 0)
		return
	essence += essence_amt
	essence = max(0, essence)
	if(essence_amt > 0)
		essence_accumulated += essence_amt
		essence_accumulated = max(0, essence_accumulated)
	if(!silent)
		if(essence_amt > 0)
			src << "<span class='notice'>Gained [essence_amt]E from [source].</span>"
		else
			src << "<span class='danger'>Lost [essence_amt]E from [source].</span>"
	return 1



/mob/living/simple_animal/revenant/proc/reveal(time)
	if(!src)
		return
	if(time <= 0)
		return
	revealed = 1
	invisibility = 0
	src << "<span class='warning'>You have been revealed.</span>"
	spawn(time)
		revealed = 0
		invisibility = INVISIBILITY_OBSERVER
		src << "<span class='notice'>You are once more concealed.</span>"

/mob/living/simple_animal/revenant/proc/stun(time)
	if(!src)
		return
	if(time <= 0)
		return
	notransform = 1
	src << "<span class='warning'>You cannot move!</span>"
	spawn(time)
		notransform = 0
		src << "<span class='notice'>You can move again!</span>"



/datum/objective/revenant
	dangerrating = 10
	var/targetAmount = 100

/datum/objective/revenant/New()
	targetAmount = rand(100,200)
	explanation_text = "Absorb [targetAmount] points of essence from humans."
	..()

/datum/objective/revenant/check_completion()
	if(!istype(owner.current, /mob/living/simple_animal/revenant))
		return 0
	var/mob/living/simple_animal/revenant/R = owner.current
	if(!R || R.stat == DEAD)
		return 0
	var/essence_stolen = R.essence_accumulated
	if(essence_stolen < targetAmount)
		return 0
	return 1

/datum/objective/revenantFluff
	dangerrating = 0

/datum/objective/revenantFluff/New()
	var/list/explanationTexts = list("Attempt to make your presence unknown to the crew.", \
									 "Collaborate with existing antagonists aboard the station to gain essence.", \
									 "Remain nonlethal and only absorb bodies that have already died.", \
									 "Use your environments to eliminate isolated people.", \
									 "If there is a chaplain aboard the station, ensure they are killed.", \
									 "Hinder the crew without killing them.")
	explanation_text = pick(explanationTexts)
	..()

/datum/objective/revenantFluff/check_completion()
	return 1


/obj/item/weapon/ectoplasm/revenant
	name = "glimmering residue"
	desc = "A pile of fine blue dust. Small tendrils of violet mist swirl around it."
	icon = 'icons/effects/effects.dmi'
	icon_state = "revenantEctoplasm"
	w_class = 2
	var/reforming = 0
	var/reformed = 0

/obj/item/weapon/ectoplasm/revenant/New()
	..()
	reforming = 1
	spawn(600) //1 minute
		if(src && reforming)
			return reform()
		if(src && !reforming)
			visible_message("<span class='warning'>[src] settles down and seems lifeless.</span>")
			return

/obj/item/weapon/ectoplasm/revenant/attack_hand(mob/user)
	if(reformed)
		user << "<span class='warning'>[src] keeps slipping out of your hands, you can't get a hold on it!</span>"
		return
	..()

/obj/item/weapon/ectoplasm/revenant/attack_self(mob/user)
	if(!reforming)
		return ..()
	user.visible_message("<span class='notice'>[user] scatters [src] in all directions.</span>", \
						 "<span class='notice'>You scatter [src] across the area. The particles slowly fade away.</span>")
	user.drop_item()
	qdel(src)

/obj/item/weapon/ectoplasm/revenant/throw_impact(atom/hit_atom)
	..()
	visible_message("<span class='notice'>[src] breaks into particles upon impact, which fade away to nothingness.</span>")
	qdel(src)

/obj/item/weapon/ectoplasm/revenant/examine(mob/user)
	..()
	if(reforming)
		user << "<span class='warning'>It is shifting and distorted. It would be wise to destroy this.</span>"
	else if(!reforming)
		user << "<span class='notice'>It seems inert.</span>"

/obj/item/weapon/ectoplasm/revenant/proc/reform()
	if(!reforming || !src)
		return
	message_admins("Revenant ectoplasm was left undestroyed for 1 minute and has reformed into a new revenant.")
	loc = get_turf(src) //In case it's in a backpack or someone's hand
	visible_message("<span class='boldannounce'>[src] suddenly rises into the air before fading away.</span>")
	var/mob/living/simple_animal/revenant/R = new(get_turf(src))
	qdel(src)
	var/list/candidates = get_candidates(BE_REVENANT)
	if(!candidates.len)
		message_admins("No candidates were found for the new revenant. Oh well!")
		return 0
	var/client/C = pick(candidates)
	var/key_of_revenant = C.key
	if(!key_of_revenant)
		message_admins("No ckey was found for the new revenant. Oh well!")
		return 0
	var/datum/mind/player_mind = new /datum/mind(key_of_revenant)
	player_mind.active = 1
	player_mind.transfer_to(R)
	player_mind.assigned_role = "revenant"
	player_mind.special_role = "Revenant"
	ticker.mode.traitors |= player_mind
	message_admins("[key_of_revenant] has been made into a revenant by reforming ectoplasm.")
	log_game("[key_of_revenant] was spawned as a revenant by reforming ectoplasm.")
	return 1
