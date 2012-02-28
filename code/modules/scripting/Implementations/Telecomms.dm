
/* --- Traffic Control Scripting Language --- */
	// Nanotrasen TCS Language - Made by Doohl

/n_Interpreter/TCS_Interpreter
	var/datum/TCS_Compiler/Compiler

	HandleError(runtimeError/e)
		Compiler.Holder.add_entry(e.ToString(), "Execution Error")

/datum/TCS_Compiler
	var/n_Interpreter/TCS_Interpreter/interpreter
	var/obj/machinery/telecomms/server/Holder	// the server that is running the code
	var/ready = 1 // 1 if ready to run code

	/* -- Compile a raw block of text -- */

	proc/Compile(code as message)
		var
			n_scriptOptions/nS_Options/options = new()
			n_Scanner/nS_Scanner/scanner       = new(code, options)
			list/tokens                        = scanner.Scan()
			n_Parser/nS_Parser/parser          = new(tokens, options)
			node/BlockDefinition/GlobalBlock/program   	 = parser.Parse()

			list/returnerrors = list()

		returnerrors += scanner.errors
		returnerrors += parser.errors

		if(returnerrors.len)
			return returnerrors

		interpreter 		= new(program)
		interpreter.persist	= 1
		interpreter.Compiler= src

		// Set up all the preprocessor bullshit
		//TCS_Setup(program)
		// Apply preprocessor global variables
		program.SetVar("PI"		, 	3.141592653)	// value of pi
		program.SetVar("E" 		, 	2.718281828)	// value of e
		program.SetVar("SQURT2" , 	1.414213562)	// value of the square root of 2
		program.SetVar("FALSE"  , 	0)				// boolean shortcut to 0
		program.SetVar("TRUE"	,	1)				// boolean shortcut to 1

		program.SetVar("NORTH" 	, 	NORTH)			// NORTH (1)
		program.SetVar("SOUTH" 	, 	SOUTH)			// SOUTH (2)
		program.SetVar("EAST" 	, 	EAST)			// EAST  (4)
		program.SetVar("WEST" 	, 	WEST)			// WEST  (8)

		program.SetVar("HONK"	, 	"clown griff u")
		program.SetVar("CODERS" ,	"hide the fun")
		program.SetVar("GRIFF"	,	pick("HALP IM BEING GRIFFED", "HALP AI IS MALF", "HALP GRIFFE", "HALP TRAITORS", "HALP WIZ GRIEFE ME"))


		return returnerrors

	/* -- Execute the compiled code -- */

	proc/Run(var/datum/signal/signal)

		if(!ready)
			return

		interpreter.SetVar("$content", 	signal.data["message"])
		interpreter.SetVar("$freq"   , 	signal.frequency)
		interpreter.SetVar("$source" , 	signal.data["name"])
		interpreter.SetVar("$job"    , 	signal.data["job"])
		interpreter.SetVar("$sign"   ,	signal)
		interpreter.SetVar("$pass"	 ,  !(signal.data["reject"])) // if the signal isn't rejected, pass = 1; if the signal IS rejected, pass = 0

		// Set up the script procs

		/*
			-> Send another signal to a server
					@format: broadcast(content, frequency, source, job)

					@param content:		Message to broadcast
					@param frequency:	Frequency to broadcast to
					@param source:		The name of the source you wish to imitate. Must be stored in stored_names list.
					@param job:			The name of the job.
		*/
		interpreter.SetProc("broadcast", "tcombroadcast", signal, list("message", "freq", "source", "job"))

		/*
			-> Store a value permanently to the server machine (not the actual game hosting machine, the ingame machine)
					@format: mem(address, value)

					@param address:		The memory address (string index) to store a value to
					@param value:		The value to store to the memory address
		*/
		interpreter.SetProc("mem", "mem", signal, list("address", "value"))

		/*
			-> Delay code for a given amount of deciseconds
					@format: sleep(time)

					@param time: 		time to sleep in deciseconds (1/10th second)
		*/
		interpreter.SetProc("sleep", /proc/delay)

		/*
			-> Replaces a string with another string
					@format: replace(string, substring, replacestring)

					@param string: 			the string to search for substrings (best used with $content$ constant)
					@param substring: 		the substring to search for
					@param replacestring: 	the string to replace the substring with

		*/
		interpreter.SetProc("replace", /proc/dd_replacetext)

		/*
			-> Locates an element/substring inside of a list or string
					@format: find(haystack, needle, start = 1, end = 0)

					@param haystack:	the container to search
					@param needle:		the element to search for
					@param start:		the position to start in
					@param end:			the position to end in

		*/
		interpreter.SetProc("find", /proc/smartfind)

		/*
			-> Finds the length of a string or list
					@format: length(container)

					@param container: the list or container to measure

		*/
		interpreter.SetProc("length", /proc/smartfind)

		/* -- Clone functions, carried from default BYOND procs --- */

		// vector namespace
		interpreter.SetProc("vector", /proc/n_list)
		interpreter.SetProc("at", /proc/n_listpos)
		interpreter.SetProc("copy", /proc/n_listcopy)
		interpreter.SetProc("push_back", /proc/n_listadd)
		interpreter.SetProc("remove", /proc/n_listremove)
		interpreter.SetProc("cut", /proc/n_listcut)
		interpreter.SetProc("swap", /proc/n_listswap)
		interpreter.SetProc("insert", /proc/n_listinsert)

		interpreter.SetProc("pick", /proc/n_pick)
		interpreter.SetProc("prob", /proc/prob_chance)
		interpreter.SetProc("substr", /proc/docopytext)



		// Run the compiled code
		interpreter.Run()

		// Backwards-apply variables onto signal data
		/* html_encode() EVERYTHING. fucking players can't be trusted with SHIT */

		signal.data["message"] 	= html_encode(interpreter.GetVar("$content"))
		signal.frequency 		= interpreter.GetVar("$freq")

		var/setname = ""
		var/obj/machinery/telecomms/server/S = signal.data["server"]
		if(interpreter.GetVar("$source") in S.stored_names)
			setname = html_encode(interpreter.GetVar("$source"))
		else
			setname = "<i>[html_encode(interpreter.GetVar("$source"))]</i>"

		if(signal.data["name"] != setname)
			signal.data["realname"] = setname
		signal.data["name"]		= setname
		signal.data["job"]		= html_encode(interpreter.GetVar("$job"))
		signal.data["reject"]	= !(interpreter.GetVar("$pass")) // set reject to the opposite of $pass

