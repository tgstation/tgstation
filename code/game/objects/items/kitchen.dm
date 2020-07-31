/* Kitchen tools
 * Contains:
 *		Fork
 *		Kitchen knives
 *		Ritual Knife
 *		Bloodletter
 *		Butcher's cleaver
 *		Combat Knife
 *		Rolling Pins
 *		Plastic Utensils
 */

/obj/item/kitchen
	icon = 'icons/obj/kitchen.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'

/obj/item/kitchen/fork
	name = "fork"
	desc = "Pointy."
	icon_state = "fork"
	force = 4
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 5
	custom_materials = list(/datum/material/iron=80)
	flags_1 = CONDUCT_1
	attack_verb = list("attacked", "stabbed", "poked")
	hitsound = 'sound/weapons/bladeslice.ogg'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)
	item_flags = EYE_STAB
	sharpness = SHARP_POINTY
	var/datum/reagent/forkload //used to eat omelette

/obj/item/kitchen/fork/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] stabs \the [src] into [user.p_their()] chest! It looks like [user.p_theyre()] trying to take a bite out of [user.p_them()]self!</span>")
	playsound(src, 'sound/items/eatfood.ogg', 50, TRUE)
	return BRUTELOSS

/obj/item/kitchen/fork/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M))
		return ..()

	if(forkload)
		if(M == user)
			M.visible_message("<span class='notice'>[user] eats a delicious forkful of omelette!</span>")
			M.reagents.add_reagent(forkload.type, 1)
		else
			M.visible_message("<span class='notice'>[user] feeds [M] a delicious forkful of omelette!</span>")
			M.reagents.add_reagent(forkload.type, 1)
		icon_state = "fork"
		forkload = null
	else
		return ..()

/obj/item/kitchen/fork/plastic
	name = "plastic fork"
	desc = "Really takes you back to highschool lunch."
	icon_state = "plastic_fork"
	force = 0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	custom_materials = list(/datum/material/plastic=80)
	custom_price = 50
	var/break_chance = 25

/obj/item/kitchen/fork/plastic/afterattack(atom/target, mob/user)
	.=..()
	if(prob(break_chance))
		user.visible_message("<span class='danger'>[user]'s fork snaps into tiny pieces in their hand.</span>")
		qdel(src)

/obj/item/kitchen/knife
	name = "kitchen knife"
	icon_state = "knife"
	inhand_icon_state = "knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	flags_1 = CONDUCT_1
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	throw_speed = 3
	throw_range = 6
	custom_materials = list(/datum/material/iron=12000)
	attack_verb = list("slashed", "stabbed", "sliced", "tore", "lacerated", "ripped", "diced", "cut")
	sharpness = SHARP_EDGED
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	item_flags = EYE_STAB
	var/bayonet = FALSE	//Can this be attached to a gun?
	custom_price = 250
	wound_bonus = -5
	bare_wound_bonus = 10

/obj/item/kitchen/knife/ComponentInitialize()
	. = ..()
	set_butchering()

///Adds the butchering component, used to override stats for special cases
/obj/item/kitchen/knife/proc/set_butchering()
	AddComponent(/datum/component/butchering, 80 - force, 100, force - 10) //bonus chance increases depending on force

/obj/item/kitchen/knife/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] is slitting [user.p_their()] wrists with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting [user.p_their()] throat with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting [user.p_their()] stomach open with the [src.name]! It looks like [user.p_theyre()] trying to commit seppuku.</span>"))
	return (BRUTELOSS)

/obj/item/kitchen/knife/plastic
	name = "plastic knife"
	icon_state = "plastic_knife"
	inhand_icon_state = "knife"
	desc = "A very safe, barely sharp knife made of plastic. Good for cutting food and not much else."
	force = 0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_range = 5
	custom_materials = list(/datum/material/plastic = 100)
	attack_verb = list("prodded", "whiffed","scratched", "poked")
	sharpness = SHARP_EDGED
	custom_price = 50
	var/break_chance = 25

/obj/item/kitchen/knife/plastic/afterattack(mob/living/carbon/user)
	.=..()
	if(prob(break_chance))
		user.visible_message("<span class='danger'>[user]'s knife snaps into tiny pieces in their hand.</span>")
		qdel(src)

/obj/item/kitchen/knife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/kitchen/knife/bloodletter
	name = "bloodletter"
	desc = "An occult looking dagger that is cold to the touch. Somehow, the flawless orb on the pommel is made entirely of liquid blood."
	icon = 'icons/obj/ice_moon/artifacts.dmi'
	icon_state = "bloodletter"
	w_class = WEIGHT_CLASS_NORMAL
	/// Bleed stacks applied when an organic mob target is hit
	var/bleed_stacks_per_hit = 3

