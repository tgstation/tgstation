'''
Created on Dec 12, 2013

@author: Rob
'''
import vgstation.common.config as config
import vgstation.common.plugin as plugins
import vgstation.bot as irc
import logging, time

def main():
    logging.basicConfig(format='%(asctime)s [%(levelname)-8s]: %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.INFO)
    config.ReadFromDisk()
    for server in config.config['servers']:
        while True:
            try:
                bot = irc.Bot(server,config.config['servers'][server])
                bot.plugins = plugins.Load(bot)
                bot.start()
            except Exception as e:
                logging.critical(str(e))
                logging.info('Waiting 10 seconds before reconnecting...')
                time.sleep(10)

if __name__ == '__main__':
    main()