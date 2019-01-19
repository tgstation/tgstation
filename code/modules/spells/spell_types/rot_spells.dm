

/obj/effect/proc_holder/spell/aimed/rotten_invocation
	name = "Rotten Invocation"
	desc = "This spell fires a bolt of rot at a target. While this spell may have once been great magicks, all it is now is mental sludge."
	school = "evocation"
	charge_max = 60
	clothes_req = FALSE
	invocation = "ONI SOMA"
	invocation_type = "shout"
	range = 20
	cooldown_min = 20 //10 deciseconds reduction per rank
	projectile_type = /obj/item/projectile/magic/rot
	base_icon_state = "rotten"
	action_icon_state = "rotten0"
	action_background_icon_state = "bg_rotting"
	sound = 'sound/magic/fireball.ogg' //todo: replace with something better.
	active_msg = "You prepare to cast a bolt of rot!"
	deactive_msg = "You rinse your Invocation... for now."
	active = FALSE