pushd .
cd Source
haxe -main Main -cpp ../Export -lib hxcpp -D HXCPP_M64 -debug
popd
