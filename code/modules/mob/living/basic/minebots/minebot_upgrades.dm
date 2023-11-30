/obj/item/mine_bot_upgrade
	name = "minebot melee upgrade"
	desc = "A minebot upgrade."
	icon_state = "door_electronics"
	icon = 'icons/obj/assemblies/circuitry_n_data.dmi'

/obj/item/mine_bot_upgrade/afterattack(mob/living/basic/mining_drone/minebot, mob/user, proximity)
	. = ..()
	if(!istype(minebot) || !proximity)
		return
	upgrade_bot(minebot, user)

/obj/item/mine_bot_upgrade/proc/upgrade_bot(mob/living/basic/mining_drone/minebot, mob/user)
	if(minebot.melee_damage_upper != initial(minebot.melee_damage_upper))
		user.balloon_alert(user, "already has armor!")
		return
	minebot.melee_damage_lower += 7
	minebot.melee_damage_upper += 7
	to_chat(user, span_notice("You increase the close-quarter combat abilities of [minebot]."))
	qdel(src)

//Health

/obj/item/mine_bot_upgrade/health
	name = "minebot armor upgrade"

/obj/item/mine_bot_upgrade/health/upgrade_bot(mob/living/basic/mining_drone/minebot, mob/user)
	if(minebot.maxHealth != initial(minebot.maxHealth))
		to_chat(user, span_warning("[minebot] already has reinforced armor!"))
		return
	minebot.maxHealth += 45
	minebot.updatehealth()
	to_chat(user, span_notice("You reinforce the armor of [minebot]."))
	qdel(src)

//AI

/obj/item/slimepotion/slime/sentience/mining
	name = "minebot AI upgrade"
	desc = "Can be used to grant sentience to minebots. It's incompatible with minebot armor and melee upgrades, and will override them."
	icon_state = "door_electronics"
	icon = 'icons/obj/assemblies/circuitry_n_data.dmi'
	sentience_type = SENTIENCE_MINEBOT
	///health boost to add
	var/base_health_add = 5
	///damage boost to add
	var/base_damage_add = 1
	///speed boost to add
	var/base_speed_add = 1
	///cooldown boost to add
	var/base_cooldown_add = 10

/obj/item/slimepotion/slime/sentience/mining/after_success(mob/living/user, mob/living/basic_mob)
	if(!istype(basic_mob, /mob/living/basic/mining_drone))
		return
	var/mob/living/basic/mining_drone/minebot = basic_mob
	minebot.maxHealth = initial(minebot.maxHealth) + base_health_add
	minebot.melee_damage_lower = initial(minebot.melee_damage_lower) + base_damage_add
	minebot.melee_damage_upper = initial(minebot.melee_damage_upper) + base_damage_add
	minebot.stored_gun?.recharge_time += base_cooldown_add
