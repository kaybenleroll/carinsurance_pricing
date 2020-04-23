DOCKER_USER=mcooney

PROJECT_USER=kaybenleroll
PROJECT_NAME=carinsurance_pricing
PROJECT_LABEL=latest

IMAGE_TAG=${PROJECT_USER}/${PROJECT_NAME}:${PROJECT_LABEL}

RSTUDIO_PORT=8788


echo-reponame:
	echo "${REPO_NAME}"


10_carinspricing_exploration.html: 10_carinspricing_exploration.Rmd
	Rscript -e 'rmarkdown::render("10_carinspricing_exploration.Rmd")'

20_carinspricing_initmodel.html: 10_carinspricing_exploration.html \
                                 20_carinspricing_initmodel.Rmd
	Rscript -e 'rmarkdown::render("20_carinspricing_initmodel.Rmd")'

30_carinspricing_calcprices.html: 20_carinspricing_initmodel.html \
                                  30_carinspricing_calcprices.Rmd
	Rscript -e 'rmarkdown::render("30_carinspricing_calcprices.Rmd")'

40_carinspricing_modelcheck.html: 30_carinspricing_calcprices.html \
                                  40_carinspricing_modelcheck.Rmd
	Rscript -e 'rmarkdown::render("40_carinspricing_modelcheck.Rmd")'

render-all:
	Rscript -e 'rmarkdown::render("10_carinspricing_exploration.Rmd")'
	Rscript -e 'rmarkdown::render("20_carinspricing_initmodel.Rmd")'
	Rscript -e 'rmarkdown::render("30_carinspricing_calcprices.Rmd")'
	Rscript -e 'rmarkdown::render("40_carpricing_modelcheck.Rmd")'

all-html: 10_carinspricing_exploration.html \
          20_carinspricing_initmodel.html \
          30_carinspricing_calcprices.html \
          40_carinspricing_modelcheck.html

clean-html:
	rm -rfv *.html

clean-cache:
	rm -rfv 10_carinspricing_exploration_cache
	rm -rfv 10_carinspricing_exploration_files
	rm -rfv 20_carinspricing_initmodel_cache
	rm -rfv 20_carinspricing_initmodel_files
	rm -rfv 30_carinspricing_calcprices_cache
	rm -rfv 30_carinspricing_calcprices_files
	rm -rfv 40_carinspricing_modelcheck_cache
	rm -rfv 40_carinspricing_modelcheck_files


docker-build-image: Dockerfile
	docker build -t ${IMAGE_TAG} -f Dockerfile .

docker-run:
	docker run --rm -d \
	  -p ${RSTUDIO_PORT}:8787 \
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
