cmake_minimum_required(VERSION 3.27)

project(gravity)

# remove "lib" prefix on unix systems
set(CMAKE_STATIC_LIBRARY_PREFIX "")

add_subdirectory(gravity)

if (WIN32)
    set(OUTPUT_DIR "windows" CACHE STRING "")
elseif(APPLE)
    set(OUTPUT_DIR "macos" CACHE STRING "")
elseif(UNIX)
    set(OUTPUT_DIR "linux" CACHE STRING "")
endif ()

set_target_properties(gravityapi_s PROPERTIES ARCHIVE_OUTPUT_DIRECTORY $<LOWER_CASE:../../../../libs/${OUTPUT_DIR}>) 
set_target_properties(gravityapi_s PROPERTIES OUTPUT_NAME_DEBUG "gravityd")
set_target_properties(gravityapi_s PROPERTIES OUTPUT_NAME_RELEASE "gravity")