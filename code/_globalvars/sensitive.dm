/datum/sensitive_data
    //Server API key
    var/comms_key = "default_pwd"
    var/comms_allowed = FALSE //By default, the server does not allow messages to be sent to it, unless the key is strong enough (this is to prevent misconfigured servers from becoming vulnerable)

    var/medal_hub
    var/medal_pass = " "
    var/medals_enabled = TRUE	//will be auto set to false if the game fails contacting the medal hub to prevent unneeded calls.

    // MySQL configuration

    var/sqladdress = "localhost"
    var/sqlport = "3306"
    var/sqlfdbkdb = "test"
    var/sqlfdbklogin = "root"
    var/sqlfdbkpass = ""
    var/sqlfdbktableprefix = "erro_"

GLOBAL_REAL(SENSITIVE, /datum/sensitive_data) = new