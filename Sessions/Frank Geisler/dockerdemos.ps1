#--------------------------------------------------------------------------
# Demo 1 - Gucken ob Docker läuft
# -------------------------------------------------------------------------
docker version

#--------------------------------------------------------------------------
# Demo 2 - SQL Server Container erzeugen
# -------------------------------------------------------------------------
docker search microsoft/mssql
docker pull microsoft/mssql-server-linux
docker images
docker container run -d -p 1433:1433 --env ACCEPT_EULA=Y --env SA_PASSWORD=!test123 --name sqlcontainer microsoft/mssql-server-linux
docker ps
docker inspect sqlcontainer
docker exec -it sqlcontainer bash
# In der bash shell
ls
cd /var/opt/mssql/data
ls
Exit
# Raus aus bash shell
docker cp c:\temp\Adventureworks.bak sqlcontainer:/var/opt/mssql/data/Adventureworks.bak
# adventureworks Backup wiederherstellen
docker container stop sqlcontainer 

#--------------------------------------------------------------------------
# Demo 2 - Angepasstes Container Image
# -------------------------------------------------------------------------
# ins Verzeichnis gehen
docker build . -t newsqlserverimage 
docker images 

#--------------------------------------------------------------------------
# Demo 3 - Image exportieren
# -------------------------------------------------------------------------
docker save -o newsqlserverimage.tar newsqlserverimage

#--------------------------------------------------------------------------
# Demo 4 - Image exportieren
# -------------------------------------------------------------------------
docker tag newsqlserverimage frankgeisler/newsqlserverimage:v1
docker login 
docker push frankgeisler/newsqlserverimage:v1

#--------------------------------------------------------------------------
# Demo 5 - Portainer
# -------------------------------------------------------------------------
docker volume create portainer_data
docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
