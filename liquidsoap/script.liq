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
  host="icecast",
  port=8000,
  password="hackme",
  mount="stream",
  name="Radio Lucas",
  url="http://localhost:8000",
  description="Radio Lucas",
  radio
)

