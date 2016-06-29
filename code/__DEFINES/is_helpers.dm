// simple is_type and similar inline helpers

#define islist(L) (istype(L,/list))

#define in_range(source, user) (get_dist(source, user) <= 1)

// MOB HELPERS

#define ishuman(A) (istype(A, /mob/living/carbon/human))

// Human sub-species
#define isabductor(A) (is_species(A, /datum/species/abductor))
#define isgolem(A) (is_species(A, /datum/species/golem))
#define islizard(A) (is_species(A, /datum/species/lizard))
#define isplasmaman(A) (is_species(A, /datum/species/plasmaman))
#define ispodperson(A) (is_species(A, /datum/species/podperson))
#define isflyperson(A) (is_species(A, /datum/species/fly))
#define iszombie(A) (is_species(A, /datum/species/zombie))
#define ishumanbasic(A) (is_species(A, /datum/species/human))

#define ismonkey(A) (istype(A, /mob/living/carbon/monkey))

#define isbrain(A) (istype(A, /mob/living/carbon/brain))

#define isalien(A) (istype(A, /mob/living/carbon/alien))

#define isalienadult(A) (istype(A, /mob/living/carbon/alien/humanoid))

#define islarva(A) (istype(A, /mob/living/carbon/alien/larva))

#define isslime(A) (istype(A, /mob/living/simple_animal/slime))

#define isrobot(A) (istype(A, /mob/living/silicon/robot))

#define isanimal(A) (istype(A, /mob/living/simple_animal))

#define iscorgi(A) (istype(A, /mob/living/simple_animal/pet/dog/corgi))

#define iscrab(A) (istype(A, /mob/living/simple_animal/crab))

#define iscat(A) (istype(A, /mob/living/simple_animal/pet/cat))

#define ismouse(A) (istype(A, /mob/living/simple_animal/mouse))

#define isconstruct(A) (istype(A, /mob/living/simple_animal/hostile/construct))

#define isclockmob(A) (istype(A, /mob/living/simple_animal/hostile/clockwork))

#define isshade(A) (istype(A, /mob/living/simple_animal/shade))

#define isbear(A) (istype(A, /mob/living/simple_animal/hostile/bear))

#define iscarp(A) (istype(A, /mob/living/simple_animal/hostile/carp))

#define isclown(A) (istype(A, /mob/living/simple_animal/hostile/retaliate/clown))

#define isAI(A) (istype(A, /mob/living/silicon/ai))

#define ispAI(A) (istype(A, /mob/living/silicon/pai))

#define iscarbon(A) (istype(A, /mob/living/carbon))

#define issilicon(A) (istype(A, /mob/living/silicon))

#define isliving(A) (istype(A, /mob/living))

#define isobserver(A) (istype(A, /mob/dead/observer))

#define isnewplayer(A) (istype(A, /mob/new_player))

#define isovermind(A) (istype(A, /mob/camera/blob))

#define isdrone(A) (istype(A, /mob/living/simple_animal/drone))

#define isswarmer(A) (istype(A, /mob/living/simple_animal/hostile/swarmer))

#define isguardian(A) (istype(A, /mob/living/simple_animal/hostile/guardian))

#define isumbra(A) (istype(A, /mob/living/simple_animal/umbra))

#define islimb(A) (istype(A, /obj/item/bodypart))

#define isbot(A) (istype(A, /mob/living/simple_animal/bot))

#define ismovableatom(A) (istype(A, /atom/movable))

#define isobj(A) istype(A, /obj) //override the byond proc because it returns true on children of /atom/movable that aren't objs

// ASSEMBLY HELPERS

#define isassembly(O) (istype(O, /obj/item/device/assembly))

#define isigniter(O) (istype(O, /obj/item/device/assembly/igniter))

#define isinfared(O) (istype(O, /obj/item/device/assembly/infra))

#define isprox(O) (istype(O, /obj/item/device/assembly/prox_sensor))

#define issignaler(O) (istype(O, /obj/item/device/assembly/signaler))

#define istimer(O) (istype(O, /obj/item/device/assembly/timer))
