DOCKER_USER=rstudio
PROJECT_USER=kaybenleroll
PROJECT_NAME=carinsurance_pricing


docker-build-image: Dockerfile
	docker build -t ${PROJECT_USER}/${PROJECT_NAME} -f Dockerfile .

docker-run: docker-stop
	docker run --rm -d -p 8787:8787 \
	  -v "${PWD}":"/home/${DOCKER_USER}/${PROJECT_NAME}":rw \
	  -e PASSWORD=quickpass \
	  ${PROJECT_USER}/${PROJECT_NAME}

docker-stop:
	docker stop $(shell docker ps -q -a)

docker-clean:
	docker rm $(shell docker ps -q -a)

