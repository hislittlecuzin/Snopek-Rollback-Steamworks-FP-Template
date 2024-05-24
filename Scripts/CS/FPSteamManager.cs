using Godot;
using System;
using Steamworks;
using Steamworks.Data;
using System.Linq;
using System.Collections.Generic;
using System.Threading.Tasks;

// FP is short for Facepunch just to have a distinction. 

public partial class FPSteamManager : Node {

	public static FPSteamManager instance;

	public Lobby? currentLobby;
	public bool wasHost = false;
	public FPSteamGameServer? currentServer;
	public FPSteamConnectionManager? currentConnectionToServer;
	const int serverPort = 6969;

	public static Node MPManager;


	// Root node of scene's name
	public const string pregameSteamLobby = "Steam pre-game_Lobby";

	#region Setup & callbacks

	#region initialize & defaults
	// Called when the node enters the scene tree for the first time.
	public override void _Ready() { }
	
	public ulong SetupSteam() {
		instance = this;

		try {
			GD.Print("Loading FP");
			SteamClient.Init(480, true); //change 480 to your steam game's ID later. 480 is "Space War" the steamworks test game.
			GD.Print("Initialized Steam");
		} catch (Exception ex) {
			GD.Print("FAILED INIT STEAM! " + ex.Message);
		}
		#region Demonstation of calling GD Script from C#
		MPManager = GetTree().Root.GetNode("MPManager");
		MPManager.Call("cscall");
		#endregion

		#region Callback links
		SteamMatchmaking.OnLobbyCreated += SteamMatchmaking_OnLobbyCreated;
		SteamMatchmaking.OnLobbyEntered += SteamMatchmaking_OnLobbyEntered;
		SteamMatchmaking.OnLobbyMemberJoined += SteamMatchmaking_OnLobbyMemberJoined;
		SteamMatchmaking.OnLobbyMemberLeave += SteamMatchmaking_OnLobbyMemberLeave;
		SteamMatchmaking.OnLobbyInvite += SteamMatchmaking_OnLobbyInvite;
		SteamMatchmaking.OnLobbyGameCreated += SteamMatchmaking_OnLobbyGameCreated;
		SteamFriends.OnGameLobbyJoinRequested += SteamFriends_OnGameLobbyJoinRequested;
		#endregion

		return SteamClient.SteamId.Value;
	}

	public void GDScriptCall() {
		GD.Print("I was called by GD Script");
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta) {
		SteamClient.RunCallbacks();
		if (wasHost && currentServer != null) {
			currentServer.Receive();
		} else if (currentConnectionToServer != null) {
			currentConnectionToServer.Receive();
		}
	}
	#endregion

	#region On Lobby created and game created
	/// <summary>
	/// When lobby was created but first of 2
	/// </summary>
	/// <param name="_result"></param>
	/// <param name="_lobby"></param>
	private void SteamMatchmaking_OnLobbyCreated(Result _result, Lobby _lobby) {
		if (_result != Result.OK) {
			GD.Print("lobby was not created");
			return;
		}
		_lobby.SetPublic();
		_lobby.SetJoinable(true);
		_lobby.SetGameServer(_lobby.Owner.Id);
		_lobby.SetData("Info", SteamClient.Name);
		wasHost = true;
		GD.Print("lobby created: " + _lobby.Id);
		//NetworkTransmission.instance.AddMeToDictionaryServerRPC(SteamClient.SteamId, "FakeSteamName", NetworkManager.Singleton.LocalClientId);

	}

	/// <summary>
	/// When the lobby is created. second of 2 - Used When you "lobby.SetGameServer(foobar)" and someone joins said thingy. When a server is added to the lobby.
	/// </summary>
	/// <param name="arg1"></param>
	/// <param name="arg2"></param>
	/// <param name="arg3"></param>
	/// <param name="arg4"></param>
	private void SteamMatchmaking_OnLobbyGameCreated(Lobby arg1, uint arg2, ushort arg3, SteamId arg4) {
		GD.Print("Lobby was created");
		//GameManager.instance.SendMessageToChat($"Lobby was created", NetworkManager.Singleton.LocalClientId, true);
	}
	#endregion

	#region joining lobbies
	/// <summary>
	/// When a player actually enters the lobby you are already in.
	/// </summary>
	/// <param name="_lobby"></param>
	/// <param name="friend"></param>
	private void SteamMatchmaking_OnLobbyMemberJoined(Lobby _lobby, Friend friend) {
		//string[] newNames = { friend.Name };

		
		MPManager.Call("AddLobbyUsername", friend.Name, friend.Id.Value);
		if (GetTree().CurrentScene.Name.Equals(pregameSteamLobby)) {
			MPManager.Call("AddNewLobbyUsername", friend.Name);
		}

		//GetNode<Test2d>("/root/Node2D").AddPlayerToList(friend.Name);
		GD.Print("member join");
	}

