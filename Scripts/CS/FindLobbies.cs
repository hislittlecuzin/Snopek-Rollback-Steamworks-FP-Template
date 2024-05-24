using Godot;
using Steamworks;
using Steamworks.Data;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

//Steam Server Browser

public partial class FindLobbies : Control {

	[Export(PropertyHint.File)]
	string mainMenu;
	public void ReturnToMainMenu() { 
		GetTree().ChangeSceneToFile(mainMenu);
	}



	[Export]
	VBoxContainer lobbiesContainer;
	[Export]
	PackedScene lobbySelector;

	/// <summary>
	/// Used by lobby selector buttons to identify what lobby is selected.
	/// </summary>
	public void SelectLobbyToJoin() { 
	}


	[Export(PropertyHint.File)]
	string lobbyScreen;
	/// <summary>
	/// Used to actually join the selected lobby
	/// </summary>
	public void JoinLobby() { 

		if (lobbyToJoinID != null) {
			GetTree().ChangeSceneToFile("res://Scenes/Menus/pre-game_lobby.tscn");
			SteamMatchmaking.JoinLobbyAsync((SteamId)lobbyToJoinID);
		}

		//SteamManager.instance.JoinLobby();
		//GetTree().ChangeSceneToFile(lobbyScreen);
	}

	// Called when the node enters the scene tree for the first time.
	public override void _Ready() {
		var task = LobbyList();
	}

	public Lobby? lobbyToJoin = null;
	public SteamId? lobbyToJoinID;

	public async Task LobbyList() { 
		

		var list = await SteamMatchmaking.LobbyList.RequestAsync();

		if (list == null) { 
		}

		foreach(var lobby in list) {


			GD.Print("Lobby: " + lobby.MemberCount + " Data: " + lobby.GetData("Info"));

			Find_Lobbies__joinable_lobby_button newLobbyButton = lobbySelector.Instantiate<Find_Lobbies__joinable_lobby_button>();
			newLobbyButton.findLobbiesScript = this;
			newLobbyButton.selectButton.Text = lobby.GetData("Info") + " : " + lobby.MemberCount; // lobby.GetData("Info")
			newLobbyButton.lobbyToJoin = lobby;
			newLobbyButton.lobbyID = lobby.Id;

			lobbiesContainer.AddChild(newLobbyButton);
		}
	}

	//List<>
	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta) {
		
	}
}
