function(MOVEII_BUILD_MESON name)
  SET(multiValueArgs EXTRA_OPTIONS)
  CMAKE_PARSE_ARGUMENTS(BUILD "" "" "${multiValueArgs}" ${ARGN})
  STRING(REPLACE "-" "_" underscore ${name})
  STRING(TOUPPER ${underscore} prefix)

  FILE(MAKE_DIRECTORY ${BUILD_PATH}/${name})

  ## cmake step:
  ADD_CUSTOM_COMMAND(OUTPUT ${BUILD_PATH}/${name}/build.ninja
	COMMAND ${MESON} ${BUILD_EXTRA_OPTIONS} --buildtype release ${${prefix}_SOURCE} ${BUILD_PATH}/${name} --prefix=${PREFIX_PATH}/usr --reconfigure -Dgtk_doc=false
	DEPENDS ${name}
	WORKING_DIRECTORY ${BUILD_PATH}/${name})

  ## make step:
  ADD_CUSTOM_COMMAND(OUTPUT ${BUILD_PATH}/${name}/success
	COMMAND ${NINJA} -j${N} -C${BUILD_PATH}/${name}
	COMMAND ${CMAKE_COMMAND} -E touch ${BUILD_PATH}/${name}/success
	WORKING_DIRECTORY ${BUILD_PATH}/${name}
	DEPENDS ${BUILD_PATH}/${name}/build.ninja)

  ## make install step:
  ADD_CUSTOM_COMMAND(OUTPUT ${PREFIX_PATH}/installed_${name}
	COMMAND ${NINJA} -C${BUILD_PATH}/${name} install
	COMMAND ${CMAKE_COMMAND} -E touch ${PREFIX_PATH}/installed_${name}
	WORKING_DIRECTORY ${BUILD_PATH}/${name}
	DEPENDS ${BUILD_PATH}/${name}/success)
  
  ADD_CUSTOM_TARGET(build_${underscore}
	DEPENDS ${PREFIX_PATH}/installed_${name})

  ADD_DEPENDENCIES(build_${underscore} prefix)
endfunction()
