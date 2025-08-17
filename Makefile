FLINK_VERSION ?= 1.20.2
FLUSS_VERSION ?= 0.7.0

# Define home directories relative to current directory
FLUSS_HOME ?= ./fluss-$(FLUSS_VERSION)
FLINK_HOME ?= ./flink-$(FLINK_VERSION)

.PHONY: help setup clean-setup clean-bin-dist clean-logs clean-jars clean-all some-magic-happen show-jars download-jars show-setup
help:
	@echo "Available targets:"
	@echo "  setup               - Download and install Flink and Fluss with custom configuration"
	@echo "  clean-setup         - Remove installed Flink and Fluss directories"
	@echo "  clean-logs          - Clean log files from Flink and Fluss"
	@echo "  clean-bin-dist      - Remove binary distributions"
	@echo "  clean-jars          - Remove all JAR files from jar/ directories"
	@echo "  clean-all           - Remove everything (installations, logs, and JARs)"
	@echo "  start-all           - Setup (if needed), start MinIO, Fluss, and Flink clusters"
	@echo "  stop-all            - Stop all clusters and MinIO"
	@echo "  start-fluss         - Start Fluss local cluster"
	@echo "  stop-fluss          - Stop Fluss local cluster"
	@echo "  start-flink         - Start Flink local cluster"
	@echo "  stop-flink          - Stop Flink local cluster"
	@echo "  start-mino          - Start MinIO (Docker)"
	@echo "  stop-mino           - Stop MinIO (Docker)"
	@echo "  some-magic-happen   - Setup, start MinIO, Fluss, and Flink in sequence"
	@echo "  show-jars           - Show JAR files that will be copied during setup"
	@echo "  show-setup          - Show Flink lib and Fluss lib and plugins directories"
	@echo "  download-jars       - Download JAR files from Maven repositories"
	@echo "  submit-tiering-job  - Submit tiering job to local flink cluster"

setup:
	@echo "Running setup script..."
	@./setup.sh
	@echo "Setup completed successfully!"

clean-setup:
	@echo "Cleaning installed directories..."
	@if [ -d "$(FLUSS_HOME)" ]; then \
		echo "Removing $(FLUSS_HOME)..."; \
		rm -rf "$(FLUSS_HOME)"; \
	else \
		echo "Fluss directory not found: $(FLUSS_HOME)"; \
	fi
	@if [ -d "$(FLINK_HOME)" ]; then \
		echo "Removing $(FLINK_HOME)..."; \
		rm -rf "$(FLINK_HOME)"; \
	else \
		echo "Flink directory not found: $(FLINK_HOME)"; \
	fi

