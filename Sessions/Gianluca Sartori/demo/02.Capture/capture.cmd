sqlcmd -SSQLDEMO\SQL2016 -Q"IF DB_ID('SqlWorkload02') IS NULL CREATE DATABASE SqlWorkload02"

del sqlworkload.sqlite /Q

"%programfiles%\workloadtools\sqlworkload.exe" --File "%cd%\capture.json"