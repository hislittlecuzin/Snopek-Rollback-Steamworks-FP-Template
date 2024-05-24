extends Control

#Depricated old GodotSteam Server Browser

@onready var serverList = $"Panel/ServerList VBoxContainer"


# Called when the node enters the scene tree for the first time.
func _ready():
	#Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	#Steam.requestLobbyList()
	print("Server Browser Requested lobbies")

func PopulateServerList(lobbies: Array):
	print("Populating Server List")
	for lobby in lobbies:
		#print("Steam Lobby: " + Steam.getLobbyData(lobby, "name"))
		var button: Button = Button.new()
		#button.text = Steam.getLobbyData(lobby, "name")
		#button.text += Steam.getLobbyData(lobby, "mode")
		serverList.add_child(button)
		button.connect("button_down", Callable(self, "join_lobby").bind(lobby))

func join_lobby(this_lobby_id: int):
	print("Attempting to join lobby: " + str(this_lobby_id))
	#Steam.joinLobby(this_lobby_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
