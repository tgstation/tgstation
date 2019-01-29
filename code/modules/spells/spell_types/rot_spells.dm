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

/obj/effect/proc_holder/spell/targeted/forcewall/rotwall
	name = "Rotten Invocation: Wall of Pestilence"
	desc = "Create a rotten barrier that only you can pass through without decaying."
	invocation = "BASK IN FILTH"
	clothes_req = FALSE
	sound = 'sound/magic/forcewall.ogg'//it's own sound todo
	action_icon_state = "rotwall"
	action_background_icon_state = "bg_rotting"
	wall_type = /obj/effect/forcefield/rotwall

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

/obj/effect/proc_holder/spell/aoe_turf/conjure/the_traps/rot_trap
	name = "Rotten Invocation: Patient Malaise"
	desc = "Summon a number of rotten traps around you. They will damage and decay any enemies that step on them."

	clothes_req = FALSE
	invocation = "FROM YOUR WOUNDS THE FESTER POURS"

	summon_type = list(/obj/structure/trap/rot)

	action_icon_state = "the_traps_malaise"
	action_background_icon_state = "bg_rotting"

/obj/effect/proc_holder/spell/aoe_turf/forcevomit
	name = "Nauseating emanation"
	desc = "This spell makes other people's head turn so much, they will feel like throwing up."
	charge_max = 600
	clothes_req = TRUE
	invocation = "SU'UR STROM EENG"
	invocation_type = "shout"
	range = 1
	cooldown_min = 400
	action_icon_state = "time"
	clothes_req = FALSE

/obj/effect/proc_holder/spell/aoe_turf/forcevomit/cast(list/targets,mob/user = usr)
	for(var/mob/living/carbon/M in oview(min(3, spell_level), usr))
		M.vomit()
		M.mind.rot_mind()
