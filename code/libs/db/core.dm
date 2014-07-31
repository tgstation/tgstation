var/const
	DB_SERVER = "localhost" // This is the location of your MySQL server (localhost is USUALLY fine)
	DB_PORT = 3306 			// This is the port your MySQL server is running on (3306 is the default)

DBConnection
	var
		_db_con 		// This variable contains a reference to the actual database connection.
		dbi 			// This variable is a string containing the DBI MySQL requires.
		user 			// This variable contains the username data.
		password 		// This variable contains the password data.
		default_cursor  // This contains the default database cursor data.
		server = DB_SERVER // "localhost"
		port = DB_PORT // 3306

	New(dbi_handler,username,password_handler,cursor_handler)
		src.dbi = dbi_handler
		src.user = username
		src.password = password_handler
		src.default_cursor = cursor_handler
		_db_con = _dm_db_new_con()

	proc
		Connect(dbi_handler=src.dbi,user_handler=src.user,password_handler=src.password,cursor_handler)
			if(!src) return 0
			cursor_handler = src.default_cursor
			if(!cursor_handler) cursor_handler = Default_Cursor
			return _dm_db_connect(_db_con,dbi_handler,user_handler,password_handler,cursor_handler,null)

		Disconnect() return _dm_db_close(_db_con)

		IsConnected() return _dm_db_is_connected(_db_con)

		Quote(str) return _dm_db_quote(_db_con,str)

		ErrorMsg() return _dm_db_error_msg(_db_con)

		SelectDB(database_name,dbi)
			if(IsConnected()) Disconnect()
			return Connect("[dbi?"[dbi]":"dbi:mysql:[database_name]:[DB_SERVER]:[DB_PORT]"]",user,password)

		NewQuery(sql_query,cursor_handler=src.default_cursor) return new/DBQuery(sql_query,src,cursor_handler)


DBQuery
	var
		sql 			// The sql query being executed.
		default_cursor
		list/columns 	// list of DB Columns populated by Columns()
		list/conversions
		list/item[0]  	// list of data values populated by NextRow()

		DBConnection/db_connection
		_db_query

	New(sql_query,DBConnection/connection_handler,cursor_handler)
		if(sql_query) src.sql = sql_query
		if(connection_handler) src.db_connection = connection_handler
		if(cursor_handler) src.default_cursor = cursor_handler
		_db_query = _dm_db_new_query()
		return ..()

	proc

		Connect(DBConnection/connection_handler) src.db_connection = connection_handler

		Execute(sql_query=src.sql,cursor_handler=default_cursor)
			Close()
			return _dm_db_execute(_db_query,sql_query,db_connection._db_con,cursor_handler,null)

		NextRow() return _dm_db_next_row(_db_query,item,conversions)

		RowsAffected() return _dm_db_rows_affected(_db_query)

		RowCount() return _dm_db_row_count(_db_query)

		ErrorMsg() return _dm_db_error_msg(_db_query)

		Columns()
			if(!columns)
				columns = _dm_db_columns(_db_query,/DBColumn)
			return columns

		GetRowData()
			var/list/columns = Columns()
			var/list/results
			if(columns.len)
				results = list()
				for(var/C in columns)
					results+=C
					var/DBColumn/cur_col = columns[C]
					results[C] = src.item[(cur_col.position+1)]
			return results

		Close()
			item.len = 0
			columns = null
			conversions = null
			return _dm_db_close(_db_query)

		Quote(str)
			return db_connection.Quote(str)

	/*	SetConversion(column,conversion)
			// This doesn't seem to be doing anything internally...
			if(istext(column)) column = columns.Find(column)
			if(!conversions) conversions = new/list(column)
			else if(conversions.len < column) conversions.len = column
			conversions[column] = conversion*/

DBColumn
	var
		name
		table
		position // 1-based index into item data
		sql_type
		flags
		length
		max_length

	New(name_handler,table_handler,position_handler,type_handler,flag_handler,length_handler,max_length_handler)
		src.name = name_handler
		src.table = table_handler
		src.position = position_handler
		src.sql_type = type_handler
		src.flags = flag_handler
		src.length = length_handler
		src.max_length = max_length_handler
		return ..()

	proc
		SqlTypeName(type_handler=src.sql_type)
			switch(type_handler)
				if(TINYINT) return "TINYINT"
				if(SMALLINT) return "SMALLINT"
				if(MEDIUMINT) return "MEDIUMINT"
				if(INTEGER) return "INTEGER"
				if(BIGINT) return "BIGINT"
				if(FLOAT) return "FLOAT"
				if(DOUBLE) return "DOUBLE"
				if(DATE) return "DATE"
				if(DATETIME) return "DATETIME"
				if(TIMESTAMP) return "TIMESTAMP"
				if(TIME) return "TIME"
				if(STRING) return "STRING"
				if(BLOB) return "BLOB"