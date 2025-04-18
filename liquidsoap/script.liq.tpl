myplaylist = playlist(mode="random", reload_mode="watch", "/music/playlist.m3u")

primeira_playlist = playlist(mode="random", reload_mode="watch", "/home/ubuntu/music/music/10.Almoco_Brasileiro_Elegante/playlist.m3u")
segunda_playlist = playlist(mode="random", reload_mode="watch", "/home/ubuntu/music/music/11.Brasil_Descontraido_Animado/playlist.m3u")
terceira_playlist = playlist(mode="random", reload_mode="watch", "/home/ubuntu/music/music/12.Noturno_Jazz_Brasil/playlist.m3u")

radio = switch( [
  ({12h00-16h30},  primeira_playlist),
  ({16h30-20h30},  segunda_playlist),
  ({20h30-23h00},  terceira_playlist),
  ({true},  myplaylist)
  ])
radio = fallback(track_sensitive = false, [radio, blank()])



nivelado = compress(
  attack=50.0,
  release=300.0,
  threshold=-18.0,
  ratio=3.0,
  gain=3.0,
  knee=2.0,
  window=0.1,
  radio
)

output.icecast(%mp3(bitrate=128),
  host="${ICECAST_HOSTNAME}",
  port=8000,
  password="${ICECAST_SOURCE_PASSWORD}",
  mount="stream",
  name="Radio cloudbeats",
  url="${ICECAST_HOSTNAME}",
  description="Best music for your cloud",
  radio
)

