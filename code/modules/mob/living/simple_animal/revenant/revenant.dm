//Revenants: based off of wraiths from Goon
//"Ghosts" that are invisible and move like ghosts, cannot take damage while invsible
//Don't hear deadchat and are NOT normal ghosts
//Admin-spawn or random event

/mob/living/simple_animal/revenant
	name = "revenant"
	desc = "A malevolent spirit."
	icon = 'icons/mob/mob.dmi'
	icon_state = "revenant_idle"
	incorporeal_move = 1
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
	var/strikes = 2 //How many times a revenant can die before dying for good
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
			src << "<span class='userdanger'><b>NO! No... it's too late, you can feel yourself fading...</b></span>"
			src.notransform = 1
			src.revealed = 1
			src.invisibility = 0
			playsound(src, 'sound/effects/screech.ogg', 100, 1)
			src.visible_message("<b>The revenant</b> lets out a waning screech as violet mist swirls around its dissolving body!")
			src.icon_state = "revenant_draining"
			sleep(30)
			src.death()
	maxHealth = essence * 2
	if(!revealed)
		health = maxHealth //Heals to full when not revealed
	if(essence_regen && !inhibited && essence < essence_regen_cap) //While inhibited, essence will not regenerate
		essence++

/mob/living/simple_animal/revenant/Process_Spacemove(var/movement_dir = 0)
	return 1 //Mainly to prevent the no-grav effect

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
	notransform = 1
	spawn(50)
		if(src.mind)
			src.mind.spell_list += new /obj/effect/proc_holder/spell/targeted/revenant_harvest
			src.mind.spell_list += new /obj/effect/proc_holder/spell/targeted/revenant_transmit
			src.mind.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/revenant_light
			src.mind.spell_list += new /obj/effect/proc_holder/spell/targeted/revenant_life_tap
			src.mind.spell_list += new /obj/effect/proc_holder/spell/targeted/revenant_seed_drain
			src.mind.spell_list += new /obj/effect/proc_holder/spell/targeted/revenant_mindspike
			src.mind.spell_list += new /obj/effect/proc_holder/spell/targeted/revenant_mindblast
			notransform = 0
		else
			qdel(src)

/mob/living/simple_animal/revenant/death()
	..(1)
	src.invisibility = 0
	visible_message("<span class='danger'>[src] pulses with an eldritch purple light as its form unwinds into smoke.</span>")
	ghostize()
	qdel(src)
	return

/mob/living/simple_animal/revenant/attackby(obj/item/W, mob/living/user, params)
	..()
	if(istype(W, /obj/item/weapon/nullrod))
		src.visible_message("<b>The revenant</b> screeches and flails!", \
							"<span class='boldannounce'>The null rod invokes agony in you! You feel your essence draining away!</span>")
		src.essence -= 25 //hella effective
		src.inhibited = 1
		spawn(30)
			src.inhibited = 0



/obj/effect/proc_holder/spell/proc/essence_check(var/essence_cost, var/silent = 0)
	var/mob/living/simple_animal/revenant/W = usr
	if(W.essence < essence_cost)
		if(!silent)
			W << "<span class='warning'>You need [essence_cost]E to use [name] but you only have [W.essence]E available. Harvest some more things.</span>"
		return 0
	W.essence -= essence_cost
	return 1



/mob/living/simple_animal/revenant/proc/change_essence_amount(var/essence_amt, var/silent = 0, var/source = null, var/mob/living/simple_animal/revenant/user = usr)
	if(!essence_amt)
		return
	user.essence += essence_amt
	if(!silent)
		if(essence_amt >= 0)
			user << "<span class='info'>Gained [essence_amt]E from [source].</span>"
		else
			user << "<span class='info'>Lost [essence_amt]E.</span>"
	return 1
