kube:
	mkdir -p ./kubeconfig
	docker compose up agent server

down:
	docker compose down -v

tf-shell:
	docker compose run --rm --entrypoint='' terraform /bin/ash

exec-server:
	docker exec -it $(shell docker ps -f label=ai.harrison.container.name=k3s-server -q) /bin/ash

exec-agent:
	docker exec -it $(shell docker ps -f label=ai.harrison.container.name=k3s-agent -q) /bin/ash
