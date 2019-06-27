sqlcmd -SSQLDEMO\SQL2016 -Q"IF DB_ID('SqlWorkload01') IS NULL CREATE DATABASE SqlWorkload01"

"%programfiles%\workloadtools\sqlworkload.exe" --File "%cd%\analyze.json"