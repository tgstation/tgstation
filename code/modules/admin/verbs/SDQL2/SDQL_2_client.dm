/*
	Welcome admins, badmins and coders alike, to Structured Datum Query Language.
	SDQL allows you to powerfully run code on batches of objects (or single objects, it's still unmatched
	even there.)
	When I say "powerfully" I mean it you're in for a ride.

	Ok so say you want to get a list of every mob. How does one do this?
	"SELECT /mob"
	This will open a list of every object in world that is a /mob.
	And you can VV them if you need.

	What if you want to get every mob on a *specific z-level*?
	"SELECT /mob WHERE z == 4"

	What if you want to select every mob on even numbered z-levels?
	"SELECT /mob WHERE z % 2 == 0"

	Can you see where this is going? You can select objects with an arbitrary expression.
	These expressions can also do variable access and proc calls (yes, both on-object and globals!)
	Keep reading!

	Ok. What if you want to get every machine in the SSmachine process list? Looping through world is kinda
	slow.

	"SELECT * IN SSmachines.machinery"

	Here "*" as type functions as a wildcard.
	We know everything in the global SSmachines.machinery list is a machine.

	You can specify "IN <expression>" to return a list to operate on.
	This can be any list that you can wizard together from global variables and global proc calls.
	Every variable/proc name in the "IN" block is global.
	It can also be a single object, in which case the object is wrapped in a list for you.
	So yeah SDQL is unironically better than VV for complex single-object operations.

	You can of course combine these.
	"SELECT * IN SSmachines.machinery WHERE z == 4"
	"SELECT * IN SSmachines.machinery WHERE stat & 2" // (2 is NOPOWER, can't use defines from SDQL. Sorry!)
	"SELECT * IN SSmachines.machinery WHERE stat & 2 && z == 4"

	The possibilities are endless (just don't crash the server, ok?).

	Oh it gets better.

	You can use "MAP <expression>" to run some code per object and use the result. For example:

	"SELECT /obj/machinery/power/smes MAP [charge / capacity * 100, RCon_tag, src]"

	This will give you a list of all the APCs, their charge AND RCon tag. Useful eh?

	[] being a list here. Yeah you can write out lists directly without > lol lists in VV. Color matrix
	shenanigans inbound.

	After the "MAP" segment is executed, the rest of the query executes as if it's THAT object you just made
	(here the list).
	Yeah, by the way, you can chain these MAP / WHERE things FOREVER!

	"SELECT /mob WHERE client MAP client WHERE holder MAP holder"

	You can also generate a new list on the fly using a selector array. @[] will generate a list of objects based off the selector provided.

	"SELECT /mob/living IN (@[/area/service/bar MAP contents])[1]"

	What if some dumbass admin spawned a bajillion spiders and you need to kill them all?
	Oh yeah you'd rather not delete all the spiders in maintenace. Only that one room the spiders were
	spawned in.

	"DELETE /mob/living/carbon/superior_animal/giant_spider WHERE loc.loc == marked"

	Here I used VV to mark the area they were in, and since loc.loc = area, voila.
	Only the spiders in a specific area are gone.

	Or you know if you want to catch spiders that crawled into lockers too (how even?)

	"DELETE /mob/living/carbon/superior_animal/giant_spider WHERE global.get_area(src) == marked"

	What else can you do?

	Well suppose you'd rather gib those spiders instead of simply flat deleting them...

	"CALL gib() ON /mob/living/carbon/superior_animal/giant_spider WHERE global.get_area(src) == marked"

	Or you can have some fun..

	"CALL forceMove(marked) ON /mob/living/carbon/superior_animal"

	You can also run multiple queries sequentially:

	"CALL forceMove(marked) ON /mob/living/carbon/superior_animal; CALL gib() ON
	/mob/living/carbon/superior_animal"

	And finally, you can directly modify variables on objects.

	"UPDATE /mob WHERE client SET client.color = [0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]"

	Don't crash the server, OK?

	"UPDATE /mob/living/carbon/human/species/monkey SET #null = forceMove(usr.loc)"

	Writing "#null" in front of the "=" will call the proc and discard the return value.

	A quick recommendation: before you run something like a DELETE or another query.. Run it through SELECT
	first.
	You'd rather not gib every player on accident.
	Or crash the server.

	By the way, queries are slow and take a while. Be patient.
	They don't hang the entire server though.

	With great power comes great responsability.

	Here's a slightly more formal quick reference.

	The 4 queries you can do are:

	"SELECT <selectors>"
	"CALL <proc call> ON <selectors>"
	"UPDATE <selectors> SET var=<value>,var2=<value>"
	"DELETE <selectors>"

	"<selectors>" in this context is "<type> [IN <source>] [chain of MAP/WHERE modifiers]"

	"IN" (or "FROM", that works too but it's kinda weird to read),
	is the list of objects to work on. This defaults to world if not provided.
	But doing something like "IN living_mob_list" is quite handy and can optimize your query.
	All names inside the IN block are global scope, so you can do living_mob_list (a global var) easily.
	You can also run it on a single object. Because SDQL is that convenient even for single operations.

	<type> filters out objects of, well, that type easily. "*" is a wildcard and just takes everything in
	the source list.

	And then there's the MAP/WHERE chain.
	These operate on each individual object being ran through the query.
	They're both expressions like IN, but unlike it the expression is scoped *on the object*.
	So if you do "WHERE z == 4", this does "src.z", effectively.
	If you want to access global variables, you can do `global.living_mob_list`.
	Same goes for procs.

	MAP "changes" the object into the result of the expression.
	WHERE "drops" the object if the expression is falsey (0, null or "")

	What can you do inside expressions?

	* Proc calls
	* Variable reads
	* Literals (numbers, strings, type paths, etc...)
	* \ref referencing: {0x30000cc} grabs the object with \ref [0x30000cc]
	* Lists: [a, b, c] or [a: b, c: d]
	* Math and stuff.
	* A few special variables: src (the object currently scoped on), usr (your mob),
		marked (your marked datum), global(global scope)

	TG ADDITIONS START:
	Add USING keyword to the front of the query to use options system
	The defaults aren't necessarily implemented, as there is no need to.
	Available options: (D) means default
	PROCCALL = (D)ASYNC, BLOCKING
	SELECT = FORCE_NULLS, (D)SKIP_NULLS
	PRIORITY = HIGH, (D) NORMAL
	AUTOGC = (D) AUTOGC, KEEP_ALIVE
	SEQUENTIAL = TRUE - The queries in this batch will be executed sequentially one by one not in parallel

	Example: USING PROCCALL = BLOCKING, SELECT = FORCE_NULLS, PRIORITY = HIGH SELECT /mob FROM world WHERE z == 1

*/
/client/proc/admin_SDQL2_query(query_text as message)
	set category = "Debug"
	set name = "SDQL2 Query"

	if(!check_rights(R_DEBUG))  //Shouldn't happen... but just to be safe.
		message_admins(span_danger("ERROR: Non-admin [key_name(usr)] attempted to execute a SDQL query!"))
		usr.log_message("non-admin attempted to execute a SDQL query!", LOG_ADMIN)
		return FALSE
	var/prompt = tgui_alert(usr, "Run SDQL2 Query?", "SDQL2", list("Yes", "Cancel"))
	if (prompt != "Yes")
		return
	SSblackbox.record_feedback("nested tally", "SDQL query", 1, list(ckey, query_text))
	var/list/results = world.SDQL2_query(usr, query_text, key_name_admin(usr), "[key_name(usr)]")
	if(length(results) == 0)
		return

	for(var/message in 1 to 3)
		to_chat(usr, results[message], confidential = TRUE)
