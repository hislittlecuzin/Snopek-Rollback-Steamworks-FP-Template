# Snopek-Rollback-Steamworks-FP-Template
Uses AFSI to let you send all your network protocol through Steam Sockets to not need server hosting nor port forwarding

Made with Godot 4.2.1 MONO
Needs C#. Used Visual Studio 2022 Community Edition. (Free for Individuals... maybe also free for very small companies with commercial use... maybe free for sole proprieterships with commercial use.)
Uses Facepunch's Steamworks implementation 
https://github.com/Facepunch/Facepunch.Steamworks
Documentation:
https://wiki.facepunch.com/steamworks/
Read the "Classes" sections for the class you want to use. It assumes intermediate or above programmer skill, so it doesn't tell you much. Break stuff, see what happens, learn. 

# For Builds
Make sure you copy over the `steam_api64.dll` and put it next to the `.exe` for standalone execution.
Currently ONLY suppoorts windows. You'd have to build Facepunch Steamworks if you want to support other platforms & figure out how to get the `.csproj` to take that stuff.

# Access Steamworks Functionality:
NOT COMPATIBLE WITH GODOTSTEAM! YOU CAN ONLY USE FACEPUNCH STEAMWORKS
Scripts->CS->FPSteamManager.cs
This is where steam is initialized and accessed by GD Script.

Global class `MPManager` accesses Facepunch's steamwworks by `MPManager.Facepunch` and you can call methods like so
`MPManager.Facepunch.TheNameOfTheMethodIWantToCall()`
`MPManager.Facepunch.TheNameOfTheMethodIWantToCall(TheNameOfTheArgumentVariableIWantToPass)`
`MPManager.Facepunch.TheNameOfTheMethodIWantToCall(TheNameOfTheArgumentVariableIWantToPass, AnotherVariableIfIWantToSendThatToo)`


# For network communication
Most of the basic stuff is there if you just want to use Snopek's stuff the way it is.
YOU CANNOT USE RPC. 
You have to serialize and de-serialize data manually. 
# serialize data
`SteamMessageSerializer.gd` is the serializer used for serializing data. The network process EXPECTS a 64 bit number for the receiving Steam ID (not connection ID), an 8 bit packet identifier, and a 64 bit Steam ID of who sent the packet.
For easier use, I use `Globals.gd` to have names of packets. with 8 bits avaiable, you can make 128~256 different packet types. 

# network transmissions
`SteamSocketNetworkAdapter.gd` is used for all network communication & routing. 
Packets are received by `process_new_on_message_client` or `process_new_on_message` - I need to depricate the client one since it just calls the server one anyway.
Add if statement for your new incoming packet. 
Naming convention is to add `receive_` to the name of the method that sends the data. 

For constant data that doesn't NEED to arrive (ie player input) use `transmit_to_peer` likely you're sending 100 times and old data gets old fast
For data that must be received like "start the game" use `reliable_to_peer` likely you're saying this once.

Most stuff in the region "Snopek Stuff" you can ignore.

# How to test?
Own two computers. I suggest buying cheap laptops off eBay. a laptop with a gtx 960m, gtx 1050, or newer is perfectly adequate imo unless you have REALLY good graphics.

# to do by you
Disconnection
ending matches
entire game
...more?

# Possible issues
the `.csproj` specifies the Facepunch .dll to be where it is on my computer. If you have problems, you may need to build Facepunch steamworks, and edit the location to be where yours is on your pc. 
Then also you'd have to replace the `steam_api64.dll` in your project & next to your built .exe

Sync manager has been modified. I think directly.

Something about checking the ability to do network processes may have been changed... do a "Find" (Control + F) on sync manager for calling `node.network_process` or something.
Snopek's original code expects use of Godot's built in RPC functionality which I wasn't using, so it wasn't compatible. 
