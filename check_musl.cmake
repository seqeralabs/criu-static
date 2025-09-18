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

        set(LOCAL_MUSL_LICENSE "${CMAKE_SOURCE_DIR}/musl.COPYRIGHT")

        if(EXISTS ${LOCAL_MUSL_LICENSE})
            install(FILES ${LOCAL_MUSL_LICENSE} DESTINATION share/doc/fusion-snapshot)
            message(STATUS "Using local musl license from ${LOCAL_MUSL_LICENSE}")
        else()
            message(WARNING "musl libc detected but local musl.COPYRIGHT file not found at ${LOCAL_MUSL_LICENSE}")
        endif()
    else()
        message(STATUS "musl libc not detected. Skipping license installation.")
    endif()
endfunction()
