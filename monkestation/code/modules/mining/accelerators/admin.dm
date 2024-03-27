/obj/item/gun/energy/recharge/kinetic_accelerator/meme
	name = "adminium reaper"
	desc = "Mining RnD broke the fabric of space time, please return to your nearest centralcommand officer. <b> WARNING FROM THE MINING RND DIRECTOR : DO NOT RAPIDLY PULL TRIGGER : FABRIC OF SPACE TIME LIABLE TO BREAK </b>"
	recharge_time = 0.1
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/meme)
	max_mod_capacity = 420

/obj/item/gun/energy/recharge/kinetic_accelerator/meme/nonlethal
	name = "adminium stunner"
	desc = "Mining RnD broke the fabric of space time AGAIN, please return to your nearest centralcommand officer. <b> WARNING FROM THE MINING RND DIRECTOR : DO NOT RAPIDLY PULL TRIGGER : FABRIC OF SPACE TIME LIABLE TO BREAK </b>\
	Im being bullied by the admins"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/meme/nonlethal)
	can_bayonet = FALSE
	max_mod_capacity = 0

/obj/item/ammo_casing/energy/kinetic/meme
	projectile_type = /obj/projectile/kinetic/meme
	e_cost = 1
	pellets = 69
	variance = 90
	fire_sound = 'sound/effects/adminhelp.ogg'

/obj/projectile/kinetic/meme
	name = "proto kinetic meme force"
	damage = 420
	range = 300
	pressure_decrease = 1
	dismemberment = 10
	catastropic_dismemberment = TRUE
	hitsound = 'sound/effects/adminhelp.ogg'

/obj/item/ammo_casing/energy/kinetic/meme/nonlethal
	projectile_type = /obj/projectile/kinetic/meme/nonlethal

/obj/projectile/kinetic/meme/nonlethal
	name = "surprisingly soft proto kinetic meme force"
	damage = 0
	dismemberment = 0
	catastropic_dismemberment = FALSE
	stun = 69
	knockdown = 69
	paralyze = 69
	immobilize = 69
	unconscious = 69
	eyeblur = 69
	drowsy = 69 SECONDS
	jitter = 69 SECONDS
	stamina = 69 SECONDS
	stutter = 69 SECONDS
	slur = 69 SECONDS
