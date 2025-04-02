# Online Radio - Radio Lucas

Este projeto implementa uma rádio online utilizando containers Docker com Icecast e Liquidsoap, rodando em uma instância EC2 na AWS. O ambiente foi configurado para transmitir músicas a partir de uma playlist (.m3u) e conta com automações para sincronizar novas músicas baixadas via [spotdl](https://github.com/ritiek/spotify-downloader) e atualizar a playlist automaticamente. Além disso, há um pipeline CI/CD via GitHub Actions para facilitar o deploy e a manutenção do ambiente.

## Sumário

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Pré-requisitos](#pré-requisitos)
- [Estrutura de Diretórios](#estrutura-de-diretórios)
- [Configuração e Deploy](#configuração-e-deploy)
- [Automação e Atualização de Músicas](#automação-e-atualização-de-músicas)
- [Pipeline CI/CD](#pipeline-cicd)
- [Futuras Melhorias](#futuras-melhorias)
- [Contribuição](#contribuição)
- [Licença](#licença)

## Visão Geral

Este projeto tem como objetivo criar uma rádio online robusta e de baixo custo, utilizando:

- **Docker Compose:** Para orquestrar os containers do Icecast e do Liquidsoap.
- **Icecast:** Servidor de streaming de áudio.
- **Liquidsoap:** Script para gerenciar a playlist, compressão do áudio e enviar o fluxo para o Icecast.
- **Spotdl:** Script para download automático de músicas a partir de playlists do Spotify.
- **GitHub Actions:** Pipeline CI/CD para automatizar o deploy na instância EC2 da AWS.

## Arquitetura

A arquitetura do projeto é baseada em uma instância EC2 na AWS, que hospeda:
- Os arquivos de configuração e scripts (Git repository).
- Os containers Docker, gerenciados pelo Docker Compose.
- Os arquivos de música (armazenados localmente na instância).

![Arquitetura do Projeto]  

## Pré-requisitos

- **Conta AWS:** Para criar a instância EC2.
- **Docker e Docker Compose:** Instalados na instância EC2.
- **GitHub Account:** Para utilizar o repositório e configurar os workflows de CI/CD.
- **Spotdl:** Instalado na instância ou incluído no script para download de músicas.
- **Chave SSH:** Para permitir que o GitHub Actions se conecte à instância EC2 (armazenada como secret `EC2_SSH_KEY`).



