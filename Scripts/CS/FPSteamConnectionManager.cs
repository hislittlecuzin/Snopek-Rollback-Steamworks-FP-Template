using Godot;
using Steamworks;
using Steamworks.Data;
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;


// Steamworks Socket Client


public partial class FPSteamConnectionManager : ConnectionManager {

    public override void OnConnecting(ConnectionInfo data) {
        base.OnConnecting(data);
		GD.Print($"{data.Identity.SteamId} is connecting");
	}
	public override void OnConnected(ConnectionInfo data) {
		base.OnConnected(data);
		GD.Print($"{data.Identity.SteamId} has joined the game");

		// get steam name in lobby.
		// get peer_id here and add to syncmanager peer list. 

		GD.Print(FPSteamManager.instance.currentLobby.Value.MemberCount);
		foreach (Friend friend in FPSteamManager.instance.currentLobby.Value.Members) {
			GD.Print(friend.Name);

			//FPSteamManager.MPManager.Call("AddLobbyUsername", friend.Name, friend.Id.Value);

		}
		if (FPSteamManager.instance.GetTree().CurrentScene.Name.Equals(FPSteamManager.pregameSteamLobby)) {
			FPSteamManager.MPManager.Call("SetLobbyNames");
		}

	}

	public override void OnDisconnected(ConnectionInfo data) {
        base.OnDisconnected(data);
		GD.Print($"{data.Identity.SteamId} is out of here");
		FPSteamManager.MPManager.Call("_on_network_peer_disconnected", data.Identity.SteamId.Value);
	}

	/// <summary>
	/// Message received from socket server, delegate to method for processing.
	/// </summary>
	public override void OnMessage(IntPtr data, int size, long messageNum, long recvTime, int channel) {
		base.OnMessage(data, size, messageNum, recvTime, channel);

		//GD.Print("Client Got A Message " + data);

		byte[] incomingData = new byte[size];
		Marshal.Copy(data, incomingData, 0, size);

		FPSteamManager.MPManager.Call("on_message_client", incomingData);

        return;

		
		//SteamManager.Instance.ProcessMessageFromSocketServer(data, size);

		//ProcessMessage(data, size);

		GD.Print("Connection Got A Message " + data);
		byte[] pingArray = new byte[sizeof(byte)];
        Marshal.Copy(data, pingArray, 0, 1);
        //GD.Print("MyPingArray Check");
        //GD.Print(pingArray[0]);
    }


	/// <summary>
	/// Message Server
	/// </summary>
	/// <param name="messageToSend"></param>
	/// <returns></returns>
	public bool SendMessageToSocketServer(byte[] messageToSend) {
        try {
            Result success = Connection.SendMessage(messageToSend, SendType.Unreliable);
            if (success == Result.OK) {
                return true;
            }
            else {
				// RETRY
				Result retry = Connection.SendMessage(messageToSend, SendType.Unreliable);
                if (retry == Result.OK) {
                    return true;
                }
                return false;
            }
        }
        catch (Exception e) {
            GD.Print(e.Message);
            GD.Print("Unable to send message to socket server");
            return false;
        }
    }

	public bool ReliableSendMessageToSocketServer(byte[] messageToSend) {
		GD.Print("Messaging server Reliably.");
		try {
			Result success = Connection.SendMessage(messageToSend, SendType.Reliable);
			if (success == Result.OK) {
				return true;
			}
			else {
				// RETRY
				Result retry = Connection.SendMessage(messageToSend, SendType.Reliable);
				if (retry == Result.OK) {
					return true;
				}
				return false;
			}
		}
		catch (Exception e) {
			GD.Print(e.Message);
			GD.Print("Unable to send message to socket server");
			return false;
		}
	}

}
