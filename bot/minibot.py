#!/usr/bin/env python3
# This bot was made by tkdrg.
# Ask #coderbus@irc.rizon.net if this breaks.
# See LICENSE-bot_folder.txt for the license of the files in this folder.
from config import *
import collections
import json
import time
import pickle
import socket
import sys
import threading
import logging

logging.basicConfig(level=logging.INFO)
global irc


def print_err(msg):
	logging.error(msg)


def parse_sender(v):
	end = v.find('!')
	return v[1:end]


def load_memos():
	try:
		f = open('memos.json', 'r')
		memos = json.load(f)
	except FileNotFoundError:
		memos = dict()
		for channel in channels:
			memos[channel] = dict()
	return memos


def flush_memos(memos):
	f = open('memos.json', 'w')
	json.dump(memos, f)
	f.close()


def setup_irc_socket():
	s = socket.socket()
	s.settimeout(240)

	while 1:
		try:
			s.connect((server, port))
		except socket.error:
			print_err("Unable to connect to server {0}:{1}, attempting to reconnect in 20 seconds.".format(server, port))
			time.sleep(20)
		else:
			print_err("Connection established to server {0}:{1}.".format(server, port))
			break

	s.send(bytes("NICK {0}\r\n".format(nick), "UTF-8"))
	s.send(bytes("USER {0} {1} {2} :{3}\r\n".format(ident, server, name, realname), "UTF-8"))
	return s


def setup_nudge_socket():
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	s.bind(("", 45678))  # localhost:45678
	s.listen(5)
	return s


def nudge_handler():
	global irc
	nudge = setup_nudge_socket()
	message_queue = collections.deque()
	while 1:
		if len(message_queue):
			message = message_queue.popleft()
		else:
			try:
				s, ip = nudge.accept()
			except:
				print_err("Nudge socket lost, attempting to reopen.")
				nudge = setup_nudge_socket()
				continue
			rawdata = s.recv(1024)
			s.close()
			data = pickle.loads(rawdata)
			logging.info(data)
			if data["ip"][0] == "#":
				message = "{0} :AUTOMATIC ANNOUNCEMENT : {1}\r\n".format(data["ip"], str(" ".join(data["data"])))
			else:
				message = "{0} :AUTOMATIC ANNOUNCEMENT : {1} | {2}\r\n".format(defaultchannel, data["ip"], str(" ".join(data["data"])))
		try:
			irc.send(bytes("PRIVMSG {0}".format(message), "UTF-8"))
		except:
			print_err("Nudge received without IRC socket, appending to queue.")
			print_err("Message: {0}".format(message))
			message_queue.append(message)


def irc_handler():
	global irc
	memos = load_memos()
	while 1:
		try:
			buf = irc.recv(1024).decode("UTF-8").split("\n")
			for i in buf:
				logging.info(i)
				if i[0:4] == "PING":
					irc.send(bytes("PONG {0}\r\n".format(i[5:]), "UTF-8"))
				else:
					l = i.split(" ")
					if len(l) < 2:
						continue
					elif l[1] == "001":
						print_err("connected and registered, identifing and joining channels")
						irc.send(bytes("PRIVMSG NickServ :IDENTIFY {0}\r\n".format(password), "UTF-8"))
						time.sleep(1)
						for channel in channels:
							irc.send(bytes("JOIN {0}\r\n".format(channel), "UTF-8"))
					elif l[1] == "477":
						print_err("Error: Nickname was not registered when joining {0}. Reauthing and retrying...".format(l[3]))
						irc.send(bytes("PRIVMSG NickServ :IDENTIFY {0}\r\n".format(password), "UTF-8"))
						time.sleep(5)
						irc.send(bytes("JOIN {0}\r\n".format(l[3]), "UTF-8"))
					elif l[1] == "433":
						print_err("Error: Nickname already in use. Attempting to use alt nickname if available, sleeping 60s otherwise...")
						if(altnick):
							irc.send(bytes("NICK {0}\r\n".format(altnick), "UTF-8"))
						else:
							time.sleep(60)
							irc = setup_irc_socket()
					elif l[1] == "JOIN":
						sender = parse_sender(l[0])
						channel = l[2][1:].strip()
						if channel in channels:
							if sender in memos[channel] and len(memos[channel][sender]):
								message = "{0}: You have {1} unread memos in {2}. Send any message to read them.".format(sender, len(memos[channel][sender]), channel)
								irc.send(bytes("PRIVMSG {0} :{1}\r\n".format(channel, message), "UTF-8"))
					elif l[1] == "PRIVMSG":
						sender = parse_sender(l[0])
						channel = l[2]
						if channel in channels:
							if sender in memos[channel] and len(memos[channel][sender]):
								message = "{0}: {1}".format(sender, memos[channel][sender].pop(0))
								if not len(memos[channel][sender]):
									memos[channel].pop(sender)
								irc.send(bytes("PRIVMSG {0} :{1}\r\n".format(channel, message), "UTF-8"))
								flush_memos(memos)
							if len(l) > 5 and nick in l[3] and "tell" in l[4]:
								target = l[5]
								memomsg = "<{0}> {1}".format(sender, ' '.join(l[6:]).strip())
								if target not in memos[channel]:
									memos[channel][target] = list()
								memos[channel][target].append(memomsg)
								message = "{0}: Memo sent to {1}.".format(sender, target)
								irc.send(bytes("PRIVMSG {0} :{1}\r\n".format(channel, message), "UTF-8"))
								flush_memos(memos)
		except:
			print_err("Lost connection to IRC server.")
			irc = setup_irc_socket()


if __name__ == "__main__":
	irc = setup_irc_socket()
	t = threading.Thread(target=nudge_handler)
	t.daemon = True
	t.start()
	irc_handler()
