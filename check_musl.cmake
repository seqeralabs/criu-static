function(fetch_musl_license_if_needed)
    if(NOT DEFINED CMAKE_IS_USING_MUSL)
        message(STATUS "Checking for musl libc...")

        # Get the compiler target triplet
        execute_process(
            COMMAND ${CMAKE_C_COMPILER} -dumpmachine
            OUTPUT_VARIABLE COMPILER_TARGET_TRIPLET
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )

        # Check if the target triplet contains "musl"
        if(COMPILER_TARGET_TRIPLET MATCHES "musl")
            set(CMAKE_IS_USING_MUSL TRUE)
        else()
            set(CMAKE_IS_USING_MUSL FALSE)
        endif()

        set(CMAKE_IS_USING_MUSL ${CMAKE_IS_USING_MUSL} CACHE INTERNAL "Result of musl libc detection")

        if(CMAKE_IS_USING_MUSL)
            message(STATUS "Checking for musl libc... - Yes (target: ${COMPILER_TARGET_TRIPLET})")
        else()
            message(STATUS "Checking for musl libc... - No (target: ${COMPILER_TARGET_TRIPLET})")
        endif()
    endif()

    if(CMAKE_IS_USING_MUSL)
        message(STATUS "musl libc detected, configuring license installation.")

        set(MUSL_LICENSE_URL "https://git.musl-libc.org/cgit/musl/plain/COPYRIGHT")
        set(DOWNLOAD_LOCATION "${CMAKE_BINARY_DIR}/musl.COPYRIGHT")
        install(FILES ${DOWNLOAD_LOCATION} DESTINATION ${CMAKE_INSTALL_DOCDIR}/third_party RENAME musl.COPYRIGHT)

        if (NOT EXISTS ${DOWNLOAD_LOCATION})
            message(STATUS "Downloading musl license from ${MUSL_LICENSE_URL} to ${DOWNLOAD_LOCATION}.")
        else()
            message(STATUS "musl license already exists at ${DOWNLOAD_LOCATION}, skipping download.")
            return()
        endif()

        file(DOWNLOAD ${MUSL_LICENSE_URL} ${DOWNLOAD_LOCATION} SHOW_PROGRESS STATUS download_status)
        

        list(GET download_status 0 download_result)
        if(NOT download_result EQUAL 0)
            list(GET download_status 1 error_msg)
            message(FATAL_ERROR "Failed to download musl license from ${MUSL_LICENSE_URL}. Error: ${error_msg}")
        endif()

        message(STATUS "musl license downloaded successfully.")
    else()
        message(STATUS "musl libc not detected. Skipping license installation.")
    endif()
endfunction()
