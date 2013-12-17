	// MySQL configuration

var/sqladdress = "localhost"
var/sqlport = "3306"
var/sqlfdbkdb = "test"
var/sqlfdbklogin = "root"
var/sqlfdbkpass = ""

//Database connections
//A connection is established on world creation. Ideally, the connection dies when the server restarts (After feedback logging.).
var/DBConnection/dbcon = new()	//Feedback database (New database)
