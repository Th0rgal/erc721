.SILENT:

.PHONY: compile
SOURCE_FOLDER=./src
last_folder=$(basename $(dirname $(dir)))

install:
	git submodule init && git submodule update --remote && cp -rf cairo/corelib .

update:
	git submodule update --remote && cp -rf cairo/corelib .

build:
	cargo build

test:
	cargo run --bin cairo-test -- --starknet --path .

format:
	cargo run --bin cairo-format -- --recursive $(SOURCE_FOLDER) --print-parsing-errors

check-format:
	cargo run --bin cairo-format -- --check --recursive $(SOURCE_FOLDER)

compile:
	mkdir -p out && \
	  cargo run --bin starknet-compile -- . out/erc721.json --allowed-libfuncs-list-name experimental_v0.1.0

language-server:
	cargo build --bin cairo-language-server --release
