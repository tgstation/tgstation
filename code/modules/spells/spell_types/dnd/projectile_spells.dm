/obj/effect/proc_holder/spell/aimed/grease
	name = "Grease"
	desc = "This spell launches a blob of grease at a target, slipping everyone in a 5 tile area around the landing point."
	school = "evocation"
	charge_max = 60
	clothes_req = TRUE
	invocation = "DUB'YA DII FOR-TEE"
	invocation_type = "shout"
	range = 20
	cooldown_min = 15
	projectile_type = /obj/projectile/magic/aoe/grease
	base_icon_state = "grease"
	action_icon_state = "grease0"
	sound = 'sound/magic/fireball.ogg'
	active_msg = "You prepare to cast your grease spell!"
	deactive_msg = "You vanish your grease...for now."
	active = FALSE

/obj/effect/proc_holder/spell/aimed/acid_splash
	name = "Acid Splash"
	desc = "Throw a glob of acid at your foe!"
	school = "evocation"
	charge_max = 60
	clothes_req = FALSE
	invocation = "MEELTAN LUV"
	invocation_type = "shout"
	range = 20
	cooldown_min = 15
	projectile_type = /obj/projectile/magic/projectile/acid
	base_icon_state = "grease"
	action_icon_state = "grease0"
	sound = 'sound/magic/fireball.ogg'
	active_msg = "You prepare to cast Acid Splash!"
	deactive_msg = "You vanish your Acid splash...for now."
	active = FALSE