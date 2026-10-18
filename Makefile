.PHONY: install test build run docker-build docker-up

install:
	cd Frontend && npm ci

test:
	cd Frontend && npm run lint

build:
	cd Frontend && npm run build

run:
	cd Frontend && npm run dev

# Needed from M4 onwards
docker-build:
	docker build -t craftcv:latest .

docker-up:
	docker compose up -d --build
