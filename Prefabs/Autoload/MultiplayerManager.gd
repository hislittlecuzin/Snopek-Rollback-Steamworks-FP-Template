extends Node

#Parallel Arrays
var my_steam_id

#Key is Steam ID. Value is Connection ID. 
#Used by network adapter to know who to talk to.
var steam_id_to_connection_id_dictionary = {}

const port = 6969
const max_players = 4

const steam_app_id := 480

const STEAM_ENABLED = true
@onready var Facepunch = get_tree().root.get_node("/root/FpSteamManager")
const steam_pregame_lobby = "Steam pre-game_Lobby"

var lobbyUsernames = []

func test_code_method():
	print("Test code: ")
	var myBool = true
	var buffer := StreamPeerBuffer.new()
	buffer.resize(1) #int 8 byte 1, int 8
	buffer.put_u8(9223372036854775807)
	buffer.resize(buffer.get_position())
	
	var returnBuf = buffer.data_array
	
	var newbuffer := StreamPeerBuffer.new()
	newbuffer.put_data(returnBuf)
	newbuffer.seek(0)
	#dict
	var newBool = newbuffer.get_u8()

# Called when the node enters the scene tree for the first time.
func _ready():
	test_code_method()
	Facepunch.GDScriptCall() #Demonstration of calling C# from GD Script
	print("Current Scene: " + get_tree().current_scene.name)
	if STEAM_ENABLED:
		my_steam_id = Facepunch.SetupSteam()
		print("My steam ID: " + str(my_steam_id))
	else:
		multiplayer.peer_connected.connect(_on_network_peer_connected)
		multiplayer.peer_disconnected.connect(_on_network_peer_disconnected)
		multiplayer.server_disconnected.connect(_on_server_disconnected)
	SyncManager.sync_started.connect(_on_SyncManager_sync_started)
	SyncManager.sync_stopped.connect(_on_SyncManager_sync_stopped)
	SyncManager.sync_lost.connect(_on_SyncManager_sync_lost)
	SyncManager.sync_regained.connect(_on_SyncManager_sync_regained)
	SyncManager.sync_error.connect(_on_SyncManager_sync_error)
	
	pass # Replace with function body.

func cscall():
	print("I was called by C# script.")

func _process(delta):
	pass



func HostGame():
	if STEAM_ENABLED:
		StartSteamLobby()
	else:
		var peer = ENetMultiplayerPeer.new()
		peer.create_server(int(port), max_players)
		multiplayer.multiplayer_peer = peer

#seems to be unused - maybe fine to keep for godot rpc.
func ClientConnectToServer(server_ip_address):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(server_ip_address, port)
	multiplayer.multiplayer_peer = peer
	#var emptyArray = []
	#Steam.connectP2P( str(lobby_id), port,  emptyArray)



#region Steam Stuff

func StartSteamLobby():
	Facepunch.CreateLobby(max_players)



#region Facepunch Steam Callbacks



#endregion

#region Facepunch Steam Callback Helper Methods
func SetLobbyUsernames(new_usernames: Array):
	lobbyUsernames = new_usernames
	print ("Set Lobby UsernameS")
	for i in lobbyUsernames:
		print("Username : " + i)
	
#remember fekin types, bruv when called by C#, yeah? 
func AddLobbyUsername(new_username: String, new_peer_id: int):
	print ("Set Lobby Username")
	if false == lobbyUsernames.has(new_username):
		lobbyUsernames.push_back(new_username)
		if new_peer_id != SyncManager._network_adaptor.get_unique_id():
			SyncManager.add_peer(new_peer_id)
	else: # may cause issues if two people with identical names join game
			# maybe switch to check by ID & adjust names accordingly?
		printerr("Tried adding " + new_username + " but he already exists in the match.")
func RemoveUsername(new_username: String):
	print ("Remove Lobby Username")
	lobbyUsernames.remove_at( lobbyUsernames.find(new_username) )
	print("Username : " + new_username)

#if in lobby, sets UI up.
func SetLobbyNames():
	var pregameLobby = get_tree().root.get_node("Steam pre-game_Lobby")
	pregameLobby.SetPregameLobbyUsernames()
func AddNewLobbyUsername(new_username: String): # Add showing of name in UI
	var pregameLobby = get_tree().root.get_node("Steam pre-game_Lobby")
	pregameLobby.AddNewLobbyUsername(new_username)
#endregion

#region SteamSocketNetworkAdapter callbacks

#Clients don't get "Who" the message is from with Steamworks. 
func on_message_server(msg: PackedByteArray, peer_id: int):
	if STEAM_ENABLED:
		SyncManager.network_adaptor.process_new_on_message(msg, peer_id)
func on_message_client(msg: PackedByteArray):
	if STEAM_ENABLED:
		SyncManager.network_adaptor.process_new_on_message_client(msg)

#region Connect  /  Disconnect

func server_on_network_peer_connected(peer_id: int, connection_id: int):
	steam_id_to_connection_id_dictionary[peer_id] = connection_id
	print("Connected ID.. steam ID: " + str(peer_id) + " Connection id: " + str(steam_id_to_connection_id_dictionary[peer_id]))
	#SyncManager.add_peer(peer_id)
func _on_network_peer_connected(peer_id: int):
	#SyncManager.add_peer(peer_id)
	print("Current Scene: " + get_tree().current_scene.name)
	pass

func _on_network_peer_disconnected(peer_id: int):
	SyncManager.remove_peer(peer_id)
	print("Current Scene: " + get_tree().current_scene.name)

func _on_server_disconnected():
	_on_network_peer_disconnected(1)

#endregion

#endregion

#endregion




#region Sync Manager Callbacks - start stop, lost, regained, error

func _on_SyncManager_sync_started():
	print("Started Syncing!")
	pass

func _on_SyncManager_sync_stopped():
	pass

func _on_SyncManager_sync_lost():
	printerr("Sync Lost!!")
	pass
	#sync_lost_label.visible = true

func _on_SyncManager_sync_regained():
	pass
	#sync_lost_label.visible = false

func _on_SyncManager_sync_error(msg: String):
	printerr("Fatal sync error: " + msg)
	#message_label.text = "Fatal sync error: " + msg
	#sync_lost_label.visible = false
	
	var peer = multiplayer.multiplayer_peer
	if peer:
		peer.close()
	#SyncManager.clear_peers()

#endregion
