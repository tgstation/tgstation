/obj/item/gem
	name = "Gem"
	desc = "Just needs time to reform..."
	var/gemhealth = 100
	var/bubbled = FALSE
	var/informed = FALSE
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "ruby"
	var/baseicon = "ruby"

	var/revive_time = 600
	var/mob/living/carbon/human/gem

/obj/item/gem/attack_animal(mob/living/simple_animal/user)
	..()
	gemhealth = gemhealth-rand(user.melee_damage_lower,user.melee_damage_upper)
	if(gemhealth > 0)
		user.visible_message("<span class='danger'>[user.name] strikes [src]'s Gemstone!</span>")
		log_combat("[key_name(user)] attacks [name]'s gemstone")
		log_admin("[key_name(user)] attacks [name]'s gemstone.")
	else
		user.visible_message("<span class='danger'>[user.name] shatters [src]!</span>")
		log_combat("[key_name(user)] shattered [name]")
		log_admin("[key_name(user)] shattered [name]")
		src.Destroy()

/obj/item/gem/Initialize(mapload, mob/living/carbon/human/H)
	. = ..()
	baseicon = icon_state
	if(!QDELETED(H) && is_species(H, /datum/species/gem))
		H.forceMove(src)
		gem = H
		name = H.name
		icon_state = H.dna.species.id
		to_chat(gem, "<span class='notice'>You start focusing, preparing to reform...</span>")
		addtimer(CALLBACK(src, .proc/revive), revive_time)
	else
		return INITIALIZE_HINT_QDEL

/obj/item/gem/Destroy()

	if(gem)
		gem.unequip_everything()
		var/obj/item/shard/gem/shard = new/obj/item/shard/gem
		shard.loc = src.loc
		shard.icon_state = "[gem.dna.species.id]shard"
		shard.name = "Shattered [gem.dna.species.id]"
		shard.desc = "It appears to be the remains of [gem.name]"
		QDEL_NULL(gem)
	return ..()

/obj/item/gem/proc/revive()
	if(bubbled == FALSE)
		if(QDELETED(src) || QDELETED(gem)) //QDELETED also checks for null, so if no cloth golem is set this won't runtime
			return
		if(gem.suiciding || gem.hellbound)
			QDEL_NULL(gem)
			return

		invisibility = INVISIBILITY_MAXIMUM //disappear before the animation
		new /obj/effect/temp_visual/gem_reform(get_turf(src))
		if(gem.revive(full_heal = TRUE, admin_revive = TRUE))
			gem.grab_ghost() //won't pull if it's a suicide
		sleep(12)
		gem.forceMove(get_turf(src))
		gem.visible_message("<span class='danger'>[src] rises, a bright lit emits and a Body takes form!</span>","<span class='userdanger'>You reform your body!</span>")
		gem = null
		qdel(src)
	else
		if(informed == FALSE)
			to_chat(gem, "<span class='userdanger'>You are currently bubbled, you cannot reform...</span>")
			informed = TRUE
		addtimer(CALLBACK(src, .proc/revive), 100)

/obj/item/gem/attackby(obj/item/P, mob/living/carbon/human/user, params)
	if(istype(P, /obj/item/pickaxe))
		var/obj/item/pickaxe/pickaxe = P
		gemhealth = gemhealth-pickaxe.force
		pickaxe.play_tool_sound(src, volume=50)
		if(gemhealth > 0)
			visible_message("<span class='danger'>[usr.name] strikes [name]'s Gemstone using [P.name]!</span>")
			log_combat("[key_name(user)] attacks [name]'s gemstone")
			log_admin("[key_name(user)] attacks [name]'s gemstone.")
		else
			visible_message("<span class='danger'>[usr.name] shatters [name] using [P.name]!</span>")
			log_combat("[key_name(user)] shattered [name]")
			log_admin("[key_name(user)] shattered [name]")
			src.Destroy()
	else if(bubbled == TRUE)
		visible_message("<span class='danger'>[usr.name] pops the bubble containing [name]!</span>")
		icon_state = baseicon
		bubbled = FALSE
	else
		. = ..()