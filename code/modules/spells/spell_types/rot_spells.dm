

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
	rotten_spell = TRUE

	action_icon_state = "rotten0"
	action_background_icon_state = "bg_rotting"

/obj/effect/proc_holder/spell/targeted/forcewall/rotwall
	name = "Rotten Invocation: Wall of Pestilence"
	desc = "Create a rotten barrier that only you can pass through without decaying."
	invocation = "BASK IN FILTH"
	clothes_req = FALSE
	sound = 'sound/magic/forcewall.ogg'//it's own sound todo
	action_icon_state = "rotwall"
	action_background_icon_state = "bg_rotting"
	wall_type = /obj/effect/forcefield/rotwall
	rotten_spell = TRUE

/obj/effect/forcefield/rotwall
	name = "Rotten Flesh"
	desc = "A barrier of pestilence. You feel as if you could go through, but dark energies emanate from it..."
	icon_state = "rotwall"
	var/mob/wizard

/obj/effect/forcefield/rotwall/Initialize(mapload, mob/summoner)
	. = ..()
	wizard = summoner
	var/turf/T = get_turf(src.loc)
	if(T)
		var/datum/gas_mixture/stank = new
		ADD_GAS(/datum/gas/miasma, stank.gases)
		stank.gases[/datum/gas/miasma][MOLES] = 100 //300 moles in total
		T.assume_air(stank)
		T.air_update_turf()

/obj/effect/forcefield/rotwall/CanPass(atom/movable/mover, turf/target)
	if(mover == wizard)
		return TRUE
	if(ismob(mover))
		var/mob/M = mover
		if(M.anti_magic_check(major = FALSE))
			return TRUE
		M.rot_mind()
		if(ishuman(M))
			var/mob/living/carbon/human/nurglevictim = M
			nurglevictim.adjust_hygiene(-150)//this should make you dirty from HYGIENE_LEVEL_NORMAL, and barely alright from HYGIENE_LEVEL_CLEAN
			nurglevictim.adjust_disgust(60)

	return TRUE


/obj/effect/proc_holder/spell/targeted/touch/rot
	name = "Rotten Invocation: Diseased Touch"
	desc = "This spell charges your hand with vile energy that can be used to give diseases to a victim."
	clothes_req = FALSE
	action_background_icon_state = "bg_rotting"
	hand_path = /obj/item/melee/touch_attack/rot
	rotten_spell = TRUE

	//catchphrase = "DECAY IS INESCAPABLE, BUT ALSO GLORIOUS"
	school = "evocation"
	charge_max = 400
	clothes_req = FALSE
	cooldown_min = 200 //100 deciseconds reduction per rank

	action_icon_state = "disease"

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

/*
/obj/effect/proc_holder/spell/corpulent_summon
	name = "Rotten Invocation: Summon Corpulent Demon"
	desc = "Summons a Corpulent Demon. You must attract him to the realm with bodies around you for him to feast."
*/
/obj/effect/proc_holder/spell/aoe_turf/conjure/the_traps/rot_trap
	name = "Rotten Invocation: Patient Malaise"
	desc = "Summon a number of rotten traps around you. They will damage and decay any enemies that step on them."

	clothes_req = FALSE
	invocation = "FROM YOUR WOUNDS THE FESTER POURS"

	summon_type = list(
		/obj/structure/trap/rot,
	)

	action_icon_state = "the_traps_malaise"
	action_background_icon_state = "bg_rotting"

	rotten_spell = TRUE
