# JFStack — Wazuh Agent Linux 4.14.7

Instalador para añadir un servidor Debian/Ubuntu como agente del Wazuh Manager
4.14.7.

El nombre del agente se obtiene automáticamente de:

```bash
hostname -s
```

y se pasa explícitamente a la instalación como `WAZUH_AGENT_NAME`.

Wazuh permite definir `WAZUH_AGENT_NAME` como variable de despliegue. Si no se
define, el agente usa el hostname del endpoint. Este proyecto lo establece de
forma explícita para dejar el comportamiento visible y reproducible.

No se asigna ningún grupo por defecto. Por tanto, este proyecto no fuerza
grupos como `Debian`; el agente se enrola en el comportamiento predeterminado
del manager salvo que se configure posteriormente.

## Requisitos

- Debian o Ubuntu.
- Privilegios root para la instalación.
- Acceso HTTPS a `packages.wazuh.com`.
- Conectividad hacia el manager:
  - TCP/1514 para comunicación del agente.
  - TCP/1515 para enrollment.
- Hostname único.

Comprueba:

```bash
hostname -s
```

No uses `localhost` ni un hostname duplicado entre agentes.

## Configuración

```bash
make init
nano .env
```

Configura:

```dotenv
WAZUH_MANAGER=192.0.2.10
WAZUH_REGISTRATION_SERVER=192.0.2.10
WAZUH_REGISTRATION_PASSWORD=
WAZUH_AGENT_VERSION=4.14.7-1
```

`.env` contiene configuración local y, si se usa, la contraseña de
enrollment. Está excluido de Git y `make init` lo establece a modo `0600`.

El script nunca evalúa `.env` como código shell.

## Instalación

```bash
sudo make install
```

El instalador:

1. valida Debian/Ubuntu;
2. obtiene el hostname corto;
3. configura el repositorio oficial Wazuh 4.x;
4. comprueba que `4.14.7-1` está disponible;
5. instala exactamente esa versión;
6. usa el hostname como `WAZUH_AGENT_NAME`;
7. no define `WAZUH_AGENT_GROUP`;
8. habilita e inicia `wazuh-agent`;
9. deja el paquete en `apt-mark hold` para evitar una actualización accidental
   a una versión más nueva que el manager.

Si ya existe otra versión del agente, el script se detiene en vez de realizar
una actualización/downgrade silenciosa.

## Validación

```bash
make check
make status
```

Logs:

```bash
make logs
```

En el manager Docker puedes listar los agentes con:

```bash
docker compose exec wazuh.manager /var/ossec/bin/agent_control -l
```

El nombre esperado será el resultado de `hostname -s` en el servidor agente.

## Firewall

Desde el agente debe existir conectividad hacia el manager en TCP/1514 y
TCP/1515. No es necesario exponer puertos entrantes en el servidor agente para
el funcionamiento normal de Wazuh Agent.

## Desinstalación

No hay un objetivo `make uninstall` destructivo. Consulta
`scripts/uninstall.sh`; muestra los comandos necesarios pero no elimina nada
automáticamente.

La eliminación del paquete en el endpoint no elimina la entrada correspondiente
del manager.

## Git

Versiona:

```text
.env.example
Makefile
README.md
scripts/
```

No versiones:

```text
.env
```
