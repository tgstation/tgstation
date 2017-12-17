#define DIP_TYPE_STATIC 1 //Transfer an absolute amount of reagents from the dip container when dipping
#define DIP_TYPE_FRACTIONAL_DIP_TOTAL 2 //Transfer a fraction of the dip container's current volume when dipping
#define DIP_TYPE_FRACTIONAL_DIP_MAXIMUM 3 //Transfer a fraction of the dip container's maximum volume when dipping
#define DIP_TYPE_FRACTIONAL_DIPPED_TOTAL 4 //Transfer a fraction of the dipped item's current volume from the dip container when dipping
#define DIP_TYPE_FRACTIONAL_DIPPED_MAXIMUM 5 //Transfer a fraction of the dipped item's maximum volume from the dip container when dipping

/*
DIPPING:
The following arguments in the Initialize function determine the dipping properties of the item:
capacity_already_defined: If this is true, don't alter the item's max reagent volume. This is to be used for dippable foodstuffs like cookies.
_capacity: If _size is zero, the dippable item's maximum capacity is this.
_dip_mix_ratio: How much of the dipped item's reagents should be mixed with the dip before applying the dip?
_dip_transfer_rate: How much of the dip is transferred to the dipped item?
_dip_transfer_type: Refer to the defines above.
_transfer_on_attack: Should the dipped item transfer its reagents to mobs that are attacked by it? This should be false for dippable foodstuffs.
_attack_transfer_ratio: What fraction of the dipped item's reagents should be transferred to attacked mobs?
*/

/datum/component/dippable
	var/dip_mix_ratio	//How much of the dipped item's reagents should be mixed with the dip before applying the dip?
	var/dip_transfer_rate	//How much dip should we apply to the dipped item upon dipping?
	var/dip_transfer_type	//Is the rate of dip transfer a fraction of the dippable item's capacity or a static quantity of reagent?
	var/transfer_on_attack	//Should we transfer the dipped item's reagents when attacking someone?
	var/attack_transfer_ratio	//How much of the dipped item's reagents should be applied to whatever is attacked with the dipped item?

/datum/component/dippable/Initialize(capacity_already_defined = FALSE, _capacity = 0, _dip_mix_ratio = 0, _dip_transfer_rate = 0, _dip_transfer_type = DIP_TYPE_STATIC, _transfer_on_attack = FALSE, _attack_transfer_ratio = 0)
	if(!isitem(parent))
		. = COMPONENT_INCOMPATIBLE
		CRASH("Attempted to put dippable component in [parent.type]!")
	var/obj/item/container = parent
	if(!capacity_already_defined)
		if(!container.reagents)
			container.reagents = new /datum/reagents(maximum = _capacity)
		else
			container.reagents.maximum_volume = _capacity
	else if(!container.reagents)
		container.reagents = new /datum/reagents(maximum = _capacity)
	dip_mix_ratio = _dip_mix_ratio
	dip_transfer_rate = _dip_transfer_rate
	dip_transfer_type = _dip_transfer_type
	transfer_on_attack = _transfer_on_attack
	attack_transfer_ratio = _attack_transfer_ratio
	RegisterSignal(COMSIG_ITEM_ATTACK_REAGENT_CONTAINER, .proc/on_dip)
	RegisterSignal(COMSIG_ITEM_ATTACK, .proc/on_attack)

/datum/component/dippable/proc/get_transfer_amount(datum/reagents/dip, datum/reagents/dipped)
	switch(dip_transfer_type)
		if(DIP_TYPE_STATIC)
			return dip_transfer_rate
		if(DIP_TYPE_FRACTIONAL_DIP_TOTAL)
			return dip.total_volume * dip_transfer_rate
		if(DIP_TYPE_FRACTIONAL_DIP_MAXIMUM)
			return dip.maximum_volume * dip_transfer_rate
		if(DIP_TYPE_FRACTIONAL_DIPPED_TOTAL)
			return dipped.total_volume * dip_transfer_rate
		if(DIP_TYPE_FRACTIONAL_DIPPED_MAXIMUM)
			return dipped.maximum_volume * dip_transfer_rate
		else
			stack_trace("Null dip transfer type detected!")
			return 0

/datum/component/dippable/proc/on_dip(obj/item/reagent_containers/target, mob/user)
	var/obj/item/container = parent
	var/datum/reagents/dip = target.reagents
	var/datum/reagents/dipped = container.reagents
	if(!target.is_open_container())
		return
	if(dip && !dip.total_volume)
		to_chat(user, "<span class='warning'>[target] doesn't have anything to dip [container] in!</span>")
		return
	var/datum/reagents/mixture = new
	mixture.maximum_volume = dip.maximum_volume + dipped.maximum_volume
	dipped.trans_to(mixture, dipped.total_volume * dip_mix_ratio, no_react = TRUE)
	dip.trans_to(mixture, get_transfer_amount(dip, dipped), no_react = TRUE)
	var/datum/reagents/reactants = new
	reactants.maximum_volume = mixture.maximum_volume
	var/spillover = mixture.total_volume - mixture.trans_to(reactants, dipped.maximum_volume, no_react = TRUE)
	reactants.reaction(container, TOUCH)
	reactants.trans_to(dipped, dipped.maximum_volume) //This transfer is okay with having reactions occur because reagents are being transferred to their final destination.
	qdel(reactants)
	spillover -= mixture.trans_to(dip, mixture.total_volume) //Same with transferring the reactants to the dipped item.
	to_chat(user, "<span class='notice'>You dip [container] in [target][spillover ? "..." : "."]</span>")
	if(spillover)
		to_chat(user, "<span class='warning'>...but spill some of the contents!</span>")
		mixture.reaction(get_turf(user), TOUCH)
		mixture.clear_reagents()
	qdel(mixture)

/datum/component/dippable/proc/on_attack(mob/living/target, mob/living/user)
	if(transfer_on_attack && target.can_inject())
		var/obj/item/container = parent
		var/datum/reagents/dip = container.reagents
		if(dip.total_volume)
			var/datum/reagents/reactants = new
			reactants.maximum_volume = dip.total_volume * attack_transfer_ratio
			dip.trans_to(reactants, reactants.maximum_volume, no_react = TRUE)
			reactants.reaction(target, TOUCH)
			reactants.trans_to(target, reactants.maximum_volume)
			qdel(reactants)