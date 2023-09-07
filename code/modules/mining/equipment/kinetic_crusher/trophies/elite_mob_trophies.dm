/**
 * Elite fauna (tumor bosses) trophies go here.
*/

/**
 * Goliath broodmother
 * Detonating a mark has a 10% chance to create a tentacle patch under the victim, stunning and dealing damage.
 * Does not affect the user.
 * The item itself can also be used in-hand to grant the user lava immunity for 10 seconds on a 1 minute cooldown.
 */
/obj/item/crusher_trophy/broodmother_tongue
	name = "broodmother tongue"
	desc = "The tongue of a broodmother. If attached a certain way, makes for a suitable crusher trophy. It also feels very spongey, I wonder what would happen if you squeezed it?..."
	icon = 'icons/obj/mining_zones/elite_trophies.dmi'
	icon_state = "broodmother_tongue"
	denied_type = /obj/item/crusher_trophy/broodmother_tongue
	bonus_value = 10
	COOLDOWN_DECLARE(broodmother_tongue_cooldown)
	///How long does the lava immunity last.
	var/use_buff_duration = 10 SECONDS
	///Cooldown for using the item in-hand to gain lava immunity.
	var/use_cooldown = 1 MINUTES

/obj/item/crusher_trophy/broodmother_tongue/effect_desc()
	return "mark detonation to have a <b>[bonus_value]%</b> chance to summon a patch of goliath tentacles at the target's location"

/obj/item/crusher_trophy/broodmother_tongue/on_mark_detonation(mob/living/target, mob/living/user)
	if(prob(bonus_value) && target.stat != DEAD)
		new /obj/effect/goliath_tentacle/broodmother/patch/crusher(get_turf(target), user)

/obj/item/crusher_trophy/broodmother_tongue/attack_self(mob/user)
	. = ..()
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	if(!COOLDOWN_FINISHED(src, broodmother_tongue_cooldown))
		balloon_alert(user, "not ready!")
		return
	if(HAS_TRAIT(living_user, TRAIT_LAVA_IMMUNE))
		to_chat(living_user, span_notice("You stare at the tongue. You don't think this is any use to you."))
		return
	ADD_TRAIT(living_user, TRAIT_LAVA_IMMUNE, type)
	to_chat(living_user, span_boldnotice("You squeeze the tongue, and some transluscent liquid shoots out all over you!"))
	playsound(get_turf(living_user), 'sound/effects/slosh.ogg', 30, TRUE)
	addtimer(TRAIT_CALLBACK_REMOVE(user, TRAIT_LAVA_IMMUNE, type), use_buff_duration)
	COOLDOWN_START(src, broodmother_tongue_cooldown, use_cooldown)

/obj/effect/goliath_tentacle/broodmother/patch/crusher
	created_tentacle = /obj/effect/goliath_tentacle/broodmother/crusher
	trophy_spawned = TRUE //the central tentacle would otherwise not count towards this

/obj/effect/goliath_tentacle/broodmother/crusher
	trophy_spawned = TRUE

/obj/effect/goliath_tentacle/broodmother/crusher/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/crusher_damage_ticker, APPLY_WITH_SPELL, min_damage)

/**
 * Legionnaire
 * Detonating a mark has a chance to spawn a user-allied legion skull, attacking the victim.
 * The item itself can also be used in-hand to summon a user-allied legion skull on a 4 second cooldown.
 */
/obj/item/crusher_trophy/legionnaire_spine
	name = "legionnaire spine"
	desc = "The spine of a legionnaire. With some creativity, you could use it as a crusher trophy. Alternatively, shaking it might do something as well."
	icon = 'icons/obj/mining_zones/elite_trophies.dmi'
	icon_state = "legionnaire_spine"
	denied_type = /obj/item/crusher_trophy/legionnaire_spine
	bonus_value = 20
	COOLDOWN_DECLARE(legionnaire_spine_cooldown)
	///Cooldown time for using the item in-hand to spawn a skull
	var/use_cooldown = 4 SECONDS

/obj/item/crusher_trophy/legionnaire_spine/effect_desc()
	return "mark detonation to have a <b>[bonus_value]%</b> chance to summon a loyal legion skull"

/obj/item/crusher_trophy/legionnaire_spine/on_mark_detonation(mob/living/target, mob/living/user)
	if(!prob(bonus_value) || target.stat == DEAD)
		return
	playsound(get_turf(user), prob(0.5) ? 'sound/magic/RATTLEMEBONES2.ogg' : 'sound/magic/RATTLEMEBONES.ogg', 80, TRUE)
	var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/summoned_skull = new /mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion(get_turf(user))
	summoned_skull.AddComponent(/datum/component/crusher_damage_ticker, APPLY_WITH_MOB_ATTACK, summoned_skull.melee_damage_lower)
	summoned_skull.GiveTarget(target)
	summoned_skull.friends += user
	summoned_skull.faction = user.faction.Copy()

/obj/item/crusher_trophy/legionnaire_spine/attack_self(mob/user)
	. = ..()
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	if(!COOLDOWN_FINISHED(src, legionnaire_spine_cooldown))
		living_user.visible_message(span_warning("[living_user] shakes \the [src], but nothing happens..."))
		balloon_alert(living_user, "not ready!")
		return
	living_user.visible_message(span_boldwarning("[living_user] shakes \the [src] and summons a legion skull!"))
	playsound(get_turf(user), prob(0.5) ? 'sound/magic/RATTLEMEBONES2.ogg' : 'sound/magic/RATTLEMEBONES.ogg', 80, TRUE)
	var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/summoned_skull = new /mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion(get_turf(living_user))
	summoned_skull.friends += living_user
	summoned_skull.faction = living_user.faction.Copy()
	COOLDOWN_START(src, legionnaire_spine_cooldown, use_cooldown)
