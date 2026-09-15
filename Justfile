all: check test build

[parallel]
check: lint tsc

lint:
    biome check --fix

tsc:
    tsc

build: build-logo
    vsce package

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

test: test-textmate-grammar

test-textmate-grammar:
    npx --no-install --call 'textmate-grammar-test syntaxes/tests/**/*.eyg'
    # npx --no-install --call 'textmate-grammar-test syntaxes/snapshots/**/*.eyg.snap'

update-snapshots:
    npx --no-install --call 'textmate-grammar-snap -u syntaxes/snapshots/*.eyg'
