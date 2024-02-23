.PHONY: check-os
check-os:
	@OS=$$(uname -s | tr '[:upper:]' '[:lower:]')-$$(uname -m); \
	echo $$OS; \
	if echo "$$OS" | grep -q -e 'mingw' -e '_nt'; then \
			echo "Windows"; \
	else \
			echo "Linux/MacOS"; \
	fi; \

.PHONY: check-os-then-build
check-os-then-build:
	@OS=$$(uname -s | tr '[:upper:]' '[:lower:]')-$$(uname -m); \
	if echo "$$OS" | grep -q -e 'mingw' -e '_nt'; then \
			go build -o ./bin/$(APP_NAME).exe ./cmd/$(APP_NAME)/main.go && echo "Windows Build Successful"; \
	else \
			go build -o ./bin/$(APP_NAME) ./cmd/$(APP_NAME)/main.go && echo "Linux/MacOS Build Successful"; \
	fi; \

.PHONY: check-os-then-dev-build
check-os-then-dev-build:
	@OS=$$(uname -s | tr '[:upper:]' '[:lower:]')-$$(uname -m); \
	if echo "$$OS" | grep -q -e 'mingw' -e '_nt'; then \
			go build -o ./tmp/main.exe ./cmd/$(APP_NAME)/main.go && echo "Windows Build Successful"; \
	else \
			go build -o ./tmp/main ./cmd/$(APP_NAME)/main.go && echo "Linux/MacOS Build Successful"; \
	fi; \

.PHONY: tailwind-watch
tailwind-watch:
	npm run tailwind-watch

.PHONY: tailwind-build
tailwind-build:
	npm run tailwind-build
	echo "Tailwind Build Successful"

.PHONY: templ-generate
templ-generate:
	@if command -v templ > /dev/null; then \
	    templ generate; \
			echo "Templ Generated"; \
	else \
	    /bin/echo -n "'Templ' is not installed on your machine. Do you want to install it? [Y/n] "; \
			read choice; \
	    if [ "$$choice" != "n" ] && [ "$$choice" != "N" ]; then \
					GO_VERSION=$$(go version | awk '{print $$3}' | tr -d 'go'); \
					MIN_GO_VERSION=1.20; \
					if [ "$$(printf '%s\n' "$$MIN_GO_VERSION" "$$GO_VERSION" | sort -V | head -n1)" = "$$MIN_GO_VERSION" ]; then \
							echo "Installing templ..."; \
	        		go install github.com/a-h/templ/cmd/templ@latest; \
	        		templ generate; \
							echo "Templ Generated"; \
					else \
	        		echo "templ requires golang version 1.20 or greater. Exiting..."; \
	        		exit 1; \
					fi; \
	    else \
	        echo "You chose not to install templ. Exiting..."; \
	        exit 1; \
	    fi; \
	fi

.PHONY: sqlc-generate
sqlc-generate:
	@if command -v sqlc > /dev/null; then \
			sqlc generate; \
			echo "SQLC Generated"; \
	else \
			/bin/echo -n "'Sqlc' is not installed on your machine. Do you want to install it? [Y/n] "; \
			read choice; \
			if [ "$$choice" != "n" ] && [ "$$choice" != "N" ]; then \
					echo "Installing sqlc..."; \
					GO_VERSION=$$(go version | awk '{print $$3}' | tr -d 'go'); \
					MIN_GO_VERSION=1.17; \
					if [ "$$(printf '%s\n' "$$MIN_GO_VERSION" "$$GO_VERSION" | sort -V | head -n1)" = "$$MIN_GO_VERSION" ]; then \
							go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest; \
							sqlc generate; \
							echo "SQLC Generated"; \
					else \
							go get github.com/sqlc-dev/sqlc/cmd/sqlc; \
							sqlc generate; \
					fi; \
			else \
					echo "You chose not to install sqlc. Exiting..."; \
					exit 1; \
			fi; \
	fi

.PHONY: dev
dev:
	@if command -v air > /dev/null; then \
	    make check-os-then-dev-build && air; \
	    echo "Watching...";\
	else \
	    /bin/echo -n "Go's 'air' is not installed on your machine. Do you want to install it? [Y/n] "; \
			read choice; \
	    if [ "$$choice" != "n" ] && [ "$$choice" != "N" ]; then \
					echo "Installing air..."; \
	        go install github.com/cosmtrek/air@latest; \
	        make check-os-then-dev-build && air; \
	        echo "Watching...";\
	    else \
	        echo "You chose not to install air. Exiting..."; \
	        exit 1; \
	    fi; \
	fi

.PHONY: build
build:
	make tailwind-build && make templ-generate && make sqlc-generate && make check-os-then-build