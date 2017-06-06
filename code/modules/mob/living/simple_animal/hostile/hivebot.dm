/obj/item/projectile/hivebotbullet
	desc = "A normal looking lead pellet...\n\
	...on closer inspection, you notice that it is perfectly smooth, \
	except for one side, which has a microscopic engraving:\n\n\
	TRANSCRIBED MESSAGE BEGIN:\nHello, this is Dr. Gen. Eric. The general\
	part comes from my time in the war, the 3830th mobile marine squadron,\
	it was. I still remember the day I was in a battle with those nasty \
	Hkulogons.. I was of course, an admiral of the mighty NTSS Forehead, \
	named for its typical position in the formation, which was in the shape \
	of our then-leader Gen. Mo T. Res. On the front lines, I was enjoying my \
	delicious can of Space Cola while at my console, when suddenly, I heard a \
	tremor through the floor.. I could feel it, the enemy closing in. Ready \
	for battle, I told my men to not be afraid, and instead, be strong.. \
	..all the while knowing a great slaughter would take place, for the enemy \
	was the hardest foe we would face during our conquest. I prepared myself \
	for the worst, and plunged into battle. We started off extremely poorly, \
	losing ships left and right. I felt like it was the end.. But then, by \
	some miracle, my forces began to achieve this massive boost to \
	their determination.. They began to drive the enemy forces back! Even \
	though they were severely outnumbered! It still makes me happy when \
	I remember that moment.. We were pushing them back to their motherbase! \
	As we continued the assault to their stronghold, my men just kept \
	getting stronger! Almost like a cheat code, in a way, it was unreal! \
	We went right through their entrance gates, which barely stood a chance \
	against our Ballistic-Bluespace-Bombardment. I half-designed that maneuver, \
	you know.. I got really bored one day while I was being shipped home \
	as a lieutenant, so I started drawing a battle plan on a piece of paper. \
	I had a dumb idea to combine both super cheap explosive rounds with the \
	super expensive but super effective bluespace artillery cannons. \
	So I drew a quick sketch and showed it to my best friend then-Lt. Righ T. Urn. \
	We've known each other since the level 1 education plan. He's a real \
	jokester that one.. One time he took this banana and put a death nettle \
	inside of it, then fed it to one of the clowns, and it died! Haha, he \
	really knew how to make us laugh.. Either way, he took the sketch and \
	turned it into a nice little drawing, giving a tiny bit of input as to \
	which shots should go first.. After it was done, he gave it back to me, \
	and I showed it to our leader.. We had used it a lot since then.. \
	That very technique was what brought us straight to the heart of the \
	enemy. Our final battle was upon us, and we had them totally surrounded... \
	But just as things started looking up for me, everything went black..\
	My game crashed.. No! I was winning, do you know how hard I worked on \
	that save?! I couldn't believe it! I became so enraged that I had failed \
	to notice the grim truth around me, my real crew was being slaughtered \
	right next to me, from right under my nose. The Hkulogons had actually \
	infiltrated the real NTSS Forehead while I was playing the online campaign \
	with Righ and Jac, the other two admirals. Then I was kidnapped by them! I \
	still don't know why! Maybe they wanted me as a prize or something. \
	Either way, rotting away in that cell, I devised a plan to escape. \
	I took some rope I found on the floor of the cell.. Did you know I \
	found out later from a historian, that the rope was an ancient \"treehouse\" \
	line from way back in the 21st century? Legend has it that the treehouse was \
	used by ancient warrior of justice Sarah Jane West in the great war of \
	the banana. I heard that's why we lost all our phallic fruits and vegetables \
	until we found the clown planet, and from there we were gifted new ones by the \
	plant people. But with all that history and significance in the rope, I cut it \
	so I could use it as fake 'dreadlocks', and fooled the guards into thinking I was \
	a time traveler from the 1980s who has come to show everyone rad disco moves man.. \
	With my escape made, I managed to get them to unlock the other prisoners, \
	saying my now-famous tagline 'we need more bodies to make the groove real'. I \
	think they sell that on tshirts now.. Either way, we escaped capture, and I was \
	promoted to my new rank.. Head Assistant Admiral! It wasn't a General yet, \
	but it was a very luxurious position! After I was granted the complimentary \
	10-year leave, and decided to use that time to develop something to \
	finally crush the Hkulogons forever.. I called them The Drop Dudes.. \
	You know, I really liked that name. I started my work, tirelessly fiddling \
	with the design for years and years. One time, I almost burned my lab down, \
	and for some strange reason decided to try and repurpose my work into \
	firefighting robots! The principle was simple, fill a titanium-enforced \
	uranium-plated frame with a radium lined tank underneath a carbon \
	dioxide generator hooked up to a Eric-brand atmospheric generator, \
	powered by the one and only dimonoxide-trinitrate-moonite-\
	goos-wernetite-toluene-chlorite-plasmati-superpowered-\
	overcharged-turbofueled-doublepumped-duorifled-protein engine. \
	It was a complete failure, the robots exploded violently into thousands \
	of tiny pieces, my work was finished... But I tried again, this time \
	not straying from my goal of total Hkulogon extermination. \
	I fitted these robots with a new capability, the hivemind. It would link \
	them together without using radio signals. Stolen from organs of \
	alien origin, they would never lose the connection, no matter where \
	they were! I then decided they should be able to reproduce, in these \
	orbs I totally didn't steal from my scientist colleague.. They would be \
	pieced together part at a time, drawing particles from the air to make \
	the metal needed for their body.. I showed this marvelous achievement to \
	the military technology board.. They loved it! I was instantly promoted to.. \
	General! Finally, I did it, I am a General! Haha, ha... \
	But something went wrong, I decided to TAKE OVER THE UNIVERSE! AHAHAHAHAHAHA! \
	I programmed the now-named 'hivebots' to kill everything \
	in sight.. Absolutely everything! \
	I am recording this message because.. Well, actually.. I just \
	wanted to monologue I guess, nobody's going to hear this.. \
	Wait w-- what are you.. No, you're supposed to kill every thing \
	EXCEPT ME... I... Oh god, the alien organ, it must have.. no.. \
	it must BE a mind of its own.. *bang*\n\
	TRANSCRIBED MESSAGE END"
	damage = 10
	damage_type = BRUTE

/mob/living/simple_animal/hostile/hivebot
	name = "hivebot"
	desc = "A small robot."
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basic"
	gender = NEUTER
	health = 15
	maxHealth = 15
	healable = 0
	melee_damage_lower = 2
	melee_damage_upper = 3
	attacktext = "claws"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	projectilesound = 'sound/weapons/Gunshot.ogg'
	projectiletype = /obj/item/projectile/hivebotbullet
	faction = list("hivebot")
	check_friendly_fire = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speak_emote = list("states")
	gold_core_spawnable = 1
	del_on_death = 1
	loot = list(/obj/effect/decal/cleanable/robot_debris)

/mob/living/simple_animal/hostile/hivebot/Initialize()
	..()
	deathmessage = "[src] blows apart!"

/mob/living/simple_animal/hostile/hivebot/range
	name = "hivebot"
	desc = "A smallish robot, this one is armed!"
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/rapid
	ranged = 1
	rapid = 1
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/strong
	name = "strong hivebot"
	desc = "A robot, this one is armed and looks tough!"
	health = 80
	maxHealth = 80
	ranged = 1

/mob/living/simple_animal/hostile/hivebot/death(gibbed)
	do_sparks(3, TRUE, src)
	..(1)