/obj/item/weapon/twohanded/fireaxe/fireyaxe
	desc = "This axe has become touched by the very flames it was built to destroy..."
	force_wielded = 5
	var/charged = TRUE
	var/charge_time = 15

/obj/item/projectile/bullet/incendiary/shell/firehammer
	name = "fiery gout"
	damage = 0 //Its for burnin' not shootin'


/obj/item/weapon/twohanded/fireaxe/fireyaxe/attack(mob/living/carbon/M, mob/user)
	if(!wielded)
		return ..()
	if(isliving(M))
		var/def_check = M.getarmor(type = "fire")
		to_chat(M, "<span class='danger'>The fires of the [name] burn you!</span>")
		if(M.on_fire)
			to_chat(M, "<span class='danger'>The fire burns hotter!</span>")
			M.apply_damage(25, BURN, blocked = def_check)
		M.adjust_fire_stacks(3)
		if(M.IgniteMob())
			message_admins("[key_name_admin(user)] set [key_name_admin(M)] on fire")
			log_game("[key_name(user)] set [key_name(M)] on fire")
	..()

/obj/item/weapon/twohanded/fireaxe/fireyaxe/afterattack(atom/target, mob/living/user, proximity_flag)
	if(!proximity_flag && charged && wielded)
		var/turf/proj_turf = user.loc
		if(!isturf(proj_turf))
			return
		var/obj/item/projectile/bullet/incendiary/shell/firehammer/F = new /obj/item/projectile/bullet/incendiary/shell/firehammer(proj_turf)
		F.preparePixelProjectile(target, get_turf(target), user)
		F.firer = user
		playsound(user, 'sound/magic/Fireball.ogg', 100, 1)
		F.fire()
		charged = FALSE
		addtimer(CALLBACK(src, .proc/Recharge), charge_time)
		return


/obj/item/weapon/twohanded/fireaxe/fireyaxe/proc/Recharge()
	if(!charged)
		charged = TRUE
		playsound(src.loc, 'hippiestation/sound/effects/corpseexplosion.ogg', 100, 1)

