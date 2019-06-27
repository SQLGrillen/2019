sqlcmd -SSQLDEMO\SQL2016 -Q"IF DB_ID('SqlWorkload03') IS NULL CREATE DATABASE SqlWorkload03"

"%programfiles%\workloadtools\sqlworkload.exe" --File "%cd%\analyze.json"