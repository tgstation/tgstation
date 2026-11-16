/datum/action/cooldown/mob_cooldown/bot/sword
	name = "Energy Sword"
	desc = "Turn your sword off/on!"
	button_icon = 'icons/obj/weapons/transforming_energy.dmi'
	button_icon_state = "e_sword_on"
	cooldown_time = 0 SECONDS
	click_to_activate = FALSE

/datum/action/cooldown/mob_cooldown/bot/sword/Activate(mob/living/firer, atom/target)
	var/obj/item/melee/energy/sword/saber/my_sword = locate() in owner
	INVOKE_ASYNC(my_sword, TYPE_PROC_REF(/obj/item, attack_self), owner)
	return TRUE
