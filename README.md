# swift-aio
Swift All In One (SAIO)

Provides a SAIO environment for Openstack Swift software built with https://github.com/sapcc/swift/blob/stable/2023.1-m3/Dockerfile-sap and runs the follwoing test suites based on this:
* Unit tests
* Functional tests
* Probe tests

## Building the container

```bash
docker build . --progress plain --build-arg RELEASE=2023.1 -t saio:2023.1
```

## Running the tests

During the setup phase an XFS filesystem for temporary data and the actual Swift data is created and mounted. This requires `privileged` mode for the container to do mounts and unmounts of these filesystems.

```bash
docker run --rm --privileged saio:2023.1
```
