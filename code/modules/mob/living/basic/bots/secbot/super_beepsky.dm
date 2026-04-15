/mob/living/basic/bot/secbot/grievous //This bot is powerful. If you managed to get 4 eswords somehow, you deserve this horror. Emag him for best results.
	name = "General Beepsky"
	desc = "Is that a secbot with four eswords in its arms...?"
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "grievous"
	health = 150
	maxHealth = 150
	ai_controller =
	baton_type = /obj/item/melee/energy/sword/saber
	base_speed = 4 //he's a fast fucker
	weapon_force = 30
	///chance we block bullets
	var/block_chance = 50

/mob/living/basic/bot/secbot/grievous/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/appearance_on_aggro,\
		overlay_icon = 'icons/mob/silicon/aibots.dmi',\
		overlay_state = "grievous-c",\
	)
	RegisterSignal(src, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(block_bullets))

/mob/living/basic/bot/secbot/grievous/proc/add_arrest_component() //i dont think we'll be arresting people...
	return

/mob/living/basic/bot/secbot/grievous/toy //A toy version of general beepsky!
	name = "Genewul Bweepskee"
	desc = "An adorable looking secbot with four toy swords taped to its arms"
	health = 50
	maxHealth = 50
	baton_type = /obj/item/toy/sword
	weapon_force = 0

/mob/living/basic/bot/secbot/grievous/proc/block_bullets(datum/source, obj/projectile/hitting_projectile)
	SIGNAL_HANDLER

	if(stat != CONSCIOUS)
		return NONE

	visible_message(span_warning("[source] deflects [hitting_projectile] with its energy swords!"))
	playsound(source, 'sound/items/weapons/blade1.ogg', 50, TRUE)
	return COMPONENT_BULLET_BLOCKED

/mob/living/basic/bot/secbot/grievous/on_entered(datum/source, atom/movable/movable_target)
	. = ..()
	if(!ismob(movable_target) || !ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] == movable_target)
		return
	visible_message(span_warning("[src] flails his swords and cuts [AM]!"))
	playsound(src,'sound/mobs/non-humanoids/beepsky/beepskyspinsabre.ogg',100,TRUE,-1)
	ClickOn(movable_target)

/mob/living/basic/bot/secbot/grievous/Initialize(mapload)
	. = ..()
	INVOKE_ASYNC(weapon, TYPE_PROC_REF(/obj/item, attack_self), src)

/mob/living/basic/bot/secbot/grievous/Destroy()
	QDEL_NULL(weapon)
	return ..()

/mob/living/basic/bot/secbot/grievous/early_melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	INVOKE_ASYNC(weapon, TYPE_PROC_REF(/obj/item, melee_attack_chain), src, target)
	playsound(src, 'sound/items/weapons/blade1.ogg', 50, TRUE, -1)

/mob/living/basic/bot/secbot/grievous/explode()
	var/atom/drop_location = drop_location()
	//Parent is dropping the weapon, so let's drop 3 more to make up for it.
	for(var/i in 0 to 3)
		drop_part(weapon, drop_location)

	return ..()
