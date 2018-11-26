function(MOVEII_BUILD_AUTOTOOLS name)
  SET(options OPTIONAL NO_AUTORECONF NO_INSTALL NO_DEFAULT COPY_SOURCE CONFIG_SITE)
  SET(oneValueArgs SOURCE_SUFFIX)
  SET(multiValueArgs EXTRA_OPTIONS)
  CMAKE_PARSE_ARGUMENTS(BUILD "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  STRING(REPLACE "-" "_" underscore ${name})
  STRING(TOUPPER ${underscore} prefix)

  IF(CONFIG_SITE)
	SET(CONFIGURE_CONFIG_SITE "env CONFIG_SITE=${PREFIX_PATH}/config.site")
  ENDIF()

  ### In case out-of-source build does not work copy source to build directory:
  IF(BUILD_COPY_SOURCE)
	SET(BUILD_DIR "${BUILD_PATH}/${name}${BUILD_SOURCE_SUFFIX}")
	ADD_CUSTOM_TARGET(${name}_copy
	  ${CMAKE_COMMAND} -E copy_directory ${${prefix}_SOURCE} ${BUILD_PATH}/${name}
	  DEPENDS ${name})
	SET(SOURCE_DIR "${BUILD_PATH}/${name}${BUILD_SOURCE_SUFFIX}")
  ELSE()
	SET(BUILD_DIR "${BUILD_PATH}/${name}")
	ADD_CUSTOM_TARGET(${name}_copy
	  DEPENDS ${name})
	FILE(MAKE_DIRECTORY ${BUILD_PATH}/${name})
	SET(SOURCE_DIR "${${prefix}_SOURCE}${BUILD_SOURCE_SUFFIX}")
  ENDIF()

  ### Disable or enable configure options by default:
  IF(NOT BUILD_NO_DEFAULT)
	SET(DEFAULT_OPTIONS "--prefix=${PREFIX_PATH}/usr" "--enable-shared")
  ENDIF()

  ### Build has configure.ac?
  IF(NOT BUILD_NO_AUTORECONF)
	FIND_PROGRAM(AUTORECONF autoreconf)
	ADD_CUSTOM_COMMAND(OUTPUT ${SOURCE_DIR}/configure
	  COMMAND ${AUTORECONF} -vfi
	  DEPENDS ${name}_copy
	  WORKING_DIRECTORY ${SOURCE_DIR})
  ENDIF()

  ### ./configure step:
  ADD_CUSTOM_COMMAND(OUTPUT ${BUILD_DIR}/Makefile
	COMMAND ${CONFIGURE_CONFIG_SITE} ${SOURCE_DIR}/configure ${DEFAULT_OPTIONS} ${BUILD_EXTRA_OPTIONS}
	DEPENDS ${name}_copy ${SOURCE_DIR}/configure
	WORKING_DIRECTORY ${BUILD_DIR})

  ### make step:
  ADD_CUSTOM_COMMAND(OUTPUT ${BUILD_DIR}/success
	COMMAND ${MAKE} -j${N}
	COMMAND ${CMAKE_COMMAND} -E touch ${BUILD_DIR}/success
	WORKING_DIRECTORY ${BUILD_DIR}
	DEPENDS ${BUILD_DIR}/Makefile)

  ### make install step: (if not disabled for some reason)
  IF(NOT BUILD_NO_INSTALL)
	ADD_CUSTOM_COMMAND(OUTPUT ${PREFIX_PATH}/installed_${name}
	  COMMAND ${MAKE} install
	  COMMAND ${CMAKE_COMMAND} -E touch ${PREFIX_PATH}/installed_${name}
	  WORKING_DIRECTORY ${BUILD_DIR}
	  DEPENDS ${BUILD_DIR}/success)

	ADD_CUSTOM_TARGET(build_${underscore}
	  DEPENDS ${PREFIX_PATH}/installed_${name})
  ELSE()
	ADD_CUSTOM_TARGET(build_${underscore}
	  DEPENDS ${BUILD_DIR}/success)
  ENDIF()
  ADD_DEPENDENCIES(build_${underscore} prefix)
endfunction()
