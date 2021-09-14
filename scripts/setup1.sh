#!/bin/bash
echo ""
echo "USE PROJECT"
echo ""
oc project user2-istio-system

oc create -n user2-istio-system -f -<<EOF
apiVersion: maistra.io/v1
kind: ServiceMeshMemberRoll
metadata:
  name: default
  namespace: user2-istio-system 
spec:
  members:
    - user2-bookinfo 
    - user2-catalog
    - user2-inventory
EOF


echo ""
echo "CREATE BOOKINFO APP"
echo ""
oc apply -n user2-bookinfo -f istio/bookinfo.yaml
echo ""
echo "CREATE GATEWAY"
echo ""
oc apply -n user2-bookinfo -f istio/bookinfo-gateway.yaml
echo "route url:"
export BOOK_URL=$(oc get routes -n user2-istio-system | grep istio-ingressgateway | awk  '{print $2}')
echo istio-ingressgateway-user2-istio-system.apps.cluster-jwn6r.jwn6r.sandbox1508.opentlc.com
echo ""
echo "CREATE DESTINATION RULES"
echo ""
oc apply -n user2-bookinfo -f istio/destination-rule-all.yaml
echo ""
echo "SHOW DESTINATION RULES"
echo ""
oc get -n user2-bookinfo destinationrules
echo ""
echo "ADD LABELS"
echo ""

oc project user2-bookinfo && \
oc label deployment/productpage-v1 app.openshift.io/runtime=python --overwrite && \
oc label deployment/details-v1 app.openshift.io/runtime=ruby --overwrite && \
oc label deployment/reviews-v1 app.openshift.io/runtime=java --overwrite && \
oc label deployment/reviews-v2 app.openshift.io/runtime=java --overwrite && \
oc label deployment/reviews-v3 app.openshift.io/runtime=java --overwrite && \
oc label deployment/ratings-v1 app.openshift.io/runtime=nodejs --overwrite && \
oc label deployment/details-v1 app.kubernetes.io/part-of=bookinfo --overwrite && \
oc label deployment/productpage-v1 app.kubernetes.io/part-of=bookinfo --overwrite && \
oc label deployment/ratings-v1 app.kubernetes.io/part-of=bookinfo --overwrite && \
oc label deployment/reviews-v1 app.kubernetes.io/part-of=bookinfo --overwrite && \
oc label deployment/reviews-v2 app.kubernetes.io/part-of=bookinfo --overwrite && \
oc label deployment/reviews-v3 app.kubernetes.io/part-of=bookinfo --overwrite && \
oc annotate deployment/productpage-v1 app.openshift.io/connects-to=reviews-v1,reviews-v2,reviews-v3,details-v1 && \
oc annotate deployment/reviews-v2 app.openshift.io/connects-to=ratings-v1 && \
oc annotate deployment/reviews-v3 app.openshift.io/connects-to=ratings-v1

echo ""
echo "CHECK ROLLOUTS"
echo ""

oc rollout status -n user2-bookinfo -w deployment/productpage-v1 && \
oc rollout status -n user2-bookinfo -w deployment/reviews-v1 && \
oc rollout status -n user2-bookinfo -w deployment/reviews-v2 && \
oc rollout status -n user2-bookinfo -w deployment/reviews-v3 && \
oc rollout status -n user2-bookinfo -w deployment/details-v1 && \
oc rollout status -n user2-bookinfo -w deployment/ratings-v1

echo ""
echo "CHECK PODS"
echo ""

oc get pods -n user2-bookinfo --selector app=reviews

