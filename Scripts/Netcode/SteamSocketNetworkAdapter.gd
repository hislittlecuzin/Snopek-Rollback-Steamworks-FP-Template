extends "res://addons/godot-rollback-netcode/NetworkAdaptor.gd"

static func is_type(obj: Object):
	return obj.has_method("attach_network_adaptor") \
		and obj.has_method("detach_network_adaptor") \
		and obj.has_method("start_network_adaptor") \
		and obj.has_method("stop_network_adaptor") \
		and obj.has_method("send_ping") \
		and obj.has_method("send_ping_back") \
		and obj.has_method("send_remote_start") \
		and obj.has_method("send_remote_stop") \
		and obj.has_method("send_input_tick") \
		and obj.has_method("is_network_host") \
		and obj.has_method("is_network_master_for_node") \
		and obj.has_method("get_unique_id") \
		and obj.has_method("poll")

func _ready():
	pass

#region Snopek Stuff

#region Snopek Connection maintenence stuff

func send_ping(peer_id: int, msg: Dictionary) -> void:
	var data = SyncManager.message_serializer.serialize_send_ping(peer_id, msg)
	transmit_to_peer(peer_id, data)
func receive_send_ping(peer_id: int, msg: PackedByteArray):
	var unserialized_data = SyncManager.message_serializer.unserialize_send_ping(msg)
	
	if unserialized_data["sender"] == MPManager.my_steam_id:
		received_ping_back.emit(peer_id, unserialized_data )
	elif MPManager.Facepunch.wasHost:
		transmit_to_peer(unserialized_data["receiver"], msg)

func send_ping_back(peer_id: int, msg: Dictionary) -> void:
	var data = SyncManager.message_serializer.serialize_send_ping_back(peer_id, msg)
	transmit_to_peer(peer_id, data)
func receive_send_ping_back(peer_id: int, msg: PackedByteArray):
	var unserialized_data = SyncManager.message_serializer.unserialize_send_ping_back(msg)
	if unserialized_data["receiver"] == MPManager.my_steam_id:
		received_ping_back.emit(peer_id, unserialized_data )
	elif MPManager.Facepunch.wasHost:
		transmit_to_peer( unserialized_data["receiver"], msg )

#endregion

#region Snopek Start/Stop & input

func send_remote_start(peer_id: int) -> void:
	var data = SyncManager.message_serializer.serialize_send_remote_start(peer_id)
	transmit_to_peer(peer_id, data)
func receive_send_remote_start(msg: PackedByteArray):
	received_remote_start.emit()

func send_remote_stop(peer_id: int) -> void:
	var data = SyncManager.message_serializer.serialize_send_remote_stop(peer_id)
	transmit_to_peer(peer_id, data)
func receive_send_remote_stop(msg: PackedByteArray):
	var unserialized_data = SyncManager.message_serializer.unserialize_send_remote_stop(msg)
	if unserialized_data["receiver"] == MPManager.my_steam_id:
		received_remote_stop.emit()
	elif MPManager.Facepunch.wasHost:
		transmit_to_peer( unserialized_data["receiver"], msg )

#PackedByteArray is just a byte array like byte[] 
func send_input_tick(peer_id: int, msg: PackedByteArray) -> void:
	transmit_to_peer(peer_id, msg)
func receive_send_input_tick(sender_id: int, destination_id: int, msg: PackedByteArray):
	var unserialized_data = SyncManager.message_serializer.unserialize_input_message(msg)
	if destination_id == MPManager.my_steam_id:
		received_input_tick.emit(sender_id, msg)
	elif MPManager.Facepunch.wasHost:
		transmit_to_peer( destination_id, msg )

#endregion

#region Snopek Getters

func is_network_host() -> bool:
	return MPManager.Facepunch.wasHost

func is_network_master_for_node(node: Node) -> bool:
	var node_in_question = node as network_player_v1
	if node is network_player_v1:
		return node_in_question.is_local_authority
	else:
		return node.get_multiplayer_authority() == MPManager.my_steam_id
	#return node.is_network_master_for_node()

func get_unique_id() -> int:
	return MPManager.my_steam_id

#func poll() -> void:
	#pass

#endregion

#endregion



#region setup of match


func send_start_match(peer_id: int, msg: Dictionary):
	print("Told client to start match " + str(peer_id))
	var packet = SyncManager.message_serializer.serialize_start_custom_match(peer_id, msg)
	reliable_to_peer(peer_id, packet)
