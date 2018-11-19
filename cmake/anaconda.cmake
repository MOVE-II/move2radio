IF(CONDA_ENV)
  ## Initialize conda env
  IF(NO_DOWNLOAD OR CONDA_ENV_OFFLINE)
	SET(CONDA_PATH ${OFFLINE_DEPENDENCY_PATH}/conda_env)
	ADD_CUSTOM_COMMAND(OUTPUT ${CONDA_PATH}/conda_success
	  COMMAND ${CMAKE_COMMAND} -E touch ${CONDA_PATH}/conda_success)
  ELSE()
	SET(CONDA_PATH ${DEPS_PATH}/conda_env)
	ADD_CUSTOM_COMMAND(OUTPUT ${CONDA_PATH}/usr/conda_success
	  COMMAND ${CMAKE_SOURCE_DIR}/conda_install.sh
	    ${DEPS_PATH}/src/Miniconda2-4.5.11-Linux-x86_64.sh
	    ${CONDA_PATH}/usr
	  DEPENDS miniconda ${CMAKE_SOURCE_DIR}/conda_install.sh)
  ENDIF()

  ADD_CUSTOM_TARGET(conda_env
	DEPENDS ${CONDA_PATH}/usr/conda_success)

  ## target to install cached conda env to prefix
  ADD_CUSTOM_COMMAND(OUTPUT ${PREFIX_PATH}/conda_prefix_success
	COMMAND cp -r ${CONDA_PATH} ${PREFIX_PATH}
	COMMAND ${CMAKE_COMMAND} -E touch ${PREFIX_PATH}/conda_prefix_success
	DEPENDS conda_env)
  ADD_CUSTOM_TARGET(conda_prefix
	DEPENDS ${PREFIX_PATH}/conda_prefix_success)

  ADD_DEPENDENCIES(prefix conda_prefix)
  ADD_DEPENDENCIES(download conda_env)
ENDIF()
