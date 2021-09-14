#!/bin/sh
export BOOK_URL=$(oc get routes -n user1-istio-system | grep istio-ingressgateway | awk  '{print $2}')
if [ -z "$BOOK_URL" ]
then
echo "\$BOOK_URL is empty"
else
find ../ -type f -name "*.yaml" -exec sed -i "s/teste/$BOOK_URL/g" {} \;
fi
