playlist_musicas = playlist(mode="random", reload_mode="watch", "/music")
#single_musica = single("/music/Seal - A Change Is Gonna Come_clean.mp3")

fonte_segura = fallback([playlist_musicas, blank()])

nivelado = compress(
  attack=50.0,
  release=300.0,
  threshold=-18.0,
  ratio=3.0,
  gain=3.0,
  knee=2.0,
  window=0.1,
  fonte_segura
)

output.icecast(
  %mp3,
  host="icecast",
  port=8000,
  password="hackme",
  mount="stream",
  name="Rádio Lucas",
  url="http://localhost:8000",
  nivelado
)

