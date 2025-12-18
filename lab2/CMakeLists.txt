cmake_minimum_required(VERSION 3.23)
set(CMAKE_CXX_STANDARD 23)


macro(propagate)
    foreach(_list ${ARGV})
        set (${_list} "${${_list}}" PARENT_SCOPE)
    endforeach()
endmacro()

project(function_verification VERSION 0.1)

foreach(_target ${MAIN_TARGETS})
    add_executable("program_${_target}")
    target_sources("program_${_target}" PRIVATE ${${_target}_HEADERS} ${${_target}_SOURCES} ${main_runner})
    target_include_directories("program_${_target}" PRIVATE ${${_target}_INCLUDEDIRS})
    target_link_libraries("program_${_target}" ${${_target}_LIBS})
    target_link_directories("program_${_target}" PRIVATE ${${_target}_LIBDIRS})
    target_compile_options("program_${_target}" PRIVATE ${COMPILER_FLAGS} ${${_target}_COMPILE_OPTIONS})
    if(${_target}_DEPS)
        add_dependencies("program_${_target}" ${${_target}_DEPS})
    endif()
    install(TARGETS "program_${_target}")
endforeach()


