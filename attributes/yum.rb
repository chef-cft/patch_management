#
# Cookbook:: patch_management
# Attributes:: yum
#
# Copyright:: 2016 Chef Software, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

default['yum']['repos']['centos-base'] = 'http://mirror.centos.org/centos/7/os/x86_64'
default['yum']['repos']['centos-updates'] = 'http://mirror.centos.org/centos/7/updates/x86_64'
default['yum']['combined'] = false

default['yum']['local_server'] = '104.43.233.144'