# sakai-ldap
Mostra com crear una imatge de Sakai configurada per a autenticar contra LDAP i construir un entorn docker compose per a fer-la anar.

## Passos
### Construcció de la imatge
docker build . -t udl/sakai

### Edició dels fitxers de configuració
Ficar a config/sakai.properties els paràmetres correctes de configuració del directori ldap.

### Arrencada
docker compose up
