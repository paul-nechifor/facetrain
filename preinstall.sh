rm -fr lib
coffee --compile --bare --output lib src

cd code
make

