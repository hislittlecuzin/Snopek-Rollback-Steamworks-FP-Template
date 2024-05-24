extends Node3D
class_name FieldManager

@export var playerPawns : Array[network_player_v1]

# Called when the node enters the scene tree for the first time.
func _ready():
	if false == MPManager.Facepunch.wasHost:
		return
	
	await ( get_tree().create_timer(3.0).timeout )
	
	print("Showing peers: ")
	
	var pawn_data = {}
	pawn_data["player_count"] = SyncManager.peers.size() + 1
	
	var currentPawn : int = 1
	posssess_pawn(0, MPManager.my_steam_id)
	pawn_data[0] = MPManager.my_steam_id
	print("Assigning pawn Peer IDs:")
	for peer_id in SyncManager.peers:
		print(str(peer_id))
		if peer_id == MPManager.my_steam_id:
			continue
		
		pawn_data[currentPawn] = peer_id
		
		posssess_pawn(currentPawn, peer_id)
		#playerPawns[currentPawn].set_multiplayer_authority(peer_id)
		
		currentPawn += 1
	
	for peer_id in SyncManager.peers:
		SyncManager.network_adaptor.assign_client_multiplayer_authority(peer_id, pawn_data)
	
	await ( get_tree().create_timer(3.0).timeout )
	SyncManager.start()

func posssess_pawn(pawn_index: int, peer_id: int):
	print("Peer ID: " + str(peer_id) + " Pawn Index : " + str(pawn_index))
	playerPawns[pawn_index].id_of_network_authority = peer_id
	print("Peer Authority : " + str(playerPawns[pawn_index].id_of_network_authority) )
	if peer_id == MPManager.my_steam_id:
		playerPawns[pawn_index].cam.current = true
		playerPawns[pawn_index].is_local_authority = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

