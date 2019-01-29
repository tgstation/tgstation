/obj/effect/proc_holder/spell/aimed/canker
	name = "Rotten Invocation: Canker"
	desc = "This spell fires a bolt of rot at a target. While this spell may have once been great magicks, all it is now is mental sludge."
	school = "evocation"
	charge_max = 60
	clothes_req = FALSE
	invocation = "BUBOES, PHLEGM, BLOOD AND GUTS"
	invocation_type = "shout"
	range = 20
	cooldown_min = 20 //10 deciseconds reduction per rank
	projectile_type = /obj/item/projectile/magic/rot
	base_icon_state = "rotten"
	sound = 'sound/magic/fireball.ogg' //todo: replace with something better.
	active_msg = "You prepare to cast a bolt of rot!"
	deactive_msg = "You rinse your Invocation... for now."
	active = FALSE

	action_icon_state = "rotten0"
	action_background_icon_state = "bg_rotting"

/obj/effect/proc_holder/spell/aimed/canker/cast(list/targets, mob/living/user)
	..()
	var/obj/effect/proc_holder/spell/mark_of_putrescence/mop = locate(/obj/effect/proc_holder/spell/mark_of_putrescence) in user.mind.spell_list
	if(mop)
		mop.boost_spell(user)
	

/obj/effect/proc_holder/spell/targeted/forcewall/rotwall
	name = "Rotten Invocation: Wall of Pestilence"
	desc = "Create a rotten barrier that only you can pass through without decaying."
	invocation = "BASK IN FILTH"
	clothes_req = FALSE
	sound = 'sound/magic/forcewall.ogg'//it's own sound todo
	action_icon_state = "rotwall"
	action_background_icon_state = "bg_rotting"
	wall_type = /obj/effect/forcefield/rotwall

/obj/effect/proc_holder/spell/targeted/forcewall/rotwall/cast(list/targets,mob/user = usr)
	..()
	var/obj/effect/proc_holder/spell/mark_of_putrescence/mop = locate(/obj/effect/proc_holder/spell/mark_of_putrescence) in user.mind.spell_list
	if(mop)
		mop.boost_spell(user)

/obj/effect/forcefield/rotwall
	name = "Rotten Flesh"
	desc = "A barrier of pestilence. You feel as if you could go through, but dark energies emanate from it..."
	icon_state = "rotwall"
	var/mob/wizard

/obj/effect/forcefield/rotwall/Initialize(mapload, mob/summoner)
	. = ..()
	wizard = summoner
	var/turf/T = get_turf(src)
	if(T)
		T.atmos_spawn_air("miasma=100")

/obj/effect/forcefield/rotwall/CanPass(atom/movable/mover, turf/target)
	if(mover == wizard)
		return TRUE
	if(ismob(mover))
		var/mob/M = mover
		if(M.anti_magic_check(major = FALSE))
			return TRUE
		if(M.mind)
			M.mind.rot_mind()
		if(ishuman(M))
			var/mob/living/carbon/human/nurglevictim = M
			nurglevictim.adjust_hygiene(-150)//this should make you dirty from HYGIENE_LEVEL_NORMAL, and barely alright from HYGIENE_LEVEL_CLEAN
			nurglevictim.adjust_disgust(60)

	return TRUE


/obj/effect/proc_holder/spell/targeted/touch/rot
	name = "Rotten Invocation: Diseased Touch"
	desc = "This spell charges your hand with vile energy that can be used to give diseases to a victim."
	clothes_req = FALSE
	hand_path = /obj/item/melee/touch_attack/rot

	//catchphrase = "DECAY IS INESCAPABLE, BUT ALSO GLORIOUS"
	school = "evocation"
	charge_max = 400
	clothes_req = FALSE
	cooldown_min = 200 //100 deciseconds reduction per rank

	action_icon_state = "disease"
	action_background_icon_state = "bg_rotting"

/obj/effect/proc_holder/spell/targeted/genetic/ascendant_form
	name = "Rotten Invocation: Ascendant Form"
	desc = "Binds you to a putrid form to carry out your work."

	clothes_req = FALSE
	rotten_spell = TRUE
	school = "transmutation"
	charge_max = 400
	invocation = "EMBRACE ENTROPY"
	invocation_type = "shout"
	range = -1
	include_user = TRUE

	mutations = list(XRAY, STRONG)
	duration = 300
	cooldown_min = 300 //25 deciseconds reduction per rank

	action_icon_state = "mutate_crop"
	action_background_icon_state = "bg_rotting"
	sound = 'sound/magic/mutate.ogg'

