from typing import Optional

"""Linting error with associated filename and line number."""
class MaplintError(Exception):
    """The DMM file name the exception occurred in"""
    file_name = "unknown"

    """The line the error occurred on"""
    line_number = 1

    """The optional coordinates"""
    coordinates: Optional[str] = None

    """The optional pop ID"""
    pop_id: Optional[str] = None

    """The optional help message"""
    help: Optional[str] = None

    def __init__(self, message: str, file_name: str, line_number = 1):
        Exception.__init__(self, message)

        self.file_name = file_name
        self.line_number = line_number

"""A parsing error that must be upgrading to a linting error by parse()."""
class MapParseError(Exception):
    pass
