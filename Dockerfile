FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive
# Git
# Python — PyPI 
# Ruby — RubyGems
# Java — Maven and Gradle
# PHP — Composer
# Rust — Cargo.
# Go — Go Modules
# JavaScript/TypeScript — Yarn
# .NET — NuGet
RUN apt update && apt install -y python3 python3-pip npm maven gradle gem composer cargo yarn nuget git