clean-logs:
	@echo "Cleaning fluss and flink logs..."
	@rm -f $(FLUSS_HOME)/log/*
	@rm -f $(FLINK_HOME)/log/*
	@echo "Done."

clean-jars:
	@echo "Cleaning JAR files and jar/ directory..."
	@if [ -d "jar/flink/lib" ]; then \
		echo "Removing JAR files from jar/flink/lib/..."; \
		rm -f jar/flink/lib/*.jar; \
	else \
		echo "jar/flink/lib/ directory not found"; \
	fi
	@if [ -d "jar/fluss/lib" ]; then \
		echo "Removing JAR files from jar/fluss/lib/..."; \
		rm -f jar/fluss/lib/*.jar; \
	else \
		echo "jar/fluss/lib/ directory not found"; \
	fi
	@if [ -d "jar/fluss/plugins" ]; then \
		echo "Removing JAR files from jar/fluss/plugins/..."; \
		rm -f jar/fluss/plugins/*.jar; \
	else \
		echo "jar/fluss/plugins/ directory not found"; \
	fi
	@if [ -d "jar" ]; then \
		echo "Removing entire jar/ directory..."; \
		rm -rf jar; \
	else \
		echo "jar/ directory not found"; \
	fi
	@echo "JAR files and jar/ directory cleaned successfully!"

clean-bin-dist:
	@echo "Removing any leftover downloaded files..."
	@rm -f flink-$(FLINK_VERSION)-bin-scala_2.12.tgz
	@rm -f fluss-$(FLUSS_VERSION)-bin.tgz
	@rm -f fluss-flink-tiering-0.7.0.jar
	@echo "Clean completed!"



clean-all: clean-setup clean-bin-dist clean-jars
	@echo "✅ Everything cleaned successfully!"

submit-tiering-job:
	@echo "Submitting job to local flink cluster..."
	@./tiering-job.sh


some-magic-happen: download-jars show-jars setup show-setup start-all
	@echo "✨ Magic has happened! All services are now running."
	sleep 10
	@echo "Submitting job to local flink cluster..."
	@./tiering-job.sh



show-jars:
	@echo "Showing JAR files that will be copied during setup..."
	@./show-jars.sh

download-jars:
	@echo "Downloading JAR files from Maven repositories..."
	@./download-jars.sh

show-setup:
	@echo "=== Flink Library Directory ==="
	@if [ -d "$(FLINK_HOME)/lib" ]; then \
		echo "Flink lib directory: $(FLINK_HOME)/lib"; \
		echo "Contents:"; \
		ls -la "$(FLINK_HOME)/lib" | head -20; \
		echo "Total JAR files: $$(find "$(FLINK_HOME)/lib" -name "*.jar" | wc -l)"; \
	else \
		echo "Flink lib directory not found: $(FLINK_HOME)/lib"; \
	fi
	@echo ""
	@echo "=== Fluss Library Directory ==="
	@if [ -d "$(FLUSS_HOME)/lib" ]; then \
		echo "Fluss lib directory: $(FLUSS_HOME)/lib"; \
		echo "Contents:"; \
		ls -la "$(FLUSS_HOME)/lib" | head -20; \
		echo "Total JAR files: $$(find "$(FLUSS_HOME)/lib" -name "*.jar" | wc -l)"; \
	else \
		echo "Fluss lib directory not found: $(FLUSS_HOME)/lib"; \
	fi
	@echo ""
	@echo "=== Fluss Plugins Paimon Directory ==="
	@if [ -d "$(FLUSS_HOME)/plugins/paimon" ]; then \
		echo "Fluss plugins paimon directory: $(FLUSS_HOME)/plugins/paimon"; \
		echo "Contents:"; \
		ls -la "$(FLUSS_HOME)/plugins/paimon" | head -20; \
		echo "Total JAR files: $$(find "$(FLUSS_HOME)/plugins/paimon" -name "*.jar" | wc -l)"; \
	else \
		echo "Fluss plugins paimon directory not found: $(FLUSS_HOME)/plugins/paimon"; \
	fi

.PHONY: start-fluss stop-fluss start-flink stop-flink start-all stop-all

start-all: start-mino start-fluss start-flink

stop-all: stop-flink stop-fluss stop-mino

start-mino:
	@echo "Starting minio..."
	@if docker ps -a --format '{{.Names}}' | grep -Eq '^minio$$'; then \
		echo "Stopping and removing existing 'minio' container..."; \
		docker stop minio >/dev/null 2>&1 || true; \
		docker rm minio >/dev/null 2>&1 || true; \
	fi
	@if docker ps -a --format '{{.Names}}' | grep -Eq '^minio-mc$$'; then \
		echo "Stopping and removing existing 'minio-mc' container..."; \
		docker stop minio-mc --timeout 5 >/dev/null 2>&1 || true; \
		docker rm minio-mc >/dev/null 2>&1 || true; \
	fi
	docker compose up -d
	@echo "Waiting for minio to start and initialize fluss bucket..."
	sleep 5

stop-mino:
	@echo "Stopping minio..."
	docker compose down --timeout 5

start-fluss:
	@echo "Starting fluss local cluster..."
	@echo "Using FLUSS_HOME: $(FLUSS_HOME)"
	@cd $(FLUSS_HOME)/bin && ./local-cluster.sh start

stop-fluss:
	@echo "Stopping fluss local cluster..."
	@cd $(FLUSS_HOME)/bin && ./local-cluster.sh stop

start-flink:
	@echo "Starting flink local cluster..."
	@echo "Using FLINK_HOME: $(FLINK_HOME)"
	@$(FLINK_HOME)/bin/start-cluster.sh

stop-flink:
	@echo "Stopping flink local cluster..."
	@$(FLINK_HOME)/bin/stop-cluster.sh
