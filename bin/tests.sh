#!/bin/sh

set -e

TOP_DIR=/usr/local/src/swift

echo "==== Unit tests ===="
cd $TOP_DIR/test/unit
# Skip IPv6 test - not all container runtimes have support enabled for this
pytest -k "not test_get_conns_v6_default and not test_get_conns_v6 and not test_get_conns_hostname6"
rvalue=$?
cd -
if [ $rvalue -ne 0 ]; then exit $rvalue; fi

/swift/bin/resetswift
swift-init main start
echo "==== Func tests ===="
if [ "$RELEASE" = "zed" ]; then
  cd $TOP_DIR/test/functional
  # TODO Remove the Zed related special handling of skippng test
  # Skip some S3API tests for Zed as they dont work with the 2023.1 test environment
  pytest -k "not test_put_object_invalid_x_delete_at and not test_put_object_invalid_x_delete_after and not test_absolute_form_request and not TestS3ApiBucket and not TestS3ApiXxeInjection"
else
  $TOP_DIR/.functests
fi

/swift/bin/resetswift
echo "==== Probe tests ===="
if [ "$RELEASE" = "zed" ]; then
  cd $TOP_DIR/test/probe
  # TODO Remove the Zed related special handling of skippng test
  # Skip ContainerSharding tests for Zed as they dont work with the 2023.1 test environment
  pytest -k "not ContainerSharding"
else
  $TOP_DIR/.probetests
fi
rvalue=$?
cd -
if [ $rvalue -ne 0 ]; then exit $rvalue; fi

echo "All tests runs fine"

exit 0
