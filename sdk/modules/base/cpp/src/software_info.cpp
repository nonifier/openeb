/**********************************************************************************************************************
 * Copyright (c) Prophesee S.A.                                                                                       *
 *                                                                                                                    *
 * Licensed under the Apache License, Version 2.0 (the "License");                                                    *
 * you may not use this file except in compliance with the License.                                                   *
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0                                 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed   *
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.                      *
 * See the License for the specific language governing permissions and limitations under the License.                 *
 **********************************************************************************************************************/

#include "metavision/sdk/base/utils/software_info.h"
#include "metavision/sdk/version.h"

namespace Metavision {

SoftwareInfo::SoftwareInfo(int version_major, int version_minor, int version_patch, int version_dev,
                           const std::string &vcs_branch, const std::string &vcs_commit, const std::string &vcs_date) :
    version_major_(version_major),
    version_minor_(version_minor),
    version_patch_(version_patch),
    version_dev_(version_dev),
    vcs_branch_(vcs_branch),
    vcs_commit_(vcs_commit),
    vcs_date_(vcs_date) {}

int SoftwareInfo::get_version_major() const {
    return version_major_;
}

int SoftwareInfo::get_version_minor() const {
    return version_minor_;
}

int SoftwareInfo::get_version_patch() const {
    return version_patch_;
}

int SoftwareInfo::get_version_dev() const {
    return version_dev_;
}

std::string SoftwareInfo::get_version() const {
    return std::to_string(get_version_major()) + "." + std::to_string(get_version_minor()) + "." +
           std::to_string(get_version_patch()) + "." + std::to_string(get_version_dev());
}

std::string SoftwareInfo::get_vcs_branch() const {
    return vcs_branch_;
}

std::string SoftwareInfo::get_vcs_commit() const {
    return vcs_commit_;
}

std::string SoftwareInfo::get_vcs_date() const {
    return vcs_date_;
}

SoftwareInfo &get_metavision_software_info() {
    static Metavision::SoftwareInfo metavision_sdk_info(METAVISION_SDK_VERSION_MAJOR, METAVISION_SDK_VERSION_MINOR,
                                                        METAVISION_SDK_VERSION_PATCH, METAVISION_SDK_GIT_COMMIT_DATE,
                                                        METAVISION_SDK_GIT_BRANCH_RAW, METAVISION_SDK_GIT_HASH_RAW,
                                                        std::to_string(METAVISION_SDK_GIT_COMMIT_DATE));
    return metavision_sdk_info;
}
} // namespace Metavision
