# Copyright (c) Prophesee S.A.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

include(CMakeParseArguments)
##################################################
# Override target_link_libraries to handle OBJECT libraries

if(${CMAKE_VERSION} VERSION_LESS "3.12.0")

    # The following function is meant to implement the cmake function "target_link_libraries", when
    # the target of the call (i.e. first arg) is an object library.
    # Remark : only the all-keyword version has been implemented (not the all-plain one). This means
    # that when creating an object library, you'll always need to specify the link libraries with one or
    # more of the keywords "PUBLIC", "PRIVATE" or "INTERFACE"
    #
    # To mimic the behaviour that will be available with cmake >= 3.12 (cf releases notes
    # at https://cmake.org/cmake/help/v3.12/release/3.12.html#command-line) we create some proxy
    # interface libraries, which we use to propagate the dependencies and properties of the object library.
    #
    # Without this function, then trying to call target_link_libraries with an object library as target,
    # you'll get the following error :
    #
    #            Object library target "xxxx" may not link to anything.
    #
    function(object_library_target_link_libraries obj_lib_name)

        set(multiValueArgs PUBLIC PRIVATE INTERFACE)
        cmake_parse_arguments(PARSED_ARGS "" "" "${multiValueArgs}" ${ARGN})

        # Handle public and interface link libraries
        if(DEFINED PARSED_ARGS_PUBLIC OR DEFINED PARSED_ARGS_INTERFACE)

            # Check if for this target we already created an interface library to propagate
            # public properties :
            if(NOT TARGET __${obj_lib_name}_public_interface)

                # If not present, create it (remark : we try to use a name that it's less likely for the user to
                # use, hence the __ prefix, but it's not 100% full proof)
                add_library(__${obj_lib_name}_public_interface INTERFACE)

                # Propagate public properties INTERFACE_INCLUDE_DIRECTORIES and INTERFACE_COMPILE_DEFINITIONS (maybe others will be needed too? )
                # to the interface library created
                target_include_directories(__${obj_lib_name}_public_interface INTERFACE $<TARGET_PROPERTY:${obj_lib_name},INTERFACE_INCLUDE_DIRECTORIES>)
                target_compile_definitions(__${obj_lib_name}_public_interface INTERFACE $<TARGET_PROPERTY:${obj_lib_name},INTERFACE_COMPILE_DEFINITIONS>)

            endif(NOT TARGET __${obj_lib_name}_public_interface)

            # Link public interface library with input public and interface libraries
            target_link_libraries(__${obj_lib_name}_public_interface INTERFACE ${PARSED_ARGS_PUBLIC} ${PARSED_ARGS_INTERFACE})

            # Get the links libraries' public properties and propagate them (publicly) to the object library :
            target_include_directories(${obj_lib_name} PUBLIC $<TARGET_PROPERTY:__${obj_lib_name}_public_interface,INTERFACE_INCLUDE_DIRECTORIES>)
            target_compile_definitions(${obj_lib_name} PUBLIC $<TARGET_PROPERTY:__${obj_lib_name}_public_interface,INTERFACE_COMPILE_DEFINITIONS>)

        endif(DEFINED PARSED_ARGS_PUBLIC OR DEFINED PARSED_ARGS_INTERFACE)

        # Handle private link libraries
        if(DEFINED PARSED_ARGS_PRIVATE)

            # Check if for this target we already created a private interface library :
            if(NOT TARGET __${obj_lib_name}_private_interface)
                # If not present, create it :
                add_library(__${obj_lib_name}_private_interface INTERFACE)

                # In this case, we do not propagate the public INTERFACE_INCLUDE_DIRECTORIES and INTERFACE_COMPILE_DEFINITIONS, because this interface
                # is for private properties only
            endif(NOT TARGET __${obj_lib_name}_private_interface)

            # Link private interface library with input private libraries
            target_link_libraries(__${obj_lib_name}_private_interface INTERFACE ${PARSED_ARGS_PRIVATE})

            # Get the links libraries' public properties and propagate them (privately) to the object library :
            target_include_directories(${obj_lib_name} PRIVATE $<TARGET_PROPERTY:__${obj_lib_name}_private_interface,INTERFACE_INCLUDE_DIRECTORIES>)
            target_compile_definitions(${obj_lib_name} PRIVATE $<TARGET_PROPERTY:__${obj_lib_name}_private_interface,INTERFACE_COMPILE_DEFINITIONS>)

        endif(DEFINED PARSED_ARGS_PRIVATE)

    endfunction(object_library_target_link_libraries)


    # The following function is meant to implement the cmake function "target_link_libraries", when
    # an object library is at the right-end side of the function call.
    #
    # To mimic the behaviour that will be available with cmake >= 3.12 (cf releases notes
    # at https://cmake.org/cmake/help/v3.12/release/3.12.html#command-line) we'll use the
    # interface libraries created when calling the function object_library_target_link_libraries (cf above)
    function(target_link_to_object_libraries target_name)

        # Remark : this function assumes that ALL the right-end side target are OBJECT libraries

        set(multiValueArgs PUBLIC PRIVATE INTERFACE)
        cmake_parse_arguments(PARSED_ARGS "" "" "${multiValueArgs}" ${ARGN})

        # If target_name is an INTERFACE_LIBRARY, only INTERFACE keyword may be used :
        get_target_property(_target_type ${target_name} TYPE)
        if(_target_type STREQUAL "INTERFACE_LIBRARY")
            if(DEFINED PARSED_ARGS_PUBLIC OR DEFINED PARSED_ARGS_PRIVATE)
                message(FATAL_ERROR "Invalid call to target_link_to_object_libraries(target ...),  with target = ${target_name} : INTERFACE library can only be used with the INTERFACE keyword")
                return()
            endif(DEFINED PARSED_ARGS_PUBLIC OR DEFINED PARSED_ARGS_PRIVATE)
        endif(_target_type STREQUAL "INTERFACE_LIBRARY")

        # Check that we use either all-keyword signature or all-plain
        if(PARSED_ARGS_UNPARSED_ARGUMENTS)
            foreach(keyword PUBLIC PRIVATE INTERFACE)
                if(DEFINED PARSED_ARGS_${keyword})
                    message(FATAL_ERROR "The keyword signature for target_link_libraries has already been used with the target ${target_name}.  All uses of target_link_libraries with a target must be either all-keyword or all-plain.")
                    return()
                endif(DEFINED PARSED_ARGS_${keyword})
            endforeach(keyword)
        endif(PARSED_ARGS_UNPARSED_ARGUMENTS)

        # Loop through the object libraries that we want the target ${target_name} to link to publicly
        foreach(obj_lib_to_link_to ${PARSED_ARGS_PUBLIC} ${PARSED_ARGS_INTERFACE} ${PARSED_ARGS_UNPARSED_ARGUMENTS})

            set(PUBLIC_KEYWORD "PUBLIC")
            set(PRIVATE_KEYWORD "PRIVATE")
            if(${obj_lib_to_link_to} IN_LIST PARSED_ARGS_UNPARSED_ARGUMENTS)
                set(PUBLIC_KEYWORD "")
                set(PRIVATE_KEYWORD "")
            elseif (NOT ${obj_lib_to_link_to} IN_LIST PARSED_ARGS_PUBLIC)
                set(PUBLIC_KEYWORD "INTERFACE")
                set(PRIVATE_KEYWORD "INTERFACE")
            endif (${obj_lib_to_link_to} IN_LIST PARSED_ARGS_UNPARSED_ARGUMENTS)

            # First, we need to check if the target __${obj_lib_to_link_to}_public_interface has
            # been created. This may not be the case if the object_library_target_link_libraries()
            # has never been called for this target (you could for example call only target_include_directories
            # on the object lib, if you don't need to link it to anything).

            if(TARGET __${obj_lib_to_link_to}_public_interface)
                target_link_libraries(${target_name} ${PUBLIC_KEYWORD} __${obj_lib_to_link_to}_public_interface)
            else()
                # In this case, just propagate directly the INTERFACE_INCLUDE_DIRECTORIES and INTERFACE_COMPILE_DEFINITIONS of the object library
                # (no INTERFACE_LINK_LIBRARIES since function object_library_target_link_libraries() has never been called for this object library)
                target_include_directories(${target_name} ${PUBLIC_KEYWORD} $<TARGET_PROPERTY:${obj_lib_to_link_to},INTERFACE_INCLUDE_DIRECTORIES>)
                target_compile_definitions(${target_name} ${PUBLIC_KEYWORD} $<TARGET_PROPERTY:${obj_lib_to_link_to},INTERFACE_COMPILE_DEFINITIONS>)
            endif(TARGET __${obj_lib_to_link_to}_public_interface)

            if(TARGET __${obj_lib_to_link_to}_private_interface)
                # In the case of the private interface, we only want to propagate the link libraries, nothing else :
                target_link_libraries(${target_name} ${PRIVATE_KEYWORD} $<TARGET_PROPERTY:__${obj_lib_to_link_to}_private_interface,INTERFACE_LINK_LIBRARIES>)
            endif(TARGET __${obj_lib_to_link_to}_private_interface)

        endforeach(obj_lib_to_link_to)

        # Now do the same thing but for  the object libraries that we want the target ${target_name}
        # to link to privately
        foreach(private_obj_lib_to_link_to ${PARSED_ARGS_PRIVATE})
            # Note that this loop is the same as above, but with the PRIVATE keyword used instead of PUBLIC
            if(TARGET __${private_obj_lib_to_link_to}_public_interface)
                target_link_libraries(${target_name} PRIVATE __${private_obj_lib_to_link_to}_public_interface)
            else()
                target_include_directories(${target_name} PRIVATE $<TARGET_PROPERTY:${private_obj_lib_to_link_to},INTERFACE_INCLUDE_DIRECTORIES>)
                target_compile_definitions(${target_name} PRIVATE $<TARGET_PROPERTY:${private_obj_lib_to_link_to},INTERFACE_COMPILE_DEFINITIONS>)
            endif(TARGET __${private_obj_lib_to_link_to}_public_interface)

            if(TARGET __${private_obj_lib_to_link_to}_private_interface)
                target_link_libraries(${target_name} PRIVATE $<TARGET_PROPERTY:__${private_obj_lib_to_link_to}_private_interface,INTERFACE_LINK_LIBRARIES>)
            endif(TARGET __${private_obj_lib_to_link_to}_private_interface)

        endforeach(private_obj_lib_to_link_to)

    endfunction(target_link_to_object_libraries)


    # Override built-in target_link_libraries to take into account object libraries
    function(target_link_libraries target_name)

        # Check the type of the target
        get_target_property(_target_type ${target_name} TYPE)

        if (_target_type STREQUAL "OBJECT_LIBRARY")

            # If the target is an object property, then call object_library_target_link_libraries
            object_library_target_link_libraries(${target_name} ${ARGN})

        else()

            # In this case we check if we have some object libraries on the right end side.
            # To do this, parse all arguments and create a list for calling both the
            # custom function target_link_to_object_libraries and the cmake _built-in target_link_libraries
            set(args_for_target_link_libraries "")
            set(args_for_target_link_to_object_libraries "")
            set(need_to_call_target_link_libraries False)
            set(need_to_call_target_link_to_object_libraries False)

            foreach(arg ${ARGN})
                if (arg STREQUAL "PUBLIC" OR arg STREQUAL "PRIVATE" OR arg STREQUAL "INTERFACE")
                    list(APPEND args_for_target_link_libraries ${arg})
                    list(APPEND args_for_target_link_to_object_libraries ${arg})
                else()
                    if(TARGET ${arg})
                        get_target_property(_current_target_type ${arg} TYPE)
                        if (_current_target_type STREQUAL "OBJECT_LIBRARY")
                            set(need_to_call_target_link_to_object_libraries True)
                            list(APPEND args_for_target_link_to_object_libraries ${arg})
                        else()
                            set(need_to_call_target_link_libraries True)
                            list(APPEND args_for_target_link_libraries ${arg})
                        endif(_current_target_type STREQUAL "OBJECT_LIBRARY")
                    else()
                        set(need_to_call_target_link_libraries True)
                        list(APPEND args_for_target_link_libraries ${arg})
                    endif(TARGET ${arg})
                endif (arg STREQUAL "PUBLIC" OR arg STREQUAL "PRIVATE" OR arg STREQUAL "INTERFACE")
            endforeach(arg)

            if(need_to_call_target_link_libraries)
                _target_link_libraries(${target_name} ${args_for_target_link_libraries})
            endif(need_to_call_target_link_libraries)

            if(need_to_call_target_link_to_object_libraries)
                 target_link_to_object_libraries(${target_name} ${args_for_target_link_to_object_libraries})
            endif(need_to_call_target_link_to_object_libraries)

        endif (_target_type STREQUAL "OBJECT_LIBRARY")

    endfunction(target_link_libraries)

