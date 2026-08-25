all: check test build

[parallel]
check: lint tsc

lint:
    biome check --fix

tsc:
    tsc

[parallel]
build: build-js build-logo
	vsce package

build-js:
    esbuild \
        src/extension.ts \
        --bundle \
        --format=cjs \
        --minify \
        --sources-content=false \
        --platform=node \
        --outfile=dist/extension.js \
        --external:vscode

build-logo:
    magick \
        images/penelopea.webp \
        -alpha on \
        -bordercolor white \
        -border 1 \
        -fill none \
        -fuzz 25% \
        -draw "color 0,0 floodfill" \
        -shave 1 \
        -resize 250x250^ \
        -background none \
        -gravity center \
        -extent 250x250 \
        images/penelopea.png

watch:
    esbuild \
        src/extension.ts \
        --bundle \
        --format=cjs \
        --sourcemap \
        --sources-content=false \
        --platform=node \
        --outfile=dist/extension.js \
        --external:vscode \
        --watch

[parallel]
test: test-extension test-textmate-grammar

[linux]
test-extension:
    xvfb-run -a npm run test

[macos]
test-extension:
    npm run test

test-textmate-grammar:
    npx --no-install --call 'textmate-grammar-test syntaxes/tests/**/*.eyg'
    # npx --no-install --call 'textmate-grammar-test syntaxes/snapshots/**/*.eyg.snap'

update-snapshots:
    npx --no-install --call 'textmate-grammar-snap -u syntaxes/snapshots/*.eyg'
