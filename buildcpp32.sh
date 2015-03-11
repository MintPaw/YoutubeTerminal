pushd .
cd Source
haxe -main Main -cpp ../Export -lib hxcpp -D HXCPP_M32 -debug
popd
