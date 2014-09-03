mob/living/carbon/proc/dream()
	dreaming = 1
	var/list/dreams = list(
		"an ID card","a bottle","a familiar face","a crewmember","a toolbox","a security officer","the captain",
		"deep space","a doctor","the engine","a traitor","an ally","darkness","light","a scientist","a monkey",
		"a loved one","warmth","the sun","a hat","the Luna","a planet","plasma","air","the medical bay","the bridge",
		"blinking lights","a blue light","Nanotrasen","healing","power","respect","riches","space","happiness","pride",
		"water","melons","flying","the eggs","money","the head of personnel","the head of security","a chief engineer",
		"a research director","a chief medical officer","the detective","the warden","a member of the internal affairs",
		"a station engineer","the janitor","atmospheric technician","the quartermaster","a cargo technician","the botanist",
		"a shaft miner","a psychologist","the chemist","the geneticist","the virologist","the roboticist","the chef","the bartender",
		"the chaplain","the librarian","a mouse","an ert member","a beach","the holodeck","a smokey room","a mouse","the bar",
		"the rain","the ai core","the mining station","the research station","a beaker of strange liquid","a team","a man with a bad haircut",
		"the moons of jupiter","an old malfunctioning AI","a ship full of spiders","bork","a chicken","a supernova","lockers","ninjas",
		"chickens","the oven","euphoria","space god","farting","bones burning","flesh evaporating","distant worlds","skeletons",
		"voices everywhere","death","a traitor","dark allyways","darkness","a catastrophe","a gun","freezing","a ruined station","plasma fires",
		"an abandoned laboratory","The Syndicate","blood","falling","flames","ice","the cold","an operating table","a war","red men","malfunctioning robots",
		"a ship full of spiders","valids","hardcore","your mom","lewd","explosions","broken bones","clowns everywhere","features","a crash","a skrell","a unathi","a tajaran"
		)
	spawn(0)
		for(var/i = rand(1,4),i > 0, i--)
			var/dream_image = pick(dreams)
			dreams -= dream_image
			src << "\blue <i>... [dream_image] ...</i>"
			sleep(rand(40,70))
			if(paralysis <= 0)
				dreaming = 0
				return 0
		dreaming = 0
		return 1

mob/living/carbon/proc/handle_dreams()
	if(prob(5) && !dreaming) dream()

mob/living/carbon/var/dreaming = 0
