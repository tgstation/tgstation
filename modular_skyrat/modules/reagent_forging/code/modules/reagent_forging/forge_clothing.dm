//armor
/obj/item/clothing/suit/armor/reagent_clothing
	name = "chain armor"
	desc = "A piece of armor made out of chains, ready to be imbued with a chemical."
	icon = 'modular_skyrat/modules/reagent_forging/icons/obj/forge_clothing.dmi'
	icon_state = "chain_armor"
	worn_icon = 'modular_skyrat/modules/reagent_forging/icons/mob/forge_clothing.dmi'
	resistance_flags = FIRE_PROOF
	armor = list(MELEE = 40, BULLET = 40, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 0, WOUND = 30)
	var/list/imbued_reagent = list()
	var/world_pausing = 0
	var/has_imbued = FALSE
	var/obj/item/reagent_containers/reagentContainer
	mutant_variants = NONE

/obj/item/clothing/suit/armor/reagent_clothing/Initialize()
	. = ..()
	create_reagents(500, INJECTABLE | REFILLABLE)
	reagentContainer = new /obj/item/reagent_containers(src)
	START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/armor/reagent_clothing/Destroy()
	STOP_PROCESSING(SSobj, src)
	qdel(reagentContainer)
	. = ..()

/obj/item/clothing/suit/armor/reagent_clothing/process()
	if(world_pausing >= world.time)
		return
	world_pausing = world.time + 3 SECONDS
	if(!imbued_reagent.len || !ishuman(loc))
		return
	var/mob/living/carbon/human/humanMob = loc
	if(humanMob.wear_suit != src)
		return
	for(var/reagentList in imbued_reagent)
		reagentContainer.reagents.add_reagent(reagentList, 0.5)
		reagentContainer.reagents.trans_to(target = humanMob, amount = 0.5, transfered_by = src, methods = INJECT)

//gloves
/obj/item/clothing/gloves/reagent_clothing
	name = "chain gloves"
	desc = "A set of gloves made out of chains, ready to be imbued with a chemical."
	icon = 'modular_skyrat/modules/reagent_forging/icons/obj/forge_clothing.dmi'
	icon_state = "chain_glove"
	worn_icon = 'modular_skyrat/modules/reagent_forging/icons/mob/forge_clothing.dmi'
	resistance_flags = FIRE_PROOF
	armor = list(MELEE = 40, BULLET = 40, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 0, WOUND = 30)
	var/list/imbued_reagent = list()
	var/world_pausing = 0
	var/has_imbued = FALSE
	var/obj/item/reagent_containers/reagentContainer
	mutant_variants = NONE

/obj/item/clothing/gloves/reagent_clothing/Initialize()
	. = ..()
	create_reagents(500, INJECTABLE | REFILLABLE)
	reagentContainer = new /obj/item/reagent_containers(src)
	START_PROCESSING(SSobj, src)

/obj/item/clothing/gloves/reagent_clothing/Destroy()
	STOP_PROCESSING(SSobj, src)
	qdel(reagentContainer)
	. = ..()

/obj/item/clothing/gloves/reagent_clothing/process()
	if(world_pausing >= world.time)
		return
	world_pausing = world.time + 3 SECONDS
	if(!imbued_reagent.len || !ishuman(loc))
		return
	var/mob/living/carbon/human/humanMob = loc
	if(humanMob.gloves != src)
		return
	for(var/reagentList in imbued_reagent)
		reagentContainer.reagents.add_reagent(reagentList, 0.5)
		reagentContainer.reagents.trans_to(target = humanMob, amount = 0.5, transfered_by = src, methods = INJECT)

/obj/item/clothing/head/helmet/reagent_clothing
	name = "chain helmet"
	desc = "A helmet made out of chains, ready to be imbued with a chemical."
	icon = 'modular_skyrat/modules/reagent_forging/icons/obj/forge_clothing.dmi'
	icon_state = "chain_helmet"
	worn_icon = 'modular_skyrat/modules/reagent_forging/icons/mob/forge_clothing.dmi'
	resistance_flags = FIRE_PROOF
	armor = list(MELEE = 40, BULLET = 40, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 0, WOUND = 30)
	var/list/imbued_reagent = list()
	var/world_pausing = 0
	var/has_imbued = FALSE
	var/obj/item/reagent_containers/reagentContainer

/obj/item/clothing/head/helmet/reagent_clothing/Initialize()
	. = ..()
	create_reagents(500, INJECTABLE | REFILLABLE)
	reagentContainer = new /obj/item/reagent_containers(src)
	START_PROCESSING(SSobj, src)

/obj/item/clothing/head/helmet/reagent_clothing/Destroy()
	STOP_PROCESSING(SSobj, src)
	qdel(reagentContainer)
	. = ..()

/obj/item/clothing/head/helmet/reagent_clothing/process()
	if(world_pausing >= world.time)
		return
	world_pausing = world.time + 3 SECONDS
	if(!imbued_reagent.len || !ishuman(loc))
		return
	var/mob/living/carbon/human/humanMob = loc
	if(humanMob.head != src)
		return
	for(var/reagentList in imbued_reagent)
		reagentContainer.reagents.add_reagent(reagentList, 0.5)
		reagentContainer.reagents.trans_to(target = humanMob, amount = 0.5, transfered_by = src, methods = INJECT)