endif(${CMAKE_VERSION} VERSION_LESS "3.12.0")

##################################################

# Override built-in add_library so that we can call it without sources, and add sources with method target_sources()
if(${CMAKE_VERSION} VERSION_LESS "3.11.0")

    set(dummy_header "${GENERATE_FILES_DIRECTORY}/dummy_header.h")
    file(WRITE "${dummy_header}" "")

    function(add_library)
        cmake_parse_arguments(LIB_ARGS "IMPORTED;ALIAS;INTERFACE" "" "" ${ARGN})
        if(LIB_ARGS_IMPORTED OR LIB_ARGS_ALIAS OR LIB_ARGS_INTERFACE)
            # No need to add sources : just redirect call to built-in add_library method
            _add_library(${ARGN})
        else()
            # In this case, if the sources are not provided we need to add them. To make the
            # code clearer to read, we add the dummy header in any case (even if it's needed
            # only when the call to add_library is done without any source file) : it doensn't hurt
            # and if you forget to add sources to the library (via target_sources), you'll be warned
            # by cmake, which will throw the following error :
            #
            #    CMake Error: CMake can not determine linker language for target: LIBNAME
            #
            _add_library(${ARGN} ${dummy_header})
        endif(LIB_ARGS_IMPORTED OR LIB_ARGS_ALIAS OR LIB_ARGS_INTERFACE)
    endfunction(add_library)

