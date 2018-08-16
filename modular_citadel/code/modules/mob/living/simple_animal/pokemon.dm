//Sprites are trademarks of Gamefreak, Nintendo, The Pokemon Company, and Spike Chunsoft.
#define ispokemon(A) (istype(A, /mob/living/simple_animal/pokemon))
//POKEBALL
/obj/item/pokeball
	name = "pokeball"
	icon = 'icons/obj/pokeball.dmi'
	icon_state = "pokeball"
	force = 0
	throwforce = 0
	var/success_chance = 25
	var/pokemon
/obj/item/pokeball/great
	name = "great ball"
	icon_state = "pokeball_great"
	success_chance = 50
/obj/item/pokeball/ultra
	icon_state = "pokeball_ultra"
	name = "ultra ball"
	success_chance = 75
/obj/item/pokeball/master
	icon_state = "pokeball_master"
	name = "master ball"
	success_chance = 100
/* //WIP
/obj/item/pokeball/throw_impact(atom/hit_atom)
	if(ispokemon(hit_atom))
		var/mob/living/simple_animal/pokemon/pmon = hit_atom
		var/initial_success_chance = success_chance
		pmon.resize = 0.1
		pmon.color = "RED"
		pmon.canmove = 0
		sleep(15)
		if(pmon.pokeball == src)
			pmon.loc = src
			pokemon = pmon

			return 1
		if(pmon.pokeball && pmon.pokeball !=src)
			return ..()
		var/bonus_chance = ((pmon.maxHealth - pmon.health) / 2)
		if(bonus_chance > 100)
			bonus_chance = 100
		success_chance = (success_chance + bonus_chance)
		if(success_chance > 100)
			success_chance = 100
		if(success_chance < 0)//just in case
			success_chance  = 0
		sleep(15)
		if(prob(success_chance))
			visible_message("<span class='warning'>[src] shakes...</span>")
		else
			escape()
		sleep(15)
		if(prob(success_chance))
			visible_message("<span class='warning'>[src] shakes...</span>")
		else
			escape()
		sleep(15)
		if(prob(success_chance))
			visible_message("<span class='warning'>[src] shakes...</span>")
		else
			escape()
	else
		..()
/obj/item/pokeball/proc/capture(mob/living/simple_animal/pokemon/pmon, mob/living/user)

/obj/item/pokeball/proc/escape(mob/living/simple_animal/pokemon/pmon, mob/living/user)
	if(!pokemon)
		return
	pmon.resize = 10
	pmon.color = null
	pmon.canmove = 1
	pmon.loc = src.loc
	if(pmon.pokeball != src)
		visible_message("<span class='warning'>[pmon] breaks free from [src]</span>")
		PoolOrNew(/obj/effect/particle_effect/sparks, loc)
		playsound(src.loc, "sparks", 50, 1)
		qdel(src)

	else
/obj/item/pokeball/proc/recall
/obj/item/pokeball/proc/release
*/
/mob/living/simple_animal/pokemon
	name = "eevee"
	icon_state = "eevee"
	icon_living = "eevee"
	icon_dead = "eevee_d"
	desc = "Gotta catch 'em all!"
	icon = 'icons/mob/pokemon.dmi'
	var/pokeball
	pixel_x = -16
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 5)
	ventcrawler = 2
	health = 100
	maxHealth = 100
	layer = 4
	response_help = "pets"
	wander = 1
	turns_per_move = 2
	pass_flags = PASSTABLE | PASSMOB

/mob/living/simple_animal/pokemon/proc/simple_lay_down()
	set name = "Rest"
	set category = "IC"

	resting = !resting
	src << "<span class='notice'>You are now [resting ? "resting" : "getting up"].</span>"
	update_canmove()
	update_icon()

/mob/living/simple_animal/pokemon/proc/update_icon()
	if(lying || resting || sleeping)
		icon_state = "[icon_state]_rest"
	else
		icon_state = "[icon_living]"

/mob/living/simple_animal/pokemon/New()
	..()
	verbs += /mob/living/simple_animal/pokemon/proc/simple_lay_down

/*
/////TEMPLATE/////

/mob/living/simple_animal/pokemon/
	name = ""
	icon_state = ""
	icon_living = ""
	icon_dead = ""
*/

/mob/living/simple_animal/pokemon/leg
	icon = 'icons/mob/legendary.dmi'
	pixel_x = -32
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 12)
	health = 200
	maxHealth = 200


/mob/living/simple_animal/pokemon/leg/articuno
	name = "Articuno"
	icon_state = "articuno"
	icon_living = "articuno"
	icon_dead = "articuno_d"
	flying = 1

/mob/living/simple_animal/pokemon/leg/rayquaza
	name = "Rayquaza"
	icon_state = "rayquaza"
	icon_living = "rayquaza"
	icon_dead = "rayquaza_d"
	flying = 1

//ALPHABETICAL PLEASE

/mob/living/simple_animal/pokemon/absol
	name = "absol"
	icon_state = "absol"
	icon_living = "absol"
	icon_dead = "absol_d"
	speak = list("Absol!", "Ab-Absol!")

/mob/living/simple_animal/pokemon/aggron
	name = "aggron"
	icon_state = "aggron"
	icon_living = "aggron"
	icon_dead = "aggron_d"

