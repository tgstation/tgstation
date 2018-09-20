/world/TgsNew(datum/tgs_event_handler/event_handler, minimum_required_security_level = TGS_SECURITY_ULTRASAFE)
	var/current_api = TGS_READ_GLOBAL(tgs)
	if(current_api)
		TGS_ERROR_LOG("TgsNew(): TGS API datum already set ([current_api])!")
		return

	var/tgs_version = world.params[TGS_VERSION_PARAMETER]
	if(!tgs_version)
		return

	var/path = SelectTgsApi(tgs_version)
	if(!path)
		TGS_ERROR_LOG("Found unsupported API version: [tgs_version]. If this is a valid version please report this, backporting is done on demand.")
		return

	TGS_INFO_LOG("Activating API for version [tgs_version]")
	var/datum/tgs_api/new_api = new path

	TGS_WRITE_GLOBAL(tgs, new_api)

	var/result = new_api.OnWorldNew(event_handler ? event_handler : new /datum/tgs_event_handler/tgs_default, minimum_required_security_level)
	if(!result || result == TGS_UNIMPLEMENTED)
		TGS_WRITE_GLOBAL(tgs, null)
		TGS_ERROR_LOG("Failed to activate API!")

/world/proc/SelectTgsApi(tgs_version)
	//remove the old 3.0 header
	tgs_version = replacetext(tgs_version, "/tg/station 13 Server v", "")
  
	var/list/version_bits = splittext(tgs_version, ".")

	var/super = text2num(version_bits[1])
	var/major = text2num(version_bits[2])
	var/minor = text2num(version_bits[3])
	var/patch = text2num(version_bits[4])

	switch(super)
		if(3)
			switch(major)
				if(2)
					return /datum/tgs_api/v3210
		if(4)
			switch(major)
				if(0)
					return /datum/tgs_api/v4

	if(super != null && major != null && minor != null && patch != null && tgs_version > TgsMaximumAPIVersion())
		TGS_ERROR_LOG("Detected unknown API version! Defaulting to latest. Update the DMAPI to fix this problem.")
		return /datum/tgs_api/latest

/world/TgsMaximumAPIVersion()
	return "4.0.0.0"

/world/TgsMinimumAPIVersion()
	return "3.2.0.0"

/world/TgsInitializationComplete()
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		api.OnInitializationComplete()

/world/proc/TgsTopic(T)
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		var/result = api.OnTopic(T)
		if(result != TGS_UNIMPLEMENTED)
			return result

/world/TgsRevision()
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		var/result = api.Revision()
		if(result != TGS_UNIMPLEMENTED)
			return result

/world/TgsReboot()
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		api.OnReboot()

/world/TgsAvailable()
	return TGS_READ_GLOBAL(tgs) != null

/world/TgsVersion()
	return world.params[TGS_VERSION_PARAMETER]

/world/TgsInstanceName()
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		var/result = api.InstanceName()
		if(result != TGS_UNIMPLEMENTED)
			return result

/world/TgsTestMerges()
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		var/result = api.TestMerges()
		if(result != TGS_UNIMPLEMENTED)
			return result
	return list()

/world/TgsEndProcess()
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		api.EndProcess()

/world/TgsChatChannelInfo()
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		var/result = api.ChatChannelInfo()
		if(result != TGS_UNIMPLEMENTED)
			return result
	return list()

/world/TgsChatBroadcast(message, list/channels)
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		api.ChatBroadcast(message, channels)

/world/TgsTargetedChatBroadcast(message, admin_only)
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		api.ChatTargetedBroadcast(message, admin_only)

/world/TgsChatPrivateMessage(message, datum/tgs_chat_user/user)
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		api.ChatPrivateMessage(message, user)

/world/TgsSecurityLevel()
	var/datum/tgs_api/api = TGS_READ_GLOBAL(tgs)
	if(api)
		api.SecurityLevel()

/*
The MIT License

Copyright (c) 2017 Jordan Brown

Permission is hereby granted, free of charge,
to any person obtaining a copy of this software and
associated documentation files (the "Software"), to
deal in the Software without restriction, including
without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom
the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice
shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
