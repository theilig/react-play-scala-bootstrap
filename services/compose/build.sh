version=`perl services/compose/update_version.pl`
cd ui && npm run build
cd .. && sbt docker:publishLocal
docker build -f services/nginx/Dockerfile -t rpsbs-nginx:1.0 .
docker tag rpsbs-nginx:1.0 gcr.io/<your repo here>rpsbs-nginx:$version
docker tag rpsbs:1.0 gcr.io/<your repo here>/rpsbs:$version
docker push gcr.io/<your repo here>/rpsbs:$version
docker push gcr.io/<your repo here>/rpsbs-nginx:$version