endif(${CMAKE_VERSION} VERSION_LESS "3.11.0")

##################################################

# Define some function on lists, that implement
# the list(TRANSFORM ..) available from cmake version 3.12
# cf https://cmake.org/cmake/help/v3.12/command/list.html#transform
function (list_transform_prepend list val)
  if(${CMAKE_VERSION} VERSION_LESS "3.12")
    set(res)
    foreach(el IN LISTS ${list})
      list(APPEND res "${val}${el}")
    endforeach()
    set(${list} ${res})
  else()
    list(TRANSFORM ${list} PREPEND ${val})
  endif()
  set(${list} ${${list}} PARENT_SCOPE)
endfunction()

function (list_transform_append list val)
  if(${CMAKE_VERSION} VERSION_LESS "3.12")
    set(res)
    foreach(el IN LISTS ${list})
      list(APPEND res "${el}${val}")
    endforeach()
    set(${list} ${res})
  else()
    list(TRANSFORM ${list} APPEND ${val})
  endif()
  set(${list} ${${list}} PARENT_SCOPE)
endfunction()

function (list_transform_replace list match_string replace_string)
  if(${CMAKE_VERSION} VERSION_LESS "3.12")
    set(res)
    foreach(el IN LISTS ${list})
      string(REGEX REPLACE "${match_string}" "${replace_string}" out "${el}")
      list(APPEND res "${out}")
    endforeach()
    set(${list} ${res})
  else()
    list(TRANSFORM ${list} REPLACE ${match_string} ${replace_string})
  endif()
  set(${list} ${${list}} PARENT_SCOPE)
endfunction()