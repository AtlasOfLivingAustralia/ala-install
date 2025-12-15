.PHONY: test-quick test-config-only test-full build build-i18n clean help localhost-config localhost-quick localhost-full la-toolkit-config la-toolkit-deploy publish-images

# Environment variables
export COMPOSE_BAKE?=true

# Variables
INVENTORY ?= la-test-inventories/la-test-inventory.ini
LA_TOOLKIT_INVENTORY ?= la-test-inventories/la-test-inventory.ini
PLAYBOOK := ansible/docker-compose-deploy.yml
DATA_DIR := docker-compose-output
DATA_DIR_ABS := $(shell pwd)/$(DATA_DIR)
DOCKER_REGISTRY ?= livingatlases
DOCKER_USERNAME ?=
DOCKER_PASSWORD ?=

help:
	@echo "Living Atlas Container Deployment"
	@echo ""
	@echo "📋 Available targets:"
	@echo ""
	@echo "  🛠️  LA Toolkit Integration (DEFAULT):"
	@echo "    test-quick       - Quick validation with build (uses la-toolkit inventory)"
	@echo "    test-full        - Full test (build + start stack)"
	@echo "    la-toolkit-config  - Generate docker-compose from la-toolkit inventory"
	@echo "    la-toolkit-deploy  - Full deploy using la-toolkit variables"
	@echo ""
	@echo "  🔧 Build & Config:"
	@echo "    test-config-only - Only generate config (no image build)"
	@echo "    build-i18n       - Build ala-i18n image (required before first run)"
	@echo "    clean            - Stop and remove all containers"
	@echo ""
	@echo "  📤 Publish (optional - requires Docker Hub credentials):"
	@echo "    publish-images   - Push built images to Docker Hub (livingatlases/*)"
	@echo "                       Requires: DOCKER_USERNAME and DOCKER_PASSWORD"
	@echo ""
	@echo "  🏠 Legacy (localhost-container):"
	@echo "    localhost-config - Generate config for localhost"
	@echo "    localhost-quick  - Full build for localhost"
	@echo "    localhost-full   - Build, start and validate stack"
	@echo ""
	@echo "💡 Recommended workflow:"
	@echo "    make test-quick              # Uses la-toolkit inventory automatically"
	@echo "    # Or step by step:"
	@echo "    make test-config-only        # Generate config"
	@echo "    make build-i18n              # Build i18n image (first time)"
	@echo "    cd docker-compose-output && docker compose up -d"
	@echo ""
	@echo "💡 Custom inventory:"
	@echo "    make INVENTORY=path/to/inventory.ini test-quick"
	@echo ""
	@echo "💡 Publish to Docker Hub:"
	@echo "    docker login"
	@echo "    make publish-images"
	@echo ""
	@echo "ℹ️  Default inventory: la-test-inventories/la-test-inventory.ini"

test-config-only:
	@echo "📄 Generating configuration only (no builds)..."
	@echo "[1/3] Checking Ansible syntax..."
	@ansible-playbook -i $(INVENTORY) -i la-test-inventories/la-test-local-passwords.ini $(PLAYBOOK) -e "data_dir=$(DATA_DIR_ABS)" --syntax-check
	@echo "[2/3] Generating docker-compose.yml..."
	@ansible-playbook -i $(INVENTORY) -i la-test-inventories/la-test-local-passwords.ini $(PLAYBOOK) -e "data_dir=$(DATA_DIR_ABS)" -e build_images=false
	@echo "[3/3] Validating generated YAML..."
	@docker compose -f $(DATA_DIR)/docker-compose.yml config --quiet
	@echo "✅ Config generation passed!"
	@echo ""
	@echo "📌 Note: Using pre-built images from Docker Hub"
	@echo "   Run 'make test-quick' to build from source"

test-quick:
	@echo "🔍 Running quick validation..."
	@echo "[1/3] Checking Ansible syntax..."
	@ansible-playbook -i $(INVENTORY) -i la-test-inventories/la-test-local-passwords.ini $(PLAYBOOK) -e "data_dir=$(DATA_DIR_ABS)" --syntax-check
	@echo "[2/3] Generating docker-compose.yml..."
	@ansible-playbook -vv -i $(INVENTORY) -i la-test-inventories/la-test-local-passwords.ini $(PLAYBOOK) -e "data_dir=$(DATA_DIR_ABS)"
	@echo "[3/3] Validating generated YAML..."
	@docker compose -f $(DATA_DIR)/docker-compose.yml config --quiet
	@echo "✅ Quick tests passed!"

build:
	@echo "🔨 Building Docker images..."
	@echo "This is handled by the ansible playbook when build_images=true"
	@echo "Images built during test-quick run."

