function(MOVEII_BUILD_CMAKE name)
  SET(oneValueArgs SOURCE_SUFFIX)
  SET(multiValueArgs EXTRA_OPTIONS)
  CMAKE_PARSE_ARGUMENTS(BUILD "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  STRING(REPLACE "-" "_" underscore ${name})
  STRING(TOUPPER ${underscore} prefix)

  FILE(MAKE_DIRECTORY ${BUILD_PATH}/${name})

  ## cmake step:
  ADD_CUSTOM_COMMAND(OUTPUT ${BUILD_PATH}/${name}/Makefile
	COMMAND ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_ROOT_PATH=${PREFIX_PATH} -DCMAKE_INSTALL_PREFIX=${PREFIX_PATH}/usr ${BUILD_EXTRA_OPTIONS} ${${prefix}_SOURCE}${BUILD_SOURCE_SUFFIX}
	DEPENDS ${name}
	WORKING_DIRECTORY ${BUILD_PATH}/${name})

  ## make step:
  ADD_CUSTOM_COMMAND(OUTPUT ${BUILD_PATH}/${name}/success
	COMMAND ${MAKE} -j${N}
	COMMAND ${CMAKE_COMMAND} -E touch ${BUILD_PATH}/${name}/success
	WORKING_DIRECTORY ${BUILD_PATH}/${name}
	DEPENDS ${BUILD_PATH}/${name}/Makefile)

  ## make install step:
  ADD_CUSTOM_COMMAND(OUTPUT ${PREFIX_PATH}/installed_${name}
	COMMAND ${MAKE} install
	COMMAND ${CMAKE_COMMAND} -E touch ${PREFIX_PATH}/installed_${name}
	WORKING_DIRECTORY ${BUILD_PATH}/${name}
	DEPENDS ${BUILD_PATH}/${name}/success)
  
  ADD_CUSTOM_TARGET(build_${underscore}
	DEPENDS ${PREFIX_PATH}/installed_${name})

  ADD_DEPENDENCIES(build_${underscore} prefix)
endfunction()