/*  -- Actual language proc code --  */

datum/signal

	proc/mem(var/address, var/value)

		if(istext(address))
			var/obj/machinery/telecomms/server/S = data["server"]

			if(!value)
				return S.memory[address]

			else
				S.memory[address] = value


	proc/tcombroadcast(var/message, var/freq, var/source, var/job)

		var/mob/living/carbon/human/H = new
		var/datum/signal/newsign = new
		var/obj/machinery/telecomms/server/S = data["server"]
		var/obj/item/device/radio/hradio

		if(!message)
			message = "*beep*"
		if(!source)
			source = "[html_encode(uppertext(S.id))]"
			hradio = new // sets the hradio as a radio intercom
		if(!freq)
			freq = 1459
		if(!job)
			job = "None"

		newsign.data["mob"] = H
		newsign.data["mobtype"] = H.type
		if(source in S.stored_names)
			newsign.data["name"] = source
		else
			newsign.data["name"] = "<i>[html_encode(uppertext(source))]<i>"
		newsign.data["realname"] = newsign.data["name"]
		newsign.data["job"] = html_encode(job)
		newsign.data["compression"] = 0
		newsign.data["message"] = html_encode(message)
		newsign.data["type"] = 2 // artificial broadcast
		if(!isnum(freq))
			freq = text2num(freq)
		newsign.frequency = freq

		var/datum/radio_frequency/connection = radio_controller.return_frequency(freq)
		newsign.data["connection"] = connection

		// The radio is a radio headset!

		if(!hradio)
			hradio = new /obj/item/device/radio/headset

		newsign.data["radio"] = hradio
		newsign.data["vmessage"] = H.voice_message
		newsign.data["vname"] = H.voice_name
		newsign.data["vmask"] = 0
		S.relay_information(newsign, "/obj/machinery/telecomms/broadcaster") // send this simple message to broadcasters
