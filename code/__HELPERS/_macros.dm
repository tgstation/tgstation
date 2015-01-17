///MACRO FILE//
//Define your macros here if they're used in general code

//Typechecking macros
// fun if you want to typecast humans/monkeys/etc without writing long path-filled lines.
#define ishuman(A) istype(A, /mob/living/carbon/human)

#define ismonkey(A) istype(A, /mob/living/carbon/monkey)

#define isbrain(A) istype(A, /mob/living/carbon/brain)

#define isalien(A) istype(A, /mob/living/carbon/alien)

#define isalienadult(A) istype(A, /mob/living/carbon/alien/humanoid)

#define islarva(A) istype(A, /mob/living/carbon/alien/larva)

#define isslime(A) istype(A, /mob/living/carbon/slime)

#define isslimeadult(A) istype(A, /mob/living/carbon/slime/adult)

#define isrobot(A) istype(A, /mob/living/silicon/robot)

#define isanimal(A) istype(A, /mob/living/simple_animal)

#define iscorgi(A) istype(A, /mob/living/simple_animal/corgi)

#define iscrab(A) istype(A, /mob/living/simple_animal/crab)

#define iscat(A) istype(A, /mob/living/simple_animal/cat)

#define ismouse(A) istype(A, /mob/living/simple_animal/mouse)

#define isbear(A) istype(A, /mob/living/simple_animal/hostile/bear)

#define iscarp(A) istype(A, /mob/living/simple_animal/hostile/carp)

#define isclown(A) istype(A, /mob/living/simple_animal/hostile/retaliate/clown)

#define iscluwne(A) istype(A, /mob/living/simple_animal/hostile/retaliate/cluwne)

#define isAI(A) istype(A, /mob/living/silicon/ai)

#define isAIEye(A) istype(A, /mob/camera/aiEye)

#define ispAI(A) istype(A, /mob/living/silicon/pai)

#define iscarbon(A) istype(A, /mob/living/carbon)

#define issilicon(A) istype(A, /mob/living/silicon)

#define isMoMMI(A) istype(A, /mob/living/silicon/robot/mommi)

#define isbot(A) istype(A, /obj/machinery/bot)

#define isborer(A) istype(A, /mob/living/simple_animal/borer)

#define isshade(A) istype(A, /mob/living/simple_animal/shade)

#define isconstruct(A) istype(A, /mob/living/simple_animal/construct)

#define isliving(A) istype(A, /mob/living)

#define isobserver(A) istype(A, /mob/dead/observer)

#define isovermind(A) istype(A, /mob/camera/blob)

#define isorgan(A) istype(A, /datum/organ/external)
