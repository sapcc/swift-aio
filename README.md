# swift-aio
Swift All In One (SAIO)

This bundles the instructions describe in Openstack Swift All In One documentation https://docs.openstack.org/swift/latest/development_saio.html and provides a SAIO environment for Openstack Swift software built with https://github.com/sapcc/swift/blob/stable/2023.1-m3/Dockerfile-sap and runs the follwoing test suites based on this:
* Unit tests
* Functional tests
* Probe tests

Alternativly you can just launch a SAIO and interact with it (see below).

## Building the container

```bash
docker build . --build-arg RELEASE=2023.1 -t saio:2023.1
```

## Running the tests

During the setup phase an XFS filesystem for temporary data and the actual Swift data is created and mounted. This requires `privileged` mode for the container to do mounts and unmounts of these filesystems.

```bash
docker run --rm --privileged saio:2023.1
```

## Launching SAIO and use it

```bash
docker run --rm -p 8080:8080 --privileged saio:2023.1 "/bin/bash" "-c" ". /var/lib/swift/.bashrc && /swift/bin/prepare.sh && exec /swift/bin/launch.sh"
```

Afterwards you can use the `python-swiftclient` to connect to SAIO:

```bash
$ swift -A http://127.0.0.1:8080/auth/v1.0 -U test:tester -K testing stat
               Account: AUTH_test
            Containers: 0
               Objects: 0
                 Bytes: 0
          Content-Type: text/plain; charset=utf-8
           X-Timestamp: 1688991393.36064
       X-Put-Timestamp: 1688991393.36064
                  Vary: Accept
            X-Trans-Id: tx73fe734565c746078538c-0064abf6a1
X-Openstack-Request-Id: tx73fe734565c746078538c-0064abf6a1
```
