# CreatorPilot — shared developer commands.
#
# Thin wrappers only: no build logic and no application code lives here.
# `make` is optional. On Windows without make, run the command in the comment
# next to each target instead (README → Quick start).

SHELL   := /bin/sh
PY      ?= python
VENV    ?= .venv
COMPOSE ?= docker compose

ifeq ($(OS),Windows_NT)
  VENV_BIN := $(VENV)/Scripts
else
  VENV_BIN := $(VENV)/bin
endif

.DEFAULT_GOAL := help
.PHONY: help venv install lint format format-check typecheck test dev up down logs ps clean

help: ## Show this help
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

venv: ## Create the virtual environment — python -m venv .venv
	$(PY) -m venv $(VENV)

install: ## Install the package with dev tooling — pip install -e ".[dev]"
	$(VENV_BIN)/python -m pip install --upgrade pip
	$(VENV_BIN)/python -m pip install -e ".[dev]"

lint: ## Lint — ruff check backend
	$(VENV_BIN)/python -m ruff check backend

format: ## Format — ruff format backend
	$(VENV_BIN)/python -m ruff format backend

format-check: ## Verify formatting — ruff format --check backend
	$(VENV_BIN)/python -m ruff format --check backend

typecheck: ## Type-check — mypy (configuration in pyproject.toml)
	$(VENV_BIN)/python -m mypy

test: ## Run the suite — pytest
	$(VENV_BIN)/python -m pytest

dev: ## Run the API locally — uvicorn app.main:app --reload
	@$(VENV_BIN)/python -c "import app.main" 2>/dev/null || { \
		echo "backend/app/main.py is not in place yet — owner: Member 3"; exit 1; }
	$(VENV_BIN)/python -m uvicorn app.main:app --reload --port 8000

up: ## Start local infrastructure — docker compose up -d
	$(COMPOSE) up -d

down: ## Stop local infrastructure — docker compose down
	$(COMPOSE) down

logs: ## Follow infrastructure logs — docker compose logs -f
	$(COMPOSE) logs -f

ps: ## Show infrastructure status — docker compose ps
	$(COMPOSE) ps

clean: ## Remove caches and reports (keeps the virtual environment)
	rm -rf .pytest_cache .mypy_cache .ruff_cache htmlcov .coverage
	find . -type d -name __pycache__ -prune -exec rm -rf {} +
