/// Item you use on a mob to make it bigger and stronger
/obj/item/fugu_gland
	name = "wumborian fugu gland"
	desc = "The key to the wumborian fugu's ability to increase its mass arbitrarily, this disgusting remnant can apply the same effect to other creatures, giving them great strength."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "fugu_gland"
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_NORMAL
	layer = MOB_LAYER
	/// List of mob types which you can't apply the gland to
	var/static/list/fugu_blacklist

/obj/item/fugu_gland/Initialize(mapload)
	. = ..()
	if(fugu_blacklist)
		return
	fugu_blacklist = typecacheof(list(
		/mob/living/simple_animal/hostile/guardian,
	))

/obj/item/fugu_gland/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag || !isanimal_or_basicmob(target) || fugu_blacklist[target.type])
		return
	var/mob/living/animal = target

	if(animal.stat == DEAD || HAS_TRAIT(animal, TRAIT_FAKEDEATH))
		balloon_alert(user, "it's dead!")
		return
	if(HAS_TRAIT(animal, TRAIT_FUGU_GLANDED))
		balloon_alert(user, "already large!")
		return

	ADD_TRAIT(animal, TRAIT_FUGU_GLANDED, type)
	animal.AddComponent(/datum/component/seethrough_mob)
	animal.maxHealth *= 1.5
	animal.health = min(animal.maxHealth, animal.health * 1.5)
	animal.melee_damage_lower = max((animal.melee_damage_lower * 2), 10)
	animal.melee_damage_upper = max((animal.melee_damage_upper * 2), 10)
	animal.transform *= 2
	animal.AddElement(/datum/element/wall_smasher, strength_flag = ENVIRONMENT_SMASH_RWALLS)
	to_chat(user, span_info("You increase the size of [animal], giving [animal.p_them()] a surge of strength!"))
	qdel(src)
