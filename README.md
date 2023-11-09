# sakai-ldap
Mostra com crear una imatge de Sakai configurada per a autenticar contra LDAP i construir un entorn docker compose per a fer-la anar.

## Passos
### Construcció de la imatge
docker build . -t udl/sakai

### Edició dels fitxers de configuració
Ficar a config/sakai.properties els paràmetres correctes de configuració del directori ldap.

### Arrencada
docker compose up

## Afegir SAML
# Descarregar dades del nostre IdP
- Anar a Metadatos -> Metadatos propios -> SAML2
- Copiar dades en un fitxer xml
- Ficar el fitxer a una ubicació del tomcat

# Descomentar SAML a xlogin-content
Al fitxer sakai/login/login-tool/tool/src/webapp/WEB-INF/applicationContext.xml descomentar línia  <!-- import resource="xlogin-context.saml.xml" / -->

# Configurar IdP a sakai/login/login-tool/tool/src/webapp/WEB-INF/xlogin-context.saml.xml
Canviar 

<!-- Filter automatically generates default SP metadata -->
    <bean id="metadataGeneratorFilter" class="org.springframework.security.saml.metadata.MetadataGeneratorFilter">

Ficar la nostra entitat a <property name="entityId" ....

A un dels <bean class="org.springframework.security.saml.metadata.ExtendedMetadataDelegate"> ficar el path al fitxer de metadades del nostre IdP
<constructor-arg value="/urs/local/tomcat/sakai/autenticaciopreprod-metadata.xml"/>

# Canviar sakai.properties

top.login=false
\# Enable SSO login
container.login=true
login.text=ADFS Login
\# Second login link (bypasses container auth)
xlogin.enabled=true
xlogin.text=Guest Login
login.use.xlogin.to.relogin=false
\# Enable the auth choice page. Only set this if container.login=true
login.auth.choice=true
\# Set the icon or text you want for each. Generally you wouldn't use
both.
container.login.choice.text=ADFS Login
xlogin.choice.text = Guest Login
\# SAML logout (ADFS) for account types that can authenticate via SSO
loggedOutUrl.staff=/sakai-login-tool/container/saml/logout
loggedOutUrl.student=/sakai-login-tool/container/saml/logout
