extends "res://addons/godot-rollback-netcode/MessageSerializer.gd"

func _init():
	pass
	
func feignserialize_input(all_input: Dictionary) -> PackedByteArray:
	
	var bytes = var_to_bytes(all_input)
	return bytes
	
	#var buffer := StreamPeerBuffer.new()
	#buffer.resize(16)
	#serialize
	#buffer.resize(buffer.get_position())
	#return buffer.data_array

#remove feign to re-implement
func feignunserialize_input(serialized: PackedByteArray) -> Dictionary:
	var buffer := StreamPeerBuffer.new()
	buffer.put_data(serialized)
	buffer.seek(0)
	var client
	if false == MPManager.Facepunch.wasHost:
		client = buffer.get_64()
	var packetType = buffer.get_u8()
	
	#dictionary to return
	var all_input := {}
	
	all_input['$'] = buffer.get_u32()
	var input_count = buffer.get_u8()
	if input_count == 0:
		return all_input
	
	
	
	#return
	return all_input

#Template method.
func serialize_send_ping(peer_id: int, msg: Dictionary) -> PackedByteArray: #peer_id: int
	var buffer := StreamPeerBuffer.new()
	buffer.resize(25) #int 8 byte 1 int 8, int 8
	buffer.put_64(peer_id) # Destination
	#Packet Type
	buffer.put_u8(Globals.PacketIndicator.PING)
	buffer.put_64(SyncManager._network_adaptor.get_unique_id()) # sender ID
	
	#message contents
	buffer.put_64(msg.local_time)
	
	#resize and return.
	buffer.resize(buffer.get_position())
	return buffer.data_array
func unserialize_send_ping(serialized: PackedByteArray) -> Dictionary: #foobar completion
	#setup buffer
	var buffer := StreamPeerBuffer.new()
	buffer.put_data(serialized)
	buffer.seek(0)
	#dict
	var return_data = {}
	var client = buffer.get_64() # Destination
	var packetType = buffer.get_u8() # Packet type
	var sender = buffer.get_64() # sender ID
	
	#Packet Data
	var local_time = buffer.get_64()
	
	#turn binary to dictionary
	return_data["receiver"] = client
	return_data["sender"] = sender
	#Don't need packet type because the receiver has the binary, 
	#and the dictionary doesn't need it. 
	return_data["local_time"] = local_time
	
	return return_data

func serialize_send_ping_back(peer_id: int, msg: Dictionary) -> PackedByteArray: #peer_id: int
	var buffer := StreamPeerBuffer.new()
	buffer.resize(25) #int 8 byte 1 int 8, int 8
	buffer.put_64(peer_id)
	buffer.put_u8(Globals.PacketIndicator.PING_BACK)
	buffer.put_64(SyncManager._network_adaptor.get_unique_id()) # sender ID
	
	#packet data
	buffer.put_64(msg.remote_time)
	
	buffer.resize(buffer.get_position())
	return buffer.data_array
func unserialize_send_ping_back(serialized: PackedByteArray) -> Dictionary: #foobar completion
	var buffer := StreamPeerBuffer.new()
	buffer.put_data(serialized)
	buffer.seek(0)
	var return_data = {}
	
	var client = buffer.get_64()
	var packetType = buffer.get_u8()
	var sender = buffer.get_64() # sender ID
	
	var local_time = buffer.get_64()
	
	return_data["receiver"] = client
	return_data["sender"] = sender
	return_data["remote_time"] = local_time
	
	return return_data

func serialize_send_remote_start(peer_id: int) -> PackedByteArray:#No data
	var buffer := StreamPeerBuffer.new()
	buffer.resize(17) #int 8 byte 1 int 8, 
	buffer.put_64(peer_id)
	buffer.put_u8(Globals.PacketIndicator.REMOTE_START)
	buffer.put_64(SyncManager._network_adaptor.get_unique_id()) # sender ID
	
	#no data. 
	
	buffer.resize(buffer.get_position())
	return buffer.data_array
