# Camel based implementation of the _open-data-apis_ API

## API Description ##
Open Banking open data apis

### Building

    mvn clean package

### Running Locally

    mvn spring-boot:run

Getting the API docs:

    curl http://localhost:8080/openapi.json

## Running on OpenShift

    mvn fabric8:deploy

You can expose the service externally using the following command:

    oc expose svc open-data-apis

And then you can access it's OpenAPI docs hosted by the service at:

    curl -s http://$(oc get route open-data-apis --template={{.spec.host}})/openapi.json
