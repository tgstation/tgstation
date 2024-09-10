#define MAX_IMBUE_STORAGE 250
#define REAGENT_CLOTHING_INJECT_AMOUNT 0.5
#define REAGENT_WEAPON_INJECT_AMOUNT 1
#define REAGENT_WEAPON_DAMAGE_MULTIPLIER 2

//the component that is attached to clothes that allows them to be imbued
//ONLY USE THIS FOR CLOTHING
/datum/component/reagent_clothing
	///the item that the component is attached to
	var/obj/item/parent_clothing
	///the slot that the item will check
	var/checking_slot
	///the human that is wearing the parent_clothing
	var/mob/living/carbon/human/cloth_wearer
	///the container that will apply the chemicals
	var/obj/item/reagent_containers/applying_container
	///the list of imbued reagents that will given to the human owner
	var/list/imbued_reagent = list()
	//the cooldown between each imbue
	COOLDOWN_DECLARE(imbue_cooldown)

/datum/component/reagent_clothing/Initialize(set_slot = null)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE //they need to be clothing, I already said this

	if(set_slot)
		checking_slot = set_slot

	parent_clothing = parent
	parent_clothing.create_reagents(MAX_IMBUE_STORAGE, INJECTABLE | REFILLABLE)
	applying_container = new /obj/item/reagent_containers(src)
	RegisterSignal(parent_clothing, COMSIG_ITEM_EQUIPPED, PROC_REF(set_wearer))
	RegisterSignal(parent_clothing, COMSIG_ITEM_PRE_UNEQUIP, PROC_REF(remove_wearer))
	RegisterSignal(parent_clothing, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	START_PROCESSING(SSdcs, src)

/datum/component/reagent_clothing/Destroy(force)
	parent_clothing = null
	cloth_wearer = null
	QDEL_NULL(applying_container)
	STOP_PROCESSING(SSdcs, src)
	return ..()

/datum/component/reagent_clothing/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("[parent_clothing] is able to be inbued with a chemical at a reagent forge!")

/datum/component/reagent_clothing/proc/set_wearer()
	SIGNAL_HANDLER

	if(!ishuman(parent_clothing.loc))
		return
	cloth_wearer = parent_clothing.loc

/datum/component/reagent_clothing/proc/remove_wearer()
	SIGNAL_HANDLER
	cloth_wearer = null

/datum/component/reagent_clothing/process(seconds_per_tick)
	if(!parent_clothing || !cloth_wearer || !length(imbued_reagent))
		return

	if(parent_clothing != cloth_wearer.get_item_by_slot(checking_slot))
		return

	if(!COOLDOWN_FINISHED(src, imbue_cooldown))
		return

	COOLDOWN_START(src, imbue_cooldown, 3 SECONDS)

	for(var/create_reagent in imbued_reagent)
		applying_container.reagents.add_reagent(create_reagent, REAGENT_CLOTHING_INJECT_AMOUNT)
		applying_container.reagents.trans_to(target = cloth_wearer, amount = REAGENT_CLOTHING_INJECT_AMOUNT, methods = INJECT)

//the component that is attached to weapons that allows them to be imbued
//ONLY USE THIS FOR WEAPONS
/datum/component/reagent_weapon
	///the item that the component is attached to
	var/obj/item/parent_weapon
	///the list of imbued reagents that will given to the human owner
	var/list/imbued_reagent = list()

/datum/component/reagent_weapon/Initialize(...)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE //they need to be weapons, I already said this
	parent_weapon = parent
	parent_weapon.create_reagents(MAX_IMBUE_STORAGE, INJECTABLE | REFILLABLE)
	RegisterSignal(parent_weapon, COMSIG_ITEM_ATTACK, PROC_REF(inject_attacked))
	RegisterSignal(parent_weapon, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/reagent_weapon/Destroy(force)
	parent_weapon = null
	return ..()

/datum/component/reagent_weapon/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("[parent_weapon] is able to be imbued with a chemical at a reagent forge!")

/datum/component/reagent_weapon/proc/inject_attacked(datum/source, mob/living/target, mob/living/user, params)
	SIGNAL_HANDLER

	//don't have the weapon or any imbued reagents? don't try
	if(!parent_weapon || !length(imbued_reagent))
		return

	//lets inject that target
	var/mob/living_target = target
	for(var/create_reagent in imbued_reagent)
		living_target.reagents.add_reagent(create_reagent, REAGENT_WEAPON_INJECT_AMOUNT)

	//now lets take damage corresponding to the amount of chems we have imbued (hit either 100 times or 50 times before it breaks)
	parent_weapon.take_damage(length(imbued_reagent) * REAGENT_WEAPON_DAMAGE_MULTIPLIER)

#undef MAX_IMBUE_STORAGE
#undef REAGENT_CLOTHING_INJECT_AMOUNT
#undef REAGENT_WEAPON_INJECT_AMOUNT
#undef REAGENT_WEAPON_DAMAGE_MULTIPLIER
