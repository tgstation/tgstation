/obj/item/clockwork/weapon
	name = "Clockwork Weapon"
	desc = "Something"
	icon = 'massmeta/icons/obj/clockwork_objects.dmi'
	lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi';
	righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'
	force = 15
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 20
	throw_speed = 4
	armour_penetration = 10
	custom_materials = list(/datum/material/iron=1150, /datum/material/gold=2750)
	hitsound = 'sound/weapons/slash.ogg'
	attack_verb_simple = list("атакует", "тычет", "накалывает", "рвёт", "насаживает")
	sharpness = SHARP_EDGED
	max_integrity = 200
	var/clockwork_hint = ""
	var/datum/action/cooldown/spell/summonspear/SS

/obj/item/clockwork/weapon/pickup(mob/user)
	. = ..()
	if(is_servant_of_ratvar(user))
		SS = new
		SS.marked_item = src


/obj/item/clockwork/weapon/examine(mob/user)
	. = ..()
	if(is_servant_of_ratvar(user) && clockwork_hint)
		. += clockwork_hint

/obj/item/clockwork/weapon/attack(mob/living/target, mob/living/user)
	. = ..()
	if(!is_reebe(user.z))
		return ..()
	//Gain a slight buff when fighting near to the Ark.
	var/force_buff = 0
	//Check distance
	if(GLOB.celestial_gateway)
		var/turf/gatewayT = get_turf(GLOB.celestial_gateway)
		var/turf/ourT = get_turf(user)
		var/distance_from_ark = get_dist(gatewayT, ourT)
		if(gatewayT.z == ourT.z && distance_from_ark < 15)
			switch(distance_from_ark)
				if(0 to 6)
					force_buff = 8
				if(6 to 10)
					force_buff = 5
				if(10 to 15)
					force_buff = 3
			//Magic sound
			playsound(src, 'sound/effects/clockcult_gateway_disrupted.ogg', 40)
	force += force_buff
	. = ..()
	force -= force_buff
	if(!QDELETED(target) && target.stat != DEAD && !is_servant_of_ratvar(target))
		hit_effect(target, user)

/obj/item/clockwork/weapon/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!is_reebe(z))
		return
	if(isliving(hit_atom))
		var/mob/living/target = hit_atom
		if(!.)
			if(!target.can_block_magic(MAGIC_RESISTANCE) && !is_servant_of_ratvar(target))
				hit_effect(target, throwingdatum.thrower, TRUE)

/obj/item/clockwork/weapon/proc/hit_effect(mob/living/target, mob/living/user, thrown=FALSE)
	return

/obj/item/clockwork/weapon/brass_spear
	name = "латунное копье"
	desc = "Острое, как бритва, копье из латуни. Он гудит от едва сдерживаемой энергии."
	clockwork_desc = "Острое, как бритва, копье из латуни. Он гудит от едва сдерживаемой энергии. Наносит мощный урон при броске на Риби."
	icon_state = "ratvarian_spear"
	embedding = list("embedded_impact_pain_multiplier" = 3)
	force = 18
	throwforce = 36
	armour_penetration = 24
	clockwork_hint = "Бросок копья нанесет дополнительный урон, пока находится на Риби."

/obj/item/clockwork/weapon/brass_battlehammer
	name = "латунный боевой молот"
	desc = "Латунный молот, светящийся энергией."
	clockwork_desc = "Латунный молот, светящийся энергией. Позволяет лупить по врагам с невероятной силой."
	icon_state = "ratvarian_hammer"
	force = 15
	throwforce = 25
	armour_penetration = 6
	sharpness = NONE
	attack_verb_simple = list("лупит", "дубасит", "бьёт", "хуячит")
	clockwork_hint = "Враги, пораженные этим, будут отброшены, пока молот находится на Риби."

/obj/item/clockwork/weapon/brass_battlehammer/Initialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=15, force_wielded=25, block_power_wielded=25)

/obj/item/clockwork/weapon/brass_battlehammer/hit_effect(mob/living/target, mob/living/user, thrown=FALSE)
	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	target.throw_at(throw_target, thrown ? 2 : 1, 4)

/obj/item/clockwork/weapon/brass_sword
	name = "латунный длинный меч"
	desc = "Большой меч из латуни."
	clockwork_desc = "Большой меч из латуни. Может поражать электронику мощным электромагнитным импульсом."
	icon_state = "ratvarian_sword"
	force = 19
	throwforce = 20
	armour_penetration = 12
	attack_verb_simple = list("атакует", "рубит", "режет", "рвёт", "протыкает")
	clockwork_hint = "Находясь на Риби, цели будут поражены мощным электромагнитным импульсом."
	COOLDOWN_DECLARE(emp_cooldown)

/obj/item/clockwork/weapon/brass_sword/hit_effect(mob/living/target, mob/living/user, thrown)
	if(!COOLDOWN_FINISHED(src, emp_cooldown))
		return
	COOLDOWN_START(src, emp_cooldown, 30 SECONDS)

	target.emp_act(EMP_LIGHT)
	new /obj/effect/temp_visual/emp/pulse(target.loc)
	addtimer(CALLBACK(src, PROC_REF(send_message), user), 30 SECONDS)
	to_chat(user, span_brass("Попадаю по [target] мощным электромагнитным импульсом!"))
	playsound(user, 'sound/magic/lightningshock.ogg', 40)

/obj/item/clockwork/weapon/brass_sword/proc/send_message(mob/living/target)
	to_chat(target, span_brass("[capitalize(src.name)] светится, сообщая о готовности следующего электромагнитного удара."))

/obj/item/gun/energy/kinetic_accelerator/crossbow/clockwork
	name = "латунный лук"
	desc = "Лук из латуни и других деталей, которые вы не совсем понимаете. Он светится глубокой энергией и сам по себе дробит стрелы."
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "bow_clockwork"
	ammo_type = list(/obj/item/ammo_casing/energy/bolt/clockbolt)

/obj/item/gun/energy/kinetic_accelerator/crossbow/clockwork/update_icon()
	. = ..()
	if(!can_shoot())
		icon_state = "bow_clockwork_unloaded"
	else
		icon_state = "bow_clockwork_loaded"

/obj/item/ammo_casing/energy/bolt/clockbolt
	name = "энергетическая стрела"
	desc = "Стрела из странной энергии."
	icon_state = "arrow_redlight"
	projectile_type = /obj/projectile/energy/clockbolt

/obj/projectile/energy/clockbolt
	name = "энергетическая стрела"
	icon_state = "arrow_energy"
	damage = 15
	damage_type = BURN
