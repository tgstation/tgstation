/obj/item/organ/internal/alien
	origin_tech = "biotech=5"
	icon = 'icons/effects/blood.dmi'
	icon_state = "xgibmid2"
	var/list/alien_powers = list()

/obj/item/organ/internal/alien/New()
	for(var/A in alien_powers)
		if(ispath(A))
			alien_powers -= A
			alien_powers += new A(src)
	..()

/obj/item/organ/internal/alien/Insert(mob/living/carbon/M, special = 0)
	..()
	for(var/obj/effect/proc_holder/alien/P in alien_powers)
		M.AddAbility(P)


/obj/item/organ/internal/alien/Remove(mob/living/carbon/M, special = 0)
	for(var/obj/effect/proc_holder/alien/P in alien_powers)
		M.RemoveAbility(P)
	..()

/obj/item/organ/internal/alien/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("sacid", 10)
	return S


/obj/item/organ/internal/alien/plasmavessel
	name = "plasma vessel"
	origin_tech = "biotech=5;plasma=2"
	w_class = 3
	zone = "chest"
	slot = "plasmavessel"
	alien_powers = list(/obj/effect/proc_holder/alien/plant, /obj/effect/proc_holder/alien/transfer)

	var/storedPlasma = 100
	var/max_plasma = 250
	var/heal_rate = 5
	var/plasma_rate = 10

/obj/item/organ/internal/alien/plasmavessel/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("plasma", storedPlasma/10)
	return S

/obj/item/organ/internal/alien/plasmavessel/large
	name = "large plasma vessel"
	w_class = 4
	storedPlasma = 200
	max_plasma = 500
	plasma_rate = 15

/obj/item/organ/internal/alien/plasmavessel/large/queen
	origin_tech = "biotech=6;plasma=3"
	plasma_rate = 20

/obj/item/organ/internal/alien/plasmavessel/small
	name = "small plasma vessel"
	w_class = 2
	storedPlasma = 100
	max_plasma = 150
	plasma_rate = 5

/obj/item/organ/internal/alien/plasmavessel/small/tiny
	name = "tiny plasma vessel"
	w_class = 1
	max_plasma = 100
	alien_powers = list(/obj/effect/proc_holder/alien/transfer)

/obj/item/organ/internal/alien/plasmavessel/on_life()
	//If there are alien weeds on the ground then heal if needed or give some plasma
	if(locate(/obj/structure/alien/weeds) in owner.loc)
		if(owner.health >= owner.maxHealth)
			owner.adjustPlasma(plasma_rate)
		else
			var/heal_amt = heal_rate
			if(!isalien(owner))
				heal_amt *= 0.2
			owner.adjustPlasma(plasma_rate*0.5)
			owner.adjustBruteLoss(-heal_amt)
			owner.adjustFireLoss(-heal_amt)
			owner.adjustOxyLoss(-heal_amt)
			owner.adjustCloneLoss(-heal_amt)

/obj/item/organ/internal/alien/plasmavessel/Insert(mob/living/carbon/M, special = 0)
	..()
	if(isalien(M))
		var/mob/living/carbon/alien/A = M
		A.updatePlasmaDisplay()

/obj/item/organ/internal/alien/plasmavessel/Remove(mob/living/carbon/M, special = 0)
	..()
	if(isalien(M))
		var/mob/living/carbon/alien/A = M
		A.updatePlasmaDisplay()


/obj/item/organ/internal/alien/hivenode
	name = "hive node"
	zone = "head"
	slot = "hivenode"
	origin_tech = "biotech=5;magnets=4;bluespace=3"
	w_class = 1
	alien_powers = list(/obj/effect/proc_holder/alien/whisper)

/obj/item/organ/internal/alien/hivenode/Insert(mob/living/carbon/M, special = 0)
	..()
	M.faction |= "alien"

/obj/item/organ/internal/alien/hivenode/Remove(mob/living/carbon/M, special = 0)
	M.faction -= "alien"
	..()


/obj/item/organ/internal/alien/resinspinner
	name = "resin spinner"
	zone = "mouth"
	slot = "resinspinner"
	origin_tech = "biotech=5;materials=4"
	alien_powers = list(/obj/effect/proc_holder/alien/resin)


/obj/item/organ/internal/alien/acid
	name = "acid gland"
	zone = "mouth"
	slot = "acidgland"
	origin_tech = "biotech=5;materials=2;combat=2"
	alien_powers = list(/obj/effect/proc_holder/alien/acid)


/obj/item/organ/internal/alien/neurotoxin
	name = "neurotoxin gland"
	zone = "mouth"
	slot = "neurotoxingland"
	origin_tech = "biotech=5;combat=5"
	alien_powers = list(/obj/effect/proc_holder/alien/neurotoxin)


/obj/item/organ/internal/alien/eggsac
	name = "egg sac"
	zone = "groin"
	slot = "eggsac"
	w_class = 4
	origin_tech = "biotech=8"
	alien_powers = list(/obj/effect/proc_holder/alien/lay_egg)