/obj/item/kitchen/knife/bloodletter/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!isliving(target) || !proximity_flag)
		return
	var/mob/living/M = target
	if(!(M.mob_biotypes & MOB_ORGANIC))
		return
	var/datum/status_effect/stacking/saw_bleed/bloodletting/B = M.has_status_effect(/datum/status_effect/stacking/saw_bleed/bloodletting)
	if(!B)
		M.apply_status_effect(/datum/status_effect/stacking/saw_bleed/bloodletting, bleed_stacks_per_hit)
	else
		B.add_stacks(bleed_stacks_per_hit)

/obj/item/kitchen/knife/butcher
	name = "butcher's cleaver"
	icon_state = "butch"
	inhand_icon_state = "butch"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown by-products."
	flags_1 = CONDUCT_1
	force = 15
	throwforce = 10
	custom_materials = list(/datum/material/iron=18000)
	attack_verb = list("cleaved", "slashed", "stabbed", "sliced", "tore", "lacerated", "ripped", "diced", "cut")
	w_class = WEIGHT_CLASS_NORMAL
	custom_price = 600

/obj/item/kitchen/knife/hunting
	name = "hunting knife"
	desc = "Despite its name, it's mainly used for cutting meat from dead prey rather than actual hunting."
	inhand_icon_state = "huntingknife"
	icon_state = "huntingknife"

/obj/item/kitchen/knife/hunting/set_butchering()
	AddComponent(/datum/component/butchering, 80 - force, 100, force + 10)

/obj/item/kitchen/knife/combat
	name = "combat knife"
	icon_state = "buckknife"
	desc = "A military combat utility survival knife."
	embedding = list("pain_mult" = 4, "embed_chance" = 65, "fall_chance" = 10, "ignore_throwspeed_threshold" = TRUE)
	force = 20
	throwforce = 20
	attack_verb = list("slashed", "stabbed", "sliced", "tore", "lacerated", "ripped", "cut")
	bayonet = TRUE

/obj/item/kitchen/knife/combat/survival
	name = "survival knife"
	icon_state = "survivalknife"
	embedding = list("pain_mult" = 4, "embed_chance" = 35, "fall_chance" = 10)
	desc = "A hunting grade survival knife."
	force = 15
	throwforce = 15
	bayonet = TRUE

/obj/item/kitchen/knife/combat/bone
	name = "bone dagger"
	inhand_icon_state = "bone_dagger"
	icon_state = "bone_dagger"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	desc = "A sharpened bone. The bare minimum in survival."
	embedding = list("pain_mult" = 4, "embed_chance" = 35, "fall_chance" = 10)
	force = 15
	throwforce = 15
	custom_materials = null

/obj/item/kitchen/knife/combat/cyborg
	name = "cyborg knife"
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "knife_cyborg"
	desc = "A cyborg-mounted plasteel knife. Extremely sharp and durable."

/obj/item/kitchen/knife/shiv
	name = "glass shiv"
	icon = 'icons/obj/shards.dmi'
	icon_state = "shiv"
	inhand_icon_state = "shiv"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	desc = "A makeshift glass shiv."
	force = 8
	throwforce = 12
	attack_verb = list("shanked", "shivved")
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	custom_materials = list(/datum/material/glass=400)

/obj/item/kitchen/knife/shiv/carrot
	name = "carrot shiv"
	icon_state = "carrotshiv"
	inhand_icon_state = "carrotshiv"
	icon = 'icons/obj/kitchen.dmi'
	desc = "Unlike other carrots, you should probably keep this far away from your eyes."
	custom_materials = null

/obj/item/kitchen/knife/shiv/carrot/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] forcefully drives \the [src] into [user.p_their()] eye! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon_state = "rolling_pin"
	force = 8
	throwforce = 5
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT * 1.5)
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	custom_price = 200

/obj/item/kitchen/rollingpin/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins flattening [user.p_their()] head with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS
/* Trays  moved to /obj/item/storage/bag */

/obj/item/kitchen/spoon/plastic
	name = "plastic spoon"
	desc = "Just be careful your food doesn't melt the spoon first."
	icon_state = "plastic_spoon"
	force = 0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	custom_materials = list(/datum/material/plastic=120)
	custom_price = 50
	var/break_chance = 25

/obj/item/kitchen/spoon/plastic/afterattack(atom/target, mob/user)
	.=..()
	if(prob(break_chance))
		user.visible_message("<span class='danger'>[user]'s spoon snaps into tiny pieces in their hand.</span>")
		qdel(src)
