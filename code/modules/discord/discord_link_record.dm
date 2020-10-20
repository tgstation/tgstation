/// Represents a record from the discord link table in a nicer format
/datum/discord_link_record
	var/ckey
	var/discord_id
	var/one_time_token
	var/timestamp

/**
  * Generate a discord link datum from the values
  *
  * This is only used by SSdiscord wrapper functions for now, so you can reference the fields
  * slightly easier
  *
  * Arguments:
  * * ckey Ckey as a string
  * * discord_id Discord id as a string
  * * one_time_token as a string
  * * timestamp as a string
  */
/datum/discord_link_record/New(ckey, discord_id, one_time_token, timestamp)
	src.ckey = ckey
	src.discord_id = discord_id
	src.one_time_token = one_time_token
	src.timestamp = timestamp
