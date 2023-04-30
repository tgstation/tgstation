import argparse

class Step:
    @staticmethod
    def should_run() -> bool:
        raise NotImplementedError()

    @staticmethod
    def run(args: argparse.Namespace):
        raise NotImplementedError()
