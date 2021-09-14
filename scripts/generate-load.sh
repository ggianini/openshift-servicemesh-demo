#!/bin/sh
export BOOK_URL=$(oc get routes -n user1-istio-system | grep istio-ingressgateway | awk  '{print $2}')
for i in {1..10000} ; do curl -o /dev/null -s -w "%{http_code}\n" http://istio-ingressgateway-user1-istio-system.apps.cluster-jwn6r.jwn6r.sandbox1508.opentlc.com/productpage ; sleep 2 ; done