	/// <summary>
	/// When YOU join a lobby. 
	/// </summary>
	/// <param name="_lobby"></param>
	private void SteamMatchmaking_OnLobbyEntered(Lobby _lobby) {
		//List<String> lobbyUsernames = new List<String>();
		//List<int> lobbyIDs = new List<int>();
		GD.Print(_lobby.MemberCount);
		foreach (Friend friend in _lobby.Members) {
			GD.Print(friend.Name);
			//lobbyUsernames.Add(friend.Name);

			//Add people already in match to the peer list & stuff; you are likely not first person in the game because server. 
			MPManager.Call("AddLobbyUsername", friend.Name, friend.Id.Value);

		}
		//MPManager.Call("SetLobbyUsernames", lobbyUsernames.ToArray());
		if (GetTree().CurrentScene.Name.Equals(pregameSteamLobby)) {
			MPManager.Call("SetLobbyNames");
		}

		// When you are Client - connect to server
		if (false == _lobby.IsOwnedBy(SteamClient.SteamId)) {
			currentConnectionToServer = SteamNetworkingSockets.ConnectRelay<FPSteamConnectionManager>(_lobby.Owner.Id, serverPort); // Make client connect server by Steam socket
		}
	}
	#endregion

	#region Client/game methods
	/// <summary>
	/// Called by user/program. This is what I used to create the lobby AND the server.
	/// </summary>
	/// <param name="_maxMembers"></param>
	public async void CreateLobby(int _maxMembers) {
		currentLobby = await SteamMatchmaking.CreateLobbyAsync(_maxMembers);
		StartServer();
	}

	/// <summary>
	/// Used to create the steam server. Or alternate server...
	/// </summary>
	public void StartServer() {
		if (currentLobby != null) {
			currentLobby.Value.SetGameServer(currentLobby.Value.Owner.Id);
		}
		currentServer = SteamNetworkingSockets.CreateRelaySocket<FPSteamGameServer>(serverPort);
		GD.Print("Started Game Server");
		GD.Print(currentServer.ToString());
	}

	/// <summary>
	/// Fekin nuthn
	/// </summary>
	/// <param name="_sId"></param>
	public void StartClient(SteamId _sId) {
		//NetworkManager.Singleton.OnClientConnectedCallback += Singleton_OnClientConnectedCallback;
		//NetworkManager.Singleton.OnClientDisconnectCallback += Singleton_OnClientDisconnectCallback;
		//transport.targetSteamId = _sId;
		//GameManager.instance.myClientId = NetworkManager.Singleton.LocalClientId;
		//if (NetworkManager.Singleton.StartClient())
		//{
		//    Debug.Log("Client has started");
		//}/
	}

	/// <summary>
	/// Would be called by the user/game/program. Use to disconnect from a lobby or sumn.
	/// </summary>
	public void Disconnected() {
		currentLobby?.Leave();
		//if (NetworkManager.Singleton == null)
		//{
		//    return;
		//}
		//if (NetworkManager.Singleton.IsHost)
		//{
		//    NetworkManager.Singleton.OnServerStarted -= Singleton_OnServerStarted;
		//}
		//else
		//{
		//    NetworkManager.Singleton.OnClientConnectedCallback -= Singleton_OnClientConnectedCallback;
		//}
		//NetworkManager.Singleton.Shutdown(true);
		//GameManager.instance.ClearChat();
		//GameManager.instance.Disconnected();
		GD.Print("disconnected");
	}
	#endregion

	#region idfk what to do with tis stuff
	private void SteamMatchmaking_OnLobbyInvite(Friend _steamId, Lobby arg2) {
		GD.Print($"Invite from {_steamId.Name}");
	}
	private async void SteamFriends_OnGameLobbyJoinRequested(Lobby _lobby, SteamId _steamId) {
		RoomEnter joinedLobby = await _lobby.Join();
		if (joinedLobby != RoomEnter.Success) {
			GD.Print("Failed to create lobby");
		}
		else {
			currentLobby = _lobby;
			//GameManager.instance.ConnectedAsClient();
			GD.Print("Joined Lobby");
		}
	}
	#endregion

	#endregion

	/// <summary>
	/// When someone else leaves the lobby
	/// </summary>
	/// <param name="_lobby"></param>
	/// <param name="_steamId"></param>
	private void SteamMatchmaking_OnLobbyMemberLeave(Lobby _lobby, Friend _steamId) {

		MPManager.Call("RemoveUsername", _steamId.Name);

		GD.Print("member leave");
		if (_lobby.IsOwnedBy(SteamClient.SteamId)) {
			GD.Print("You are now the host.");
		}
		if (false == wasHost) {
			GD.Print("Host Migrated to you.");
			wasHost = true;
			//Host Migrated to you.
			//Potentially Cancel game & return to lobby
		}
	}


	#region Lobby Edit

	public void SetJoinable(bool new_value) {
		currentLobby.Value.SetJoinable(new_value);
	}

	#endregion


	#region transport
	public void ServerMessageSpecificClient(ulong clientID, byte[] message) {
		currentServer.MessageSpecificClient(clientID, message);
	}
	public void ReliableServerMessageSpecificClient(ulong clientID, byte[] message) {
		currentServer.ReliableMessageSpecificClient(clientID, message);
	}

	public void SendMessageToSocketServer(byte[] messageToSend) {
		currentConnectionToServer.SendMessageToSocketServer(messageToSend);
	}
	public void ReliableSendMessageToSocketServer(byte[] messageToSend) {
		currentConnectionToServer.ReliableSendMessageToSocketServer(messageToSend);
	}
	#endregion


}
