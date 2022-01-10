/obj/item/organ/alien
	icon_state = "xgibmid2"
	visual = FALSE
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/toxin/acid = 10)
	var/list/alien_powers = list()

/obj/item/organ/alien/Initialize(mapload)
	. = ..()
	for(var/A in alien_powers)
		if(ispath(A))
			alien_powers -= A
			alien_powers += new A(src)

/obj/item/organ/alien/Destroy()
	QDEL_LIST(alien_powers)
	return ..()

/obj/item/organ/alien/Insert(mob/living/carbon/M, special = 0)
	..()
	for(var/obj/effect/proc_holder/alien/P in alien_powers)
		M.AddAbility(P)


/obj/item/organ/alien/Remove(mob/living/carbon/M, special = 0)
	for(var/obj/effect/proc_holder/alien/P in alien_powers)
		M.RemoveAbility(P)
	..()


/obj/item/organ/alien/plasmavessel
	name = "plasma vessel"
	icon_state = "plasma"
	w_class = WEIGHT_CLASS_NORMAL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_XENO_PLASMAVESSEL
	alien_powers = list(/obj/effect/proc_holder/alien/plant, /obj/effect/proc_holder/alien/transfer)
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/toxin/plasma = 10)

	/// The current amount of stored plasma.
	var/storedPlasma = 100
	/// The maximum plasma this organ can store.
	var/max_plasma = 250
	/// The rate this organ regenerates its owners health at per damage type per second.
	var/heal_rate = 2.5
	/// The rate this organ regenerates plasma at per second.
	var/plasma_rate = 5

/obj/item/organ/alien/plasmavessel/large
	name = "large plasma vessel"
	icon_state = "plasma_large"
	w_class = WEIGHT_CLASS_BULKY
	storedPlasma = 200
	max_plasma = 500
	plasma_rate = 7.5

/obj/item/organ/alien/plasmavessel/large/queen
	plasma_rate = 10

/obj/item/organ/alien/plasmavessel/small
	name = "small plasma vessel"
	icon_state = "plasma_small"
	w_class = WEIGHT_CLASS_SMALL
	storedPlasma = 100
	max_plasma = 150
	plasma_rate = 2.5

/obj/item/organ/alien/plasmavessel/small/tiny
	name = "tiny plasma vessel"
	icon_state = "plasma_tiny"
	w_class = WEIGHT_CLASS_TINY
	max_plasma = 100
	alien_powers = list(/obj/effect/proc_holder/alien/transfer)

/obj/item/organ/alien/plasmavessel/on_life(delta_time, times_fired)
	//If there are alien weeds on the ground then heal if needed or give some plasma
	if(locate(/obj/structure/alien/weeds) in owner.loc)
		if(owner.health >= owner.maxHealth)
			owner.adjustPlasma(plasma_rate * delta_time)
		else
			var/heal_amt = heal_rate
			if(!isalien(owner))
				heal_amt *= 0.2
			owner.adjustPlasma(0.5 * plasma_rate * delta_time)
			owner.adjustBruteLoss(-heal_amt * delta_time)
			owner.adjustFireLoss(-heal_amt * delta_time)
			owner.adjustOxyLoss(-heal_amt * delta_time)
			owner.adjustCloneLoss(-heal_amt * delta_time)
	else
		owner.adjustPlasma(0.1 * plasma_rate * delta_time)

/obj/item/organ/alien/plasmavessel/Insert(mob/living/carbon/M, special = 0)
	..()
	if(isalien(M))
		var/mob/living/carbon/alien/A = M
		A.updatePlasmaDisplay()

/obj/item/organ/alien/plasmavessel/Remove(mob/living/carbon/M, special = 0)
	..()
	if(isalien(M))
		var/mob/living/carbon/alien/A = M
		A.updatePlasmaDisplay()

#define QUEEN_DEATH_DEBUFF_DURATION 2400

/obj/item/organ/alien/hivenode
	name = "hive node"
	icon_state = "hivenode"
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_XENO_HIVENODE
	w_class = WEIGHT_CLASS_TINY
	///Indicates if the queen died recently, aliens are heavily weakened while this is active.
	var/recent_queen_death = FALSE
	alien_powers = list(/obj/effect/proc_holder/alien/whisper)

/obj/item/organ/alien/hivenode/Insert(mob/living/carbon/M, special = 0)
	..()
	M.faction |= ROLE_ALIEN
	ADD_TRAIT(M, TRAIT_XENO_IMMUNE, ORGAN_TRAIT)

/obj/item/organ/alien/hivenode/Remove(mob/living/carbon/M, special = 0)
	M.faction -= ROLE_ALIEN
	REMOVE_TRAIT(M, TRAIT_XENO_IMMUNE, ORGAN_TRAIT)
	..()

//When the alien queen dies, all aliens suffer a penalty as punishment for failing to protect her.
/obj/item/organ/alien/hivenode/proc/queen_death()
	if(!owner|| owner.stat == DEAD)
		return
	if(isalien(owner)) //Different effects for aliens than humans
		to_chat(owner, span_userdanger("Your Queen has been struck down!"))
		to_chat(owner, span_danger("You are struck with overwhelming agony! You feel confused, and your connection to the hivemind is severed."))
		owner.emote("roar")
		owner.Stun(200) //Actually just slows them down a bit.

	else if(ishuman(owner)) //Humans, being more fragile, are more overwhelmed by the mental backlash.
		to_chat(owner, span_danger("You feel a splitting pain in your head, and are struck with a wave of nausea. You cannot hear the hivemind anymore!"))
		owner.emote("scream")
		owner.Paralyze(100)

	owner.jitteriness += 30
	owner.add_confusion(30)
	owner.stuttering += 30

	recent_queen_death = TRUE
	owner.throw_alert("alien_noqueen", /atom/movable/screen/alert/alien_vulnerable)
	addtimer(CALLBACK(src, .proc/clear_queen_death), QUEEN_DEATH_DEBUFF_DURATION)


/obj/item/organ/alien/hivenode/proc/clear_queen_death()
	if(QDELETED(src)) //In case the node is deleted
		return
	recent_queen_death = FALSE
	if(!owner) //In case the xeno is butchered or subjected to surgery after death.
		return
	to_chat(owner, span_noticealien("The pain of the queen's death is easing. You begin to hear the hivemind again."))
	owner.clear_alert("alien_noqueen")

#undef QUEEN_DEATH_DEBUFF_DURATION

/obj/item/organ/alien/resinspinner
	name = "resin spinner"
	icon_state = "stomach-x"
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_XENO_RESINSPINNER
	alien_powers = list(/obj/effect/proc_holder/alien/resin)


/obj/item/organ/alien/acid
	name = "acid gland"
	icon_state = "acid"
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_XENO_ACIDGLAND
	alien_powers = list(/obj/effect/proc_holder/alien/acid)


/obj/item/organ/alien/neurotoxin
	name = "neurotoxin gland"
	icon_state = "neurotox"
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_XENO_NEUROTOXINGLAND
	alien_powers = list(/obj/effect/proc_holder/alien/neurotoxin)


/obj/item/organ/alien/eggsac
	name = "egg sac"
	icon_state = "eggsac"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_XENO_EGGSAC
	w_class = WEIGHT_CLASS_BULKY
	alien_powers = list(/obj/effect/proc_holder/alien/lay_egg)