/mob/living/simple_animal/pokemon/ampharos
	name = "ampharos"
	icon_state = "ampharos"
	icon_living = "ampharos"
	icon_dead = "ampharos_d"

/mob/living/simple_animal/pokemon/charmander
	name = "charmander"
	icon_state = "charmander"
	icon_living = "charmander"
	icon_dead = "charmander_d"

/mob/living/simple_animal/pokemon/ditto
	name = "ditto"
	icon_state = "ditto"
	icon_living = "ditto"
	icon_dead = "ditto_d"

/mob/living/simple_animal/pokemon/dratini/dragonair
	name = "dragonair"
	desc = "A Dragonair stores an enormous amount of energy inside its body. It is said to alter the weather around it by loosing energy from the crystals on its neck and tail."
	icon_state = "dragonair"
	icon_living = "dragonair"
	icon_dead = "dragonair_d"

/mob/living/simple_animal/pokemon/dratini/dragonair/dragonite
	name = "dragonite"
	desc = "It can circle the globe in just 16 hours. It is a kindhearted Pokémon that leads lost and foundering ships in a storm to the safety of land."
	icon_state = "dragonite"
	icon_living = "dragonite"
	icon_dead = "dragonite_d"

/mob/living/simple_animal/pokemon/dratini
	name = "dratini"
	desc = "A Dratini continually molts and sloughs off its old skin. It does so because the life energy within its body steadily builds to reach uncontrollable levels."
	icon_state = "dratini"
	icon_living = "dratini"
	icon_dead = "dratini_d"

/mob/living/simple_animal/pokemon/eevee
	name = "eevee"
	desc = "Eevee has an unstable genetic makeup that suddenly mutates due to its environment. Radiation from various stones causes this Pokémon to evolve."
	icon_state = "eevee"
	icon_living = "eevee"
	icon_dead = "eevee_d"
	speak = list("Eevee!", "Ee-Eevee!")
	response_help  = "pets"
	response_harm   = "hits"

/mob/living/simple_animal/pokemon/eevee/espeon
	name = "espeon"
	desc = "Espeon is extremely loyal to any trainer it considers to be worthy. It is said to have developed precognitive powers to protect its trainer from harm."
	icon_state = "espeon"
	icon_living = "espeon"
	icon_dead = "espeon_d"

/mob/living/simple_animal/pokemon/flaaffy
	name = "flaaffy"
	icon_state = "flaaffy"
	icon_living = "flaaffy"
	icon_dead = "flaaffy_d"

/mob/living/simple_animal/pokemon/eevee/flareon
	name = "flareon"
	desc = "Flareon's fluffy fur releases heat into the air so that its body does not get excessively hot. Its body temperature can rise to a maximum of 1,650 degrees F."
	icon_state = "flareon"
	icon_living = "flareon"
	icon_dead = "flareon_d"
	speak = list("Flare!", "Flareon!")

/mob/living/simple_animal/pokemon/eevee/glaceon
	name = "glaceon"
	desc = "By controlling its body heat, it can freeze the atmosphere around it to make a diamond-dust flurry."
	icon_state = "glaceon"
	icon_living = "glaceon"
	icon_dead = "glaceon_d"
	speak = list("Glace!", "Glaceon!")

/mob/living/simple_animal/pokemon/eevee/jolteon
	name = "jolteon"
	desc = "Its cells generate weak power that is amplified by its fur's static electricity to drop thunderbolts. The bristling fur is made of electrically charged needles."
	icon_state = "jolteon"
	icon_living = "jolteon"
	icon_dead = "jolteon_d"
	speak = list("Jolt!", "Jolteon!")

/mob/living/simple_animal/pokemon/larvitar
	name = "larvitar"
	desc = "It is born deep underground. It can't emerge until it has entirely consumed the soil around it."
	icon_state = "larvitar"
	icon_living = "larvitar"
	icon_dead = "larvitar_d"

/mob/living/simple_animal/pokemon/mareep
	name = "mareep"
	icon_state = "mareep"
	icon_living = "mareep"
	icon_dead = "mareep_d"

/mob/living/simple_animal/pokemon/poochyena/mightyena
	name = "mightyena"
	icon_state = "mightyena"
	icon_living = "mightyena"
	icon_dead = "mightyena"

/mob/living/simple_animal/pokemon/miltank
	name = "miltank"
	icon_state = "miltank"
	icon_living = "miltank"
	icon_dead = "miltank_d"

/mob/living/simple_animal/pokemon/poochyena
	name = "poochyena"
	icon_state = "poochyena"
	icon_living = "poochyena"
	icon_dead = "poochyena_d"

/mob/living/simple_animal/pokemon/eevee/sylveon
	name = "Sylveon"
	desc = "Sylveon, the Intertwining Pokémon. Sylveon affectionately wraps its ribbon-like feelers around its Trainer's arm as they walk together."
	icon_state = "sylveon"
	icon_living = "sylveon"
	icon_dead = "sylveon_d"
	speak = list("Sylveon!", "Syl!")
	response_help  = "pets"
	response_harm   = "hits"

/mob/living/simple_animal/pokemon/eevee/umbreon
	name = "umbreon"
	icon_state = "umbreon"
	icon_dead = "umbreon_d"
	icon_living = "umbreon"

/mob/living/simple_animal/pokemon/vulpix
	name = "vulpix"
	icon_state = "vulpix"
	icon_living = "vulpix"
	icon_dead = "vulpix_d"
