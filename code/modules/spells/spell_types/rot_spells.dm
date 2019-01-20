

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
	var/rot_removed = FALSE
	active = FALSE
	rotten_spell = TRUE

	action_icon_state = "rotten0"
	action_background_icon_state = "bg_rotting"

/obj/effect/proc_holder/spell/targeted/touch/rot
	name = "Rotten Invocation: Diseased Touch"
	desc = "This spell charges your hand with vile energy that can be used to give diseases to a victim."
	hand_path = /obj/item/melee/touch_attack/rot

	//catchphrase = "BLISTERS, FEVERS, WEEPING SORES"
	school = "evocation"
	charge_max = 600
	clothes_req = TRUE
	cooldown_min = 200 //100 deciseconds reduction per rank

	action_icon_state = "disease"

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