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
	see_in_dark = 255
	see_invisible = SEE_INVISIBLE_OBSERVER
	languages = ALL
	response_help   = "passes through"
	response_disarm = "swings at"
	response_harm   = "punches"
	minbodytemp = 0
	maxbodytemp = INFINITY
	harm_intent_damage = 5
	speak_emote = list("hisses", "spits", "growls")
	friendly = "touches"
	status_flags = 0
	wander = 0
	density = 0

	var/essence = 25 //The resource of revenants. Max health is equal to twice this amount
	var/essence_regen_cap = 25 //The regeneration cap of essence (go figure); regenerates every Life() tick up to this amount.
	var/essence_regen = 1 //If the revenant regenerates essence or not; 1 for yes, 0 for no
	var/essence_min = 1 //The minimum amount of essence a revenant can have; by default, it never drops below one
	var/strikes = 0 //How many times a revenant can die before dying for good
	var/revealed = 0 //If the revenant can take damage from normal sources.
	var/inhibited = 0 //If the revenant's abilities are blocked by a chaplain's power.

/mob/living/simple_animal/revenant/Life()
	..()
	if(essence < essence_min)
		essence = essence_min
		if(strikes > 0)
			strikes--
			src << "<span class='boldannounce'>Your essence has dropped below critical levels. You barely manage to save yourself - [strikes ? "you can't keep this up!" : "next time, it's death."]</span>"
		else if(strikes <= 0)
			death()
	maxHealth = essence * 2
	if(!revealed)
		health = maxHealth //Heals to full when not revealed
	if(essence_regen && !inhibited && essence < essence_regen_cap) //While inhibited, essence will not regenerate
		essence++

/mob/living/simple_animal/revenant/ex_act(severity, target)
	return 1 //Immune to the effects of explosions.

/mob/living/simple_animal/revenant/ClickOn(var/atom/A, var/params) //Copypaste from ghost code - revenants can't interact with the world directly.
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

/mob/living/simple_animal/revenant/say(message)
	return 0 //Revenants cannot speak out loud.

/mob/living/simple_animal/revenant/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Current essence: [essence]E")

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
			objective.owner = src
			src.mind.objectives += objective
			src << "<b>Objective #1</b>: [objective.explanation_text]"
			var/datum/objective/revenantFluff/objective2 = new
			objective2.owner = src
			src.mind.objectives += objective2
			src << "<b>Objective #2</b>: [objective2.explanation_text]"
			ticker.mode.traitors |= src.mind //Necessary for announcing
		if(!src.giveSpells())
			message_admins("Revenant was created but has no mind. Trying again in five seconds.")
			spawn(50)
				if(!src.giveSpells())
					message_admins("Revenant still has no mind. Deleting...")
					qdel(src)

/mob/living/simple_animal/revenant/proc/giveSpells()
	if(src.mind)
		src.mind.spell_list += new /obj/effect/proc_holder/spell/targeted/revenant_harvest
		src.mind.spell_list += new /obj/effect/proc_holder/spell/targeted/revenant_transmit
		src.mind.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/revenant_light
		src.mind.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/revenantDefile
		return 1
	return 0

/mob/living/simple_animal/revenant/death()
	if(strikes)
		return 0 //Impossible to die with strikes still active
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
	..()
	if(istype(W, /obj/item/weapon/nullrod))
		visible_message("<span class='warning'>[src] violently flinches!</span>", \
						"<span class='boldannounce'>The null rod invokes agony in you! You feel your essence draining away!</span>")
		essence -= 25 //hella effective
		inhibited = 1
		spawn(30)
			inhibited = 0



/mob/living/simple_animal/revenant/proc/castcheck(var/essence_cost)
	var/mob/living/simple_animal/revenant/user = usr
	if(!istype(user) || !user)
		return
	var/turf/T = get_turf(usr)
	if(istype(T, /turf/simulated/wall))
		user << "<span class='warning'>You cannot use abilities from inside of a wall.</span>"
		return 0
	if(!user.change_essence_amount(essence_cost, 1))
		user << "<span class='warning'>You lack the essence to use that ability.</span>"
		return 0
	if(user.inhibited)
		user << "<span class='warning'>Your powers have been suppressed by holy energies!</span>"
		return 0
	return 1



/mob/living/simple_animal/revenant/proc/change_essence_amount(var/essence_amt, var/silent = 0, var/source = null)
	var/mob/living/simple_animal/revenant/user = usr
	if(!istype(usr) || !usr)
		return
	if(user.essence + essence_amt <= 0)
		return
	user.essence += essence_amt
	user.essence = Clamp(user.essence, 0, INFINITY)
	if(!silent)
		if(essence_amt > 0)
			user << "<span class='notice'>Gained [essence_amt]E from [source].</span>"
		else
			user << "<span class='danger'>Lost [essence_amt]E from [source].</span>"
	return 1



/mob/living/simple_animal/revenant/proc/reveal(var/time, var/stun)
	var/mob/living/simple_animal/revenant/R = usr
	if(!istype(usr) || !usr)
		return
	R.revealed = 1
	R.invisibility = 0
	if(stun)
		R.notransform = 1
	R << "<span class='warning'>You have been revealed [stun ? "and cannot move" : ""].</span>"
	spawn(time)
		R.revealed = 0
		R.invisibility = INVISIBILITY_OBSERVER
		if(stun)
			R.notransform = 0
		R << "<span class='notice'>You are once more concealed [stun ? "and can move again" : ""].</span>"

/datum/objective/revenant
	dangerrating = 10
	var/targetAmount = 100

/datum/objective/revenant/New()
	targetAmount = rand(100,200)
	explanation_text = "Absorb [targetAmount] points of essence."
	..()

/datum/objective/revenant/check_completion()
	if(!istype(owner.current, /mob/living/simple_animal/revenant) || !owner.current)
		return 0
	var/mob/living/simple_animal/revenant/R = owner.current
	if(!R || R.stat == DEAD)
		return 0
	var/essenceAccumulated = R.essence
	if(essenceAccumulated < targetAmount)
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
	spawn(1800) //3 minutes
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
	message_admins("Revenant ectoplasm was left undestroyed for 3 minutes and has reformed into a new revenant.")
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
