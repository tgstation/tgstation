/mob/living/simple_animal/chick
	gender = FEMALE

/mob/living/simple_animal/chicken
	gender = FEMALE
	rogue_egg_type = /obj/item/reagent_containers/food/snacks/egg

/mob/living/simple_animal/pet/cat
	gender = MALE
	rogue_childtype = list(/mob/living/simple_animal/pet/cat/kitten = 1)
	rogue_partner_type = /mob/living/simple_animal/pet/cat

/mob/living/simple_animal/hostile/rogue/deepone
	gender = MALE

/mob/living/simple_animal/hostile/rogue/haunt
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/rogue/beetle
	rogue_tame_chance = 20
	rogue_tame_bonus = 15

/mob/living/simple_animal/hostile/retaliate/rogue/bigrat
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/rogue/bull
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/rogue/chicken
	gender = FEMALE
	rogue_start_tame = TRUE
	rogue_egg_type = /obj/item/reagent_containers/food/snacks/egg

/mob/living/simple_animal/hostile/retaliate/rogue/cow
	gender = FEMALE
	rogue_tame_chance = 25
	rogue_tame_bonus = 15
	rogue_childtype = list(/mob/living/simple_animal/hostile/retaliate/rogue/cow/cowlet = 95, /mob/living/simple_animal/hostile/retaliate/rogue/cow/bullet = 5)
	rogue_partner_type = /mob/living/simple_animal/hostile/retaliate/rogue/bull

/mob/living/simple_animal/hostile/retaliate/rogue/goat
	gender = FEMALE
	rogue_tame_chance = 25
	rogue_tame_bonus = 15
	rogue_childtype = list(/mob/living/simple_animal/hostile/retaliate/rogue/goat/goatlet = 90, /mob/living/simple_animal/hostile/retaliate/rogue/goat/goatletboy = 10)
	rogue_partner_type = /mob/living/simple_animal/hostile/retaliate/rogue/goatmale

/mob/living/simple_animal/hostile/retaliate/rogue/goatmale
	gender = MALE
	rogue_tame_chance = 25
	rogue_tame_bonus = 15

/mob/living/simple_animal/hostile/retaliate/rogue/minotaur
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/rogue/mole
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/rogue/saiga
	gender = FEMALE
	rogue_tame_chance = 25
	rogue_tame_bonus = 15
	rogue_childtype = list(/mob/living/simple_animal/hostile/retaliate/rogue/saiga/saigakid = 70, /mob/living/simple_animal/hostile/retaliate/rogue/saiga/saigaboy = 30)
	rogue_partner_type = /mob/living/simple_animal/hostile/retaliate/rogue/saiga/saigabuck

/mob/living/simple_animal/hostile/retaliate/rogue/spider
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/rogue/swine
	gender = FEMALE
	rogue_tame_chance = 25
	rogue_tame_bonus = 15
	rogue_childtype = list(/mob/living/simple_animal/hostile/retaliate/rogue/swine/piglet = 60, /mob/living/simple_animal/hostile/retaliate/rogue/swine/hog/piglet = 40)
	rogue_partner_type = /mob/living/simple_animal/hostile/retaliate/rogue/swine/hog

/mob/living/simple_animal/hostile/retaliate/rogue/trufflepig
	gender = MALE
	rogue_partner_type = /mob/living/simple_animal/hostile/retaliate/rogue/trufflepig

/mob/living/simple_animal/hostile/retaliate/rogue/wolf
	gender = MALE

/mob/living/simple_animal/hostile/rogue/skeleton/bow
	gender = MALE

/mob/living/simple_animal/hostile/rogue/skeleton/spear
	gender = MALE

/mob/living/simple_animal/pet/cat/rogue/black
	gender = FEMALE

/mob/living/simple_animal/hostile/retaliate/rogue/cow/bullet
	gender = MALE
	rogue_partner_type = null
	rogue_adult_type = /mob/living/simple_animal/hostile/retaliate/rogue/bull

/mob/living/simple_animal/hostile/retaliate/rogue/cow/cowlet
	rogue_partner_type = null
	rogue_adult_type = /mob/living/simple_animal/hostile/retaliate/rogue/cow

/mob/living/simple_animal/hostile/retaliate/rogue/elemental/behemoth
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/rogue/elemental/colossus
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/rogue/elemental/warden
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/rogue/fae/dryad
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/rogue/fae/glimmerwing
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/rogue/fae/sprite
	gender = FEMALE

/mob/living/simple_animal/hostile/retaliate/rogue/goat/goatlet
	rogue_partner_type = null
	rogue_adult_type = /mob/living/simple_animal/hostile/retaliate/rogue/goat

/mob/living/simple_animal/hostile/retaliate/rogue/goat/goatletboy
	gender = MALE
	rogue_partner_type = null
	rogue_adult_type = /mob/living/simple_animal/hostile/retaliate/rogue/goatmale

/mob/living/simple_animal/hostile/retaliate/rogue/infernal/fiend
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/rogue/infernal/hellhound
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/rogue/infernal/imp
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/rogue/infernal/watcher
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/rogue/saiga/saigaboy
	gender = MALE
	rogue_start_tame = TRUE
	rogue_partner_type = null
	rogue_adult_type = /mob/living/simple_animal/hostile/retaliate/rogue/saiga/saigabuck

/mob/living/simple_animal/hostile/retaliate/rogue/saiga/saigabuck
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/rogue/saiga/saigakid
	rogue_start_tame = TRUE
	rogue_partner_type = null
	rogue_adult_type = /mob/living/simple_animal/hostile/retaliate/rogue/saiga

/mob/living/simple_animal/hostile/retaliate/rogue/saiga/undead
	rogue_tame_chance = 0
	rogue_tame_bonus = 0

/mob/living/simple_animal/hostile/retaliate/rogue/swine/hog
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/rogue/swine/piglet
	rogue_partner_type = null
	rogue_adult_type = /mob/living/simple_animal/hostile/retaliate/rogue/swine

/mob/living/simple_animal/hostile/retaliate/rogue/beetle/tame/saddled
	rogue_start_tame = TRUE

/mob/living/simple_animal/hostile/retaliate/rogue/saiga/saigabuck/tame
	rogue_start_tame = TRUE

/mob/living/simple_animal/hostile/retaliate/rogue/swine/hog/piglet
	rogue_partner_type = null
	rogue_adult_type = /mob/living/simple_animal/hostile/retaliate/rogue/swine/hog

/mob/living/simple_animal/hostile/retaliate/rogue/horse/male/black/tame/saddled
	gender = MALE
	rogue_tame_chance = 15
	rogue_tame_bonus = 15
	rogue_start_tame = TRUE

/mob/living/simple_animal/hostile/retaliate/rogue/horse/male/brown/tame/saddled
	gender = MALE
	rogue_tame_chance = 15
	rogue_tame_bonus = 15
	rogue_start_tame = TRUE

/mob/living/simple_animal/hostile/retaliate/rogue/horse/male/white/tame/saddled
	gender = MALE
	rogue_tame_chance = 15
	rogue_tame_bonus = 15
	rogue_start_tame = TRUE