/obj/effect/proc_holder/spell/targeted/genetic/ascendant_form/cast(list/targets,mob/user = usr)
	if(!isflyperson(user))
		playMagSound()
		user.set_species(/datum/species/fly)
		to_chat(user, "<span class='notice'>Your form becomes that of a fly. Recast to gain powers!</span>")
	else
		..()
	var/obj/effect/proc_holder/spell/mark_of_putrescence/mop = locate(/obj/effect/proc_holder/spell/mark_of_putrescence) in user.mind.spell_list
	if(mop)
		mop.boost_spell(user)

/obj/effect/proc_holder/spell/aoe_turf/conjure/the_traps/rot_trap
	name = "Rotten Invocation: Patient Malaise"
	desc = "Summon a number of rotten traps around you. They will damage and decay any enemies that step on them."

	clothes_req = FALSE
	invocation = "FROM YOUR WOUNDS THE FESTER POURS"

	summon_type = list(/obj/structure/trap/rot)

	action_icon_state = "the_traps_malaise"
	action_background_icon_state = "bg_rotting"

/obj/effect/proc_holder/spell/aoe_turf/conjure/the_traps/post_summon(obj/structure/trap/T, mob/user)
	.=..()
	var/obj/effect/proc_holder/spell/mark_of_putrescence/mop = locate(/obj/effect/proc_holder/spell/mark_of_putrescence) in user.mind.spell_list
	if(mop)
		mop.boost_spell(user)

/obj/effect/proc_holder/spell/targeted/projectile/forcevomit
	name = "Nauseating emanation"
	desc = "This spell makes other people's head turn so much, they will feel like throwing up."
	charge_max = 600
	clothes_req = TRUE
	invocation = "SU'UR STROM EENG"
	invocation_type = "shout"
	range = 1
	cooldown_min = 400
	clothes_req = FALSE
	action_icon = 'icons/obj/hand_of_god_structures.dmi'
	action_icon_state = "trap-rot"

	proj_icon_state = "forcevomit"
	proj_name = "a smelly cloud"
	proj_lingering = 1
	proj_type = "/obj/effect/proc_holder/spell/targeted/inflict_handler/force_vomit"

	proj_lifespan = 20
	proj_step_delay = 4

	proj_trail = TRUE
	proj_trail_lifespan = 7
	proj_trail_icon_state = "forcevomit"

	sound = 'sound/magic/magic_missile.ogg'

/obj/effect/proc_holder/spell/targeted/inflict_handler/force_vomit

/obj/effect/proc_holder/spell/targeted/inflict_handler/force_vomit/cast(list/targets, mob/user = usr)
	. = ..()
	var/mob/living/carbon/human/target = targets[1]
	if (!istype(target))
		return
	if (target.anti_magic_check())
		return
	var/turf/T = get_turf(src)
	if(T)
		T.atmos_spawn_air("miasma=100")
	target.vomit(30)
	var/obj/effect/proc_holder/spell/mark_of_putrescence/mop = locate(/obj/effect/proc_holder/spell/mark_of_putrescence) in user.mind.spell_list
	if(mop)
		mop.boost_spell(user)

/obj/effect/proc_holder/spell/mark_of_putrescence
	name = "Mark of putrescence"
	desc = "While toggled on, summons slippery gibs near the caster and drains their spiritual energy on each cast. Careful, don't slip."
	charge_max = 10
	clothes_req = TRUE
	invocation = "Wosh uress"
	invocation_type = "whisper"
	range = 1
	cooldown_min = 400
	action_icon_state = "time"
	clothes_req = FALSE
	action_icon = 'icons/obj/hand_of_god_structures.dmi'
	action_icon_state = "trap-rot"
	var/toggle = FALSE


/obj/effect/proc_holder/spell/mark_of_putrescence/cast()
	switch(toggle)
		if(FALSE)
			toggle = TRUE
			to_chat(usr, "<span class='warning'>You start attuning yourself to the aetherial plane of filth.</span>")
		if(TRUE)
			toggle = FALSE
			to_chat(usr, "<span class='warning'>You stop channeling the power of miasmatic aether.</span>")

/obj/effect/proc_holder/spell/mark_of_putrescence/proc/boost_spell(mob/user = usr)
	if(!toggle)
		return

	//10% chance of setting yourself a self-slip trap
	var/turf/spawningturf
	if(prob(10))
		spawningturf = get_turf(get_step(user.loc,user.dir))
	else
		spawningturf = get_turf(src.loc)

	//Spawn a nasty foam puddle
	var/datum/reagents/R = new/datum/reagents(30)
	R.my_atom = spawningturf
	R.add_reagent("liquidgibs", 15)
	R.add_reagent("vomit", 15)
	var/datum/effect_system/foam_spread/foam = new()
	foam.set_up(1, spawningturf, R)
	foam.start()

	//Add a bit of miasma
	spawningturf.atmos_spawn_air("miasma=50")

	//Get faster reload for spells
	for(var/obj/effect/proc_holder/spell/s in usr.mind.spell_list)
		s.charge_counter += 5
