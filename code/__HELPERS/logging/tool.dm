/// Logging for tool usage
/proc/log_tool(text, mob/initiator)
	if(CONFIG_GET(flag/log_tools))
		WRITE_LOG(GLOB.world_tool_log, "TOOL: [text]")
