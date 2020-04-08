DOCKER_USER=mcooney

PROJECT_USER=kaybenleroll
PROJECT_NAME=carinsurance_pricing
PROJECT_LABEL=latest

IMAGE_TAG=${PROJECT_USER}/${PROJECT_NAME}:${PROJECT_LABEL}


10_carinspricing_exploration.html: 10_carinspricing_exploration.Rmd
	Rscript -e 'Rmarkdown::render("10_carinspricing_exploration.Rmd")'

20_carinspricing_initmodel.html: 10_carinspricing_exploration.html \
                                 20_carinspricing_initmodel.Rmd
	Rscript -e 'Rmarkdown::render("20_carinspricing_initmodel.Rmd")'

30_carinspricing_calcprices.html: 20_carinspricing_initmodel.html \
                                  30_carinspricing_calcprices.Rmd
	Rscript -e 'Rmarkdown::render("30_carinspricing_calcprices.Rmd")'

render-all:
	Rscript -e 'Rmarkdown::render("10_carinspricing_exploration.Rmd")'
	Rscript -e 'Rmarkdown::render("20_carinspricing_exploration.Rmd")'
	Rscript -e 'Rmarkdown::render("30_carinspricing_exploration.Rmd")'
	Rscript -e 'Rmarkdown::render("40_carinspricing_exploration.Rmd")'


all-html: 10_carinspricing_exploration.html \
          20_carinspricing_initmodel.html \
          30_carinspricing_calcprices.html

docker-build-image: Dockerfile
	docker build -t ${IMAGE_TAG} -f Dockerfile .

docker-run:
	docker run --rm -d \
	  -p 8787:8787 \
	  -v "${PWD}":"/home/${DOCKER_USER}/${PROJECT_NAME}":rw \
	  -e USER=${DOCKER_USER} \
	  -e PASSWORD=quickpass \
	  ${IMAGE_TAG}

docker-stop:
	docker stop $(shell docker ps -q -a)

docker-clean:
	docker rm $(shell docker ps -q -a)

docker-pull:
	docker pull ${IMAGE_TAG}

docker-push:
	docker push ${IMAGE_TAG}
