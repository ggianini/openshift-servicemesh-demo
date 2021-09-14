#!/bin/bash

echo ""
echo "CREATE INVENTORY & CATALOG APPS"
echo ""

sh istio/scripts/deploy-inventory.sh user2  && \
sh istio/scripts/deploy-catalog.sh user2 3m

echo ""
echo "CHECK PODS"
echo ""

oc get pods -n user2-catalog --field-selector status.phase=Running
oc get pods -n user2-inventory --field-selector status.phase=Running

echo ""
echo "INJECT ENVOY SIDECAR ON DATABASES"
echo ""

oc patch dc/inventory-database -n user2-inventory --type='json' -p '[{"op":"add","path":"/spec/template/metadata/annotations", "value": {"sidecar.istio.io/inject": "'"true"'"}}]' && \
oc patch dc/catalog-database -n user2-catalog --type='json' -p '[{"op":"add","path":"/spec/template/metadata/annotations", "value": {"sidecar.istio.io/inject": "'"true"'"}}]' && \
oc rollout status -w dc/inventory-database -n user2-inventory && \
oc rollout status -w dc/catalog-database -n user2-catalog 1m

echo ""
echo "INJECT ENVOY SIDECAR ON APPS"
echo ""

oc patch dc/inventory -n user2-inventory --type='json' -p '[{"op":"add","path":"/spec/template/metadata/annotations", "value": {"sidecar.istio.io/inject": "'"true"'"}}]' && \
oc rollout latest dc/inventory -n user2-inventory && \
oc patch dc/catalog-springboot -n user2-catalog --type='json' -p '[{"op":"add","path":"/spec/template/metadata/annotations", "value": {"sidecar.istio.io/inject": "'"true"'"}}]' && \
oc rollout status -w dc/inventory -n user2-inventory && \
oc rollout status -w dc/catalog-springboot -n user2-catalog 1m


oc get pods -n user2-inventory --field-selector="status.phase=Running"
oc get pods -n user2-catalog --field-selector="status.phase=Running"

