docker build -t currencyservice .
docker tag currencyservice:latest 159616352881.dkr.ecr.eu-west-1.amazonaws.com/microservices-demo-currencyservice:latest
docker push 159616352881.dkr.ecr.eu-west-1.amazonaws.com/microservices-demo-currencyservice:latest
