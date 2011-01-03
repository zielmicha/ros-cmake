if(CFGBUILD_CMAKE)
  message(FATAL_ERROR "cfgbuild.cmake included twice")
else()
  set(CFGBUILD_CMAKE TRUE CACHE INTERNAL "cfgbuild include guard.")
endif()

# add_custom_target(rospack_gencfg ALL)
# add_dependencies(rospack_genmsg_libexe rospack_gencfg)

macro(rosbuild_cfgs)
  if (ARGN)
    message("rosbuild_cfgs ${ARGN}")
  endif()
  
  set(_autogen "")
  foreach(_cfg ${ARGN})

    message("MSG: gencfg_cpp on:" ${_cfg})

    # Construct the path to the .cfg file
    set(_input ${PROJECT_SOURCE_DIR}/${_cfg})
    
    rosbuild_gendeps(${PROJECT_NAME} ${_cfg})

    # The .cfg file is its own generator.
    set(gencfg_cpp_exe "")
    set(gencfg_build_files 
      ${dynamic_reconfigure_PACKAGE_PATH}/templates/ConfigType.py
      ${dynamic_reconfigure_PACKAGE_PATH}/templates/ConfigType.h
      ${dynamic_reconfigure_PACKAGE_PATH}/src/dynamic_reconfigure/parameter_generator.py)

    string(REPLACE ".cfg" "" _cfg_bare ${_cfg})

    set(_output_cpp ${PROJECT_BINARY_DIR}/gen/cpp/${PROJECT_NAME}/${_cfg_bare}Config.h)
    set(_output_dox ${PROJECT_BINARY_DIR}/docs/${_cfg_bare}Config.dox)
    set(_output_wikidoc ${PROJECT_BINARY_DIR}/docs/${_cfg_bare}Config.wikidoc)
    set(_output_usage ${PROJECT_BINARY_DIR}/docs/${_cfg_bare}Config-usage.dox)
    set(_output_py ${PROJECT_BINARY_DIR}/gen/py/${PROJECT_NAME}/cfg/${_cfg_bare}Config.py)

    # Add the rule to build the .h the .cfg and the .msg
    # FIXME Horrible hack. Can't get CMAKE to add dependencies for anything
    # but the first output in add_custom_command.
    #    execute_process(
    #      COMMAND ${dynamic_reconfigure_PACKAGE_PATH}/cmake/gendeps ${_input}
    #      OUTPUT_VARIABLE __gencfg_autodeps
    #      OUTPUT_STRIP_TRAILING_WHITESPACE)
    # string(REPLACE "\n" " " ${_input}_AUTODEPS ${__gencfg_autodeps})
    # separate_arguments(${_input}_AUTODEPS)
    #message("MSG: " ${${_input}_AUTODEPS})

    add_custom_command(OUTPUT ${_output_cpp} ${_output_dox} ${_output_usage} ${_output_py} ${_output_wikidoc}
      COMMAND ${ROSBUILD_SUBSHELL} ${gencfg_cpp_exe} 
      ${_input}
      ${dynamic_reconfigure_PACKAGE_PATH}
      ${PROJECT_BINARY_DIR}
      ${ROSBUILD_GEN_DIR}/cpp/${PROJECT_NAME}
      ${ROSBUILD_GEN_DIR}/py/${PROJECT_NAME}
      DEPENDS ${_input} ${gencfg_cpp_exe} ${ROS_MANIFEST_LIST} ${gencfg_build_files} ${gencfg_extra_deps} ${${_input}_AUTODEPS}
      COMMENT BANGHBANGHBANGH
      )

    list(APPEND ${PROJECT_NAME}_generated 
      ${_output_cpp} ${_output_msg} ${_output_getsrv} ${_output_setsrv} 
      ${_output_dox} ${_output_usage} ${_output_py})

  endforeach(_cfg)
  # Create a target that depends on the union of all the autogenerated
  # files
  #add_custom_target(ROSBUILD_gencfg_cpp DEPENDS ${_autogen})
  # Add our target to the top-level gencfg target, which will be fired if
  # the user calls gencfg()
  #add_dependencies(rospack_gencfg ROSBUILD_gencfg_cpp)

  #add_custom_target(rospack_gencfg_real ALL)
  #add_dependencies(rospack_gencfg_real rospack_gencfg)
  #include_directories(${PROJECT_SOURCE_DIR}/cfg/cpp)



  
endmacro()