func unserialize_send_remote_start(serialized: PackedByteArray): #No data
	#setup buffer
	var buffer := StreamPeerBuffer.new()
	buffer.put_data(serialized)
	buffer.seek(0)
	#dict
	var return_data = {}
	var client = buffer.get_64() # Client
	var packetType = buffer.get_u8() # Packet type
	var sender = buffer.get_64() # sender ID
	
	#turn binary to dictionary
	return_data["receiver"] = client
	return_data["sender"] = sender
	
	return return_data


func serialize_send_remote_stop(peer_id: int) -> PackedByteArray: #No data
	var buffer := StreamPeerBuffer.new()
	buffer.resize(25) #int 8 byte 1 int 8, int 8
	buffer.put_64(peer_id)
	#Packet Type
	buffer.put_u8(Globals.PacketIndicator.REMOTE_STOP)
	buffer.put_64(SyncManager._network_adaptor.get_unique_id()) # sender ID
	
	#No data
	
	#resize and return.
	buffer.resize(buffer.get_position())
	return buffer.data_array
func unserialize_send_remote_stop(serialized: PackedByteArray) -> Dictionary: #No data
		#setup buffer
	var buffer := StreamPeerBuffer.new()
	buffer.put_data(serialized)
	buffer.seek(0)
	#dict
	var return_data = {}
	var client = buffer.get_64() # Client
	var packetType = buffer.get_u8() # Packet type
	var sender = buffer.get_64() # sender ID
	
	#No data
	
	#turn binary to dictionary
	return_data["receiver"] = client
	return_data["sender"] = sender
	return return_data


func serialize_start_custom_match(peer_id: int, match_start_data: Dictionary) -> PackedByteArray:
	var buffer := StreamPeerBuffer.new()
	buffer.resize(26) #int 8 byte 1 int 8, int 8 bool 1
	buffer.put_64(peer_id)
	#Packet Type
	buffer.put_u8(Globals.PacketIndicator.START_MATCH)
	buffer.put_64(SyncManager._network_adaptor.get_unique_id()) # sender ID
	
	#Packet Data
	buffer.put_64( match_start_data["map"] )
	buffer.put_u8( match_start_data["retail_map"] )
	
	#resize and return.
	buffer.resize(buffer.get_position())
	return buffer.data_array
func unserialize_start_custom_match(serialized: PackedByteArray) -> Dictionary:
	#setup buffer
	var buffer := StreamPeerBuffer.new()
	buffer.put_data(serialized)
	buffer.seek(0)
	#dict
	var return_data = {}
	var client = buffer.get_64() # Client
	var packetType = buffer.get_u8() # Packet type
	var sender = buffer.get_64() # sender ID
	
	#message data
	var map = buffer.get_64()
	var map_type = buffer.get_u8()
	
	#turn binary to dictionary
	return_data["receiver"] = client
	return_data["sender"] = sender
	#Don't need packet type because the receiver has the binary, 
	#and the dictionary doesn't need it. 
	return_data["map"] = map
	return_data["retail_map"] = map_type
	
	return return_data

func serialize_assign_client_multiplayer_authority(peer_id: int, msg: Dictionary) -> PackedByteArray:
	var buffer := StreamPeerBuffer.new()
	
	var player_count = msg["player_count"]
	player_count = player_count * 8 # int 8, 
	
	buffer.resize(17 + player_count) #int 8 byte 1 int 8, int 8
	buffer.put_64(peer_id) # Destination
	#Packet Type
	buffer.put_u8(Globals.PacketIndicator.PAWN_ASSIGNMENT)
	buffer.put_64(SyncManager._network_adaptor.get_unique_id()) # sender ID
	
	#message contents
	buffer.put_64(msg["player_count"])
	
	for pawn_index in msg["player_count"]:
		buffer.put_64(msg[pawn_index])
	#buffer.put_64(msg["pawn_index"])
	
	#resize and return.
	buffer.resize(buffer.get_position())
	return buffer.data_array
