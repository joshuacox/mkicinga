.PHONY: all help build run builddocker rundocker kill rm-image rm clean enter logs

all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make run       - build and run docker container

# run a plain container
init: rm pull rundocker

run: rm pull runprod

pull:
	docker pull icinga/icinga2

rundocker:
	$(eval TMP := $(shell mktemp -d --suffix=DOCKERTMP))
	$(eval NAME := $(shell cat NAME))
	$(eval TAG := $(shell cat TAG))
	chmod 777 $(TMP)
	@docker run --name=$(NAME) \
	--cidfile="cid" \
	-v $(TMP):/tmp \
	-d \
	-p 3080:80 \
	-v $(shell which docker):/bin/docker \
	-t $(TAG) \
	/bin/bash -c 'while true; do /opt/icinga2/initdocker; sleep 1; done'

runprod:
	$(eval MYSQL_DATADIR := $(shell cat MYSQL_DATADIR))
	$(eval ICINGA_DATADIR := $(shell cat ICINGA_DATADIR))
	$(eval TMP := $(shell mktemp -d --suffix=DOCKERTMP))
	$(eval NAME := $(shell cat NAME))
	$(eval TAG := $(shell cat TAG))
	chmod 777 $(TMP)
	@docker run --name=$(NAME) \
	--cidfile="cid" \
	-d \
	-p 3080:80 \
	-p 3443:443 \
	-p 5665:5665 \
	-v /var/run/docker.sock:/run/docker.sock \
	-v $(MYSQL_DATADIR):/var/lib/mysql \
	-v $(ICINGA_DATADIR)/lib/icinga2:/var/lib/icinga2 \
	-v $(ICINGA_DATADIR)/etc/icinga2:/etc/icinga2 \
	-v $(ICINGA_DATADIR)/etc/icingaweb2:/etc/icingaweb2 \
	-t $(TAG) \
	/bin/bash -c 'while true; do /opt/icinga2/initdocker; sleep 1; done'

bash:
	$(eval TMP := $(shell mktemp -d --suffix=DOCKERTMP))
	$(eval NAME := $(shell cat NAME))
	$(eval TAG := $(shell cat TAG))
	chmod 777 $(TMP)
	@docker run --name=$(NAME) \
	--cidfile="cid" \
	-v $(TMP):/tmp \
	-ti \
	-d \
	-p 3080:80 \
	-v $(shell which docker):/bin/docker \
	-t $(TAG) \
	/bin/bash


kill:
	-@docker kill `cat cid`

rm-image:
	-@docker rm `cat cid`
	-@rm cid

rm: kill rm-image

clean: rm

enter:
	docker exec -i -t `cat cid` /bin/bash

logs:
	docker logs -f `cat cid`

NAME:
	@while [ -z "$$NAME" ]; do \
		read -r -p "Enter the name you wish to associate with this container [NAME]: " NAME; echo "$$NAME">>NAME; cat NAME; \
	done ;

TAG:
	@while [ -z "$$TAG" ]; do \
		read -r -p "Enter the tag you wish to associate with this container [TAG]: " TAG; echo "$$TAG">>TAG; cat TAG; \
	done ;

rmall: rm

grab: grabicingadir grabmysqldatadir

grabmysqldatadir:
	-mkdir -p datadir
	docker cp `cat cid`:/var/lib/mysql  - |sudo tar -C datadir/ -pxvf -
	echo `pwd`/datadir/mysql > MYSQL_DATADIR
	sudo chown -R 27:sudo datadir/mysql

grabicingadir:
	-mkdir -p datadir/lib
	-mkdir -p datadir/etc
	docker cp `cat cid`:/var/lib/icinga2  - |sudo tar -C datadir/lib -pxvf -
	docker cp `cat cid`:/etc/icinga2  - |sudo tar -C datadir/etc/ -pxvf -
	docker cp `cat cid`:/etc/icingaweb2  - |sudo tar -C datadir/etc/ -pxvf -
	echo `pwd`/datadir > ICINGA_DATADIR

ICINGA_DATADIR:
	@while [ -z "$$ICINGA_DATADIR" ]; do \
		read -r -p "Enter the destination of the ICINGA data directory you wish to associate with this container [ICINGA_DATADIR]: " ICINGA_DATADIR; echo "$$ICINGA_DATADIR">>ICINGA_DATADIR; cat ICINGA_DATADIR; \
	done ;

MYSQL_DATADIR:
	@while [ -z "$$MYSQL_DATADIR" ]; do \
		read -r -p "Enter the destination of the MySQL data directory you wish to associate with this container [MYSQL_DATADIR]: " MYSQL_DATADIR; echo "$$MYSQL_DATADIR">>MYSQL_DATADIR; cat MYSQL_DATADIR; \
	done ;

MYSQL_PASS:
	@while [ -z "$$MYSQL_PASS" ]; do \
		read -r -p "Enter the MySQL password you wish to associate with this container [MYSQL_PASS]: " MYSQL_PASS; echo "$$MYSQL_PASS">>MYSQL_PASS; cat MYSQL_PASS; \
	done ;

