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

echo "==== Unit tests completed ===="
/swift/bin/resetswift
swift-init main start
echo "==== Func tests ===="
$TOP_DIR/.functests

/swift/bin/resetswift
echo "==== Probe tests ===="
$TOP_DIR/.probetests
rvalue=$?
cd -
if [ $rvalue -ne 0 ]; then exit $rvalue; fi

echo "All tests runs fine"

exit 0
