# Deprecated - the official image is no longer maintained

Try this instead:
https://github.com/joshuacox/docker-icinga2

# mkicinga



Make an incinga monitor in a docker container

First initialize a new instance

```
make init
```

Now grab the important directories for persistence

```
make grab
```

move datadir whereever you like but update DATADIR

```
make prod
```
