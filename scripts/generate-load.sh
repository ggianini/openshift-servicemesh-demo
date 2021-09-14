#!/bin/sh
export BOOK_URL=$(oc get routes -n user1-istio-system | grep istio-ingressgateway | awk  '{print $2}')
for i in {1..10000} ; do curl -o /dev/null -s -w "%{http_code}\n" http://$BOOK_URL/productpage ; sleep 2 ; done
