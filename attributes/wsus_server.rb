#
# Cookbook:: patch_management
# Attributes:: wsus_server
#
# Copyright:: 2018 Chef Software, Inc
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

# WSUS is a windows only feature
return unless platform?('windows')

# Defines the directory where content is stored, it also enables local storage of wsus content.
default['wsus_server']['setup']['content_dir'] = 'c:/wsus_content'

# Enables update for the specified list of languages.
default['wsus_server']['configuration']['update_languages']             = ['en']

# Determines the targeting mode:
# => client = Clients specify the target group to which they belong.
default['wsus_server']['configuration']['properties']['TargetingMode']  = 'Client'

# Determines whether the WSUS server synchronizes the updates automatically
default['wsus_server']['subscription']['automatic_synchronization']     = true
# Defines the list of categories of updates that you want the WSUS server to synchronize. (Id or Title)
default['wsus_server']['subscription']['categories'] = ['Windows Server 2012 R2', 'Windows Server 2016']
# Defines the list of classifications of updates that you want the WSUS server to synchronize. (Id or Title)
default['wsus_server']['subscription']['classifications'] = ['Critical Updates', 'Definition Updates', 'Security Updates', 'Service Packs', 'Update Rollups', 'Updates', 'Upgrades']
# Defines the number of server-to-server synchronizations a day.
default['wsus_server']['subscription']['synchronization_per_day']       = '1'
# Defines the time of day when the WSUS server automatically synchronizes the updates.
default['wsus_server']['subscription']['synchronization_time']          = '22:00:00'
# Determines whether WSUS should synchronize categories before configuring above attributes.
default['wsus_server']['subscription']['synchronize_categories']        = true

default['wsus_server']['subscription']['configure_timeout'] = 3600
default['wsus_server']['freeze']['name'] = 'All Approved'

