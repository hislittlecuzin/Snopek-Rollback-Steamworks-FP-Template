extends Control

@onready var playerList = $"Panel/Player List VBoxContainer"

var playerNames = []

@export var maps : Array[String]
@export_file var default_map = "res://Scenes/Fields/Prototype/empty_field.tscn"

#Called by "Host Player"
func StartGame():
	if false == MPManager.STEAM_ENABLED:
		return
	if false == MPManager.Facepunch.wasHost:
		return
	MPManager.Facepunch.SetJoinable(false)
	var match_start_data = {}
	match_start_data["map"] = -1 #Change later
	match_start_data["retail_map"] = true
	
	print ( "Starting Custom Game . Is Retail map? : " + str(match_start_data["retail_map"]) + " map ID : " + str(match_start_data["map"]) )
	
	# Tell Clients to Change scene 
	for peer in SyncManager.peers:
		SyncManager.network_adaptor.send_start_match(peer, match_start_data)
	#change Scene
	load_level(match_start_data)


func SetPregameLobbyUsernames():
	if MPManager.STEAM_ENABLED:
		for username in MPManager.lobbyUsernames:
			var label: Label = Label.new()
			label.text = username
			playerList.add_child(label)
			playerNames.push_back(label)

func AddNewLobbyUsername(username: String):
	if MPManager.STEAM_ENABLED:
		var label: Label = Label.new()
		label.text = username
		playerList.add_child(label)
		playerNames.push_back(label)
	pass


func load_level(match_data: Dictionary):
	var map = match_data["map"]
	if true or match_data["retail_map"]: # Bool will be a number. 
		match map:
			-1:
				print("Going to default map")
				get_tree().change_scene_to_file(default_map)
			_:
				print("Going to retail map")
				get_tree().change_scene_to_file(maps[map])
	else:
		print("Map doesn't exist....")
