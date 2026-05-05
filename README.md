# 🎧 Online Radio – Radio Cloudbeats

This project implements an online radio station using Docker containers with Icecast and Liquidsoap, running on an AWS EC2 instance. The environment is designed to stream music from .m3u playlists and includes automation to synchronise new tracks downloaded via spotdl
 and update playlists automatically.

In addition, a CI/CD pipeline using GitHub Actions is included to simplify deployment and maintenance of the environment.

## 📑 Table of Contents

- [Overview](#-overview)
- [Architecture](#️-architecture)
- [Prerequisites](#-prerequisites)
- [Directory Structure](#-music-automation-and-synchronisation)
- [Setup and Deployment](#️-setup-and-deployment)
- [Music Automation and Synchronisation](#-music-automation-and-synchronisation)
- [Cronjob Workflow](#-cronjob-workflow)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Future Improvements](#-future-improvements)
- [Contributing](#-contributing)
- [Licence](#-licence)

## 🧭 Overview

The goal of this project is to create a robust and cost-effective online radio using:

 - **Docker Compose:** to orchestrate Icecast and Liquidsoap containers.
- **Icecast:** audio streaming server.
- **Liquidsoap:** manages playlists, audio processing, and streaming output.
- **Spotdl:** automatically downloads music from Spotify playlists
- **GitHub Actions:** CI/CD pipeline for automated deployment to AWS EC2

## 🏗️ Architecture

The project is based on an AWS EC2 instance that hosts:

- Configuration files and scripts (Git repository)
- Docker containers managed by Docker Compose
- Music files stored locally on the instance

## 📋 Prerequisites

- AWS account (for EC2 instance)
- Docker and Docker Compose installed on EC2
- GitHub account (for repository and CI/CD workflows)
- Spotdl installed (locally or on the instance)
- SSH key configured as EC2_SSH_KEY in GitHub secrets

# ⚙️ Setup and Deployment

This section explains how to configure the environment, organise the required directories, and deploy the online radio system using Docker, Liquidsoap, and Icecast.

## 🧱 1. Project Structure

Below is a recommended directory structure for the project:

```
radio-online/
│
├── docker-compose.yml
├── liquidsoap/
│   └── script.liq
├── playlists/
│   └── playlist.m3u
├── music/
│   └── (audio files stored here)
├── scripts/
│   └── sync_playlists.sh
└── .env (optional)

```

## 🐳 2. Docker Configuration

**docker-compose.yml**

This file defines the services for Icecast and Liquidsoap:

```
version: '3.8'

services:
  icecast:
    image: moul/icecast
    container_name: icecast
    ports:
      - "8000:8000"
    volumes:
      - ./icecast_config/icecast.xml:/etc/icecast_config/
    environment:
      - TZ=Europe/London
    restart: unless-stopped

  liquidsoap:
    image: savonet/liquidsoap:rolling-release-v2.3.x
    container_name: liquidsoap
    volumes:
      - ./liquidsoap/script.liq:/etc/liquidsoap/script.liq   # path to your script.liq 
      - /home/ubuntu/music/music:/home/ubuntu/music/music
      - /home/ubuntu/playlists:/playlists                 # path to music dir
    environment:
      - TZ=Europe/London # change for your location otherwise, liquidsoap fuction properly.
    depends_on:
      - icecast
    command: liquidsoap /etc/liquidsoap/script.liq
    restart: unless-stopped

  nginx:
    image: nginx:latest
    container_name: nginx_proxy
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/conf.d/default.conf:/etc/nginx/conf.d/default.conf
      - ./landing_page/:/usr/share/nginx/html
      - /home/ubuntu/letsencrypt:/etc/letsencrypt
    ports:
      - "443:443"
      - "80:80"
    restart: unless-stopped
```

## 🎶 3. Liquidsoap Configuration
**script.liq**

This script controls how the music is played and streamed:

```
myplaylist = playlist(mode="random", reload_mode="watch", "/home/ubuntu/music/music/playlist.m3u")

primeira_playlist = playlist(mode="random", reload_mode="watch", "/playlists/playlist_1.m3u")
segunda_playlist = playlist(mode="random", reload_mode="watch", "/playlists/playlist_2.m3u")
terceira_playlist = playlist(mode="random", reload_mode="watch", "/playlists/playlist_3.m3u")

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
  name="your name",
  url="${ICECAST_HOSTNAME}",
  description="your description",
  radio
)
```


## 🤖 Music Automation and Synchronisation

To keep playlists always up to date, a hybrid solution was implemented using:

- A local Linux machine (Linux Mint)
- A cronjob running every minute
- A Bash script that interacts with Spotdl
- Synchronisation with the AWS EC2 instance

## 🔄 Cronjob Workflow


The automation works as follows:

    1. Every minute, a cronjob runs a Bash script on the local machine.
    2. The script checks configured Spotify playlists.
    3. If a new track is added:
        - It is downloaded locally using Spotdl
        - Then synchronised to the EC2 instance
    4. If a track is removed:
        - It is deleted locally
        - Then removed from the EC2 server as well
    5. The playlist file (.m3u) is automatically updated based on folder contents

## ⚙️ Playlist Configuration

Each music folder contains a playlist.conf file:

```
# playlist.conf
PLAYLIST_URL="https://open.spotify.com/playlist/..."
MUSIC_PATH="/home/ubuntu/music/music/10.Almoco_Brasileiro_Elegante/"
M3U_PATH="/home/ubuntu/playlists/playlist_1.m3u"
LOCAL="/home/notebook/Music/10.Almoco_Brasileiro_Elegante/"
```
## 🧾 Bash Script
```
#!/bin/bash
BASE_DIR="/home/notebook/Music"

for PLAYLIST_DIR in "$BASE_DIR"/*/; do
    if [ -f "${PLAYLIST_DIR}playlist.conf" ]; then
        source "${PLAYLIST_DIR}playlist.conf"
        
        /home/notebook/.local/bin/spotdl --sync-without-deleting "$PLAYLIST_URL" --output "$LOCAL"
        
        echo "Playlist updated in ${PLAYLIST_DIR}"

        sleep 10
    fi
done
```

## ⏱️ Cronjob Example
```
*/1 * * * * /home/notebook/devops/script_online_radio/script_test_cronjob.sh >> /home/notebook/cronjob.log 2>&1
```

#### What it does:
- Runs every minute
- Executes the script
- Logs output to a file for debugging

## 🔄 Synchronisation with AWS (EC2)

Music is synchronised using rsync over SSH:
```
rsync -az -e "ssh -i /home/notebook/devops/radio_online.pem" /home/notebook/Music/ ubuntu@EC2_IP:/home/ubuntu/music/music/
```

This ensures:

- Fast incremental updates
- Efficient bandwidth usage
- Consistency between local and cloud environments

## 🚀 CI/CD Pipeline

GitHub Actions is used to:

- Automatically deploy updates to EC2
- Restart containers if needed
- Maintain consistency between environments

## 🔮 Future Improvements

- Web interface for managing playlists
- Real-time dashboard (Now Playing, listeners)
- Mobile app integration
- Improved error handling and monitoring

## 🤝 Contributing

Contributions are welcome. Please open an issue or submit a pull request.

## 📄 Licence

This project is licensed under the MIT Licence.

## ✅ Final Notes

This setup combines:

- Local automation (cron + bash + spotdl)
- Cloud infrastructure (AWS EC2)
- Containerised streaming (Docker + Icecast + Liquidsoap)

The result is a fully automated, scalable online radio system.

