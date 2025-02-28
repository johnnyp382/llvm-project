file(GLOB SWIG_INTERFACES interface/*.i)
file(GLOB_RECURSE SWIG_SOURCES *.swig)
file(GLOB SWIG_HEADERS
  ${LLDB_SOURCE_DIR}/include/lldb/API/*.h
  ${LLDB_SOURCE_DIR}/include/lldb/*.h
)
file(GLOB SWIG_PRIVATE_HEADERS
  ${LLDB_SOURCE_DIR}/include/lldb/lldb-private*.h
)
foreach(private_header ${SWIG_PRIVATE_HEADERS})
  list(REMOVE_ITEM SWIG_HEADERS ${private_header})
endforeach()

if(LLDB_BUILD_FRAMEWORK)
  set(framework_arg --framework --target-platform Darwin)
endif()

if(${LLDB_USE_STATIC_BINDINGS})
  set(PREPARE_BINDINGS_ARGS "--use-static-binding")
else()
  set(PREPARE_BINDINGS_ARGS "--swig-executable=${SWIG_EXECUTABLE}")
endif()

if(APPLE)
  set(DARWIN_EXTRAS "-D__APPLE__")
else()
  set(DARWIN_EXTRAS "")
endif()

set(SWIG_COMMON_FLAGS
  -c++
  # Ignored warnings:
  # 361: operator! ignored.
  # 362: operator= ignored.
  # 509: Overloaded method declaration effectively ignored, shadowed by previous declaration.
  -w361,362,509
  -features autodoc
  -I${LLDB_SOURCE_DIR}/include
  -I${CMAKE_CURRENT_SOURCE_DIR}
  ${DARWIN_EXTRAS}
)

function(create_relative_symlink swig_target dest_file output_dir output_name)
  get_filename_component(dest_file ${dest_file} ABSOLUTE)
  get_filename_component(output_dir ${output_dir} ABSOLUTE)
  file(RELATIVE_PATH rel_dest_file ${output_dir} ${dest_file})
  if(CMAKE_HOST_UNIX)
    set(LLVM_LINK_OR_COPY create_symlink)
  else()
    set(LLVM_LINK_OR_COPY copy)
  endif()
  add_custom_command(TARGET ${swig_target} POST_BUILD VERBATIM
    COMMAND ${CMAKE_COMMAND} -E ${LLVM_LINK_OR_COPY} ${rel_dest_file} ${output_name}
    WORKING_DIRECTORY ${output_dir})
endfunction()

if (LLDB_ENABLE_PYTHON)
  add_subdirectory(python)
endif()

if (LLDB_ENABLE_LUA)
  add_subdirectory(lua)
endif()

if(NOT ${LLDB_USE_STATIC_BINDINGS})
  set(copy_static_bindings_script "${LLDB_SOURCE_DIR}/scripts/copy-static-bindings.py")
  add_custom_target(update-static-bindings
    COMMAND ${copy_static_bindings_script} ${CMAKE_BINARY_DIR}
    COMMENT "Copying the generated bindings to the static bindings directory in source."
    VERBATIM
  )
  add_dependencies(update-static-bindings swig_wrapper_python)
endif()
