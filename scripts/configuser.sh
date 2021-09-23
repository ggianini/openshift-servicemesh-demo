#!/bin/sh
find /home/demo/openshift-servicemesh-demo/scripts/ -type f -name "*.sh" -exec sed -i "s/user1/user1/g" {} \;
