// simple is_type and similar inline helpers

#define islist(L) (istype(L,/list))

#define in_range(source, user) (get_dist(source, user) <= 1)

#define ismovableatom(A) (istype(A, /atom/movable))

//Turfs
#define isopenturf(A) (istype(A, /turf/open))

#define isindestructiblefloor(A) (istype(A, /turf/open/indestructible))

#define isspaceturf(A) (istype(A, /turf/open/space))

#define isfloorturf(A) (istype(A, /turf/open/floor))

#define isclosedturf(A) (istype(A, /turf/closed))

#define isindestructiblewall(A) (istype(A, /turf/close/indestructible))

#define iswallturf(A) (istype(A, /turf/closed/wall))

#define ismineralturf(A) (istype(A, /turf/closed/mineral))

#define islava(A) (istype(A, /turf/open/floor/plating/lava))

//Mobs
#define isliving(A) (istype(A, /mob/living))

#define isbrain(A) (istype(A, /mob/living/brain))

//Carbon mobs
#define iscarbon(A) (istype(A, /mob/living/carbon))

#define ishuman(A) (istype(A, /mob/living/carbon/human))

//Human sub-species
#define isabductor(A) (is_species(A, /datum/species/abductor))
#define isgolem(A) (is_species(A, /datum/species/golem))
#define islizard(A) (is_species(A, /datum/species/lizard))
#define isplasmaman(A) (is_species(A, /datum/species/plasmaman))
#define ispodperson(A) (is_species(A, /datum/species/podperson))
#define isflyperson(A) (is_species(A, /datum/species/fly))
#define isslimeperson(A) (is_species(A, /datum/species/jelly/slime))
#define isshadowperson(A) (is_species(A, /datum/species/shadow))
#define iszombie(A) (is_species(A, /datum/species/zombie))
#define ishumanbasic(A) (is_species(A, /datum/species/human))

//more carbon mobs
#define ismonkey(A) (istype(A, /mob/living/carbon/monkey))

#define isalien(A) (istype(A, /mob/living/carbon/alien))

#define islarva(A) (istype(A, /mob/living/carbon/alien/larva))

#define isalienadult(A) (istype(A, /mob/living/carbon/alien/humanoid))

#define isalienhunter(A) (istype(A, /mob/living/carbon/alien/humanoid/hunter))

#define isaliensentinel(A) (istype(A, /mob/living/carbon/alien/humanoid/sentinel))

#define isalienroyal(A) (istype(A, /mob/living/carbon/alien/humanoid/royal))

#define isalienqueen(A) (istype(A, /mob/living/carbon/alien/humanoid/royal/queen))

#define isdevil(A) (istype(A, /mob/living/carbon/true_devil))

//Silicon mobs
#define issilicon(A) (istype(A, /mob/living/silicon))

#define iscyborg(A) (istype(A, /mob/living/silicon/robot))

#define isAI(A) (istype(A, /mob/living/silicon/ai))

#define ispAI(A) (istype(A, /mob/living/silicon/pai))

//Simple animals
#define isanimal(A) (istype(A, /mob/living/simple_animal))

#define isrevenant(A) (istype(A, /mob/living/simple_animal/revenant))

#define isbot(A) (istype(A, /mob/living/simple_animal/bot))

#define iscrab(A) (istype(A, /mob/living/simple_animal/crab))

#define isshade(A) (istype(A, /mob/living/simple_animal/shade))

#define ismouse(A) (istype(A, /mob/living/simple_animal/mouse))

#define isslime(A) (istype(A, /mob/living/simple_animal/slime))

#define isdrone(A) (istype(A, /mob/living/simple_animal/drone))

#define iscat(A) (istype(A, /mob/living/simple_animal/pet/cat))

#define isdog(A) (istype(A, /mob/living/simple_animal/pet/dog))

#define iscorgi(A) (istype(A, /mob/living/simple_animal/pet/dog/corgi))

#define ishostile(A) (istype(A, /mob/living/simple_animal/hostile))

#define isbear(A) (istype(A, /mob/living/simple_animal/hostile/bear))

#define iscarp(A) (istype(A, /mob/living/simple_animal/hostile/carp))

#define isswarmer(A) (istype(A, /mob/living/simple_animal/hostile/swarmer))

#define isguardian(A) (istype(A, /mob/living/simple_animal/hostile/guardian))

#define isclockmob(A) (istype(A, /mob/living/simple_animal/hostile/clockwork))

#define isconstruct(A) (istype(A, /mob/living/simple_animal/hostile/construct))

#define ismegafauna(A) (istype(A, /mob/living/simple_animal/hostile/megafauna))

#define isclown(A) (istype(A, /mob/living/simple_animal/hostile/retaliate/clown))

//Misc mobs
#define isobserver(A) (istype(A, /mob/dead/observer))

#define isdead(A) (istype(A, /mob/dead))

#define isnewplayer(A) (istype(A, /mob/dead/new_player))

#define isovermind(A) (istype(A, /mob/camera/blob))

//Objects
#define isobj(A) istype(A, /obj) //override the byond proc because it returns true on children of /atom/movable that aren't objs

#define isitem(A) (istype(A, /obj/item))

#define is_cleanable(A) (istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/rune)) //if something is cleanable

#define isorgan(A) (istype(A, /obj/item/organ))

GLOBAL_LIST_INIT(pointed_types, typecacheof(list(
	/obj/item/weapon/pen,
	/obj/item/weapon/screwdriver,
	/obj/item/weapon/reagent_containers/syringe,
	/obj/item/weapon/kitchen/fork)))

#define is_pointed(W) (is_type_in_typecache(W, GLOB.pointed_types))

#define isbodypart(A) (istype(A, /obj/item/bodypart))

//Assemblies
#define isassembly(O) (istype(O, /obj/item/device/assembly))

#define isigniter(O) (istype(O, /obj/item/device/assembly/igniter))

#define isinfared(O) (istype(O, /obj/item/device/assembly/infra))

#define isprox(O) (istype(O, /obj/item/device/assembly/prox_sensor))

#define issignaler(O) (istype(O, /obj/item/device/assembly/signaler))

#define istimer(O) (istype(O, /obj/item/device/assembly/timer))
