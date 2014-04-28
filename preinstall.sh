rm -fr lib
coffee --compile --bare --output lib src

cd code
make

cd -
mkdir examples/images 2>/dev/null || true
