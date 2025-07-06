#!/bin/bash

SRC_POD="$1"
DST_SVC="$2"
DST_PORT="$3"

if [[ -z "$SRC_POD" || -z "$DST_SVC" || -z "$DST_PORT" ]]; then
  echo "Usage: $0 <source-pod> <target-service> <port>"
  exit 1
fi

echo "ÔøΩÔøΩ Checking pod status..."
kubectl get pods -o wide

echo -e "\nÌ¥ç Checking DNS resolution from $SRC_POD to $DST_SVC..."
kubectl exec "$SRC_POD" -- nslookup "$DST_SVC"

echo -e "\nÌ¥ç Pinging service from $SRC_POD..."
kubectl exec "$SRC_POD" -- ping -c 3 "$DST_SVC"

echo -e "\nÌ¥ç Curling service on port $DST_PORT..."
kubectl exec "$SRC_POD" -- curl -m 5 "http://$DST_SVC:$DST_PORT"

echo -e "\nÌ¥ç Getting service endpoints..."
kubectl get endpoints "$DST_SVC"

echo -e "\nÌ¥ç Listing Network Policies..."
kubectl get networkpolicy

echo -e "\nÌ¥ç Getting logs from $SRC_POD..."
kubectl logs "$SRC_POD" --tail=20

echo -e "\n‚úÖ Check complete."

