#!/usr/bin/env bash

#
set -eu

#
##
docker_check() {
    OK=true

    # check if docker is installed
    if [ ! -x "$(command -v docker)" ]; then
        echo "\033[1;31mERROR: Docker is not installed!\033[0m"
        echo "    -: https://docs.docker.com/install"
        OK=false
    fi

    # check for docker-compose is installed
    if [ ! -x "$(command -v docker-compose)" ]; then
        echo "\033[1;31mERROR: Docker Compose is not installed!\033[0m"
        echo "    -: https://docs.docker.com/compose/install"
        OK=false
    fi

    # cant continue, exit with status code 1
    if [ ! $OK ]; then
        exit 1
    fi
}

#
##
setup() {
    docker_check
}

#
##
install() {
    #
    export IS_RESTART=false

    # get current user and group id
    export CURRENT_UID=$(id -u):$(id -g)

    # shutdown and remove containers
    docker-compose down -v

    # cleanup
    docker network prune -f
    docker system prune --volumes -f

    # build image
    docker-compose build

    #
    docker-compose up
}

#
##
restart() {
    #
    export IS_RESTART=true

    # get current user and group id
    export CURRENT_UID=$(id -u):$(id -g)

    #
    docker-compose up
}

#
##
main () {
    #
    setup
    
    # check if containers are already created
    if [ "$(docker ps -aq -f name=s3)" ] && [ "$FORCE_START" = true ]; then
		restart
	else
		# check if containers are already created
		if [ "$(docker ps -aq -f name=s3)" ] && [ "$FORCE_INSTALL" = false ]; then

			echo -e >&2 "\033[1;31mS3 container(s) already exist!\033[0m"

			PS3='What would you like to do?: '
			options=("Restart" "Remove and Install" "Quit")
			select opt in "${options[@]}"
			do
				case $opt in
					"Restart")
						echo >&2 "Restarting existing containers"
						restart
						break
						;;
					"Remove and Install")
						echo >&2 "Replacing existing containers"
						install
						break
						;;
					"Quit")
						break
						;;
					*) echo >&2 "Invalid choice $REPLY, please enter [1, 2 or 3]";;
				esac
			done
		else
			install
		fi
    fi
}

# check for -f (force) flag
# npm run docker-dev -- -f
FORCE_INSTALL=false
# npm run docker-dev -- -s
FORCE_START=false

while test $# != 0
do
    case "$1" in
    -f) FORCE_INSTALL=true ;;
    -F) FORCE_INSTALL=true ;;
    -s) FORCE_START=true ;;
    -S) FORCE_START=true ;;
    *)  break ;;
    esac
    shift
done

main