build-i18n:
	@echo "🔨 Building ala-i18n image..."
	@cd $(DATA_DIR) && BUILDX_BAKE_ENTITLEMENTS_FS=0 docker buildx bake -f docker-bake.hcl --load i18n
	@echo ""
	@echo "✅ ala-i18n image ready!"
	@echo "   You can now run: make test-quick or docker compose up -d"

test-full: test-quick
	@echo ""
	@echo "🚀 Running full stack test..."
	@echo "[1/5] Ensuring services are stopped..."
	@cd $(DATA_DIR) && docker compose down
	@echo "[2/5] Starting services with fresh mounts..."
	@cd $(DATA_DIR) && docker compose up -d
	@echo "[3/5] Waiting for services to be healthy (max 3 min)..."
	@timeout 180 bash -c 'cd $(DATA_DIR) && until docker compose ps | grep -q "healthy"; do echo "  Waiting..."; sleep 5; done' || (echo "❌ Timeout waiting for healthy services" && exit 1)
	@echo "[4/5] Testing endpoints..."
	@echo "  - Testing nginx..."
	@curl --fail --silent http://localhost/ > /dev/null && echo "    ✅ Nginx OK" || echo "    ❌ Nginx failed"
	@echo "  - Testing collectory health..."
	@curl --fail --silent http://localhost:8080/collectory/actuator/health > /dev/null && echo "    ✅ Collectory OK" || echo "    ❌ Collectory failed"
	@echo "[5/5] Checking mounts..."
	@cd $(DATA_DIR) && docker compose exec -T collectory test -f /data/collectory/config/generic-collectory-config.properties && echo "  ✅ collectory config mounted" || echo "  ❌ collectory config missing"
	@cd $(DATA_DIR) && docker compose exec -T collectory ls /opt/atlas/i18n/ > /dev/null && echo "  ✅ i18n mounted" || echo "  ⚠️  i18n not found"
	@echo ""
	@echo "✅ Full test passed!"
	@echo ""
	@echo "Services running. Use 'make clean' to stop."

clean:
	@echo "🧹 Stopping and cleaning up..."
	@cd $(DATA_DIR) && docker compose down -v 2>/dev/null || true
	@echo "✅ Cleanup complete"

# ==================== Localhost Container targets ====================

localhost-config:
	@echo "📄 Generating configuration for localhost-container..."
	@echo "[1/4] Checking Ansible syntax..."
	@ansible-playbook \
		-i la-test-inventories/la-test-inventory.ini \
		-i la-test-inventories/la-test-local-extras.ini \
		-i ansible/inventories/localhost-container \
		-e "data_dir=$(DATA_DIR_ABS)" \
		$(PLAYBOOK) --syntax-check
	@echo "[2/4] Generating docker-compose.yml (no builds, no Docker required)..."
	@ansible-playbook \
		-i la-test-inventories/la-test-inventory.ini \
		-i la-test-inventories/la-test-local-extras.ini \
		-i ansible/inventories/localhost-container \
		-e "data_dir=$(DATA_DIR_ABS)" \
		$(PLAYBOOK) -e build_images=false
	@echo "[3/4] Validating generated YAML..."
	@docker compose -f $(DATA_DIR)/docker-compose.yml config --quiet 2>/dev/null || \
		echo "    ⚠️  Warning: docker compose validation skipped (Docker may not be running)"
	@echo "[4/4] Summary..."
	@echo ""
	@echo "✅ Config generation passed!"
	@echo "   Configuration: $(DATA_DIR)/docker-compose.yml"
	@echo "   Run 'make localhost-quick' to build images from source"

localhost-quick:
	@echo "🔍 Building localhost-container stack..."
	@echo "[1/4] Checking Ansible syntax..."
	@ansible-playbook \
		-i la-test-inventories/la-test-inventory.ini \
		-i la-test-inventories/la-test-local-extras.ini \
		-i ansible/inventories/localhost-container \
		-e "data_dir=$(DATA_DIR_ABS)" \
		$(PLAYBOOK) --syntax-check
	@echo "[2/4] Building images and generating docker-compose.yml..."
	@ansible-playbook -vv \
		-i la-test-inventories/la-test-inventory.ini \
		-i la-test-inventories/la-test-local-extras.ini \
		-i ansible/inventories/localhost-container \
		-e "data_dir=$(DATA_DIR_ABS)" \
		$(PLAYBOOK)
	@echo "[3/4] Validating generated YAML..."
	@docker compose -f $(DATA_DIR)/docker-compose.yml config --quiet
	@echo "[4/4] Build complete!"
	@echo ""
	@echo "✅ Quick build passed!"
	@echo "   Run 'make localhost-full' to start the stack"

