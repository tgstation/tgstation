/datum/lazy_template/virtual_domain/gondola_asteroid
	name = "Астероид с гондолами"
	desc = "Этот астероид является домом для обильного леса с гондолами. Умиротворительно."
	help_text = "Какой чудесный лес. Нужный нам ящик находится в центре леса. \
	Странно, ящик не толкнуть. А вот гондолы, похоже, без проблем его передвигают. \
	Наверняка есть способ сдвинуть его своими силами."
	key = "gondola_asteroid"
	map_name = "gondola_asteroid"
	domain_flags = DOMAIN_NO_NOHIT_BONUS

/// Very pushy gondolas, great for moving loot crates.
/obj/structure/closet/crate/secure/bitrunning/encrypted/gondola
	move_resist = MOVE_FORCE_STRONG

/mob/living/basic/pet/gondola/virtual_domain
	health = 50
	loot = list(
		/obj/effect/decal/cleanable/blood/gibs = 1,
		/obj/item/stack/sheet/animalhide/gondola = 1,
		/obj/item/food/meat/slab/gondola/virtual_domain = 1,
	)
	maxHealth = 50
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_STRONG

/obj/item/food/meat/slab/gondola/virtual_domain
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/gondola_mutation_toxin/virtual_domain = 5,
	)

/datum/reagent/gondola_mutation_toxin/virtual_domain
	name = "Advanced Tranquility"
	gondola_disease = /datum/disease/transformation/gondola/virtual_domain

/datum/disease/transformation/gondola/virtual_domain
	stage_prob = 9
	new_form = /mob/living/basic/pet/gondola/virtual_domain
	visibility_flags = parent_type::visibility_flags | HIDDEN_BOOK
