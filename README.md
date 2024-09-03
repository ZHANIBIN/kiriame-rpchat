markdown
# Chat Script Features

This script includes the following functions:

## Basic Chat Display
- Get QB player name and print it along with their message in the format:
[hh:mm:ss] FirstName LastName: Something


## Chat Commands
- **Normal Saying**: Display a normal message.
- **/me [time]*name something**: Perform an action with a name.
- **/do [time]*something((name and id))**: Perform an action with a name and ID.
- **/b [time]((name:something))/**: Broadcast a message with a name and additional information.
- **/low**: Use for low-priority messages.
- **/w**: Use for whisper messages.
- **/to**: Use for directed messages.
- **/clear**: Clear the chat display.
- **/duty (WIP)**: Mark a player as on duty (Work in Progress).
- **/f (jobchat also WIP)**: Use for job-related chat (Work in Progress).

All of the functions above can print messages in the server console, including the player's name, ID, and message.

## Customization
You can change the text by modifying the `server/main.lua` file.
