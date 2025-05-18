extends Node

@warning_ignore_start('unused_signal')
################################################################################
### Networking

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected()

################################################################################
### Gameplay

signal start_game()
signal load_map(map_name)


################################################################################
@warning_ignore_restore('unused_signal')