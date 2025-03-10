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

#include <boost/python.hpp>

#include "hal_python_binder.h"
#include "metavision/hal/facilities/i_trigger_in.h"
#include "pb_doc_hal.h"

namespace Metavision {

static DeviceFacilityGetter<I_TriggerIn> getter("get_i_trigger_in");

static HALFacilityPythonBinder<I_TriggerIn> bind(
    [](auto &module, auto &class_binding) {
        class_binding
            .def("enable", &I_TriggerIn::enable, py::arg("channel"), pybind_doc_hal["Metavision::I_TriggerIn::enable"])
            .def("disable", &I_TriggerIn::disable, py::arg("channel"),
                 pybind_doc_hal["Metavision::I_TriggerIn::disable"]);
    },
    "I_TriggerIn", pybind_doc_hal["Metavision::I_TriggerIn"]);

} // namespace Metavision
