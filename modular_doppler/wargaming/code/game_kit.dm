/obj/item/storage/briefcase/secure/wargame_kit
	name = "DIY Wargaming Kit"
	desc = "Contains everything an aspiring naval officer (or just massive nerd) would need for a proper modern naval wargame."
	custom_premium_price = PAYCHECK_CREW * 2

/obj/item/storage/briefcase/secure/wargame_kit/PopulateContents()
	var/static/items_inside = list(
		/obj/item/wargame_projector/ships = 1,
		/obj/item/wargame_projector/ships/red = 1,
		/obj/item/wargame_projector/terrain = 1,
		/obj/item/storage/dice = 1,
		/obj/item/book/manual/wargame_rules = 1,
		/obj/item/book/manual/wargame_rules/examples = 1,
		)
	generate_items_inside(items_inside,src)

/obj/item/book/manual/wargame_rules
	name = "Wargame: Blue Lizard - Example Ruleset"
	icon_state = "book"
	starting_author = "Nanotrasen Naval Wargames Commission"
	starting_title = "Wargame: Blue Lizard - Example Ruleset"
	starting_content = {"
				<head>
				<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				</style>
				</head>
				<body>
				<center>
				<b style='font-size: 12px;'>Official publication of the Nanotrasen Naval Wargames Commission</b>
				<h1>Wargame: Blue Lizard</h1>
				</center>
				<h2>Introduction</h2>
					Wargame: Blue Lizard* is a combination of historically popular wargames,
					and new, widely available hologram technology. The standard kit should contain
					a collection of the following listed items by default, and play may prove difficult
					if any of these items are missing.
					<br>
					<b>Kit items:</b>
						1x of 'terrain' holoprojector <br>
						2x of 'unit' holoprojector <br>
						1x of standard dice set <br>
					<br>
					An example set of rules will be provided further on in this manual, though it
					should be noted that it is not required to follow these rules by the letter, or at
					all. Players are encouraged to make their own rules and play the game as they wish,
					rather than feel limited by the provided set.
				<br>
				<h2>Example Ruleset</h2>
					<b>Players</b>
						By the example rules, the game is built to be played by two or more individuals.
						One player will act as a game master (sometimes referred to as an umpire), whose
						job it will be to direct the game. All other players will be the ones participating
						in the game
						<br>
						The layout of players, or teams, is fully up to the game master. For example,
						a game of two players may see both players on the same team against a non-player
						threat, or it may see them against one another.
					<br>
					<b>Setting Up a Game</b>
						Once the layout of players and teams has been established, the scenario, and what
						vessels each player should have under their control should be determined by the
						game master. What vessels there are, how many there are, what they have on them,
						and the overall scenario is completely up to the game master to decide, and it
						cannot be stated enough that <b>the scenarios do not have to be even, one side
						might have more ships than the other, one side might have more players than the
						other</b>.
						<br>
						As stated, the types of ships that exist and what they are armed with is up to the
						game master, though some examples of ships and scenarios can be found in the
						accompanying book in the standard wargaming set.
					<br>
					<b>Playing the Game</b> <br>
						Typically, the game goes in a turn by turn system. What this actually means is
						again up to the game master. Some examples may be each player going one by one,
						or every player on a team going at once. With each turn, each player's units
						(typically ships) may move, and take another non-movement action <b>each ship,
						each turn</b>.
						<br>
						<b>Commanding Units</b> <br>
							Units should move across the board, and interact with it, through the hands of
							the game master. In order to get a unit to do something that a player commands,
							<b>the player should address the game master as if the game master was the
							one in control of the ship, and give them orders accordingly</b>. From there,
							it is at the game master's discretion to interpret the order and take action.
							<br>
							An example of how this works would be:
							<br>
							Game Master: "We have spotted several enemy vessels, all ships are ready
							for orders." <br>
							Player: "I see... Destroyer, charge the enemy vessels head on, guns blazing!" <br>
							-- The game master interprets this as moving the destroyer its maximum movement range
							straight towards the enemy ships, before moving on to rolling dice for attacking any in
							range (attacking will be covered later on in the rules)
						<br>
						<b>Unit Visibility</b> <br>
							Unit visibility may sound complex at first, but should be fairly simple after
							explanation. In a standard game, if there are two or more teams, they will play
							on separate, but identical boards that have an opaque divider between them.
							<br>
							Note that most standard issue holodecks have a setup including dual boards and divider.
							<br>
							Space 'terrain', including asteroids, space dust, planetoids, gas clouds, and so on, should
							be identical, both in appearance and position, on both halves of the board. The divider
							should be closed before either team's units are placed, so that tactical secrecy may be held,
							and that players may be able to 'hide' ships from one another.
							<br>
							Determining if a ship is visible to either team is up to the game master to decide.
							Typically, however, this should work off of line of sight. An example would be two ships
							with a large asteroid between them. Neither ship can see the other due to the asteroid.
							If one ship were to move out from behind the asteroid and into direct line of sight with
							the other ship, however, both would be able to see each other. It is also possible for a
							situation where two ships might know where each other are, but cannot identify what type
							of ship the other is. An example of this would be gas clouds and thick space dust. In
							this case, the game master can represent the unit as an unidentified ship to the
							corresponding team.
							<br>
							Lastly, visibility can be lost. Taking the two ships and an asteroid example again,
							if the ship goes back behind the asteroid, then obviously neither team will be able to
							see the other ship again. They will, however, still be aware of the general area of the
							enemy.
						<br>
						<b>Attacking and Damage</b> <br>
							Inevitably, ships will come into contact with one another, blows will be exchanged,
							and damage will be sustained.
							<br>
							Typically, attacking other ships is done through one of the following means, though
							do be aware this list is not the end all be all of weapons and game masters may
							create their own.
							<br>
								-- Cannons -- <br>
								Cannons are basic weapons firing projectiles of some kind towards the enemy.
								The range of cannons varies, but typically one or two tile lengths away
								will be the range for accurate fire.
								<br>
								-- Missiles -- <br>
								Missiles are weapons that are usually limited in the number that each ship
								brings into the battle, in exchange for damaging the enemy significantly more
								as well as having a longer range than cannons. Missiles are one of the two
								'weapons' that are unique in how they work, in that if the range to the target
								is more than a single tile's length away, they should appear as an object on the
								board, and should take multiple turns to reach their target.
								<br>
								Missiles are also special in that many weapons fall under their category,
								some of the basic types will be listed below. <br>
									Unguided rockets - These are the most basic type of missile, lacking any
									guidance system at all. If these are fired at a target, and the target moves
									somehow before they impact, the rockets will simply continue on in a straight
									line until either hitting something or being lost into the depths of space.
									<br>
									Seeking missiles - These are missiles that will actively guide themselves
									towards a target, usually designated when launching them. It is possible to
									evade these by hiding behind a large object, or hiding within a debris/
									dust/gas cloud. If these missiles lose tracking, they will simply fly in
									a straight line until impacting something or being lost to deep space.
									<br>
									Seeking torpedoes - These operate similar to seeking missiles in that
									they will guide themselves towards a target. The difference with these is
									that torpedoes will typically do significantly more damage if they impact
									a target, but are significantly slower than missiles in exchange. Again if
									these lose tracking, they will fly in a straight line until impacting
									something or being lost to the void.
								<br>
								-- Strike Craft -- <br>
								Strike craft are an example of a uniquely operating weapon. Typically carried
								into combat by a larger ship of some kind, 'using' this weapon should result
								in either a single, or wing of strike craft being placed alongside the vessel
								that launched them. For all intents and purposes, these strike craft will now
								behave as if they are any other ship, including having their own weapons and
								damage.
								<br>
								Strike craft do operate differently to ships in how they are destroyed. Each
								ship capable of carrying strike craft will enter the battle with a set number
								of 'wings'. These wings will be launched as a whole and will act as one 'vessel'
								on the board. When coming under fire from other ships, dice should be rolled to
								determine how many, if any, of the strike craft are lost. If all of the craft
								in a wing are lost, the wing is destroyed, and the home vessel loses that wing
								forever. If a wing is only partially destroyed, however, it may return to the
								home vessel and spend a full turn repairing to get all its craft back.
							<br>
							Ships taking damage is left up to both rolls of the dice and the discretion of the
							game master. Typically, a D20 will be used for determining if a ship takes damage or
							not.
							<br>
							For a ship to take damage, an attack must roll higher than the ship's 'defensive power'.
							The defensive power of a vessel is a combination of many factors, though some examples
							will be provided below, though ships should all have a defensive power of '5' by default,
							with other factors raising that.
							<br>
								Heavy Armor - If a ship is determined to have heavy armor, usually ships that are
								either large, built for close range combat, or both, then they will gain a bonus to
								their defensive power (usually +5, for a total of 10 default).
								<br>
								Strong Point Defense - If a ship has a strong point defense system, it is able
								to intercept incoming projectiles before impact. In game, this translates to an
								increase in defensive power (usually +5, for a total of 10 with nothing else).
								<br>
								Weak Construction - If a ship is determined to be built fairly weak, usually reserved
								to non-combat ships (perhaps one a fleet is escorting?), then it will have a loss of
								defensive power (usually -5, for a total of 0 default)
							<br>
							These modifiers may be stacked with each other, and custom ones may be created by the game
							master for a given scenario.
							<br>
							If an attack does manage to get through the defenses of a vessel, another dice roll should
							determine what damage the vessel takes, if any. This is also up to the game master's discretion,
							though a table of damage based off of a D20 will be provided below. If a ship takes damage to
							two or more 'critical' systems (power, life support, or structure) then the ship will be
							lost and irrecoverable. Damage can be repaired, however, if a ship sacrifices both its movement
							and second action for a full turn, repairing <b>one</b> major damage of the player's choice.
							<br>
								<b>From a D20</b>
								0 - 5, Only superficial damage was taken, nothing happens <br>
								6 - 7, The ship's engines are disabled, and it will be unable to move until repairs are done <br>
								8 - 10, The ship's weapons are disabled, and it will be unable to attack until repairs are done <br>
								11 - 12, The ship's main reactor fails, both weapons and movement will be disabled until repairs are done <br>
								13 - 16, The ship suffers a disabling breach, and it will be lost if this compounds with another problem <br>
								17 - 20, The ship suffers catastrophic structural damage, and it will be lost if this compounds with another problem <br>
							<br>
							If a ship is lost in combat, then one of two things will happen. If the reactor was damaged
							at the time of the vessel being lost, then it should catastrophically fail and cause
							any ships near it should take damage from the detonation, and the ship itself should be
							removed from the board. If the reactor was not damaged when the vessel was lost, however,
							then the ship's color should be changed to a neutral grey, where it will remain as an empty
							hulk that can be used for cover or concealment by other ships.
						<br>
						<b>Objectives and Victory</b> <br>
							At the start of the match, the game master should assign each team, or player, a specific objective
							that they must complete in order to win. This objective can be something simple like complete
							destruction of the enemy forces. However more complex objectives, like escorting a civilian
							ship to a nearby planet, protecting a station of attack, and so on, are all possible. In the end
							it is up to the game master to come up with a scenario and objectives.
							<br>
							When the game master determines these objectives to be complete, or that some kind of game
							ending condition has been achieved, then they may end the game at will.
						<br>
						*Wargame: Blue Lizard is a copyright protected title under ownership of Nanotrasen
				</body>
				</html>
			"}

/obj/item/book/manual/wargame_rules/examples
	name = "Wargame: Blue Lizard - Example Ships and Scenarios"
	icon_state = "book1"
	starting_author = "Nanotrasen Naval Wargames Commission"
	starting_title = "Wargame: Blue Lizard - Example Ships and Scenarios"
	starting_content = {"
				<head>
				<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<center>
				<b style='font-size: 12px;'>Official publication of the Nanotrasen Naval Wargames Commission</b>
				<h1>Wargame: Blue Lizard</h1>
				</center>
				<h2>Introduction</h2>
					Should you not have read the example ruleset that should have come with this book, then it is
					highly suggested that you read through that first. This publication will contain a list of example
					ships and scenarios for using in games. It should be noted that it is not required to use the
					ships in this book and that making your own with your game master is encouraged.
				<br>
				<h2>Example Ships</h2>
					<b>Nanotrasen</b> <br>
					Nanotrasen's fleet has historically been focused on quick response, especially due to the spread
					of Nanotrasen assets across the galaxy. Their ships are often built to simply get to a location
					fast and, hopefully, scare off anything that's there. This isn't to say that modern vessels are
					incapable of heavy combat, though the vessels in this list will be based upon older, decommissioned
					ship types due to modern designs being classified.
						<br>
						-- Patrol Corvette -- <br>
						A small vessel armed with little more than some cannons, lacking heavy armor and point defense,
						though able to travel quickly due to its relatively small size and weight. <br>
						- Represented by a small ship marker <br>
						- Cannons <br>
						- ~1 tile's length of movement range
						<br>
						-- Torpedo Frigate -- <br>
						Built to handle threats that the patrol corvette couldn't, usually carries some anti ship torpedoes
						into battle.
						- Represented by a medium ship marker <br>
						- 2 Torpedoes <br>
						- Strong point defense <br>
						- ~1 tile's length of movement range
						<br>
						-- Light Carrier -- <br>
						Usually sent with patrols of smaller craft, used as a command and support vessel wherever task force
						cohesion is needed, or just fighter support. <br>
						- Represented by a large ship marker <br>
						- 2 Wings of strike craft, armed with 3 seeking missiles each wing <br>
						- Strong point defense <br>
						- ~1/2 a tile's length of movement range
						<br>
						-- Battlecruiser -- <br>
						The largest commonly fielded ship in Nanotrasen's navy, a fast response vessel with enough guns and
						armor to handle any large threat the fleet comes across, though these ships are a rare sight. <br>
						- Represented by an alternate large ship marker <br>
						- Cannons <br>
						- Heavy armor <br>
						- Strong point defense system <br>
						- ~1/2 a tile's length of movement range
					<br>
					<b>SolFed</b> <br>
					SolFed's navy is possibly the oldest and largest in the known universe, having more experience in
					combat historically than most other navies combined. Nowadays, due to the expanse of SolFed space,
					their patrols are thin stretched across the space they control, large groups of ships a rare sight.
					A side effect of this is that they usually lack smaller combat vessels, favoring larger ships. <br>
						<br>
						-- Flak Frigate -- <br>
						Built special purpose to shoot down the vast numbers of strike craft that were often employed by SolFed's
						enemies in large scale disputes, comes packed with enough point defense to make any carrier captain cry. <br>
						- Represented by a medium ship marker <br>
						- Cannons <br>
						- 4 Seeking missiles <br>
						- Strong point defense <br>
						- ~1 tile's length of movement range
						<br>
						-- Light Cruiser -- <br>
						The mainstay ship of any SolFed fleet, with enough armor and firepower to cruise into the thick of
						any battle and more than likely come out the other side still operational. <br>
						- Represented by a large ship marker <br>
						- Cannons <br>
						- Heavy armor <br>
						- Strong point defense <br>
						- ~1/2 a tile's length of movement range
						<br>
						-- Heavy Carrier -- <br>
						A prohibitively expensive carrier (not like this stops SolFed) that, while rarely fielded, can bring
						more strike craft into battle than any ship known to mankind. <br>
						- Represented by an alternative large ship marker <br>
						- 4 Wings of strike craft, with 3 seeking missiles each wing <br>
						- Strong point defense <br>
						- ~1/2 a tile's length of movement range
					<br>
					<b>NRI</b> <br>
					The NRI's navy has always been at least a contender to SolFed's and Nanotrasen's own, heavily focused on missiles
					with very few ships straying away from that doctrine.
						<br>
						-- Patrol Corvette --
						A common sight in NRI controlled space, with many owned by not only the navy, but also the government's
						police forces. Usually what that means is parking one near unruly stations and outposts, just to remind
						them who owns the space they live in. <br>
						- Represented by a small ship marker <br>
						- Cannons <br>
						- ~1 tile's length of movement range
						<br>
						-- Defense Frigate -- <br>
						Built for the express purpose of ruining the day of any territorial invader, stacked up with the heaviest
						armor of any frigate in the known universe, with weapons to deal back any damage thrown at it. <br>
						- Represented by a medium ship marker <br>
						- Cannons <br>
						- 4 Seeking missiles <br>
						- Heavy armor <br>
						- ~1/2 a tile's length of movement range
						<br>
						-- Missile Destroyer -- <br>
						Missiles? You like missiles don't you? I hope you do, because when NRI naval command demanded more missiles
						on a vessel, their shipyards gave the answer in the form of what is essentially a cargo ship filled to
						the brim with every guided missile they could find. <br>
						- Represented by a large ship marker <br>
						- <b>Bottomless</b> seeking missiles <br>
						- Heavy armor <br>
						- ~1/2 a tile's length of movement range
					<br>
					<b>Mothic Raiders</b>
					Though nowhere near as common as they were in the years since official contact with the Nomad Fleet,
					explorers of humanity's past have been plagued with raids from pirate ships of mothic origin. Though
					not malicious in nature, they would often come in skirmishes with patrol and escort forces on the outer
					rim of SolFed territory, and may still rarely commit to raids against human ships even today.
						<br>
						-- Raider Corvette -- <br>
						The smallest and most common ship in mothic pirate bands, using the Nomad Fleet's prowess in ship
						technology to scream across the stars faster than any vessel humanity could come up with. <br>
						- Represented by a small ship marker <br>
						- Cannons <br>
						- 1 Torpedo <br>
						- ~1 and 1/2 a tile's a movement range
						<br>
						-- Mini Carrier -- <br>
						Often the core of mothic pirate bands, a small vessel usually kept on the backlines of raids,
						capable of carrying a small compliment of strike craft to support them. <br>
						- Represented by a medium ship marker <br>
						- 2 Wings of strike craft, with 3 seeking missiles each wing <br>
						- Strong point defense <br>
						- ~1 tile's movement range
						<br>
						-- Rocket Destroyer -- <br>
						The result of common incidents where a captain will choose to evacuate a cargo vessel before a
						band of mothic raiders boards, leaving the ship fully to the control of the pirates. This will
						often result in them crudely converting the vessel into a warship of some kind. <br>
						- Represented by a large ship marker <br>
						- <b>Bottomless</b> supply of unguided rockets, can be fired twice per turn <br>
						- Weak construction <br>
						- ~1 tile's movement range
					<br>
				<h2>Example Scenarios</h2>
					-- Nanotrasen/NRI Station Skirmish -- <br>
					A Nanotrasen sponsored station located in NRI border territories has violated several regulations
					and laws, and an NRI patrol fleet has been sent to repossess the station. A force of Nanotrasen
					ships jumps in just in time to intercept. <br>
					- Takes place with a Nanotrasen station surrounded by a large asteroid field of some kind between
					where both teams start. <br>
					- Either side will win through complete destruction or surrender of the enemy. <br>
					- The NRI should start with a few more ships, or stronger ships than the NT force, however
					the NT station should have several defensive platforms surrounding it to supplement. <br>
					<br>
					-- NRI/SolFed Border Conflict -- <br>
					Two sizeable fleets from both SolFed, and the NRI meet in disputed space. A battle ensues soon
					after, this fight being only a small part of a larger battle. <br>
					- Takes place in the rings of a nearby planet, large dust fields and asteroids making spotting
					other ships difficult. <br>
					- Either side will win through complete destruction or surrender of the enemy. <br>
					- Both the NRI and SolFed fleets should be about the same size and strength.
					<br>
					-- SolFed/Mothic Raiders Convoy Raid -- <br>
					A convoy of Nanotrasen cargo vessels, escorted by a small patrol force, come under attack by a sizeable
					band of mothic raiders. <br>
					- Takes place in a dense asteroid field <br>
					- NT will win if they destroy the raiders completely <br>
					- The raiders will win if they destroy all of NT's cargo ships <br>
					- NT's fleet should be a small number of combat vessels, escorting 2-3 large cargo ships
					with stats as follows: <br>
						- Weak construction <br>
						- ~1/2 a tile's length of movement range <br>
					- The mothic raider fleet should be larger than NT's
				</body>
				</html>
			"}
