'''
Created on Dec 12, 2013

@author: Rob
'''
import vgstation.common.config as config
import vgstation.common.plugin as plugins
import vgstation.bot as irc
import logging

def main():
    logging.basicConfig(format='%(asctime)s [%(levelname)-8s]: %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.INFO)
    config.ReadFromDisk()
    for server in config.config['servers']:
        bot = irc.Bot(server,config.config['servers'][server])
        bot.plugins = plugins.Load(bot)
        bot.start()

if __name__ == '__main__':
    main()