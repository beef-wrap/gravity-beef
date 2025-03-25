cmake -S . -B gravity/build -DCMAKE_BUILD_TYPE=Debug
cmake --build gravity/build --config Debug

cmake -S . -B gravity/build -DCMAKE_BUILD_TYPE=Release
cmake --build gravity/build --config Release