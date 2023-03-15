/mob/living/simple_animal/chicken/sword
	icon_suffix = "sword"

	maxHealth = 300
	melee_damage = 4 //weak damage but strong health
	obj_damage = 5
	ai_controller = /datum/ai_controller/chicken/retaliate

	breed_name_female = "Shieldmaidhen"
	breed_name_male = "Fowlcion"
	egg_type = /obj/item/food/egg/sword
	mutation_list = list()

	book_desc = "They have seemed to have taken an oath to protect, they will protect all chickens from those who would do harm onto them."

/obj/item/food/egg/sword
	name = "Gallant Egg"
	icon_state = "sword"

	layer_hen_type = /mob/living/simple_animal/chicken/sword

/obj/item/food/egg/sword/consumed_egg(datum/source, mob/living/eater, mob/living/feeder)
	. = ..()
	eater.apply_status_effect(ARMORED_EGG)

/datum/status_effect/ranching/sword_chicken
	id = "sword_egg"
	duration = 60 SECONDS

/datum/status_effect/ranching/sword_chicken/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/human/buffed_person = owner
		buffed_person.physiology.armor.melee += 30
		buffed_person.physiology.armor.bullet += 30
	return ..()

/datum/status_effect/ranching/sword_chicken/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/buffed_person = owner
		buffed_person.physiology.armor.melee -= 30
		buffed_person.physiology.armor.bullet -= 30