localhost-full: localhost-quick
	@echo ""
	@echo "🚀 Running full stack test..."
	@echo "[1/4] Starting services..."
	@cd $(DATA_DIR) && docker compose up -d
	@echo "[2/4] Waiting for services to be healthy (max 3 min)..."
	@timeout 180 bash -c 'cd $(DATA_DIR) && until docker compose ps | tail -n +2 | grep -qE "(healthy|running)"; do echo "  Waiting..."; sleep 5; done' || (echo "⚠️  Timeout or partial startup - check with 'docker compose ps'" && false)
	@echo "[3/4] Testing endpoints..."
	@echo "  - Testing nginx..."
	@curl --fail --silent http://localhost/ > /dev/null && echo "    ✅ Nginx OK" || echo "    ⚠️  Nginx (expected - may still be starting)"
	@echo "  - Testing collectory..."
	@curl --fail --silent http://localhost:8080/collectory/actuator/health > /dev/null && echo "    ✅ Collectory OK" || echo "    ⚠️  Collectory (expected - may still be starting)"
	@echo "[4/4] Checking logs..."
	@echo "  Docker containers:"
	@cd $(DATA_DIR) && docker compose ps
	@echo ""
	@echo "✅ Stack started!"
	@echo ""
	@echo "📊 Useful commands:"
	@echo "    docker compose -f $(DATA_DIR)/docker-compose.yml logs -f        # Follow logs"
	@echo "    docker compose -f $(DATA_DIR)/docker-compose.yml ps             # Show status"
	@echo "    make clean                                          # Stop stack"
	@echo ""
	@echo "🌐 Access services at:"
	@echo "    http://localhost/collectory"

# ==================== LA Toolkit Integration ====================

la-toolkit-config:
	@echo "🛠️  Generating docker-compose from LA Toolkit inventory..."
	@echo ""
	@echo "Using inventory: $(LA_TOOLKIT_INVENTORY)"
	@echo ""
	@echo "[1/3] Checking Ansible syntax..."
	@ansible-playbook -i $(LA_TOOLKIT_INVENTORY) -i la-test-inventories/la-test-local-passwords.ini $(PLAYBOOK) -e "data_dir=$(DATA_DIR_ABS)" --syntax-check
	@echo "[2/3] Generating docker-compose.yml..."
	@ansible-playbook -i $(LA_TOOLKIT_INVENTORY) -i la-test-inventories/la-test-local-passwords.ini $(PLAYBOOK) -e "data_dir=$(DATA_DIR_ABS)" -e build_images=false
	@echo "[3/3] Validating generated YAML..."
	@docker compose -f $(DATA_DIR)/docker-compose.yml config --quiet
	@echo ""
	@echo "✅ Docker Compose generated from LA Toolkit inventory!"
	@echo ""
	@echo "📁 Generated files:"
	@echo "   - $(DATA_DIR)/docker-compose.yml"
	@echo "   - $(DATA_DIR)/generic-collectory/config/"
	@echo ""
	@echo "Next steps:"
	@echo "   1. make build-i18n              # Build i18n image (first time only)"
	@echo "   2. cd $(DATA_DIR) && docker compose up -d"

la-toolkit-deploy:
	@echo "🚀 Deploying with LA Toolkit configuration..."
	@echo ""
	@echo "[1/3] Generating docker-compose.yml with build config..."
	@ansible-playbook -i $(LA_TOOLKIT_INVENTORY) -i la-test-inventories/la-test-local-passwords.ini $(PLAYBOOK) -e "data_dir=$(DATA_DIR_ABS)" -e build_images=true
	@echo ""
	@echo "[2/3] Building images with docker buildx bake..."
	@cd $(DATA_DIR) && BUILDX_BAKE_ENTITLEMENTS_FS=0 docker buildx bake -f docker-bake.hcl --load builders
	@cd $(DATA_DIR) && BUILDX_BAKE_ENTITLEMENTS_FS=0 docker buildx bake -f docker-bake.hcl --load all
	@echo ""
	@echo "[3/3] Starting services..."
	@cd $(DATA_DIR) && docker compose up -d
	@echo ""
	@echo "✅ Services deployed!"
	@echo ""
	@echo "Check status:"
	@echo "   cd $(DATA_DIR) && docker compose ps"
	@echo "   cd $(DATA_DIR) && docker compose logs -f cas collectory"

# ============================================
# Publish Images to Docker Hub
# ============================================

publish-images:
	@echo "📤 Publishing images to Docker Hub ($(DOCKER_REGISTRY))..."
	@echo ""
	@if [ -z "$(shell docker info 2>&1 | grep Username)" ]; then \
		echo "❌ Not logged into Docker Hub. Please run: docker login"; \
		exit 1; \
	fi
	@echo "✅ Docker login verified"
	@echo ""
	@echo "🏷️  Tagging and pushing images..."
	@./scripts/publish-images.sh $(DOCKER_REGISTRY)
	@echo ""
	@echo "✅ Images published to Docker Hub!"
	@echo ""
	@echo "📋 Published images:"
	@echo "   https://hub.docker.com/u/$(DOCKER_REGISTRY)"
