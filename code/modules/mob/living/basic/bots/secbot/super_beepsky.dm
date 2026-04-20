/mob/living/basic/bot/secbot/grievous //This bot is powerful. If you managed to get 4 eswords somehow, you deserve this horror. Emag him for best results.
	name = "General Beepsky"
	desc = "Is that a secbot with four eswords in its arms...?"
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "grievous"
	base_icon_state = "grievous"
	health = 150
	maxHealth = 150
	ai_controller = /datum/ai_controller/basic_controller/bot/secbot/super_beepsky
	baton_type = /obj/item/melee/energy/sword/saber
	speed = 4 //he's a fast fucker
	///chance we block bullets
	var/block_chance = 50
	///is our sword currently active?
	var/sword_active = FALSE

/mob/living/basic/bot/secbot/grievous/Initialize(mapload)
	. = ..()
	RegisterSignal(weapon, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_weapon_transform))
	var/datum/action/cooldown/mob_cooldown/bot/sword/sword_activate_ability = new(src) //this is for sentient players.
	sword_activate_ability.Grant(src)
	INVOKE_ASYNC(weapon, TYPE_PROC_REF(/obj/item, attack_self), src)
	RegisterSignal(src, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(block_bullets))


/mob/living/basic/bot/secbot/grievous/check_block(atom/hit_by, damage, attack_text = "the attack", attack_type = MELEE_ATTACK, armour_penetration = 0, damage_type = BRUTE)
	. = ..()
	if(. & FAILED_BLOCK)
		return .

	return (sword_active && prob(block_chance) ? SUCCESSFUL_BLOCK : FAILED_BLOCK)

/mob/living/basic/bot/secbot/grievous/proc/on_weapon_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER
	if(active)
		visible_message(span_warning("[src] ignites his energy swords!"))
	sword_active = active
	update_icon_state()

/mob/living/basic/bot/secbot/grievous/add_arrest_component() //i dont think we'll be arresting people...
	return

/mob/living/basic/bot/secbot/grievous/proc/block_bullets(datum/source, obj/projectile/hitting_projectile)
	SIGNAL_HANDLER

	if(stat != CONSCIOUS )
		return NONE

	if(!sword_active || !prob(block_chance))
		return NONE

	visible_message(span_warning("[source] deflects [hitting_projectile] with its energy swords!"))
	playsound(source, 'sound/items/weapons/blade1.ogg', 50, TRUE)
	return COMPONENT_BULLET_BLOCKED

/mob/living/basic/bot/secbot/grievous/on_entered(datum/source, atom/movable/movable_target)
	. = ..()
	if(!ismob(movable_target) || !ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] == movable_target)
		return
	visible_message(span_warning("[src] flails his swords and cuts [movable_target]!"))
	playsound(src, 'sound/mobs/non-humanoids/beepsky/beepskyspinsabre.ogg' , 100, TRUE, -1)
	INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, ClickOn), movable_target)


/mob/living/basic/bot/secbot/grievous/update_icon_state()
	. = ..()

	icon_state = "[base_icon_state][ sword_active ? "-c" : ""]"

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
		drop_part(baton_type, drop_location)

	return ..()


/mob/living/basic/bot/secbot/grievous/toy //A toy version of general beepsky!
	name = "Genewul Bweepskee"
	desc = "An adorable looking secbot with four toy swords taped to its arms"
	health = 50
	maxHealth = 50
	block_chance = 0
	baton_type = /obj/item/toy/sword
