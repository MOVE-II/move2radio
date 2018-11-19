######## OPTIONS #########
SET(OFFLINE_DEPENDENCY_PATH "" CACHE STRING "Disable download and set path to sources of dependencies")
OPTION(NO_DOWNLOAD "Don't download any dependencies" OFF)
OPTION(CONDA_ENV "Use anaconda to provide python environment" ${LINUX})
OPTION(APPIMAGE "Create an AppImage" ${LINUX})
OPTION(CONDA_ENV_OFFLINE "Use conda env in OFFLINE_DEPENDENCY_PATH" OFF)
###### OPTIONS END #######

### LEGAL OPTIONS CHECK ###
IF(NOT LINUX)
  IF(APPIMAGE)
	MESSAGE(FATAL "AppImages are only supported on Linux")
  ENDIF()
  IF(CONDA_ENV)
	MESSAGE(FATAL "This cmake project supports anaconda only on Linux")
  ENDIF()
ENDIF()

IF(${NO_DOWNLOAD} AND "${OFFLINE_DEPENDENCY_PATH}" STREQUAL "")
  MESSAGE(FATAL_ERROR "Must set OFFLINE_DEPENDENCY_PATH if NO_DOWNLOAD == TRUE")
ENDIF()

IF(APPIMAGE)
  ADD_CUSTOM_TARGET(appimage)
  IF(NOT CONDA_ENV)
	MESSAGE(FATAL_ERROR "The anaconda environment is needed to execute the resulting appimage. Set either APPIMAGE=OFF or CONDA_ENV=ON")
  ENDIF()
ENDIF()
# LEGAL OPTIONS CHECK END #
