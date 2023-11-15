from contextlib import closing
from ..ezdb.changes import get_current_version
from ..ezdb.config import read_config
from ..ezdb.mysql import execute_sql, insert_new_schema_query, open_connection, start_daemon
from ..ezdb.paths import get_initial_schema_path
from .step import Step

class InstallInitialSchema(Step):
    @staticmethod
    def should_run() -> bool:
        start_daemon()

        config = read_config()
        assert config is not None, "No config file found"

        database = config["FEEDBACK_DATABASE"]
        assert database is not None, "No database found in config file"

        with open_connection() as connection:
            with closing(connection.cursor()) as cursor:
                cursor.execute(f"SHOW DATABASES LIKE '{database}'")
                if cursor.fetchone() is None:
                    return True

                cursor.execute(f"USE {database}")
                cursor.execute("SHOW TABLES LIKE 'schema_revision'")
                if cursor.fetchone() is None:
                    return True

                cursor.execute("SELECT * FROM `schema_revision` LIMIT 1")
                if cursor.fetchone() is None:
                    return True

        return False

    @staticmethod
    def run(args):
        print("Installing initial schema...")

        config = read_config()
        assert config is not None, "No config file found"

        with open_connection() as connection:
            with closing(connection.cursor()) as cursor:
                database = config["FEEDBACK_DATABASE"]
                cursor.execute(f"CREATE DATABASE {database}")
                cursor.execute(f"USE {database}")

        (major_version, minor_version) = get_current_version()

        with open(get_initial_schema_path(), 'r') as file:
            schema = file.read()
            execute_sql(schema + ";" + insert_new_schema_query(major_version, minor_version))
