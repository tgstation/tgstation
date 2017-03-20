	// MySQL configuration

GLOBAL_VAR_INIT(sqladdress, "localhost")
GLOBAL_VAR_INIT(sqlport, "3306")
GLOBAL_VAR_INIT(sqlfdbkdb, "test")
GLOBAL_VAR_INIT(sqlfdbklogin, "root")
GLOBAL_VAR_INIT(sqlfdbkpass, "")
GLOBAL_VAR_INIT(sqlfdbktableprefix, "erro_") //backwords compatibility with downstream server hosts

//Database connections
//A connection is established on world creation. Ideally, the connection dies when the server restarts (After feedback logging.).
GLOBAL_DATUM_INIT(dbcon, /DBConnection, new)	//Feedback database (New database)
