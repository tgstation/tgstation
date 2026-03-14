
/obj/item/skillchip/basketweaving
	name = "Basketsoft 3000 skillchip"
	desc = "Underwater edition."
	skill_name = "Underwater Basketweaving"
	skill_description = "Master intricate art of using twine to create perfect baskets while submerged."
	skill_icon = "shopping-basket"
	activate_message = span_notice("You're one with the twine and the sea.")
	deactivate_message = span_notice("Higher mysteries of underwater basketweaving leave your mind.")

/obj/item/skillchip/basketweaving/has_mob_incompatibility(mob/living/carbon/target)
	. = ..()
	if(.)
		return

	if(!target.mind)
		return "Target incapable of learning recipe."

/obj/item/skillchip/basketweaving/on_activate(mob/living/carbon/user, silent=FALSE)
	. = ..()
	if(!user.mind)
		return
	learn_recipes(user)
	//Prevent the skill from being transferred via mindswap. What an edge case
	RegisterSignal(user.mind, COMSIG_MIND_TRANSFERRED, PROC_REF(forget_recipes))
	RegisterSignal(user, COMSIG_MOB_MIND_TRANSFERRED_INTO, PROC_REF(learn_recipes))

/obj/item/skillchip/basketweaving/proc/learn_recipes(mob/source)
	SIGNAL_HANDLER
	for(var/recipe_type in typesof(/datum/crafting_recipe/underwater_basket))
		source.mind.teach_crafting_recipe(recipe_type)

/obj/item/skillchip/basketweaving/proc/forget_recipes(datum/mind/source, mob/previous_body)
	SIGNAL_HANDLER
	for(var/recipe_type in typesof(/datum/crafting_recipe/underwater_basket))
		source.forget_crafting_recipe(recipe_type)

/obj/item/skillchip/basketweaving/on_deactivate(mob/living/carbon/user, silent=FALSE)
	if(user.mind)
		forget_recipes(user.mind)
		UnregisterSignal(user.mind, COMSIG_MIND_TRANSFERRED)
		UnregisterSignal(user, COMSIG_MOB_MIND_TRANSFERRED_INTO)
	return ..()