func unserialize_assign_client_multiplayer_authority(serialized: PackedByteArray) -> Dictionary:
	#setup buffer
	var buffer := StreamPeerBuffer.new()
	buffer.put_data(serialized)
	buffer.seek(0)
	#dict
	var return_data = {}
	var client = buffer.get_64() # Destination
	var packetType = buffer.get_u8() # Packet type
	var sender = buffer.get_64() # sender ID
	
	#Packet Data
	var player_count = buffer.get_64()
	return_data["player_count"] = player_count
	
	for pawn_index in player_count:
		var next_id = buffer.get_64()
		return_data[pawn_index] = next_id
	
	#turn binary to dictionary
	return_data["receiver"] = client
	return_data["sender"] = sender
	
	return return_data


func serialize_input_message(peer_id: int, msg: Dictionary) -> PackedByteArray:
	var buffer := StreamPeerBuffer.new()
	buffer.resize(DEFAULT_MESSAGE_BUFFER_SIZE)
	buffer.put_64(peer_id)
	#Packet Type
	buffer.put_u8(Globals.PacketIndicator.INPUT)
	buffer.put_64(SyncManager._network_adaptor.get_unique_id()) # sender ID
	
	#Message Contents : 
	
	buffer.put_u32(msg[InputMessageKey.NEXT_INPUT_TICK_REQUESTED])
	
	if msg.has(InputMessageKey.INPUT):
		var input_ticks = msg[InputMessageKey.INPUT]
		buffer.put_u8(input_ticks.size())
		if input_ticks.size() > 0:
			var input_keys = input_ticks.keys()
			input_keys.sort()
			buffer.put_u32(input_keys[0])
			for input_key in input_keys:
				var input = input_ticks[input_key]
				buffer.put_u16(input.size())
				buffer.put_data(input)
	else:
		buffer.put_u8(0)

	buffer.put_u32(msg[InputMessageKey.NEXT_HASH_TICK_REQUESTED])

	if msg.has(InputMessageKey.STATE_HASHES):
		var state_hashes = msg[InputMessageKey.STATE_HASHES]
		buffer.put_u8(state_hashes.size())
		if state_hashes.size() > 0:
			var state_hash_keys = state_hashes.keys()
			state_hash_keys.sort()
			buffer.put_u32(state_hash_keys[0])
			for state_hash_key in state_hash_keys:
				buffer.put_u32(state_hashes[state_hash_key])
	else:
		buffer.put_u8(0)

	buffer.resize(buffer.get_position())
	return buffer.data_array
func unserialize_input_message(serialized) -> Dictionary:
	var buffer := StreamPeerBuffer.new()
	buffer.put_data(serialized)
	buffer.seek(0)

	var msg := {
		InputMessageKey.INPUT: {},
		InputMessageKey.STATE_HASHES: {},
	}
	
	var client = buffer.get_64() # Client
	var packetType = buffer.get_u8() # Packet type
	var sender = buffer.get_64() # sender ID

	msg[InputMessageKey.NEXT_INPUT_TICK_REQUESTED] = buffer.get_u32()

	var input_tick_count = buffer.get_u8()
	if input_tick_count > 0:
		var input_tick = buffer.get_u32()
		for input_tick_index in range(input_tick_count):
			var input_size = buffer.get_u16()
			msg[InputMessageKey.INPUT][input_tick] = buffer.get_data(input_size)[1]
			input_tick += 1

	msg[InputMessageKey.NEXT_HASH_TICK_REQUESTED] = buffer.get_u32()

	var hash_tick_count = buffer.get_u8()
	if hash_tick_count > 0:
		var hash_tick = buffer.get_u32()
		for hash_tick_index in range(hash_tick_count):
			msg[InputMessageKey.STATE_HASHES][hash_tick] = buffer.get_u32()
			hash_tick += 1
	
	#turn binary to dictionary
	msg["receiver"] = client
	msg["sender"] = sender
	
	return msg