func receive_send_start_match( msg: PackedByteArray ):
	var unserialized_data = SyncManager.message_serializer.unserialize_start_custom_match(msg)
	if unserialized_data["receiver"] == MPManager.my_steam_id:
		print("Should go to start the match place...")
		#received_ping_back.emit(peer_id, unserialized_data )
		if get_tree().current_scene.name == "Steam pre-game_Lobby":
			get_tree().root.get_node("Steam pre-game_Lobby").load_level(unserialized_data)
	elif MPManager.Facepunch.wasHost:
		transmit_to_peer(unserialized_data["receiver"], msg)

# Tells client which pawn he is. 
func assign_client_multiplayer_authority(peer_id: int, msg: Dictionary):
	var packet = SyncManager.message_serializer.serialize_assign_client_multiplayer_authority(peer_id, msg)
	reliable_to_peer(peer_id, packet)
func receive_assign_client_multiplayer_authority(msg: PackedByteArray):
	var unserialized_data = SyncManager.message_serializer.unserialize_assign_client_multiplayer_authority(msg)
	
	if unserialized_data["receiver"] == MPManager.my_steam_id:
		var field_manager = get_tree().root.get_node("Field_Manager") as FieldManager
		if null == field_manager:
			return
		for pawn_index in unserialized_data["player_count"]:
			field_manager.posssess_pawn(pawn_index, unserialized_data[pawn_index])
	elif MPManager.Facepunch.wasHost:
		transmit_to_peer(unserialized_data["receiver"], msg)
#endregion


#send data through ANOTHER FUCKING C# STEAMWORKS IMPLEMENTATION
func transmit_to_peer(peer_id: int, msg: PackedByteArray):
	if MPManager.Facepunch.wasHost: # Host
		if MPManager.steam_id_to_connection_id_dictionary.has(peer_id):
			var connection_id = MPManager.steam_id_to_connection_id_dictionary[peer_id]
			MPManager.Facepunch.ServerMessageSpecificClient(connection_id, msg)
	else:
		MPManager.Facepunch.SendMessageToSocketServer(msg)

func reliable_to_peer(peer_id: int, msg: PackedByteArray):
	print("Messaging : " + str(peer_id))
	if MPManager.Facepunch.wasHost: # Host
		var connection_id = MPManager.steam_id_to_connection_id_dictionary[peer_id]
		print ( " Server Connection ID: " + str(connection_id))
		MPManager.Facepunch.ReliableServerMessageSpecificClient(connection_id, msg)
	else:
		MPManager.Facepunch.ReliableSendMessageToSocketServer(msg)

#func process_new_on_message(msg: PackedByteArray):
#	process_new_on_message(msg, 0)
#No poing to separating messages - can re-consolidate... later :P
func process_new_on_message_client(msg: PackedByteArray):
	process_new_on_message(msg, 0)
func process_new_on_message(og_msg: PackedByteArray, og_peer_id: int):
	var buffer := StreamPeerBuffer.new()
	var destination_id
	var packetType
	var sender_id
	
	#if MPManager.Facepunch.wasHost: # IF host, share Peer ID before data in pack
		#buffer.put_64(og_peer_id)
	buffer.put_data(og_msg)
	buffer.seek(0)
	destination_id = buffer.get_64()
	packetType = buffer.get_u8()
	sender_id = buffer.get_64()
	
	#print ("packet : " + str(packetType))
	
	var msg = buffer.data_array
	
	if destination_id != SyncManager._network_adaptor.get_unique_id():
		if MPManager.Facepunch.wasHost:
			transmit_to_peer(destination_id, og_msg)
		return
	
	
	if packetType == Globals.PacketIndicator.INPUT:
		receive_send_input_tick( sender_id, destination_id, og_msg )
	if packetType == Globals.PacketIndicator.PING:
		receive_send_ping( sender_id, og_msg )
	if packetType == Globals.PacketIndicator.PING_BACK:
		receive_send_ping_back( sender_id, og_msg )
	if packetType == Globals.PacketIndicator.REMOTE_START:
		receive_send_remote_start( og_msg )
	if packetType == Globals.PacketIndicator.REMOTE_STOP:
		receive_send_remote_stop( og_msg )
	if packetType == Globals.PacketIndicator.START_MATCH:
		receive_send_start_match( og_msg )
	if packetType == Globals.PacketIndicator.PAWN_ASSIGNMENT:
		receive_assign_client_multiplayer_authority( og_msg )
	
