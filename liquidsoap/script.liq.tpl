myplaylist = playlist(mode="random", reload_mode="watch", "/music/playlist.m3u")


radio = myplaylist
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

output.icecast(%mp3,
  host="${ICECAST_HOSTNAME}",
  port=8000,
  password="${ICECAST_SOURCE_PASSWORD}",
  mount="stream",
  name="Radio cloudbeats",
  url="${ICECAST_HOSTNAME}",
  description="Best music for your cloud",
  radio
)

