from .download_mariadb import DownloadMariaDB
from .install_database import InstallDatabase
from .install_initial_schema import InstallInitialSchema
from .update_schema import UpdateSchema

STEPS = [
    DownloadMariaDB,
    InstallDatabase,
    InstallInitialSchema,
    UpdateSchema,
]
