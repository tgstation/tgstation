//#define DISABLE_AWAYMISSIONS_ON_ROUNDSTART

var/list/datum/map_element/away_mission/existing_away_missions = list()

var/list/awaydestinations = list() //List of landmarks
/obj/effect/landmark/awaystart
	name = "awaystart"
/*
There are two ways to add an away mission to the game

 A) Add the map file's location to maps/RandomZLevels/fileList.txt
 B) Create a subtype of /datum/map_element/away_mission and set its file_path to the map file's location (see below)

First method sucks

Second method lets you use the initialize() proc to interact with the away mission after it has loaded (for example generate map elements, create shuttles, etc).
It also lets you write a description for the away mission, as well as many other things

Example of the second method:

/datum/map_element/away_mission/my_shit
	file_path = "maps/RandomZLevels/fresh_dump.dmm"
	desc = "This stinks"

****READ THIS****
  Because a z-level is 500x500 in size, loading an away mission creates 250,000 new turfs - in addition to any additonal mobs and objects.

  If your away mission is smaller than 500x500, its northern and eastern borders will be surrounded with space turfs. Unless you're fine with this, you
 should secure these borders with an indestructible wall (insert a trump meme here) so that nobody can get out


*/

/datum/map_element/away_mission
	type_abbreviation = "AM"
	var/generate_randomly = 1 //If 0, don't generate this away mission randomly

	var/datum/zLevel/zLevel

/datum/map_element/away_mission/initialize(list/objects) //objects: list of all atoms in the away mission. This proc is called after the away mission is loaded
	..()

	existing_away_missions.Add(src)

	var/z = location ? location.z : world.maxz //z coordinate

	for(var/turf/T in block(locate(1,1,z), locate(world.maxx, world.maxy, z)))
		turfs.Add(T)

	if(accessable_z_levels.len >= z)
		zLevel = accessable_z_levels[z]

	for(var/obj/effect/landmark/L in objects) //Add all landmarks to away destinations. Also set the away mission's location for admins to jump to
		if(L.name != "awaystart") continue

		awaydestinations.Add(L)

		if(!location)
			location = get_turf(L)

	for(var/obj/machinery/gateway/G in objects)
		G.initialize()

/datum/map_element/away_mission/empty_space
	name = "empty space"
	file_path = "maps/RandomZLevels/space.dmm" //1x1 space tile. It changes its size according to the map's dimensions
	generate_randomly = 0

/datum/map_element/away_mission/empty_space/New()
	..()
	desc = "[world.maxx]x[world.maxy] tiles of pure space. No structures, no humans, absolutely nothing. Not even a gateway - you'll have to spawn one yourself."

/datum/map_element/away_mission/arcticwaste
	name = "arctic waste"
	file_path = "maps/RandomZLevels/arcticwaste.dmm"
	desc = "A frozen wasteland with an underground bunker. Features a gateway."

/datum/map_element/away_mission/assistantchamber
	name = "assistant chamber"
	file_path = "maps/RandomZLevels/assistantChamber.dmm"
	desc = "A tiny unbreachable room full of angry turrets and loot."
	generate_randomly = 0

/datum/map_element/away_mission/challenge
	name = "emitter hell"
	file_path = "maps/RandomZLevels/unused/challenge.dmm"
	desc = "A long hallway featuring emitters, turrets and syndicate agents. Features loot and a gateway."

/datum/map_element/away_mission/spaceship
	name = "stranded spaceship"
	file_path = "maps/RandomZLevels/unused/blackmarketpackers.dmm"
	desc = "A mysteriously empty shuttle crashed into the asteroid."

/datum/map_element/away_mission/academy
	name = "academy"
	file_path = "maps/RandomZLevels/unused/Academy.dmm"

/datum/map_element/away_mission/beach
	name = "beach"
	file_path = "maps/RandomZLevels/unused/beach.dmm"
	desc = "A small, comfy seaside area with a bar."
	generate_randomly = 0

/datum/map_element/away_mission/listeningpost
	name = "listening post"
	file_path = "maps/RandomZLevels/unused/listeningpost.dmm"
	desc = "A large asteroid with a hidden syndicate listening post. Don't forget to bring pickaxes!"

/datum/map_element/away_mission/stationcollision
	name = "station collision"
	file_path = "maps/RandomZLevels/unused/stationCollision.dmm"
	desc = "A shuttlecraft crashed into a small space station, bringing aboard aliens and cultists. Features the Lord Nar-Sie himself."

/datum/map_element/away_mission/wildwest
	name = "wild west"
	file_path = "maps/RandomZLevels/unused/wildwest.dmm"
	desc = "An exciting adventure for the toughest adventures your station can offer. Those who defeat all of the final area's guardians will find a wish granter."

/datum/map_element/away_mission/tomb
	name = "tomb of Rafid"
	file_path = "maps/RandomZLevels/tomb.dmm"
	desc = "On a distant planet, an ancient civilization built a great pyramid to bury their leader. After a team of archaeologists disappeared while attempting to unlock the tomb, a gateway was set up and a rescue team requested."

var/static/list/away_mission_subtypes = typesof(/datum/map_element/away_mission) - /datum/map_element/away_mission

//Returns a list containing /datum/map_element/away_mission objects.
/proc/getRandomZlevels(include_unrandom = 0)
	var/list/potentialRandomZlevels = away_mission_subtypes.Copy()
	for(var/T in potentialRandomZlevels) //Fill the list with away mission datums (because currently it only contains paths)
		potentialRandomZlevels.Add(new T)
		potentialRandomZlevels.Remove(T)

	var/list/Lines = file2list("maps/RandomZLevels/fileList.txt")
	if(!Lines.len)	return
	for (var/t in Lines)
		if (!t)
			continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
	//	var/value = null

		if (pos)
            // No, don't do lowertext here, that breaks paths on linux
			name = copytext(t, 1, pos)
		//	value = copytext(t, pos + 1)
		else
            // No, don't do lowertext here, that breaks paths on linux
			name = t

		if (!name)
			continue

		if(!isfile(name))
			warning("fileList.txt contains a map that does not exist: [name]")
			continue

		var/datum/map_element/away_mission/AM = new /datum/map_element/away_mission
		AM.file_path = name

		potentialRandomZlevels.Add(AM)

	if(!include_unrandom)
		for(var/datum/map_element/away_mission/AM in potentialRandomZlevels)
			if(!AM.generate_randomly) potentialRandomZlevels.Remove(AM)

	return potentialRandomZlevels

/proc/createRandomZlevel(override = 0, var/datum/map_element/away_mission/AM, var/messages = null)
	if(!messages) messages = world

	if(existing_away_missions.len && !override)	//crude, but it saves another var!
		return

	if(!AM) //If we were provided an away mission datum, don't generate the list of away missions
		to_chat(messages, "<span class='danger'>Searching for away missions...</span>")
		var/list/potentialRandomZlevels = getRandomZlevels()

		if(!potentialRandomZlevels.len)
			return

		AM = pick(potentialRandomZlevels)
		to_chat(messages, "<span class='danger'>[potentialRandomZlevels.len] away missions found. Loading...</span>")
	else
		to_chat(messages, "<span class='danger'>Loading an away mission...</span>")

	log_game("Loading away mission [AM.file_path]")

	if(AM.load())
		to_chat(messages, "<span class='danger'>Away mission loaded.</span>")
		return

	to_chat(messages, "<span class='danger'>Failed to load away mission [AM.file_path] (file doesn't exist).</span>")
