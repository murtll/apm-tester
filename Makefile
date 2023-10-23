build:
	podman build . -t docker.io/murtll/apm-tester:latest
	podman push docker.io/murtll/apm-tester:latest

kube:
	kubectl -n example-hotrod delete -f pod.yaml
	kubectl -n example-hotrod apply -f pod.yaml