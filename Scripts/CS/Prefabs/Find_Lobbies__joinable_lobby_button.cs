using Godot;
using Steamworks;
using Steamworks.Data;
using System;

public partial class Find_Lobbies__joinable_lobby_button : Control {

	public FindLobbies findLobbiesScript;

	[Export]
	public Button selectButton;
	//[Export]
	//Label selectLabel;

	public Lobby lobbyToJoin;
	public SteamId lobbyID;
	public void SetLobbyToJoin() {
		findLobbiesScript.lobbyToJoin = lobbyToJoin;
		findLobbiesScript.lobbyToJoinID = lobbyID;
	}

	// Called when the node enters the scene tree for the first time.
	public override void _Ready() {
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
