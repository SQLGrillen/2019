sqlcmd -SSQLDEMO\SQL2016 -Q"IF DB_ID('SqlWorkload04') IS NULL CREATE DATABASE SqlWorkload04"

"%programfiles%\workloadtools\sqlworkload.exe" --File "%cd%\replay.json"