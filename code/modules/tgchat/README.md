## /TG/ Chat

/TG/ Chat, which will be referred to as TgChat from this point onwards, is a system in which we can send messages to clients in a controlled and semi-reliable manner. The standard way of sending messages to BYOND clients simply dumps whatever you output to them directly into their chat window, however BYOND allows us to load our own code on the client to change this behaviour in a way that allows us to do some pretty neat things.

### Message Format

TgChat handles sending messages from the server to the client through the use of JSON payloads, of which the format will change depending on the type of message and the intended client endpoint. An example of the payload for chat messages is as follows:
```json
{
	"sequence": 0,
	"content": {
		"type": ". . .", // ?optional
		"text": ". . .", // ?optional !atleast-one
		"html": ". . .", // ?optional !atleast-one
		"avoidHighlighting": 0 // ?optional
	},
}
```

### Reliability

In the past there have been issues where BYOND will silently and without reason lose a message we sent to the client, to detect this and recover from it seamlessly TgChat also has a baked in reliability layer. This reliability layer is very primitive, and simply keeps track of recieved sequence numbers. Should the client recieve an unexpected sequence number TgChat asks the server to resend any missing packets. 

### Ping System

TgChat supports a round trip time ping measurement, which is displayed to the client so they can know how long it takes for their commands and inputs to reach the server. This is done by sending the client a ping request, `ping/soft`, which tells the client to send a ping to the server. When the server recieves said ping it sends a reply, `ping/reply`, to the client with a payload containing the current DateTime which the client can reference against the initial ping request.

### Chat Tabs, Local Storage, and Highlighting

To make organizing and managing chat easier and more functional for both players and admins, TgChat has the ability to filter out messages based on their primary tag, such as individual departmental radios, to a dedicated chat tab for easier reading and comprehension. These tabs can also be configured to highlist messages based on a simple keyword search. You can set a multitude of different keywords to search for and they will be highlighting for instant alerting of the client. Said tabs, highlighting rules, and your chat history will persist thanks to use of local storage on the client. Using local storage TgChat can ensure that your preferences are saved and maintained between client restarts and switching between other /TG/ servers. Local Storage is also used to keep your chat history aswell, should you need to scroll through your chat logs.
