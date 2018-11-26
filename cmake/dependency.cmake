function(MOVEII_ADD_DEP name source hash)
  SET(options OPTIONAL GIT OFFLINE)
  CMAKE_PARSE_ARGUMENTS(DEP "${options}" "" "" ${ARGN})
  STRING(REPLACE "-" "_" underscore ${name})
  STRING(TOUPPER ${underscore} prefix)

  OPTION(${prefix}_OFFLINE "Don't download ${name}" OFF) 

  STRING(REGEX MATCH "[.]tar[.]xz$|[.]zip$|[.]tar[.]gz$|[.]tar[.]xz$|[.]tar[.]lz$|[.]tgz$|[.]tar[.]bz2$" ARCHIVE ${source})
  IF("${ARCHIVE}" STREQUAL "")
	SET(EXTRACT FALSE)
  ELSE()
	SET(EXTRACT TRUE)
  ENDIF()

  IF(${DEP_OFFLINE} OR ${NO_DOWNLOAD} OR ${prefix}_OFFLINE)
	SET(DEP_PATH "${OFFLINE_DEPENDENCY_PATH}/${name}")
	SET(${prefix}_SOURCE "${DEP_PATH}" PARENT_SCOPE)
	IF (EXISTS "${DEP_PATH}" AND IS_DIRECTORY "${DEP_PATH}")
	  ADD_CUSTOM_TARGET(${name}
		${CMAKE_COMMAND} -E touch ${DEP_PATH})
	ELSE()
	  MESSAGE(FATAL_ERROR "Could not find dependency: ${name}")
	ENDIF()
	ADD_DEPENDENCIES(deps ${name})
  ELSE()
	SET(${prefix}_SOURCE "${DEPS_PATH}/src/${name}" PARENT_SCOPE)
	IF(DEP_GIT)
	  ExternalProject_Add(${name}
		EXCLUDE_FROM_ALL 1
		PREFIX "${DEPS_PATH}"
		GIT_REPOSITORY "${source}"
		GIT_TAG "${hash}"
		CONFIGURE_COMMAND "" BUILD_COMMAND "" INSTALL_COMMAND ""
		)
	ELSEIF(EXTRACT)
	  ExternalProject_Add(${name}
		EXCLUDE_FROM_ALL 1
		PREFIX "${DEPS_PATH}"
		URL ${source}
		URL_HASH SHA256=${hash}
		CONFIGURE_COMMAND "" BUILD_COMMAND "" INSTALL_COMMAND ""
		)
	ELSE()
	  ExternalProject_Add(${name}
		EXCLUDE_FROM_ALL 1
		DOWNLOAD_NO_EXTRACT TRUE
		PREFIX "${DEPS_PATH}"
		URL ${source}
		URL_HASH SHA256=${hash}
		CONFIGURE_COMMAND "" BUILD_COMMAND "" INSTALL_COMMAND ""
		)
	ENDIF()
	ADD_DEPENDENCIES(download ${name})
  ENDIF()
endfunction()
  
