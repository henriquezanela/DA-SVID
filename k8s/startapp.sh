##########################################
#\/ \/ \/ Similar to startapp.sh \/ \/ \/#
##########################################
kubectl delete --all deployments
kubectl delete --all service

DESTINATION_FOLDER="/DASVID_POC_K8S"

minikube image load asserting-wl
cd "${DESTINATION_FOLDER}/Assertingwl-mTLS"
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
sleep 0.5

minikube image load subject-wl
cd "${DESTINATION_FOLDER}/subject_workload"
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
sleep 0.5

minikube image load target-wl
cd "${DESTINATION_FOLDER}/target_workload"
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
sleep 0.5

minikube image load middle-tier
cd "${DESTINATION_FOLDER}/middle-tier"
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
sleep 0.5
##########################################
#/\ /\ /\ Similar to startapp.sh /\ /\ /\#
##########################################
